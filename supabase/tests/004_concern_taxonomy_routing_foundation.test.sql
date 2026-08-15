-- HelpHub
-- Automated concern-taxonomy and routing-foundation regression tests
-- File: 004_concern_taxonomy_routing_foundation.test.sql
--
-- Task 04.4
--
-- Purpose:
--   Verify the versioned concern taxonomy, routing configuration,
--   compatibility constraints, RLS policies, PostgreSQL privileges,
--   and role-based configuration visibility introduced by:
--
--   20260814110829_create_concern_taxonomy_and_handler_foundation.sql
--
-- This suite complements:
--
--   001_identity_foundation.test.sql
--   002_identity_rls_behavior.test.sql
--   003_admin_verification_review.test.sql
--
-- All synthetic records created later in this suite exist only
-- inside this transaction.
--
-- The final ROLLBACK removes all synthetic test data.


begin;


create extension if not exists pgtap with schema extensions;


set local search_path = public, extensions;


-- The suite contains exactly 38 pgTAP assertions.
select plan(38);


-- ============================================================
-- A. STRUCTURAL BASELINE
-- ============================================================


-- 01. Concern-taxonomy version table exists.
select ok(
    to_regclass('public.concern_taxonomy_versions') is not null,
    'public.concern_taxonomy_versions exists'
);


-- 02. Versioned concern-type table exists.
select ok(
    to_regclass('public.concern_types') is not null,
    'public.concern_types exists'
);


-- 03. Routing-configuration version table exists.
select ok(
    to_regclass('public.routing_config_versions') is not null,
    'public.routing_config_versions exists'
);


-- 04. Versioned routing-destination table exists.
select ok(
    to_regclass('public.routing_destinations') is not null,
    'public.routing_destinations exists'
);


-- 05. Version-compatible concern-to-routing map exists.
select ok(
    to_regclass('public.concern_type_routes') is not null,
    'public.concern_type_routes exists'
);


-- ============================================================
-- B. RLS AND POLICY BASELINE
-- ============================================================


-- 06. RLS is enabled on concern-taxonomy versions.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid =
            'public.concern_taxonomy_versions'::regclass
    ),
    'RLS is enabled on public.concern_taxonomy_versions'
);


-- 07. RLS is enabled on concern types.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid =
            'public.concern_types'::regclass
    ),
    'RLS is enabled on public.concern_types'
);


-- 08. RLS is enabled on routing-configuration versions.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid =
            'public.routing_config_versions'::regclass
    ),
    'RLS is enabled on public.routing_config_versions'
);


-- 09. RLS is enabled on routing destinations.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid =
            'public.routing_destinations'::regclass
    ),
    'RLS is enabled on public.routing_destinations'
);


-- 10. RLS is enabled on concern-type routing mappings.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid =
            'public.concern_type_routes'::regclass
    ),
    'RLS is enabled on public.concern_type_routes'
);


-- 11. Task 04.4 exposes exactly seven SELECT policies.
select results_eq(
    $$
        select count(*)::bigint
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and policyname in (
              'concern_taxonomy_versions_select_approved_resident_active',
              'concern_types_select_approved_resident_active_enabled',
              'concern_taxonomy_versions_select_approved_admin',
              'concern_types_select_approved_admin',
              'routing_config_versions_select_approved_admin',
              'routing_destinations_select_approved_admin',
              'concern_type_routes_select_approved_admin'
          )
          and cmd = 'SELECT'
    $$,
    array[7::bigint],
    'Task 04.4 has exactly seven expected SELECT policies'
);


-- 12. Task 04.4 defines no INSERT, UPDATE, or DELETE RLS policy.
select results_eq(
    $$
        select count(*)::bigint
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename in (
              'concern_taxonomy_versions',
              'concern_types',
              'routing_config_versions',
              'routing_destinations',
              'concern_type_routes'
          )
          and cmd in (
              'INSERT',
              'UPDATE',
              'DELETE'
          )
    $$,
    array[0::bigint],
    'Task 04.4 configuration tables expose no mutation RLS policies'
);


-- ============================================================
-- C. TABLE-PRIVILEGE BASELINE
-- ============================================================


-- 13. Anonymous clients have no SELECT privilege on configuration.
select ok(
    (
        select bool_and(
            not has_table_privilege(
                'anon',
                'public.' || table_name,
                'SELECT'
            )
        )
        from (
            values
                ('concern_taxonomy_versions'),
                ('concern_types'),
                ('routing_config_versions'),
                ('routing_destinations'),
                ('concern_type_routes')
        ) as config_tables(table_name)
    ),
    'anon has no SELECT privilege on any Task 04.4 configuration table'
);


-- 14. Authenticated clients have SELECT privilege on all five tables.
-- RLS still determines which rows an authenticated user may see.
select ok(
    (
        select bool_and(
            has_table_privilege(
                'authenticated',
                'public.' || table_name,
                'SELECT'
            )
        )
        from (
            values
                ('concern_taxonomy_versions'),
                ('concern_types'),
                ('routing_config_versions'),
                ('routing_destinations'),
                ('concern_type_routes')
        ) as config_tables(table_name)
    ),
    'authenticated has SELECT privilege on all Task 04.4 configuration tables'
);


-- 15. service_role has SELECT privilege on all five configuration tables.
select ok(
    (
        select bool_and(
            has_table_privilege(
                'service_role',
                'public.' || table_name,
                'SELECT'
            )
        )
        from (
            values
                ('concern_taxonomy_versions'),
                ('concern_types'),
                ('routing_config_versions'),
                ('routing_destinations'),
                ('concern_type_routes')
        ) as config_tables(table_name)
    ),
    'service_role has SELECT privilege on all Task 04.4 configuration tables'
);


-- 16. Anonymous clients have no mutation privileges.
select ok(
    (
        select bool_and(
            not has_table_privilege(
                'anon',
                'public.' || table_name,
                privilege_name
            )
        )
        from (
            values
                ('concern_taxonomy_versions'),
                ('concern_types'),
                ('routing_config_versions'),
                ('routing_destinations'),
                ('concern_type_routes')
        ) as config_tables(table_name)
        cross join (
            values
                ('INSERT'),
                ('UPDATE'),
                ('DELETE')
        ) as mutation_privileges(privilege_name)
    ),
    'anon has no INSERT UPDATE or DELETE privilege on Task 04.4 configuration'
);


-- 17. Authenticated clients have no mutation privileges.
select ok(
    (
        select bool_and(
            not has_table_privilege(
                'authenticated',
                'public.' || table_name,
                privilege_name
            )
        )
        from (
            values
                ('concern_taxonomy_versions'),
                ('concern_types'),
                ('routing_config_versions'),
                ('routing_destinations'),
                ('concern_type_routes')
        ) as config_tables(table_name)
        cross join (
            values
                ('INSERT'),
                ('UPDATE'),
                ('DELETE')
        ) as mutation_privileges(privilege_name)
    ),
    'authenticated has no INSERT UPDATE or DELETE privilege on Task 04.4 configuration'
);


-- 18. service_role also receives no direct mutation privilege from
-- this foundation migration.
select ok(
    (
        select bool_and(
            not has_table_privilege(
                'service_role',
                'public.' || table_name,
                privilege_name
            )
        )
        from (
            values
                ('concern_taxonomy_versions'),
                ('concern_types'),
                ('routing_config_versions'),
                ('routing_destinations'),
                ('concern_type_routes')
        ) as config_tables(table_name)
        cross join (
            values
                ('INSERT'),
                ('UPDATE'),
                ('DELETE')
        ) as mutation_privileges(privilege_name)
    ),
    'service_role has no INSERT UPDATE or DELETE privilege from the Task 04.4 foundation'
);


-- ============================================================
-- D. VERSION-COMPATIBILITY CONSTRAINT BASELINE
-- ============================================================


-- 19. concern_types exposes the composite compatibility key used by
-- concern_type_routes.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.concern_types'::regclass
          and conname = 'uq_concern_types_id_taxonomy'
          and contype = 'u'
    ),
    'concern_types has the id + taxonomy compatibility unique constraint'
);


-- 20. routing_config_versions exposes the routing/taxonomy
-- compatibility key.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.routing_config_versions'::regclass
          and conname = 'uq_routing_config_versions_id_taxonomy'
          and contype = 'u'
    ),
    'routing_config_versions has the id + taxonomy compatibility unique constraint'
);


-- 21. routing_destinations exposes the destination/routing-version
-- compatibility key.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.routing_destinations'::regclass
          and conname = 'uq_routing_destinations_id_version'
          and contype = 'u'
    ),
    'routing_destinations has the id + routing-version compatibility unique constraint'
);


-- 22. A route must pair a routing configuration with the taxonomy
-- version for which that routing configuration was defined.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.concern_type_routes'::regclass
          and conname = 'fk_concern_type_routes_routing_taxonomy'
          and contype = 'f'
    ),
    'concern_type_routes enforces routing-version and taxonomy compatibility'
);


-- 23. A routed concern type must belong to the taxonomy version
-- recorded by the route.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.concern_type_routes'::regclass
          and conname = 'fk_concern_type_routes_concern_taxonomy'
          and contype = 'f'
    ),
    'concern_type_routes enforces concern-type and taxonomy compatibility'
);


-- 24. A routing destination must belong to the routing version
-- recorded by the route.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.concern_type_routes'::regclass
          and conname = 'fk_concern_type_routes_destination_version'
          and contype = 'f'
    ),
    'concern_type_routes enforces destination and routing-version compatibility'
);


-- 25. One concern type receives at most one configured destination
-- within one routing version.
select ok(
    exists (
        select 1
        from pg_catalog.pg_constraint
        where conrelid = 'public.concern_type_routes'::regclass
          and conname = 'uq_concern_type_routes_version_concern'
          and contype = 'u'
    ),
    'one routing version cannot contain duplicate routes for one concern type'
);


-- 26. Only one concern-taxonomy version may be active at a time.
select ok(
    to_regclass(
        'public.uq_concern_taxonomy_versions_one_active'
    ) is not null,
    'single-active concern-taxonomy unique index exists'
);


-- 27. Only one routing-configuration version may be active at a time.
select ok(
    to_regclass(
        'public.uq_routing_config_versions_one_active'
    ) is not null,
    'single-active routing-configuration unique index exists'
);


-- ============================================================
-- E. ROUTING-COMPATIBILITY BEHAVIOR
-- ============================================================
--
-- Synthetic configuration in this section exists only inside the
-- pgTAP transaction and is removed by the final ROLLBACK.


-- Two independent taxonomy snapshots.
insert into public.concern_taxonomy_versions (
    id,
    version_number,
    version_label
)
values
(
    '44040000-0000-4000-8000-000000000001'::uuid,
    101,
    'TEST 004 TAXONOMY A'
),
(
    '44040000-0000-4000-8000-000000000002'::uuid,
    102,
    'TEST 004 TAXONOMY B'
);


-- One concern type in each taxonomy.
insert into public.concern_types (
    id,
    taxonomy_version_id,
    code,
    name,
    display_order
)
values
(
    '44040000-0000-4000-8000-000000000011'::uuid,
    '44040000-0000-4000-8000-000000000001'::uuid,
    'TEST004_A',
    'Test 004 Concern A',
    1
),
(
    '44040000-0000-4000-8000-000000000012'::uuid,
    '44040000-0000-4000-8000-000000000002'::uuid,
    'TEST004_B',
    'Test 004 Concern B',
    1
);


-- One routing configuration for each taxonomy.
insert into public.routing_config_versions (
    id,
    taxonomy_version_id,
    version_number,
    version_label
)
values
(
    '44040000-0000-4000-8000-000000000021'::uuid,
    '44040000-0000-4000-8000-000000000001'::uuid,
    101,
    'TEST 004 ROUTING A'
),
(
    '44040000-0000-4000-8000-000000000022'::uuid,
    '44040000-0000-4000-8000-000000000002'::uuid,
    102,
    'TEST 004 ROUTING B'
);


-- Two destinations in Routing A and one in Routing B.
insert into public.routing_destinations (
    id,
    routing_version_id,
    code,
    name,
    destination_kind,
    display_order
)
values
(
    '44040000-0000-4000-8000-000000000031'::uuid,
    '44040000-0000-4000-8000-000000000021'::uuid,
    'TEST004_DEST_A1',
    'Test 004 Internal Destination A1',
    'internal_handler',
    1
),
(
    '44040000-0000-4000-8000-000000000032'::uuid,
    '44040000-0000-4000-8000-000000000021'::uuid,
    'TEST004_DEST_A2',
    'Test 004 Internal Destination A2',
    'internal_handler',
    2
),
(
    '44040000-0000-4000-8000-000000000033'::uuid,
    '44040000-0000-4000-8000-000000000022'::uuid,
    'TEST004_DEST_B1',
    'Test 004 External Destination B1',
    'external_referral',
    1
);


-- 28. A fully compatible concern-to-routing mapping succeeds.
select lives_ok(
    $$
        insert into public.concern_type_routes (
            id,
            routing_version_id,
            taxonomy_version_id,
            concern_type_id,
            destination_id
        )
        values (
            '44040000-0000-4000-8000-000000000041'::uuid,
            '44040000-0000-4000-8000-000000000021'::uuid,
            '44040000-0000-4000-8000-000000000001'::uuid,
            '44040000-0000-4000-8000-000000000011'::uuid,
            '44040000-0000-4000-8000-000000000031'::uuid
        )
    $$,
    'compatible concern-type routing mapping is accepted'
);


-- 29. Concern A cannot be routed using Taxonomy B.
select throws_like(
    $$
        insert into public.concern_type_routes (
            id,
            routing_version_id,
            taxonomy_version_id,
            concern_type_id,
            destination_id
        )
        values (
            '44040000-0000-4000-8000-000000000042'::uuid,
            '44040000-0000-4000-8000-000000000022'::uuid,
            '44040000-0000-4000-8000-000000000002'::uuid,
            '44040000-0000-4000-8000-000000000011'::uuid,
            '44040000-0000-4000-8000-000000000033'::uuid
        )
    $$,
    '%fk_concern_type_routes_concern_taxonomy%',
    'cross-taxonomy concern mapping is rejected'
);


-- 30. A destination from Routing A cannot be used by Routing B.
select throws_like(
    $$
        insert into public.concern_type_routes (
            id,
            routing_version_id,
            taxonomy_version_id,
            concern_type_id,
            destination_id
        )
        values (
            '44040000-0000-4000-8000-000000000043'::uuid,
            '44040000-0000-4000-8000-000000000022'::uuid,
            '44040000-0000-4000-8000-000000000002'::uuid,
            '44040000-0000-4000-8000-000000000012'::uuid,
            '44040000-0000-4000-8000-000000000031'::uuid
        )
    $$,
    '%fk_concern_type_routes_destination_version%',
    'cross-routing destination mapping is rejected'
);


-- 31. Routing A cannot be falsely paired with Taxonomy B.
select throws_like(
    $$
        insert into public.concern_type_routes (
            id,
            routing_version_id,
            taxonomy_version_id,
            concern_type_id,
            destination_id
        )
        values (
            '44040000-0000-4000-8000-000000000044'::uuid,
            '44040000-0000-4000-8000-000000000021'::uuid,
            '44040000-0000-4000-8000-000000000002'::uuid,
            '44040000-0000-4000-8000-000000000012'::uuid,
            '44040000-0000-4000-8000-000000000031'::uuid
        )
    $$,
    '%fk_concern_type_routes_routing_taxonomy%',
    'routing-version and taxonomy mismatch is rejected'
);


-- 32. Routing A cannot contain a second destination mapping for
-- Concern A.
select throws_like(
    $$
        insert into public.concern_type_routes (
            id,
            routing_version_id,
            taxonomy_version_id,
            concern_type_id,
            destination_id
        )
        values (
            '44040000-0000-4000-8000-000000000045'::uuid,
            '44040000-0000-4000-8000-000000000021'::uuid,
            '44040000-0000-4000-8000-000000000001'::uuid,
            '44040000-0000-4000-8000-000000000011'::uuid,
            '44040000-0000-4000-8000-000000000032'::uuid
        )
    $$,
    '%uq_concern_type_routes_version_concern%',
    'duplicate concern route inside one routing version is rejected'
);


-- ============================================================
-- F. ROLE-BASED RLS BEHAVIOR
-- ============================================================
--
-- These synthetic users and configuration records exist only
-- inside this test transaction.
--
-- The same authenticated-user simulation already proven by the
-- identity RLS suite is reused here:
--
--   set local role authenticated;
--   set local request.jwt.claim.sub = '<user uuid>';


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
    '44040000-1000-4000-8000-000000000001'::uuid,
    'test004.approved.resident@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 004 Approved Resident'
    )
),
(
    '44040000-1000-4000-8000-000000000002'::uuid,
    'test004.pending.resident@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 004 Pending Resident'
    )
),
(
    '44040000-1000-4000-8000-000000000003'::uuid,
    'test004.approved.admin@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 004 Approved Administrator'
    )
);


-- The signup trigger initially creates safe Resident + pending
-- profiles. The database-owner test context then establishes the
-- authoritative states required by this regression fixture.

update public.profiles
set
    role = 'resident',
    account_status = 'approved'
where id =
    '44040000-1000-4000-8000-000000000001'::uuid;


-- User 0002 intentionally remains resident + pending.


update public.profiles
set
    role = 'barangay_admin',
    account_status = 'approved'
where id =
    '44040000-1000-4000-8000-000000000003'::uuid;


-- 33. Synthetic profiles have the intended authoritative states.
select results_eq(
    $$
        select
            full_name,
            role,
            account_status
        from public.profiles
        where id in (
            '44040000-1000-4000-8000-000000000001'::uuid,
            '44040000-1000-4000-8000-000000000002'::uuid,
            '44040000-1000-4000-8000-000000000003'::uuid
        )
        order by id
    $$,
    $$
        values
            (
                'Test 004 Approved Resident'::text,
                'resident'::text,
                'approved'::text
            ),
            (
                'Test 004 Pending Resident'::text,
                'resident'::text,
                'pending'::text
            ),
            (
                'Test 004 Approved Administrator'::text,
                'barangay_admin'::text,
                'approved'::text
            )
    $$,
    'synthetic Task 04.4 users have the intended authoritative profile states'
);


-- ------------------------------------------------------------
-- Synthetic taxonomy lifecycle
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
values
(
    '44040000-1000-4000-8000-000000000101'::uuid,
    103,
    'TEST 004 RLS DRAFT TAXONOMY',
    '44040000-1000-4000-8000-000000000003'::uuid,
    null,
    null,
    null,
    null
),
(
    '44040000-1000-4000-8000-000000000102'::uuid,
    104,
    'TEST 004 RLS ACTIVE TAXONOMY',
    '44040000-1000-4000-8000-000000000003'::uuid,
    '44040000-1000-4000-8000-000000000003'::uuid,
    now(),
    null,
    null
),
(
    '44040000-1000-4000-8000-000000000103'::uuid,
    105,
    'TEST 004 RLS RETIRED TAXONOMY',
    '44040000-1000-4000-8000-000000000003'::uuid,
    '44040000-1000-4000-8000-000000000003'::uuid,
    now() - interval '2 days',
    '44040000-1000-4000-8000-000000000003'::uuid,
    now() - interval '1 day'
);


-- ------------------------------------------------------------
-- Synthetic concern types
-- ------------------------------------------------------------

insert into public.concern_types (
    id,
    taxonomy_version_id,
    code,
    name,
    display_order,
    is_enabled
)
values
(
    '44040000-1000-4000-8000-000000000111'::uuid,
    '44040000-1000-4000-8000-000000000101'::uuid,
    'TEST004_RLS_DRAFT',
    'Test 004 RLS Draft Concern',
    1,
    true
),
(
    '44040000-1000-4000-8000-000000000112'::uuid,
    '44040000-1000-4000-8000-000000000102'::uuid,
    'TEST004_RLS_ACTIVE_ENABLED',
    'Test 004 RLS Active Enabled Concern',
    1,
    true
),
(
    '44040000-1000-4000-8000-000000000113'::uuid,
    '44040000-1000-4000-8000-000000000102'::uuid,
    'TEST004_RLS_ACTIVE_DISABLED',
    'Test 004 RLS Active Disabled Concern',
    2,
    false
),
(
    '44040000-1000-4000-8000-000000000114'::uuid,
    '44040000-1000-4000-8000-000000000103'::uuid,
    'TEST004_RLS_RETIRED',
    'Test 004 RLS Retired Concern',
    1,
    true
);


-- ------------------------------------------------------------
-- Synthetic routing configuration for the active taxonomy
-- ------------------------------------------------------------

insert into public.routing_config_versions (
    id,
    taxonomy_version_id,
    version_number,
    version_label,
    created_by
)
values (
    '44040000-1000-4000-8000-000000000121'::uuid,
    '44040000-1000-4000-8000-000000000102'::uuid,
    103,
    'TEST 004 RLS ROUTING',
    '44040000-1000-4000-8000-000000000003'::uuid
);


insert into public.routing_destinations (
    id,
    routing_version_id,
    code,
    name,
    destination_kind,
    display_order
)
values
(
    '44040000-1000-4000-8000-000000000131'::uuid,
    '44040000-1000-4000-8000-000000000121'::uuid,
    'TEST004_RLS_INTERNAL',
    'Test 004 RLS Internal Handler',
    'internal_handler',
    1
),
(
    '44040000-1000-4000-8000-000000000132'::uuid,
    '44040000-1000-4000-8000-000000000121'::uuid,
    'TEST004_RLS_EXTERNAL',
    'Test 004 RLS External Referral',
    'external_referral',
    2
);


insert into public.concern_type_routes (
    id,
    routing_version_id,
    taxonomy_version_id,
    concern_type_id,
    destination_id
)
values (
    '44040000-1000-4000-8000-000000000141'::uuid,
    '44040000-1000-4000-8000-000000000121'::uuid,
    '44040000-1000-4000-8000-000000000102'::uuid,
    '44040000-1000-4000-8000-000000000112'::uuid,
    '44040000-1000-4000-8000-000000000131'::uuid
);


-- ------------------------------------------------------------
-- Approved Resident
-- ------------------------------------------------------------

set local role authenticated;

set local request.jwt.claim.sub =
    '44040000-1000-4000-8000-000000000001';


-- 34. Approved Resident sees only the active taxonomy and enabled
-- concern type from this RLS fixture, with no routing rows.
select ok(
    (
        select count(*)
        from public.concern_taxonomy_versions
        where id in (
            '44040000-1000-4000-8000-000000000101'::uuid,
            '44040000-1000-4000-8000-000000000102'::uuid,
            '44040000-1000-4000-8000-000000000103'::uuid
        )
    ) = 1
    and
    (
        select count(*)
        from public.concern_types
        where id in (
            '44040000-1000-4000-8000-000000000111'::uuid,
            '44040000-1000-4000-8000-000000000112'::uuid,
            '44040000-1000-4000-8000-000000000113'::uuid,
            '44040000-1000-4000-8000-000000000114'::uuid
        )
    ) = 1
    and
    (
        select count(*)
        from public.routing_config_versions
        where id =
            '44040000-1000-4000-8000-000000000121'::uuid
    ) = 0
    and
    (
        select count(*)
        from public.routing_destinations
        where id in (
            '44040000-1000-4000-8000-000000000131'::uuid,
            '44040000-1000-4000-8000-000000000132'::uuid
        )
    ) = 0
    and
    (
        select count(*)
        from public.concern_type_routes
        where id =
            '44040000-1000-4000-8000-000000000141'::uuid
    ) = 0,
    'approved Resident sees active enabled taxonomy data but no routing configuration'
);


-- 35. The only concern from this fixture visible to the approved
-- Resident is the active + enabled concern type.
select results_eq(
    $$
        select code
        from public.concern_types
        where code like 'TEST004_RLS_%'
        order by code
    $$,
    array[
        'TEST004_RLS_ACTIVE_ENABLED'::text
    ],
    'approved Resident sees only the active enabled concern type'
);


-- ------------------------------------------------------------
-- Pending Resident
-- ------------------------------------------------------------

set local request.jwt.claim.sub =
    '44040000-1000-4000-8000-000000000002';


-- 36. Pending Resident sees no rows from the Task 04.4 RLS fixture.
select ok(
    (
        select count(*)
        from public.concern_taxonomy_versions
        where id in (
            '44040000-1000-4000-8000-000000000101'::uuid,
            '44040000-1000-4000-8000-000000000102'::uuid,
            '44040000-1000-4000-8000-000000000103'::uuid
        )
    ) = 0
    and
    (
        select count(*)
        from public.concern_types
        where id in (
            '44040000-1000-4000-8000-000000000111'::uuid,
            '44040000-1000-4000-8000-000000000112'::uuid,
            '44040000-1000-4000-8000-000000000113'::uuid,
            '44040000-1000-4000-8000-000000000114'::uuid
        )
    ) = 0
    and
    (
        select count(*)
        from public.routing_config_versions
        where id =
            '44040000-1000-4000-8000-000000000121'::uuid
    ) = 0
    and
    (
        select count(*)
        from public.routing_destinations
        where id in (
            '44040000-1000-4000-8000-000000000131'::uuid,
            '44040000-1000-4000-8000-000000000132'::uuid
        )
    ) = 0
    and
    (
        select count(*)
        from public.concern_type_routes
        where id =
            '44040000-1000-4000-8000-000000000141'::uuid
    ) = 0,
    'pending Resident sees no Task 04.4 configuration rows'
);


-- ------------------------------------------------------------
-- Approved Barangay Administrator
-- ------------------------------------------------------------

set local request.jwt.claim.sub =
    '44040000-1000-4000-8000-000000000003';


-- 37. Approved Administrator can read the complete RLS fixture.
select ok(
    (
        select count(*)
        from public.concern_taxonomy_versions
        where id in (
            '44040000-1000-4000-8000-000000000101'::uuid,
            '44040000-1000-4000-8000-000000000102'::uuid,
            '44040000-1000-4000-8000-000000000103'::uuid
        )
    ) = 3
    and
    (
        select count(*)
        from public.concern_types
        where id in (
            '44040000-1000-4000-8000-000000000111'::uuid,
            '44040000-1000-4000-8000-000000000112'::uuid,
            '44040000-1000-4000-8000-000000000113'::uuid,
            '44040000-1000-4000-8000-000000000114'::uuid
        )
    ) = 4
    and
    (
        select count(*)
        from public.routing_config_versions
        where id =
            '44040000-1000-4000-8000-000000000121'::uuid
    ) = 1
    and
    (
        select count(*)
        from public.routing_destinations
        where id in (
            '44040000-1000-4000-8000-000000000131'::uuid,
            '44040000-1000-4000-8000-000000000132'::uuid
        )
    ) = 2
    and
    (
        select count(*)
        from public.concern_type_routes
        where id =
            '44040000-1000-4000-8000-000000000141'::uuid
    ) = 1,
    'approved Barangay Administrator can read complete Task 04.4 configuration history'
);


-- ------------------------------------------------------------
-- Anonymous client
-- ------------------------------------------------------------

reset role;

set local role anon;

set local request.jwt.claim.sub =
    '00000000-0000-0000-0000-000000000000';


-- 38. Anonymous clients cannot SELECT configuration tables because
-- they have no table-level SELECT privilege.
select throws_like(
    $$
        select count(*)
        from public.concern_taxonomy_versions
    $$,
    '%permission denied%concern_taxonomy_versions%',
    'anonymous client cannot SELECT concern-taxonomy configuration'
);


reset role;

-- ============================================================
-- FINISH
-- ============================================================


reset role;


select * from finish();


rollback;