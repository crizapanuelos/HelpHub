-- HelpHub
-- Automated database regression tests
-- Test file: 001_identity_foundation.test.sql
--
-- Purpose:
--   Verify that the identity foundation created by
--   create_identity_foundation remains structurally correct.
--
-- Scope:
--   - public.profiles
--   - public.resident_verifications
--   - primary/foreign keys
--   - defaults and CHECK constraints
--   - Row Level Security
--   - RLS policy names
--   - least-privilege grants
--   - Auth -> profile trigger
--   - profile write-preparation trigger
--
-- Important:
--   Behavioral RLS tests using simulated authenticated users will
--   live in a separate test file. This file focuses on structural
--   database guarantees.
--
-- All tests execute inside a transaction and are rolled back.

begin;

-- pgTAP is available in the local Supabase PostgreSQL environment.
-- Creating it IF NOT EXISTS makes this test explicit and reproducible.
create extension if not exists pgtap with schema extensions;

-- Make pgTAP assertion functions available without schema prefixes.
set local search_path = public, extensions;

-- There are exactly 34 assertions in this test file.
select plan(34);


-- ============================================================
-- 1. public.profiles
-- ============================================================

-- 01. The application-side profile table must exist.
select has_table(
    'public',
    'profiles',
    'public.profiles exists'
);

-- 02. The table must contain exactly the expected foundation columns.
select columns_are(
    'public',
    'profiles',
    array[
        'id',
        'full_name',
        'role',
        'account_status',
        'created_at',
        'updated_at'
    ],
    'public.profiles has the expected columns'
);

-- 03. profiles.id must remain the primary key.
select col_is_pk(
    'public',
    'profiles',
    'id',
    'profiles.id is the primary key'
);

-- 04. profiles.id must remain linked one-to-one with auth.users.id,
--     and Auth-user deletion must be restricted at this stage.
select ok(
    exists (
        select 1
        from pg_constraint c
        where c.conname = 'profiles_id_fkey'
          and c.conrelid = 'public.profiles'::regclass
          and c.confrelid = 'auth.users'::regclass
          and c.contype = 'f'
          and c.confdeltype = 'r'
    ),
    'profiles.id references auth.users.id with ON DELETE RESTRICT'
);

-- 05. Public/application-created profiles must default to resident.
select ok(
    exists (
        select 1
        from pg_attribute a
        join pg_attrdef d
          on d.adrelid = a.attrelid
         and d.adnum = a.attnum
        where a.attrelid = 'public.profiles'::regclass
          and a.attname = 'role'
          and pg_get_expr(d.adbin, d.adrelid)
              = quote_literal('resident') || '::text'
    ),
    'profiles.role defaults to resident'
);

-- 06. New resident accounts must begin in pending state.
select ok(
    exists (
        select 1
        from pg_attribute a
        join pg_attrdef d
          on d.adrelid = a.attrelid
         and d.adnum = a.attnum
        where a.attrelid = 'public.profiles'::regclass
          and a.attname = 'account_status'
          and pg_get_expr(d.adbin, d.adrelid)
              = quote_literal('pending') || '::text'
    ),
    'profiles.account_status defaults to pending'
);

-- 07. Only supported HelpHub role values may be stored.
select ok(
    exists (
        select 1
        from pg_constraint
        where conrelid = 'public.profiles'::regclass
          and conname = 'chk_profiles_role'
          and contype = 'c'
    ),
    'profiles role CHECK constraint exists'
);

-- 08. Unsupported account workflow states must be rejected.
select ok(
    exists (
        select 1
        from pg_constraint
        where conrelid = 'public.profiles'::regclass
          and conname = 'chk_profiles_account_status'
          and contype = 'c'
    ),
    'profiles account_status CHECK constraint exists'
);

-- 09. full_name length/validation protection must remain present.
select ok(
    exists (
        select 1
        from pg_constraint
        where conrelid = 'public.profiles'::regclass
          and conname = 'chk_profiles_full_name'
          and contype = 'c'
    ),
    'profiles full_name CHECK constraint exists'
);

-- 10. Row Level Security must remain enabled.
select ok(
    (
        select c.relrowsecurity
        from pg_class c
        where c.oid = 'public.profiles'::regclass
    ),
    'RLS is enabled on public.profiles'
);

-- 11. The original resident-facing profile policies must remain present.
--
-- Later migrations may add additional valid policies, so this baseline
-- test checks required policy preservation rather than requiring the
-- complete policy set to remain permanently unchanged.
select ok(
    exists (
        select 1
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename = 'profiles'
          and policyname = 'profiles_select_own'
          and cmd = 'SELECT'
    )
    and exists (
        select 1
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename = 'profiles'
          and policyname = 'profiles_update_own'
          and cmd = 'UPDATE'
    ),
    'profiles retains the required resident-facing RLS policies'
);

-- 12. Authenticated users may SELECT profiles, with row visibility
--     subsequently restricted by RLS.
select ok(
    has_table_privilege(
        'authenticated',
        'public.profiles',
        'SELECT'
    ),
    'authenticated has SELECT privilege on profiles'
);

-- 13. Residents may update their own permitted full_name column.
select ok(
    has_column_privilege(
        'authenticated',
        'public.profiles',
        'full_name',
        'UPDATE'
    ),
    'authenticated has UPDATE privilege on profiles.full_name'
);

-- 14. Client users must not have permission to modify role.
select ok(
    not has_column_privilege(
        'authenticated',
        'public.profiles',
        'role',
        'UPDATE'
    ),
    'authenticated cannot UPDATE profiles.role'
);

-- 15. Client users must not have permission to approve/restrict themselves.
select ok(
    not has_column_privilege(
        'authenticated',
        'public.profiles',
        'account_status',
        'UPDATE'
    ),
    'authenticated cannot UPDATE profiles.account_status'
);


-- ============================================================
-- 2. public.resident_verifications
-- ============================================================

-- 16. Resident verification table must exist.
select has_table(
    'public',
    'resident_verifications',
    'public.resident_verifications exists'
);

-- 17. Verify its exact foundation columns.
select columns_are(
    'public',
    'resident_verifications',
    array[
        'id',
        'resident_id',
        'status',
        'submitted_at',
        'reviewed_at',
        'reviewed_by'
    ],
    'resident_verifications has the expected columns'
);

-- 18. Verification record id must remain its primary key.
select col_is_pk(
    'public',
    'resident_verifications',
    'id',
    'resident_verifications.id is the primary key'
);

-- 19. Verification requests must belong to an existing HelpHub profile.
select ok(
    exists (
        select 1
        from pg_constraint c
        where c.conname = 'resident_verifications_resident_id_fkey'
          and c.conrelid = 'public.resident_verifications'::regclass
          and c.confrelid = 'public.profiles'::regclass
          and c.contype = 'f'
          and c.confdeltype = 'r'
    ),
    'resident_verifications.resident_id references profiles with ON DELETE RESTRICT'
);

-- 20. A reviewer, when present, must reference an existing HelpHub profile.
select ok(
    exists (
        select 1
        from pg_constraint c
        where c.conname = 'resident_verifications_reviewed_by_fkey'
          and c.conrelid = 'public.resident_verifications'::regclass
          and c.confrelid = 'public.profiles'::regclass
          and c.contype = 'f'
          and c.confdeltype = 'r'
    ),
    'resident_verifications.reviewed_by references profiles with ON DELETE RESTRICT'
);

-- 21. Newly submitted verification requests must default to pending.
select ok(
    exists (
        select 1
        from pg_attribute a
        join pg_attrdef d
          on d.adrelid = a.attrelid
         and d.adnum = a.attnum
        where a.attrelid = 'public.resident_verifications'::regclass
          and a.attname = 'status'
          and pg_get_expr(d.adbin, d.adrelid)
              = quote_literal('pending') || '::text'
    ),
    'resident_verifications.status defaults to pending'
);

-- 22. Verification status vocabulary must remain constrained.
select ok(
    exists (
        select 1
        from pg_constraint
        where conrelid = 'public.resident_verifications'::regclass
          and conname = 'chk_resident_verifications_status'
          and contype = 'c'
    ),
    'verification status CHECK constraint exists'
);

-- 23. Pending/reviewed metadata consistency must remain constrained.
select ok(
    exists (
        select 1
        from pg_constraint
        where conrelid = 'public.resident_verifications'::regclass
          and conname = 'chk_resident_verifications_review_state'
          and contype = 'c'
    ),
    'verification review-state CHECK constraint exists'
);

-- 24. Only one simultaneous pending verification may exist per resident.
select ok(
    exists (
        select 1
        from pg_indexes
        where schemaname = 'public'
          and tablename = 'resident_verifications'
          and indexname = 'uq_resident_verifications_one_pending'
          and indexdef ilike '%unique%'
          and indexdef ilike '%status%'
          and indexdef ilike '%pending%'
    ),
    'partial unique index prevents duplicate pending verification requests'
);

-- 25. RLS must remain enabled on verification records.
select ok(
    (
        select c.relrowsecurity
        from pg_class c
        where c.oid = 'public.resident_verifications'::regclass
    ),
    'RLS is enabled on public.resident_verifications'
);

-- 26. The original resident-facing verification policies must remain present.
--
-- Later migrations may add additional valid administrator policies, so this
-- baseline test verifies preservation of the original resident controls
-- without requiring the complete policy set to remain permanently unchanged.
select ok(
    exists (
        select 1
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename = 'resident_verifications'
          and policyname = 'resident_verifications_select_own'
          and cmd = 'SELECT'
    )
    and exists (
        select 1
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename = 'resident_verifications'
          and policyname = 'resident_verifications_insert_own'
          and cmd = 'INSERT'
    ),
    'resident_verifications retains the required resident-facing RLS policies'
);

-- 27. Authenticated residents may SELECT verification records,
--     while RLS determines which rows are visible.
select ok(
    has_table_privilege(
        'authenticated',
        'public.resident_verifications',
        'SELECT'
    ),
    'authenticated has SELECT privilege on resident_verifications'
);

-- 28. Residents may supply only their resident_id when creating
--     their verification request.
select ok(
    has_column_privilege(
        'authenticated',
        'public.resident_verifications',
        'resident_id',
        'INSERT'
    ),
    'authenticated may INSERT resident_verifications.resident_id'
);

-- 29. Residents must not be able to update verification decisions.
select ok(
    not has_column_privilege(
        'authenticated',
        'public.resident_verifications',
        'status',
        'UPDATE'
    ),
    'authenticated cannot UPDATE resident_verifications.status'
);

-- 30. Residents must not be able to delete verification evidence.
select ok(
    not has_table_privilege(
        'authenticated',
        'public.resident_verifications',
        'DELETE'
    ),
    'authenticated cannot DELETE resident_verifications'
);


-- ============================================================
-- 3. Trigger and function foundation
-- ============================================================

-- 31. New Supabase Auth users must automatically invoke
--     HelpHub's profile-creation function.
select ok(
    exists (
        select 1
        from pg_trigger t
        join pg_proc p
          on p.oid = t.tgfoid
        join pg_namespace n
          on n.oid = p.pronamespace
        where t.tgrelid = 'auth.users'::regclass
          and t.tgname = 'on_auth_user_created'
          and not t.tgisinternal
          and n.nspname = 'public'
          and p.proname = 'handle_new_auth_user'
    ),
    'auth.users has the HelpHub profile-creation trigger'
);

-- 32. Profile writes must continue to pass through the preparation trigger.
select ok(
    exists (
        select 1
        from pg_trigger t
        join pg_proc p
          on p.oid = t.tgfoid
        join pg_namespace n
          on n.oid = p.pronamespace
        where t.tgrelid = 'public.profiles'::regclass
          and t.tgname = 'trg_profiles_prepare_write'
          and not t.tgisinternal
          and n.nspname = 'public'
          and p.proname = 'prepare_profile_write'
    ),
    'profiles has the write-preparation trigger'
);

-- 33. The Auth-user handler function itself must exist.
select ok(
    exists (
        select 1
        from pg_proc p
        join pg_namespace n
          on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.proname = 'handle_new_auth_user'
    ),
    'public.handle_new_auth_user function exists'
);

-- 34. The protected profile preparation function must exist.
select ok(
    exists (
        select 1
        from pg_proc p
        join pg_namespace n
          on n.oid = p.pronamespace
        where n.nspname = 'public'
          and p.proname = 'prepare_profile_write'
    ),
    'public.prepare_profile_write function exists'
);


-- Ask pgTAP to report the final result of all planned assertions.
select * from finish();

-- Leave the local database exactly as it was before this test.
rollback;