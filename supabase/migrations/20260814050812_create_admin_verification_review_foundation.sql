-- HelpHub
-- Migration: create_admin_verification_review_foundation
--
-- Task 04.3
--
-- This migration will establish the protected database foundation
-- required for Barangay Administrator resident-verification review.
--
-- We build the migration incrementally and verify each security
-- boundary before adding the next part.


-- ============================================================
-- 1. APPROVED BARANGAY ADMINISTRATOR AUTHORIZATION HELPER
-- ============================================================
--
-- Purpose:
--   Return TRUE only when the currently authenticated Supabase user:
--
--     1. has a matching HelpHub profile,
--     2. has role = barangay_admin, and
--     3. has account_status = approved.
--
-- Why SECURITY DEFINER:
--   public.profiles is protected by RLS. Administrator authorization
--   checks used by future policies must be able to inspect the caller's
--   protected profile without requiring broad resident-readable access.
--
-- Security precautions:
--   - Every referenced object is schema-qualified.
--   - search_path is empty.
--   - PUBLIC/anon/authenticated execution is revoked first.
--   - EXECUTE is granted back only to authenticated.
--
-- This function does NOT change a user's role or account status.
-- It only answers whether the current authenticated identity satisfies
-- the approved Barangay Administrator authorization condition.

create or replace function public.is_approved_barangay_admin()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
    select exists (
        select 1
        from public.profiles as p
        where p.id = auth.uid()
          and p.role = 'barangay_admin'
          and p.account_status = 'approved'
    );
$function$;


-- PostgreSQL functions normally receive EXECUTE for PUBLIC when they
-- are created. Remove that broad access before granting only what the
-- HelpHub application requires.

revoke all
on function public.is_approved_barangay_admin()
from public, anon, authenticated;


-- Authenticated users may call the helper.
--
-- Calling the function does not expose the profile row itself; it
-- returns only one boolean authorization result.

grant execute
on function public.is_approved_barangay_admin()
to authenticated;


comment on function public.is_approved_barangay_admin() is
'Returns true only when auth.uid() belongs to an approved HelpHub Barangay Administrator.';


-- ============================================================
-- 2. AUDIT EVENT FOUNDATION
-- ============================================================
--
-- Purpose:
--   Store immutable evidence of security-sensitive HelpHub actions.
--
-- Initial use:
--   Resident verification review performed by an approved
--   Barangay Administrator.
--
-- Later HelpHub modules may reuse the same audit foundation for:
--   - report status transitions
--   - assignments
--   - emergency acknowledgements
--   - protected configuration changes
--   - other authoritative server-side actions
--
-- Design notes:
--   - action and entity_type remain validated text rather than a fixed
--     enum because final audit-event vocabularies will grow with later
--     modules.
--   - entity_id is intentionally generic because an audit event may
--     refer to different HelpHub entity tables.
--   - details must be a JSON object.
--   - sensitive credentials must never be written into details.
--   - actor_id may be NULL for future system-generated events.
--   - administrator review operations will require a non-NULL actor
--     when they create their own audit event.


create table public.audit_events (
    id uuid primary key default gen_random_uuid(),

    actor_id uuid
        references public.profiles(id)
        on delete restrict,

    action text not null,

    entity_type text not null,

    entity_id uuid,

    details jsonb not null default '{}'::jsonb,

    created_at timestamp with time zone not null default now(),

    constraint chk_audit_events_action
        check (
            char_length(btrim(action)) between 3 and 100
        ),

    constraint chk_audit_events_entity_type
        check (
            char_length(btrim(entity_type)) between 2 and 100
        ),

    constraint chk_audit_events_details_object
        check (
            jsonb_typeof(details) = 'object'
        )
);


comment on table public.audit_events is
'Append-only HelpHub audit evidence for authoritative server-side actions.';

comment on column public.audit_events.actor_id is
'HelpHub profile that performed the action; may be NULL for future system-generated events.';

comment on column public.audit_events.action is
'Version-independent audit action identifier or name.';

comment on column public.audit_events.entity_type is
'Logical HelpHub entity type affected by the audit action.';

comment on column public.audit_events.entity_id is
'Identifier of the affected HelpHub entity when one exists.';

comment on column public.audit_events.details is
'Structured audit context. Must not contain credentials or secret values.';

comment on column public.audit_events.created_at is
'Database-generated timestamp when the audit event was recorded.';


-- ============================================================
-- 2.1 AUDIT QUERY INDEXES
-- ============================================================
--
-- These indexes support the primary audit-review access patterns:
--   - events by actor over time
--   - events affecting one entity over time
--   - events of one action type over time

create index idx_audit_events_actor_created_at
    on public.audit_events (actor_id, created_at desc)
    where actor_id is not null;

create index idx_audit_events_entity_created_at
    on public.audit_events (entity_type, entity_id, created_at desc)
    where entity_id is not null;

create index idx_audit_events_action_created_at
    on public.audit_events (action, created_at desc);


-- ============================================================
-- 2.2 ROW LEVEL SECURITY AND TABLE PRIVILEGES
-- ============================================================
--
-- No resident-facing RLS policy is created here.
--
-- Ordinary anon/authenticated clients must not directly read or write
-- the audit ledger.
--
-- Protected server-side code may use the service_role connection.
-- SECURITY DEFINER database operations created later in this migration
-- may also write audit events through their function-owner privileges.

alter table public.audit_events
enable row level security;


revoke all
on table public.audit_events
from public, anon, authenticated, service_role;


-- The protected HelpHub backend may append and inspect audit evidence.
--
-- UPDATE and DELETE are deliberately not granted to service_role.

grant select, insert
on table public.audit_events
to service_role;


-- ============================================================
-- 2.3 APPEND-ONLY PROTECTION
-- ============================================================
--
-- Grants alone are not enough for immutability because future
-- privileged application code could accidentally receive broader
-- permissions.
--
-- This trigger creates an additional database-level protection:
-- existing audit rows cannot be UPDATEd or DELETEd through ordinary
-- SQL operations.

create or replace function public.prevent_audit_event_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
    raise exception
        'HelpHub audit events are append-only and cannot be updated or deleted'
        using errcode = '55000';
end;
$function$;


revoke all
on function public.prevent_audit_event_mutation()
from public, anon, authenticated, service_role;


create trigger trg_audit_events_prevent_mutation
before update or delete
on public.audit_events
for each row
execute function public.prevent_audit_event_mutation();


comment on function public.prevent_audit_event_mutation() is
'Rejects UPDATE and DELETE operations on HelpHub append-only audit events.';


-- ============================================================
-- 3. APPROVED ADMINISTRATOR READ ACCESS
-- ============================================================
--
-- Purpose:
--   Allow an approved Barangay Administrator to view the resident
--   information required for the verification-review workflow.
--
-- Existing resident-own SELECT policies remain unchanged.
--
-- PostgreSQL's default/permissive RLS policies combine using OR:
--
--   Resident:
--       existing own-row policy may allow access
--
--   Approved Barangay Administrator:
--       the policies below may additionally allow access
--
-- Important:
--   This section grants READ access only.
--   Verification decisions remain protected and will be implemented
--   through an authoritative server-side operation later in this
--   migration.


-- ------------------------------------------------------------
-- 3.1 Resident profiles visible to approved administrators
-- ------------------------------------------------------------
--
-- Limit administrator-wide profile visibility in this slice to
-- Resident profiles.
--
-- An administrator's own profile remains readable through the
-- existing profiles_select_own policy from the identity foundation.

create policy profiles_select_approved_admin_residents
on public.profiles
for select
to authenticated
using (
    public.is_approved_barangay_admin()
    and role = 'resident'
);


comment on policy profiles_select_approved_admin_residents
on public.profiles is
'Allows an approved HelpHub Barangay Administrator to read Resident profiles required for administration and verification review.';


-- ------------------------------------------------------------
-- 3.2 Resident verification records visible to approved admins
-- ------------------------------------------------------------
--
-- Verification requests are administrative review records.
-- Approved Barangay Administrators may read them for queue/review
-- purposes, while ordinary residents retain only their existing
-- own-history visibility.

create policy resident_verifications_select_approved_admin
on public.resident_verifications
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy resident_verifications_select_approved_admin
on public.resident_verifications is
'Allows an approved HelpHub Barangay Administrator to read resident verification requests for administrative review.';

-- ============================================================
-- 4. PROTECTED RESIDENT VERIFICATION REVIEW OPERATION
-- ============================================================
--
-- Purpose:
--   Perform the authoritative approve/reject operation for a pending
--   resident verification request.
--
-- Security boundary:
--   - Flutter must NOT call this function directly.
--   - authenticated and anon receive no EXECUTE privilege.
--   - only service_role receives EXECUTE.
--   - FastAPI will later validate the authenticated administrator
--     session and supply the validated administrator profile id.
--
-- Atomic behavior:
--   One successful function call performs all of these changes:
--
--     1. verify reviewer is an approved barangay_admin
--     2. validate decision
--     3. lock the pending verification request
--     4. update verification decision/reviewer/time
--     5. update resident account status
--     6. append immutable audit evidence
--
-- Any failure aborts the operation instead of leaving a partial review.
--
-- Concurrency behavior:
--   SELECT ... FOR UPDATE locks the verification row while the review
--   is being processed. A competing review must wait and will then
--   observe that the record is no longer pending.
--
-- Engineering-defined audit identifier:
--   resident_verification.reviewed
--
-- The actual review decision remains in the structured details field
-- and in resident_verifications.status.


create or replace function public.review_resident_verification(
    p_verification_id uuid,
    p_reviewer_id uuid,
    p_decision text
)
returns table (
    verification_id uuid,
    resident_id uuid,
    status text,
    reviewed_at timestamp with time zone,
    reviewed_by uuid,
    audit_event_id uuid
)
language plpgsql
security definer
set search_path = ''
as $function$
declare
    v_resident_id uuid;
    v_current_status text;
    v_reviewed_at timestamp with time zone;
    v_audit_event_id uuid;
    v_updated_profiles integer;
begin
    -- --------------------------------------------------------
    -- 1. AUTHORIZE THE REVIEWER
    -- --------------------------------------------------------
    --
    -- The service_role caller is powerful, so the business operation
    -- still validates the supplied actor against authoritative
    -- HelpHub profile data.
    --
    -- FastAPI must derive p_reviewer_id from the administrator's
    -- validated session rather than accepting an arbitrary reviewer
    -- id from client-controlled request data.

    if p_reviewer_id is null then
        raise exception using
            errcode = '42501',
            message = 'HelpHub verification review requires an authorized Barangay Administrator';
    end if;

    if not exists (
        select 1
        from public.profiles as reviewer
        where reviewer.id = p_reviewer_id
          and reviewer.role = 'barangay_admin'
          and reviewer.account_status = 'approved'
    ) then
        raise exception using
            errcode = '42501',
            message = 'HelpHub verification review requires an approved Barangay Administrator';
    end if;


    -- --------------------------------------------------------
    -- 2. VALIDATE THE REVIEW DECISION
    -- --------------------------------------------------------
    --
    -- Current identity-foundation decisions are exactly:
    --   approved
    --   rejected
    --
    -- pending is the pre-review state and therefore is not a valid
    -- review decision.

    if p_decision is null
       or p_decision not in ('approved', 'rejected') then
        raise exception using
            errcode = '22023',
            message = 'HelpHub verification decision must be approved or rejected';
    end if;


    -- --------------------------------------------------------
    -- 3. LOCK AND LOAD THE VERIFICATION REQUEST
    -- --------------------------------------------------------

    select
        rv.resident_id,
        rv.status
    into
        v_resident_id,
        v_current_status
    from public.resident_verifications as rv
    where rv.id = p_verification_id
    for update;

    if not found then
        raise exception using
            errcode = 'P0002',
            message = 'HelpHub resident verification request was not found';
    end if;


    -- --------------------------------------------------------
    -- 4. REQUIRE A PENDING REQUEST
    -- --------------------------------------------------------
    --
    -- A completed request cannot be reviewed a second time.
    -- This also provides the deterministic result after concurrent
    -- reviewers compete for the same row lock.

    if v_current_status <> 'pending' then
        raise exception using
            errcode = '55000',
            message = 'HelpHub resident verification request is no longer pending';
    end if;


    -- --------------------------------------------------------
    -- 5. RECORD THE VERIFICATION DECISION
    -- --------------------------------------------------------
    --
    -- status, reviewed_at, and reviewed_by are written together so
    -- chk_resident_verifications_review_state remains satisfied.

    update public.resident_verifications as rv
    set
        status = p_decision,
        reviewed_at = pg_catalog.now(),
        reviewed_by = p_reviewer_id
    where rv.id = p_verification_id
    returning rv.reviewed_at
    into v_reviewed_at;


    -- --------------------------------------------------------
    -- 6. UPDATE THE RESIDENT ACCOUNT WORKFLOW STATE
    -- --------------------------------------------------------
    --
    -- Only a Resident profile may be changed through this operation.
    -- The account-status value intentionally mirrors the verified
    -- review result: approved or rejected.

    update public.profiles as resident
    set account_status = p_decision
    where resident.id = v_resident_id
      and resident.role = 'resident';

    get diagnostics v_updated_profiles = row_count;

    if v_updated_profiles <> 1 then
        raise exception using
            errcode = '55000',
            message = 'HelpHub verification target is not a valid Resident profile';
    end if;


    -- --------------------------------------------------------
    -- 7. APPEND IMMUTABLE AUDIT EVIDENCE
    -- --------------------------------------------------------
    --
    -- Do not place resident names, credentials, tokens, passwords,
    -- document contents, or unnecessary personal data in this event.
    --
    -- actor_id already records the administrator.
    -- entity_id identifies the reviewed verification request.
    -- resident_id and decision provide the minimum structured context
    -- required to explain the resulting state change.

    insert into public.audit_events (
        actor_id,
        action,
        entity_type,
        entity_id,
        details
    )
    values (
        p_reviewer_id,
        'resident_verification.reviewed',
        'resident_verification',
        p_verification_id,
        pg_catalog.jsonb_build_object(
            'decision', p_decision,
            'resident_id', v_resident_id
        )
    )
    returning id
    into v_audit_event_id;


    -- --------------------------------------------------------
    -- 8. RETURN THE AUTHORITATIVE RESULT
    -- --------------------------------------------------------

    return query
    select
        p_verification_id,
        v_resident_id,
        p_decision,
        v_reviewed_at,
        p_reviewer_id,
        v_audit_event_id;
end;
$function$;


-- ============================================================
-- 4.1 FUNCTION EXECUTION PRIVILEGES
-- ============================================================
--
-- PostgreSQL functions normally receive EXECUTE for PUBLIC unless it
-- is revoked.
--
-- Remove all broad execution first, then allow only the protected
-- server-side service role.

revoke all
on function public.review_resident_verification(uuid, uuid, text)
from public, anon, authenticated, service_role;


grant execute
on function public.review_resident_verification(uuid, uuid, text)
to service_role;


comment on function public.review_resident_verification(uuid, uuid, text) is
'Service-only atomic HelpHub operation for an approved Barangay Administrator to approve or reject a pending resident verification request and append audit evidence.';