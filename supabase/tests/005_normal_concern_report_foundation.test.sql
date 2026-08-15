-- HelpHub
-- Automated normal concern-report foundation regression tests
-- File: 005_normal_concern_report_foundation.test.sql
-- Task 04.5
--
-- Purpose:
--   Verify the database foundation introduced for normal concern
--   reporting, one-time location capture, optional private photo
--   evidence, authorization, RLS, and least-privilege access.
--
-- This suite is built incrementally.
-- A fixed plan(N), finish(), and rollback are added only after the
-- final assertion count is verified.


begin;


create extension if not exists pgtap with schema extensions;


set local search_path = public, extensions;


-- Fixed regression plan.
--
-- This suite contains exactly 62 pgTAP assertions.
select plan(62);


-- ============================================================
-- A. STRUCTURAL AND SECURITY BASELINE
-- ============================================================


-- 01. Normal concern report table exists.
select ok(
    to_regclass('public.reports') is not null,
    'public.reports exists'
);


-- 02. One-time normal report location table exists.
select ok(
    to_regclass('public.report_locations') is not null,
    'public.report_locations exists'
);


-- 03. Optional photo-evidence metadata table exists.
select ok(
    to_regclass('public.report_evidence') is not null,
    'public.report_evidence exists'
);


-- 04. Approved-Resident authorization helper exists.
select ok(
    to_regprocedure('public.is_approved_resident()') is not null,
    'approved Resident authorization helper exists'
);


-- 05. RLS is enabled on reports.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid = 'public.reports'::regclass
    ),
    'RLS is enabled on public.reports'
);


-- 06. RLS is enabled on report_locations.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid = 'public.report_locations'::regclass
    ),
    'RLS is enabled on public.report_locations'
);


-- 07. RLS is enabled on report_evidence.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid = 'public.report_evidence'::regclass
    ),
    'RLS is enabled on public.report_evidence'
);


-- 08. Dedicated evidence bucket exists.
select ok(
    exists (
        select 1
        from storage.buckets
        where id = 'report-evidence'
    ),
    'private report-evidence Storage bucket exists'
);


-- 09. Evidence bucket is private.
select ok(
    (
        select b.public = false
        from storage.buckets as b
        where b.id = 'report-evidence'
    ),
    'report-evidence Storage bucket is private'
);


-- 10. Evidence bucket enforces the engineering-defined 5 MiB limit.
select ok(
    (
        select b.file_size_limit = 5242880
        from storage.buckets as b
        where b.id = 'report-evidence'
    ),
    'report-evidence Storage bucket enforces the 5 MiB upload limit'
);


-- 11. Evidence bucket allows only the approved image MIME types.
select ok(
    (
        select b.allowed_mime_types =
            array[
                'image/jpeg',
                'image/png',
                'image/webp'
            ]::text[]
        from storage.buckets as b
        where b.id = 'report-evidence'
    ),
    'report-evidence Storage bucket allows only JPEG PNG and WebP images'
);


-- ============================================================
-- B. CONSTRAINT, POLICY, AND PRIVILEGE BASELINE
-- ============================================================


-- 12. Reports enforce concern-type/taxonomy compatibility.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.reports'::regclass
          and c.conname = 'fk_reports_concern_type_taxonomy'
          and c.contype = 'f'
    ),
    'reports enforce concern-type and taxonomy-version compatibility'
);


-- 13. A normal report can have at most one persisted location row.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_locations'::regclass
          and c.contype = 'p'
          and pg_get_constraintdef(c.oid) =
              'PRIMARY KEY (report_id)'
    ),
    'report_locations enforce one location row per normal report'
);


-- 14. A normal report can have at most one photo-evidence metadata row.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_evidence'::regclass
          and c.contype = 'p'
          and pg_get_constraintdef(c.oid) =
              'PRIMARY KEY (report_id)'
    ),
    'report_evidence enforce zero-or-one evidence row per normal report'
);


-- 15. Location latitude validation exists.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_locations'::regclass
          and c.conname = 'chk_report_locations_latitude'
          and c.contype = 'c'
    ),
    'report location latitude validation exists'
);


-- 16. Location longitude validation exists.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_locations'::regclass
          and c.conname = 'chk_report_locations_longitude'
          and c.contype = 'c'
    ),
    'report location longitude validation exists'
);


-- 17. Location accuracy validation exists.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_locations'::regclass
          and c.conname = 'chk_report_locations_accuracy'
          and c.contype = 'c'
    ),
    'report location accuracy validation exists'
);


-- 18. Evidence metadata is restricted to the dedicated bucket.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_evidence'::regclass
          and c.conname = 'chk_report_evidence_bucket_fixed'
          and c.contype = 'c'
    ),
    'report evidence metadata is restricted to the report-evidence bucket'
);


-- 19. Evidence metadata references an actual Storage bucket.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint as c
        where c.conrelid = 'public.report_evidence'::regclass
          and c.conname = 'fk_report_evidence_bucket'
          and c.contype = 'f'
    ),
    'report evidence bucket reference is protected by a foreign key'
);


-- 20. Exactly six Task 04.5 report-table RLS policies exist.
select results_eq(
    $$
        select count(*)::bigint
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename in (
              'reports',
              'report_locations',
              'report_evidence'
          )
    $$,
    array[6::bigint],
    'Task 04.5 has exactly six report-table RLS policies'
);


-- 21. Approved-Resident helper is executable by authenticated but not anon.
select ok(
    has_function_privilege(
        'authenticated',
        'public.is_approved_resident()',
        'EXECUTE'
    )
    and not has_function_privilege(
        'anon',
        'public.is_approved_resident()',
        'EXECUTE'
    ),
    'approved Resident helper execute privilege is restricted to authenticated users'
);


-- 22. anon has no direct privileges on any normal-report table.
select ok(
    not has_table_privilege('anon', 'public.reports', 'SELECT')
    and not has_table_privilege('anon', 'public.reports', 'INSERT')
    and not has_table_privilege('anon', 'public.reports', 'UPDATE')
    and not has_table_privilege('anon', 'public.reports', 'DELETE')

    and not has_table_privilege('anon', 'public.report_locations', 'SELECT')
    and not has_table_privilege('anon', 'public.report_locations', 'INSERT')
    and not has_table_privilege('anon', 'public.report_locations', 'UPDATE')
    and not has_table_privilege('anon', 'public.report_locations', 'DELETE')

    and not has_table_privilege('anon', 'public.report_evidence', 'SELECT')
    and not has_table_privilege('anon', 'public.report_evidence', 'INSERT')
    and not has_table_privilege('anon', 'public.report_evidence', 'UPDATE')
    and not has_table_privilege('anon', 'public.report_evidence', 'DELETE'),
    'anon has no direct privileges on normal-report tables'
);


-- 23. authenticated has SELECT only on all normal-report tables.
select ok(
    has_table_privilege('authenticated', 'public.reports', 'SELECT')
    and not has_table_privilege('authenticated', 'public.reports', 'INSERT')
    and not has_table_privilege('authenticated', 'public.reports', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.reports', 'DELETE')

    and has_table_privilege('authenticated', 'public.report_locations', 'SELECT')
    and not has_table_privilege('authenticated', 'public.report_locations', 'INSERT')
    and not has_table_privilege('authenticated', 'public.report_locations', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.report_locations', 'DELETE')

    and has_table_privilege('authenticated', 'public.report_evidence', 'SELECT')
    and not has_table_privilege('authenticated', 'public.report_evidence', 'INSERT')
    and not has_table_privilege('authenticated', 'public.report_evidence', 'UPDATE')
    and not has_table_privilege('authenticated', 'public.report_evidence', 'DELETE'),
    'authenticated has SELECT-only privilege on normal-report tables'
);


-- 24. service_role has SELECT + INSERT but no UPDATE or DELETE.
select ok(
    has_table_privilege('service_role', 'public.reports', 'SELECT')
    and has_table_privilege('service_role', 'public.reports', 'INSERT')
    and not has_table_privilege('service_role', 'public.reports', 'UPDATE')
    and not has_table_privilege('service_role', 'public.reports', 'DELETE')

    and has_table_privilege('service_role', 'public.report_locations', 'SELECT')
    and has_table_privilege('service_role', 'public.report_locations', 'INSERT')
    and not has_table_privilege('service_role', 'public.report_locations', 'UPDATE')
    and not has_table_privilege('service_role', 'public.report_locations', 'DELETE')

    and has_table_privilege('service_role', 'public.report_evidence', 'SELECT')
    and has_table_privilege('service_role', 'public.report_evidence', 'INSERT')
    and not has_table_privilege('service_role', 'public.report_evidence', 'UPDATE')
    and not has_table_privilege('service_role', 'public.report_evidence', 'DELETE'),
    'service_role has SELECT and INSERT but no UPDATE or DELETE on normal-report tables'
);


-- ============================================================
-- C. SYNTHETIC NORMAL-REPORT BEHAVIOR FIXTURES
-- ============================================================
--
-- All records created below exist only inside this pgTAP transaction.
-- The final ROLLBACK will remove them.


-- ------------------------------------------------------------
-- Synthetic HelpHub identities
-- ------------------------------------------------------------

insert into auth.users (
    id,
    email,
    raw_user_meta_data
)
values
(
    '55050000-1000-4000-8000-000000000001'::uuid,
    'test005.resident.one@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 005 Resident One'
    )
),
(
    '55050000-1000-4000-8000-000000000002'::uuid,
    'test005.resident.two@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 005 Resident Two'
    )
),
(
    '55050000-1000-4000-8000-000000000003'::uuid,
    'test005.pending.resident@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 005 Pending Resident'
    )
),
(
    '55050000-1000-4000-8000-000000000004'::uuid,
    'test005.approved.admin@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 005 Approved Administrator'
    )
);


-- The signup trigger initially creates safe Resident + pending profiles.
-- Establish the authoritative states needed by this regression fixture.

update public.profiles
set
    role = 'resident',
    account_status = 'approved'
where id = '55050000-1000-4000-8000-000000000001'::uuid;


update public.profiles
set
    role = 'resident',
    account_status = 'approved'
where id = '55050000-1000-4000-8000-000000000002'::uuid;


-- User 0003 intentionally remains resident + pending.


update public.profiles
set
    role = 'barangay_admin',
    account_status = 'approved'
where id = '55050000-1000-4000-8000-000000000004'::uuid;


-- 25. Synthetic identities have the intended authoritative states.
select results_eq(
    $$
        select
            full_name,
            role,
            account_status
        from public.profiles
        where id in (
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000002'::uuid,
            '55050000-1000-4000-8000-000000000003'::uuid,
            '55050000-1000-4000-8000-000000000004'::uuid
        )
        order by id
    $$,
    $$
        values
        (
            'Test 005 Resident One'::text,
            'resident'::text,
            'approved'::text
        ),
        (
            'Test 005 Resident Two'::text,
            'resident'::text,
            'approved'::text
        ),
        (
            'Test 005 Pending Resident'::text,
            'resident'::text,
            'pending'::text
        ),
        (
            'Test 005 Approved Administrator'::text,
            'barangay_admin'::text,
            'approved'::text
        )
    $$,
    'synthetic Task 04.5 users have the intended authoritative profile states'
);


-- ------------------------------------------------------------
-- Synthetic active concern taxonomy
-- ------------------------------------------------------------

insert into public.concern_taxonomy_versions (
    id,
    version_number,
    version_label,
    created_by,
    activated_by,
    activated_at,
    retired_by,
    retired_at
)
values (
    '55050000-1000-4000-8000-000000000101'::uuid,
    205,
    'TEST 005 ACTIVE TAXONOMY',
    '55050000-1000-4000-8000-000000000004'::uuid,
    '55050000-1000-4000-8000-000000000004'::uuid,
    now(),
    null,
    null
);


insert into public.concern_types (
    id,
    taxonomy_version_id,
    code,
    name,
    display_order,
    is_enabled
)
values (
    '55050000-1000-4000-8000-000000000111'::uuid,
    '55050000-1000-4000-8000-000000000101'::uuid,
    'TEST005_NORMAL_CONCERN',
    'Test 005 Normal Concern',
    1,
    true
);


-- ------------------------------------------------------------
-- Synthetic normal reports
-- ------------------------------------------------------------

insert into public.reports (
    id,
    resident_id,
    taxonomy_version_id,
    concern_type_id,
    description,
    resident_declared_urgency,
    affected_population,
    has_vulnerable_group,
    submitted_at
)
values
(
    '55050000-2000-4000-8000-000000000001'::uuid,
    '55050000-1000-4000-8000-000000000001'::uuid,
    '55050000-1000-4000-8000-000000000101'::uuid,
    '55050000-1000-4000-8000-000000000111'::uuid,
    'Synthetic normal concern belonging to Resident One.',
    'TEST_URGENCY_ONE',
    3,
    true,
    now() - interval '2 minutes'
),
(
    '55050000-2000-4000-8000-000000000002'::uuid,
    '55050000-1000-4000-8000-000000000002'::uuid,
    '55050000-1000-4000-8000-000000000101'::uuid,
    '55050000-1000-4000-8000-000000000111'::uuid,
    'Synthetic normal concern belonging to Resident Two.',
    'TEST_URGENCY_TWO',
    1,
    false,
    now() - interval '1 minute'
);


-- ------------------------------------------------------------
-- Synthetic one-time report locations
-- ------------------------------------------------------------

insert into public.report_locations (
    report_id,
    latitude,
    longitude,
    accuracy_meters,
    captured_at,
    address
)
values
(
    '55050000-2000-4000-8000-000000000001'::uuid,
    14.5995,
    120.9842,
    8.5,
    now() - interval '3 minutes',
    'Synthetic Test Address One'
),
(
    '55050000-2000-4000-8000-000000000002'::uuid,
    14.6000,
    120.9850,
    12.0,
    now() - interval '2 minutes',
    null
);


-- ------------------------------------------------------------
-- Synthetic optional photo-evidence metadata
-- ------------------------------------------------------------
--
-- No permanent Storage object is uploaded here. These rows exercise
-- report-evidence metadata ownership and RLS only.

insert into public.report_evidence (
    report_id,
    bucket_id,
    object_path,
    content_type,
    size_bytes
)
values
(
    '55050000-2000-4000-8000-000000000001'::uuid,
    'report-evidence',
    'test005/resident-one/evidence-one.jpg',
    'image/jpeg',
    1024
),
(
    '55050000-2000-4000-8000-000000000002'::uuid,
    'report-evidence',
    'test005/resident-two/evidence-two.webp',
    'image/webp',
    2048
);


-- 26. Two synthetic normal-report aggregates exist before RLS tests.
select results_eq(
    $$
        select
            (select count(*) from public.reports)::bigint,
            (select count(*) from public.report_locations)::bigint,
            (select count(*) from public.report_evidence)::bigint
    $$,
    $$
        values (
            2::bigint,
            2::bigint,
            2::bigint
        )
    $$,
    'synthetic Task 04.5 fixture contains two reports locations and evidence rows'
);


-- ============================================================
-- D. AUTHENTICATED RLS BEHAVIOR
-- ============================================================
--
-- Supabase RLS tests simulate authenticated JWT identities by:
--
--   1. switching to the authenticated PostgreSQL role; and
--   2. supplying request.jwt.claim.sub.
--
-- auth.uid() therefore resolves to the synthetic HelpHub identity.


-- ============================================================
-- D1. APPROVED RESIDENT ONE
-- ============================================================

set local role authenticated;

set local request.jwt.claim.sub =
    '55050000-1000-4000-8000-000000000001';


-- 27. Resident One satisfies the approved-Resident helper.
select ok(
    public.is_approved_resident(),
    'Resident One is recognized as an approved Resident'
);


-- 28. Resident One sees exactly one report, one location, and one
-- evidence metadata row.
select results_eq(
    $$
        select
            (select count(*) from public.reports)::bigint,
            (select count(*) from public.report_locations)::bigint,
            (select count(*) from public.report_evidence)::bigint
    $$,
    $$
        values (
            1::bigint,
            1::bigint,
            1::bigint
        )
    $$,
    'Resident One sees exactly their own report location and evidence metadata'
);


-- 29. Resident One sees only Report One.
select results_eq(
    $$
        select id
        from public.reports
        order by id
    $$,
    $$
        values (
            '55050000-2000-4000-8000-000000000001'::uuid
        )
    $$,
    'Resident One cannot read Resident Two report'
);


-- ============================================================
-- D2. APPROVED RESIDENT TWO
-- ============================================================

set local request.jwt.claim.sub =
    '55050000-1000-4000-8000-000000000002';


-- 30. Resident Two satisfies the approved-Resident helper.
select ok(
    public.is_approved_resident(),
    'Resident Two is recognized as an approved Resident'
);


-- 31. Resident Two sees exactly one report, one location, and one
-- evidence metadata row.
select results_eq(
    $$
        select
            (select count(*) from public.reports)::bigint,
            (select count(*) from public.report_locations)::bigint,
            (select count(*) from public.report_evidence)::bigint
    $$,
    $$
        values (
            1::bigint,
            1::bigint,
            1::bigint
        )
    $$,
    'Resident Two sees exactly their own report location and evidence metadata'
);


-- 32. Resident Two sees only Report Two.
select results_eq(
    $$
        select id
        from public.reports
        order by id
    $$,
    $$
        values (
            '55050000-2000-4000-8000-000000000002'::uuid
        )
    $$,
    'Resident Two cannot read Resident One report'
);


-- ============================================================
-- D3. PENDING RESIDENT
-- ============================================================

set local request.jwt.claim.sub =
    '55050000-1000-4000-8000-000000000003';


-- 33. Pending Resident does not satisfy the approved-Resident helper.
select ok(
    not public.is_approved_resident(),
    'pending Resident is not recognized as an approved Resident'
);


-- 34. Pending Resident sees no normal-report records.
select results_eq(
    $$
        select
            (select count(*) from public.reports)::bigint,
            (select count(*) from public.report_locations)::bigint,
            (select count(*) from public.report_evidence)::bigint
    $$,
    $$
        values (
            0::bigint,
            0::bigint,
            0::bigint
        )
    $$,
    'pending Resident cannot read normal-report data'
);


-- ============================================================
-- D4. APPROVED BARANGAY ADMINISTRATOR
-- ============================================================

set local request.jwt.claim.sub =
    '55050000-1000-4000-8000-000000000004';


-- 35. Administrator satisfies the existing approved-admin helper.
select ok(
    public.is_approved_barangay_admin(),
    'synthetic Administrator is recognized as an approved Barangay Administrator'
);


-- 36. Approved Administrator sees the complete synthetic report fixture.
select results_eq(
    $$
        select
            (select count(*) from public.reports)::bigint,
            (select count(*) from public.report_locations)::bigint,
            (select count(*) from public.report_evidence)::bigint
    $$,
    $$
        values (
            2::bigint,
            2::bigint,
            2::bigint
        )
    $$,
    'approved Barangay Administrator can read complete synthetic normal-report data'
);


-- Return to the session owner before later privilege/anonymous tests.
reset role;
-- ============================================================
-- E. ANONYMOUS AND MUTATION SECURITY BOUNDARY
-- ============================================================


-- ============================================================
-- E1. ANONYMOUS ACCESS
-- ============================================================

set local role anon;

set local request.jwt.claim.sub =
    '00000000-0000-0000-0000-000000000000';


-- 37. Anonymous clients cannot read normal reports.
select throws_like(
    $$
        select *
        from public.reports
    $$,
    '%permission denied%reports%',
    'anonymous client cannot SELECT normal reports'
);


reset role;


-- ============================================================
-- E2. AUTHENTICATED RESIDENT DIRECT MUTATION DENIAL
-- ============================================================

set local role authenticated;

set local request.jwt.claim.sub =
    '55050000-1000-4000-8000-000000000001';


-- 38. An authenticated approved Resident cannot directly INSERT a
-- report through the Data API/table privilege boundary.
select throws_like(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000090'::uuid,
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000101'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            'Unauthorized direct Resident insert attempt.',
            'TEST_DIRECT_INSERT',
            1,
            false
        )
    $$,
    '%permission denied%reports%',
    'authenticated Resident cannot directly INSERT a normal report'
);


-- 39. An authenticated approved Resident cannot rewrite submitted raw
-- report input.
select throws_like(
    $$
        update public.reports
        set description = 'Unauthorized rewritten description.'
        where id =
            '55050000-2000-4000-8000-000000000001'::uuid
    $$,
    '%permission denied%reports%',
    'authenticated Resident cannot directly UPDATE a submitted normal report'
);


-- 40. An authenticated approved Resident cannot directly delete a
-- submitted normal report.
select throws_like(
    $$
        delete from public.reports
        where id =
            '55050000-2000-4000-8000-000000000001'::uuid
    $$,
    '%permission denied%reports%',
    'authenticated Resident cannot directly DELETE a submitted normal report'
);


reset role;


-- ============================================================
-- E3. PROTECTED BACKEND / SERVICE_ROLE INSERT BOUNDARY
-- ============================================================
--
-- FastAPI will use protected server-side credentials.
--
-- Task 04.5 grants service_role SELECT + INSERT only on raw report
-- tables. The following fixture verifies that valid creation succeeds
-- while later direct mutation remains prohibited.


set local role service_role;


-- 41. Protected backend can create a valid raw normal report.
select lives_ok(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000101'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            'Synthetic protected-backend normal report.',
            'TEST_BACKEND_CREATE',
            2,
            false
        )
    $$,
    'service_role can INSERT a valid raw normal report'
);


-- 42. Protected backend can create the report's one-time location.
select lives_ok(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at,
            address
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            14.6010,
            120.9860,
            10.0,
            now(),
            'Synthetic Protected Backend Address'
        )
    $$,
    'service_role can INSERT a valid one-time report location'
);


-- 43. Protected backend can create valid optional evidence metadata.
select lives_ok(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            'report-evidence',
            'test005/backend/evidence-three.png',
            'image/png',
            4096
        )
    $$,
    'service_role can INSERT valid report evidence metadata'
);


-- 44. Even service_role receives no direct UPDATE table privilege in
-- this raw-report foundation.
select throws_like(
    $$
        update public.reports
        set description = 'Unauthorized backend rewrite.'
        where id =
            '55050000-2000-4000-8000-000000000003'::uuid
    $$,
    '%permission denied%reports%',
    'service_role cannot directly UPDATE submitted raw normal reports'
);


reset role;


-- ============================================================
-- F. INVALID AND BOUNDARY DATA BEHAVIOR
-- ============================================================
--
-- These tests verify that PostgreSQL itself rejects contradictory or
-- malformed raw report data and accepts the explicitly supported
-- boundary values.


-- ------------------------------------------------------------
-- Additional taxonomy used only for cross-version rejection testing
-- ------------------------------------------------------------
--
-- This version remains draft so it does not conflict with the
-- single-active-taxonomy control.

insert into public.concern_taxonomy_versions (
    id,
    version_number,
    version_label,
    created_by,
    activated_by,
    activated_at,
    retired_by,
    retired_at
)
values (
    '55050000-1000-4000-8000-000000000102'::uuid,
    206,
    'TEST 005 SECOND TAXONOMY',
    '55050000-1000-4000-8000-000000000004'::uuid,
    null,
    null,
    null,
    null
);


insert into public.concern_types (
    id,
    taxonomy_version_id,
    code,
    name,
    display_order,
    is_enabled
)
values (
    '55050000-1000-4000-8000-000000000112'::uuid,
    '55050000-1000-4000-8000-000000000102'::uuid,
    'TEST005_SECOND_CONCERN',
    'Test 005 Second Concern',
    1,
    true
);


set local role service_role;


-- 45. A report cannot pair a concern type with the wrong taxonomy.
select throws_like(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000045'::uuid,
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000102'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            'Cross-taxonomy report attempt.',
            'TEST_CROSS_TAXONOMY',
            1,
            false
        )
    $$,
    '%foreign key constraint%fk_reports_concern_type_taxonomy%',
    'cross-taxonomy concern report is rejected'
);


-- 46. Blank report descriptions are rejected.
select throws_like(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000046'::uuid,
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000101'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            '   ',
            'TEST_BLANK_DESCRIPTION',
            1,
            false
        )
    $$,
    '%check constraint%chk_reports_description%',
    'blank normal-report description is rejected'
);


-- 47. Negative affected-population values are rejected.
select throws_like(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000047'::uuid,
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000101'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            'Negative population attempt.',
            'TEST_NEGATIVE_POPULATION',
            -1,
            false
        )
    $$,
    '%check constraint%chk_reports_affected_population%',
    'negative affected population is rejected'
);


-- ------------------------------------------------------------
-- Valid boundary aggregate
-- ------------------------------------------------------------

-- 48. affected_population = 0 is accepted by this foundation.
select lives_ok(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000004'::uuid,
            '55050000-1000-4000-8000-000000000002'::uuid,
            '55050000-1000-4000-8000-000000000101'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            'Valid boundary-value report.',
            'TEST_BOUNDARY',
            0,
            false
        )
    $$,
    'zero affected population is accepted by the database foundation'
);


-- 49. Geographic extreme values and zero accuracy are accepted.
select lives_ok(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at,
            address
        )
        values (
            '55050000-2000-4000-8000-000000000004'::uuid,
            90.0,
            -180.0,
            0.0,
            now(),
            null
        )
    $$,
    'valid latitude longitude and accuracy boundary values are accepted'
);


-- 50. The exact 5 MiB evidence-size ceiling is accepted.
select lives_ok(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000004'::uuid,
            'report-evidence',
            'test005/boundary/exact-five-mib.png',
            'image/png',
            5242880
        )
    $$,
    'exact 5 MiB report evidence metadata boundary is accepted'
);


-- 51. Latitude above +90 degrees is rejected.
select throws_like(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            90.0001,
            120.0,
            1.0,
            now()
        )
    $$,
    '%check constraint%chk_report_locations_latitude%',
    'latitude above 90 degrees is rejected'
);


-- 52. Longitude above +180 degrees is rejected.
select throws_like(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            14.5,
            180.0001,
            1.0,
            now()
        )
    $$,
    '%check constraint%chk_report_locations_longitude%',
    'longitude above 180 degrees is rejected'
);


-- 53. Negative location accuracy is rejected.
select throws_like(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            14.5,
            120.0,
            -0.1,
            now()
        )
    $$,
    '%check constraint%chk_report_locations_accuracy%',
    'negative report-location accuracy is rejected'
);


-- 54. Unsupported evidence MIME type is rejected.
select throws_like(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            'report-evidence',
            'test005/invalid/evidence.gif',
            'image/gif',
            1024
        )
    $$,
    '%check constraint%chk_report_evidence_content_type%',
    'unsupported report evidence MIME type is rejected'
);


-- 55. Evidence larger than 5 MiB is rejected.
select throws_like(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000003'::uuid,
            'report-evidence',
            'test005/invalid/oversized.jpg',
            'image/jpeg',
            5242881
        )
    $$,
    '%check constraint%chk_report_evidence_size_bytes%',
    'report evidence metadata larger than 5 MiB is rejected'
);


-- 56. A second location for the same report is rejected.
select throws_like(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at
        )
        values (
            '55050000-2000-4000-8000-000000000004'::uuid,
            14.5,
            120.0,
            1.0,
            now()
        )
    $$,
    '%duplicate key value%report_locations_pkey%',
    'duplicate normal-report location row is rejected'
);


reset role;


-- ============================================================
-- G. REMAINING RAW-DATA VALIDATION BEHAVIOR
-- ============================================================


set local role service_role;


-- ------------------------------------------------------------
-- Additional valid report used only as the target of invalid child
-- record attempts below.
-- ------------------------------------------------------------

insert into public.reports (
    id,
    resident_id,
    taxonomy_version_id,
    concern_type_id,
    description,
    resident_declared_urgency,
    affected_population,
    has_vulnerable_group
)
values (
    '55050000-2000-4000-8000-000000000005'::uuid,
    '55050000-1000-4000-8000-000000000001'::uuid,
    '55050000-1000-4000-8000-000000000101'::uuid,
    '55050000-1000-4000-8000-000000000111'::uuid,
    'Synthetic target for remaining validation tests.',
    'TEST_VALIDATION_TARGET',
    1,
    false
);


-- 57. Blank Resident-declared urgency is rejected.
select throws_like(
    $$
        insert into public.reports (
            id,
            resident_id,
            taxonomy_version_id,
            concern_type_id,
            description,
            resident_declared_urgency,
            affected_population,
            has_vulnerable_group
        )
        values (
            '55050000-2000-4000-8000-000000000057'::uuid,
            '55050000-1000-4000-8000-000000000001'::uuid,
            '55050000-1000-4000-8000-000000000101'::uuid,
            '55050000-1000-4000-8000-000000000111'::uuid,
            'Blank urgency validation attempt.',
            '   ',
            1,
            false
        )
    $$,
    '%check constraint%chk_reports_resident_declared_urgency%',
    'blank Resident-declared urgency is rejected'
);


-- 58. Zero-byte evidence metadata is rejected.
select throws_like(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000005'::uuid,
            'report-evidence',
            'test005/invalid/zero-size.jpg',
            'image/jpeg',
            0
        )
    $$,
    '%check constraint%chk_report_evidence_size_bytes%',
    'zero-byte report evidence metadata is rejected'
);


-- 59. Evidence metadata cannot reference another Storage bucket.
select throws_like(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000005'::uuid,
            'wrong-bucket',
            'test005/invalid/wrong-bucket.jpg',
            'image/jpeg',
            1024
        )
    $$,
    '%check constraint%chk_report_evidence_bucket_fixed%',
    'report evidence metadata cannot reference another Storage bucket'
);


-- 60. Blank Storage object paths are rejected.
select throws_like(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000005'::uuid,
            'report-evidence',
            '   ',
            'image/jpeg',
            1024
        )
    $$,
    '%check constraint%chk_report_evidence_object_path%',
    'blank report evidence object path is rejected'
);


-- 61. A supplied human-readable address cannot be blank.
select throws_like(
    $$
        insert into public.report_locations (
            report_id,
            latitude,
            longitude,
            accuracy_meters,
            captured_at,
            address
        )
        values (
            '55050000-2000-4000-8000-000000000005'::uuid,
            14.5,
            120.0,
            5.0,
            now(),
            '   '
        )
    $$,
    '%check constraint%chk_report_locations_address%',
    'blank non-null report location address is rejected'
);


-- 62. A report cannot contain two evidence metadata rows.
--
-- Report 0004 already received valid evidence metadata in assertion 50.

select throws_like(
    $$
        insert into public.report_evidence (
            report_id,
            bucket_id,
            object_path,
            content_type,
            size_bytes
        )
        values (
            '55050000-2000-4000-8000-000000000004'::uuid,
            'report-evidence',
            'test005/duplicate/second-evidence.jpg',
            'image/jpeg',
            1024
        )
    $$,
    '%duplicate key value%report_evidence_pkey%',
    'duplicate normal-report evidence metadata row is rejected'
);


reset role;


-- ============================================================
-- FINISH
-- ============================================================

select * from finish();


-- All synthetic Task 04.5 identities, configuration records,
-- reports, locations, and evidence metadata exist only inside this
-- transaction.

rollback;