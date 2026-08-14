-- HelpHub
-- Automated behavioral database security tests
-- Test file: 002_identity_rls_behavior.test.sql
--
-- Purpose:
--   Prove that the identity-foundation permissions behave correctly
--   when requests execute as Supabase's authenticated and anon roles.
--
-- This complements:
--   001_identity_foundation.test.sql
--
-- 001 checks STRUCTURE:
--   - tables
--   - constraints
--   - grants
--   - RLS policies
--   - triggers/functions
--
-- 002 checks BEHAVIOR:
--   - own-row access
--   - cross-resident isolation
--   - safe profile editing
--   - role/status tampering protection
--   - verification submission rules
--   - duplicate-pending protection
--   - self-approval protection
--   - anonymous access denial
--
-- Test data uses fixed synthetic UUIDs and exists only inside this
-- transaction. ROLLBACK removes every synthetic record afterward.

begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

-- Exactly 22 behavioral assertions are defined below.
select plan(22);


-- ============================================================
-- TEST IDENTITIES
-- ============================================================
--
-- Resident One:
--   11111111-1111-4111-8111-111111111111
--
-- Resident Two:
--   22222222-2222-4222-8222-222222222222
--
-- We insert directly into auth.users while running as the database
-- test owner. HelpHub's on_auth_user_created trigger should then
-- create the matching public.profiles rows.
--
-- Resident One intentionally supplies malicious signup metadata:
--
--   role = barangay_admin
--   account_status = approved
--
-- The HelpHub trigger must ignore those privilege-escalation claims
-- and create the public profile as resident + pending.

insert into auth.users (
    id,
    email,
    raw_user_meta_data
)
values
(
    '11111111-1111-4111-8111-111111111111'::uuid,
    'behavior.resident.one@helphub.test',
    jsonb_build_object(
        'full_name', 'Behavior Resident One',
        'role', 'barangay_admin',
        'account_status', 'approved'
    )
),
(
    '22222222-2222-4222-8222-222222222222'::uuid,
    'behavior.resident.two@helphub.test',
    jsonb_build_object(
        'full_name', 'Behavior Resident Two'
    )
);


-- ============================================================
-- A. AUTH -> PROFILE CREATION
-- ============================================================

-- 01.
-- Even malicious metadata must not turn a public signup into an admin
-- or bypass the resident-approval workflow.
select results_eq(
    $$
        select
            full_name,
            role,
            account_status
        from public.profiles
        where id = '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    $$
        values (
            'Behavior Resident One'::text,
            'resident'::text,
            'pending'::text
        )
    $$,
    'malicious signup metadata cannot self-promote Resident One'
);

-- 02.
-- A normal second signup must receive the same safe defaults.
select results_eq(
    $$
        select
            full_name,
            role,
            account_status
        from public.profiles
        where id = '22222222-2222-4222-8222-222222222222'::uuid
    $$,
    $$
        values (
            'Behavior Resident Two'::text,
            'resident'::text,
            'pending'::text
        )
    $$,
    'Resident Two profile is automatically created with safe defaults'
);


-- ============================================================
-- B. AUTHENTICATE AS RESIDENT ONE
-- ============================================================

-- Supabase RLS tests simulate an authenticated JWT by:
--   1. switching to the authenticated PostgreSQL role
--   2. supplying request.jwt.claim.sub
--
-- auth.uid() will therefore identify Resident One.

set local role authenticated;

set local request.jwt.claim.sub =
    '11111111-1111-4111-8111-111111111111';


-- ============================================================
-- C. PROFILE READ ISOLATION
-- ============================================================

-- 03.
-- Resident One should see exactly one profile: their own.
select results_eq(
    $$
        select count(*)
        from public.profiles
    $$,
    array[1::bigint],
    'Resident One sees exactly one profile'
);

-- 04.
-- The visible profile must be Resident One's own UUID.
select results_eq(
    $$
        select id
        from public.profiles
    $$,
    array[
        '11111111-1111-4111-8111-111111111111'::uuid
    ],
    'Resident One can read their own profile'
);

-- 05.
-- Asking directly for Resident Two must still reveal nothing.
select is_empty(
    $$
        select id
        from public.profiles
        where id = '22222222-2222-4222-8222-222222222222'::uuid
    $$,
    'Resident One cannot read Resident Two profile'
);


-- ============================================================
-- D. PROFILE UPDATE BEHAVIOR
-- ============================================================

-- 06.
-- full_name is the resident-editable profile field.
select lives_ok(
    $$
        update public.profiles
        set full_name = 'Behavior Resident One Updated'
        where id = '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    'Resident One can update their own full_name'
);

-- 07.
-- Verify that the permitted update really happened.
select results_eq(
    $$
        select full_name
        from public.profiles
        where id = '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    array['Behavior Resident One Updated'::text],
    'Resident One own full_name update is stored'
);

-- 08.
-- Resident One has UPDATE(full_name), but RLS must filter Resident Two
-- out of the UPDATE target set. UPDATE ... RETURNING therefore returns
-- zero records.
select is_empty(
    $$
        update public.profiles
        set full_name = 'Cross Resident Tamper'
        where id = '22222222-2222-4222-8222-222222222222'::uuid
        returning id
    $$,
    'Resident One cannot update Resident Two full_name'
);

-- 09.
-- The role column is not granted to authenticated residents.
select throws_like(
    $$
        update public.profiles
        set role = 'barangay_admin'
        where id = '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    '%permission denied%profiles%',
    'Resident One cannot self-promote to barangay_admin'
);

-- 10.
-- account_status is also protected from resident modification.
select throws_like(
    $$
        update public.profiles
        set account_status = 'approved'
        where id = '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    '%permission denied%profiles%',
    'Resident One cannot self-approve their account'
);


-- ============================================================
-- E. RESIDENT ONE VERIFICATION SUBMISSION
-- ============================================================

-- 11.
-- Resident One may submit their own verification request.
select lives_ok(
    $$
        insert into public.resident_verifications (resident_id)
        values (
            '11111111-1111-4111-8111-111111111111'::uuid
        )
    $$,
    'Resident One can submit their own verification request'
);

-- 12.
-- Database-controlled fields must default to pending and unreviewed.
select results_eq(
    $$
        select status
        from public.resident_verifications
        where resident_id =
            '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    array['pending'::text],
    'Resident One verification starts as pending'
);

-- 13.
-- Resident One must not submit a verification request for Resident Two.
select throws_like(
    $$
        insert into public.resident_verifications (resident_id)
        values (
            '22222222-2222-4222-8222-222222222222'::uuid
        )
    $$,
    '%row-level security policy%resident_verifications%',
    'Resident One cannot submit verification for Resident Two'
);

-- 14.
-- Resident One already has one pending request, so another pending
-- request must violate the partial unique index.
select throws_like(
    $$
        insert into public.resident_verifications (resident_id)
        values (
            '11111111-1111-4111-8111-111111111111'::uuid
        )
    $$,
    '%uq_resident_verifications_one_pending%',
    'Resident One cannot create a duplicate pending verification request'
);

-- 15.
-- Residents have no UPDATE privilege on verification decisions.
select throws_like(
    $$
        update public.resident_verifications
        set status = 'approved'
        where resident_id =
            '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    '%permission denied%resident_verifications%',
    'Resident One cannot approve their own verification request'
);

-- 16.
-- Resident One should see exactly their one verification record.
select results_eq(
    $$
        select count(*)
        from public.resident_verifications
    $$,
    array[1::bigint],
    'Resident One sees exactly their own verification record'
);


-- ============================================================
-- F. AUTHENTICATE AS RESIDENT TWO
-- ============================================================

set local request.jwt.claim.sub =
    '22222222-2222-4222-8222-222222222222';

-- 17.
-- Resident Two may independently create their own pending request.
select lives_ok(
    $$
        insert into public.resident_verifications (resident_id)
        values (
            '22222222-2222-4222-8222-222222222222'::uuid
        )
    $$,
    'Resident Two can submit their own verification request'
);

-- 18.
-- RLS should expose only Resident Two's request while authenticated
-- as Resident Two.
select results_eq(
    $$
        select count(*)
        from public.resident_verifications
    $$,
    array[1::bigint],
    'Resident Two sees exactly their own verification record'
);


-- ============================================================
-- G. RETURN TO RESIDENT ONE AND TEST CROSS-RESIDENT HISTORY
-- ============================================================

set local request.jwt.claim.sub =
    '11111111-1111-4111-8111-111111111111';

-- 19.
-- Resident Two now has a real row, but Resident One must not see it.
select is_empty(
    $$
        select id
        from public.resident_verifications
        where resident_id =
            '22222222-2222-4222-8222-222222222222'::uuid
    $$,
    'Resident One cannot read Resident Two verification history'
);

-- 20.
-- Resident One's own request must remain visible even after another
-- resident's request exists.
select results_eq(
    $$
        select count(*)
        from public.resident_verifications
        where resident_id =
            '11111111-1111-4111-8111-111111111111'::uuid
    $$,
    array[1::bigint],
    'Resident One can still read their own verification history'
);


-- ============================================================
-- H. ANONYMOUS ACCESS
-- ============================================================

-- Return to the session owner before changing to the anon role.
reset role;

set local role anon;

-- Use a non-user UUID as the anonymous JWT subject.
-- This avoids accidentally retaining Resident One's identity if the
-- RLS policy implementation changes in the future.
set local request.jwt.claim.sub =
    '00000000-0000-0000-0000-000000000000';

-- 21.
-- The anon role currently has no SELECT privilege on profiles.
select throws_like(
    $$
        select id
        from public.profiles
        limit 1
    $$,
    '%permission denied%profiles%',
    'Anonymous callers cannot read profiles'
);

-- 22.
-- Verification records are also unavailable to anon.
select throws_like(
    $$
        select id
        from public.resident_verifications
        limit 1
    $$,
    '%permission denied%resident_verifications%',
    'Anonymous callers cannot read resident verification records'
);


-- ============================================================
-- FINISH
-- ============================================================

select * from finish();

-- Remove all synthetic Auth users, profiles, verification requests,
-- and profile edits made by this behavioral test.
rollback;