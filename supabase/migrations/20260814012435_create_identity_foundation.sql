-- HelpHub
-- Migration: create_identity_foundation
--
-- Purpose:
--   1. Link Supabase Auth users to HelpHub application profiles.
--   2. Force public sign-ups to begin as Resident accounts.
--   3. Provide a traceable resident-verification request/review foundation.
--   4. Protect application tables using grants plus Row Level Security.
--
-- Important:
--   - Passwords and authentication credentials remain in Supabase Auth.
--   - Residents cannot self-assign the barangay_admin role.
--   - Residents cannot directly approve/restrict accounts.
--   - Exact verification-document fields are intentionally deferred until
--     their requirements and privacy handling are defined.


-- ============================================================
-- 1. PROFILES
-- ============================================================
--
-- public.profiles is the HelpHub application-side representation
-- of an authenticated Supabase user.
--
-- The primary key is exactly the matching auth.users.id value,
-- creating a one-to-one Auth -> HelpHub profile relationship.
--
-- We intentionally use ON DELETE RESTRICT at this stage because
-- HelpHub will later contain reports, emergency records, status
-- history, and audit evidence that must not disappear silently.
-- Final retention/anonymization behavior will be handled through
-- an explicit future policy/migration.

create table public.profiles (
    id uuid primary key
        references auth.users(id)
        on delete restrict,

    full_name text not null,

    role text not null
        default 'resident',

    account_status text not null
        default 'pending',

    created_at timestamptz not null
        default now(),

    updated_at timestamptz not null
        default now(),

    constraint chk_profiles_full_name
        check (
            char_length(btrim(full_name)) >= 2
            and char_length(btrim(full_name)) <= 150
        ),

    constraint chk_profiles_role
        check (
            role in (
                'resident',
                'barangay_admin'
            )
        ),

    constraint chk_profiles_account_status
        check (
            account_status in (
                'pending',
                'approved',
                'rejected',
                'restricted'
            )
        )
);

comment on table public.profiles is
    'HelpHub application profile linked one-to-one with auth.users.';

comment on column public.profiles.role is
    'HelpHub application role. Public signup is always created as resident.';

comment on column public.profiles.account_status is
    'Engineering-defined account workflow state used for resident approval/restriction.';


-- ============================================================
-- 2. PROFILE NORMALIZATION / UPDATED-AT TRIGGER
-- ============================================================
--
-- This trigger performs two small database-integrity tasks:
--
--   1. trims leading/trailing spaces from full_name;
--   2. updates updated_at whenever the profile changes.
--
-- This is integrity behavior, not business-policy logic.

create or replace function public.prepare_profile_write()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
    new.full_name := btrim(new.full_name);

    if tg_op = 'UPDATE' then
        new.updated_at := now();
    end if;

    return new;
end;
$$;

create trigger trg_profiles_prepare_write
before insert or update
on public.profiles
for each row
execute function public.prepare_profile_write();


-- ============================================================
-- 3. AUTOMATIC PROFILE CREATION AFTER AUTH SIGN-UP
-- ============================================================
--
-- A new Supabase Auth user gets a HelpHub profile automatically.
--
-- SECURITY RULE:
-- role and account_status are NOT read from user metadata.
--
-- Even if a malicious signup request sends metadata such as:
--
--   role = barangay_admin
--
-- this trigger ignores it and explicitly inserts:
--
--   role = resident
--   account_status = pending
--
-- Only full_name is copied from signup metadata because it is
-- ordinary profile/display information, not an authorization claim.

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_full_name text;
begin
    v_full_name := btrim(
        coalesce(
            new.raw_user_meta_data ->> 'full_name',
            ''
        )
    );

    if char_length(v_full_name) < 2
       or char_length(v_full_name) > 150 then
        raise exception
            'A valid full_name between 2 and 150 characters is required.';
    end if;

    insert into public.profiles (
        id,
        full_name,
        role,
        account_status
    )
    values (
        new.id,
        v_full_name,
        'resident',
        'pending'
    );

    return new;
end;
$$;

-- This function is intended for the Auth trigger only.
revoke all
on function public.handle_new_auth_user()
from public;

create trigger on_auth_user_created
after insert
on auth.users
for each row
execute function public.handle_new_auth_user();


-- ============================================================
-- 4. RESIDENT VERIFICATION REQUEST / REVIEW FOUNDATION
-- ============================================================
--
-- This table records resident verification requests and their
-- administrative review outcome.
--
-- It deliberately does NOT contain invented document fields such
-- as national ID number, document type, or proof-of-residency URL.
--
-- Those fields will be added only after their actual requirements,
-- storage rules, retention rules, and privacy controls are defined.

create table public.resident_verifications (
    id uuid primary key
        default gen_random_uuid(),

    resident_id uuid not null
        references public.profiles(id)
        on delete restrict,

    status text not null
        default 'pending',

    submitted_at timestamptz not null
        default now(),

    reviewed_at timestamptz,

    reviewed_by uuid
        references public.profiles(id)
        on delete restrict,

    constraint chk_resident_verifications_status
        check (
            status in (
                'pending',
                'approved',
                'rejected'
            )
        ),

    constraint chk_resident_verifications_review_state
        check (
            (
                status = 'pending'
                and reviewed_at is null
                and reviewed_by is null
            )
            or
            (
                status in ('approved', 'rejected')
                and reviewed_at is not null
                and reviewed_by is not null
            )
        )
);

comment on table public.resident_verifications is
    'Resident verification request/review history. Exact evidence fields are intentionally deferred.';


-- ============================================================
-- 5. VERIFICATION INDEXES
-- ============================================================

-- Supports resident verification-history lookup.
create index idx_resident_verifications_resident_id
    on public.resident_verifications(resident_id);

-- Supports administrator review queues such as:
-- WHERE status = 'pending' ORDER BY submitted_at
create index idx_resident_verifications_status_submitted_at
    on public.resident_verifications(
        status,
        submitted_at
    );

-- Supports lookup of reviews performed by an administrator.
create index idx_resident_verifications_reviewed_by
    on public.resident_verifications(reviewed_by)
    where reviewed_by is not null;

-- A resident may have verification history, including a rejected
-- request followed by a new request, but may not have two pending
-- requests simultaneously.
create unique index uq_resident_verifications_one_pending
    on public.resident_verifications(resident_id)
    where status = 'pending';


-- ============================================================
-- 6. ENABLE ROW LEVEL SECURITY
-- ============================================================

alter table public.profiles
enable row level security;

alter table public.resident_verifications
enable row level security;


-- ============================================================
-- 7. EXPLICIT DATA-API GRANTS
-- ============================================================
--
-- PostgreSQL GRANT controls which operations/columns a role may
-- attempt to access.
--
-- RLS then controls which rows are actually accessible.
--
-- We use both layers.
--
-- No access is granted to anon for either table.

revoke all
on table public.profiles
from anon, authenticated;

revoke all
on table public.resident_verifications
from anon, authenticated;


-- Authenticated users may read profile rows permitted by RLS.
grant select
on table public.profiles
to authenticated;

-- Residents may edit ONLY full_name directly.
--
-- role and account_status are intentionally omitted so a malicious
-- client cannot promote itself or approve/restrict accounts.
grant update (full_name)
on table public.profiles
to authenticated;


-- Residents may read their verification records permitted by RLS.
grant select
on table public.resident_verifications
to authenticated;

-- Residents may submit a request by supplying only resident_id.
--
-- id, status, and submitted_at use trusted database defaults.
-- reviewed_at and reviewed_by cannot be supplied by the resident.
grant insert (resident_id)
on table public.resident_verifications
to authenticated;


-- ============================================================
-- 8. PROFILES RLS POLICIES
-- ============================================================
--
-- Residents can read only their own profile directly through the
-- Supabase Data API.

create policy profiles_select_own
on public.profiles
for select
to authenticated
using (
    (select auth.uid()) = id
);


-- Residents may update their own profile row.
--
-- Column grants above restrict the direct update to full_name only,
-- while RLS prevents updating another user's row.

create policy profiles_update_own
on public.profiles
for update
to authenticated
using (
    (select auth.uid()) = id
)
with check (
    (select auth.uid()) = id
);


-- ============================================================
-- 9. RESIDENT VERIFICATION RLS POLICIES
-- ============================================================

-- A resident may read only their own verification history.

create policy resident_verifications_select_own
on public.resident_verifications
for select
to authenticated
using (
    (select auth.uid()) = resident_id
);


-- A resident may create a pending verification request only for
-- their own Resident profile.
--
-- The INSERT column grant prevents supplying protected review
-- columns directly, while this RLS condition validates ownership
-- and confirms that the account is a Resident account.

create policy resident_verifications_insert_own
on public.resident_verifications
for insert
to authenticated
with check (
    (select auth.uid()) = resident_id
    and status = 'pending'
    and reviewed_at is null
    and reviewed_by is null
    and exists (
        select 1
        from public.profiles as p
        where p.id = (select auth.uid())
          and p.role = 'resident'
    )
);


-- ============================================================
-- 10. INTENTIONALLY ABSENT CLIENT POLICIES
-- ============================================================
--
-- There are intentionally NO direct authenticated-client policies
-- for:
--
--   profiles INSERT
--   profiles DELETE
--   resident_verifications UPDATE
--   resident_verifications DELETE
--
-- Profile creation happens through the trusted Auth trigger.
--
-- Verification review, account approval/rejection/restriction,
-- and administrator-role assignment are protected operations that
-- will be performed through the FastAPI/server authorization
-- boundary rather than trusted to Flutter client requests.