begin;

create extension if not exists pgtap with schema extensions;

set search_path = public, extensions;

-- ============================================================================
-- HELPHUB TASK 04.6
-- REPORT STATUS AND ASSIGNMENT FOUNDATION
-- INITIAL STRUCTURAL / SECURITY TEST SLICE
-- ============================================================================
--
-- This first slice verifies the applied database structure and privilege
-- boundary before synthetic lifecycle/routing behavior fixtures are added.
--
-- Production status names, transitions, handlers, destinations, deadlines,
-- and workflow policy values are intentionally NOT created by this test.
-- ============================================================================

select plan(47);


-- ============================================================================
-- A. TASK 04.6 TABLE EXISTENCE
-- ============================================================================

select ok(
    to_regclass('public.report_lifecycle_versions') is not null,
    'report_lifecycle_versions exists'
);

select ok(
    to_regclass('public.report_status_definitions') is not null,
    'report_status_definitions exists'
);

select ok(
    to_regclass('public.report_status_transitions') is not null,
    'report_status_transitions exists'
);

select ok(
    to_regclass('public.report_lifecycle_states') is not null,
    'report_lifecycle_states exists'
);

select ok(
    to_regclass('public.report_status_history') is not null,
    'report_status_history exists'
);

select ok(
    to_regclass('public.report_routing_states') is not null,
    'report_routing_states exists'
);

select ok(
    to_regclass('public.report_routing_history') is not null,
    'report_routing_history exists'
);


-- ============================================================================
-- B. RLS AND READ-POLICY STRUCTURE
-- ============================================================================

select is(
    (
        select count(*)::integer
        from pg_class c
        join pg_namespace n
          on n.oid = c.relnamespace
        where n.nspname = 'public'
          and c.relkind = 'r'
          and c.relrowsecurity
          and c.relname in (
              'report_lifecycle_versions',
              'report_status_definitions',
              'report_status_transitions',
              'report_lifecycle_states',
              'report_status_history',
              'report_routing_states',
              'report_routing_history'
          )
    ),
    7,
    'RLS is enabled on all seven Task 04.6 tables'
);

select is(
    (
        select count(*)::integer
        from pg_policies
        where schemaname = 'public'
          and tablename in (
              'report_lifecycle_states',
              'report_status_history',
              'report_routing_states',
              'report_routing_history'
          )
    ),
    8,
    'exactly eight operational Resident/Admin SELECT policies exist'
);


-- ============================================================================
-- C. SNAPSHOT / HISTORY TRACEABILITY STRUCTURE
-- ============================================================================

select is(
    (
        select count(*)::integer
        from pg_attribute
        where attrelid = 'public.report_lifecycle_states'::regclass
          and attname = 'source_history_id'
          and not attisdropped
    ),
    1,
    'report_lifecycle_states contains source_history_id'
);

select is(
    (
        select count(*)::integer
        from pg_attribute
        where attrelid = 'public.report_routing_states'::regclass
          and attname = 'source_history_id'
          and not attisdropped
    ),
    1,
    'report_routing_states contains source_history_id'
);


-- ============================================================================
-- D. CONFIGURABLE INITIAL-STATUS STRUCTURE
-- ============================================================================

select is(
    (
        select count(*)::integer
        from pg_attribute
        where attrelid = 'public.report_status_definitions'::regclass
          and attname = 'is_initial'
          and not attisdropped
    ),
    1,
    'report_status_definitions contains configurable is_initial marker'
);

select ok(
    to_regclass('public.uq_report_status_definitions_one_initial') is not null,
    'one-initial-status-per-lifecycle-version unique index exists'
);


-- ============================================================================
-- E. REPORT / ROUTING COMPATIBILITY FOUNDATION
-- ============================================================================

select is(
    (
        select count(*)::integer
        from pg_constraint
        where conname = 'uq_reports_id_taxonomy'
          and conrelid = 'public.reports'::regclass
    ),
    1,
    'reports exposes the report/taxonomy candidate key required by routing'
);


-- ============================================================================
-- F. APPEND-ONLY PROTECTION
-- ============================================================================

select ok(
    to_regprocedure('public.prevent_report_status_history_mutation()') is not null,
    'status-history append-only protection function exists'
);

select ok(
    to_regprocedure('public.prevent_report_routing_history_mutation()') is not null,
    'routing-history append-only protection function exists'
);

select is(
    (
        select count(*)::integer
        from pg_trigger t
        join pg_class c
          on c.oid = t.tgrelid
        join pg_namespace n
          on n.oid = c.relnamespace
        where n.nspname = 'public'
          and not t.tgisinternal
          and t.tgname in (
              'trg_report_status_history_prevent_mutation',
              'trg_report_routing_history_prevent_mutation'
          )
    ),
    2,
    'both append-only history mutation triggers exist'
);


-- ============================================================================
-- G. NO INVENTED WORKFLOW / ROUTING DATA
-- ============================================================================

select is(
    (
          (select count(*) from public.report_lifecycle_versions)
        + (select count(*) from public.report_status_definitions)
        + (select count(*) from public.report_status_transitions)
        + (select count(*) from public.report_lifecycle_states)
        + (select count(*) from public.report_status_history)
        + (select count(*) from public.report_routing_states)
        + (select count(*) from public.report_routing_history)
    )::bigint,
    0::bigint,
    'Task 04.6 seeds no lifecycle, status, transition, routing, or history rows'
);


-- ============================================================================
-- H. TABLE PRIVILEGE BOUNDARY
-- ============================================================================

select is(
    (
          has_table_privilege(
              'authenticated',
              'public.report_lifecycle_states',
              'SELECT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_status_history',
              'SELECT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_states',
              'SELECT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_history',
              'SELECT'
          )::integer
    ),
    4,
    'authenticated receives SELECT on the four operational tracking tables'
);

select is(
    (
          has_table_privilege(
              'authenticated',
              'public.report_lifecycle_versions',
              'SELECT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_status_definitions',
              'SELECT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_status_transitions',
              'SELECT'
          )::integer
    ),
    0,
    'authenticated receives no direct lifecycle-configuration SELECT privilege'
);

select is(
    (
          has_table_privilege(
              'authenticated',
              'public.report_lifecycle_states',
              'INSERT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_lifecycle_states',
              'UPDATE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_lifecycle_states',
              'DELETE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_status_history',
              'INSERT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_status_history',
              'UPDATE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_status_history',
              'DELETE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_states',
              'INSERT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_states',
              'UPDATE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_states',
              'DELETE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_history',
              'INSERT'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_history',
              'UPDATE'
          )::integer
        + has_table_privilege(
              'authenticated',
              'public.report_routing_history',
              'DELETE'
          )::integer
    ),
    0,
    'authenticated receives no direct operational INSERT UPDATE or DELETE privilege'
);

select is(
    (
          has_table_privilege(
              'service_role',
              'public.report_lifecycle_versions',
              'SELECT'
          )::integer
        + has_table_privilege(
              'service_role',
              'public.report_status_definitions',
              'SELECT'
          )::integer
        + has_table_privilege(
              'service_role',
              'public.report_status_transitions',
              'SELECT'
          )::integer
        + has_table_privilege(
              'service_role',
              'public.report_lifecycle_states',
              'SELECT'
          )::integer
        + has_table_privilege(
              'service_role',
              'public.report_status_history',
              'SELECT'
          )::integer
        + has_table_privilege(
              'service_role',
              'public.report_routing_states',
              'SELECT'
          )::integer
        + has_table_privilege(
              'service_role',
              'public.report_routing_history',
              'SELECT'
          )::integer
    ),
    7,
    'service_role may inspect all seven Task 04.6 tables'
);


-- ============================================================================
-- I. SYNTHETIC OPERATIONAL RLS BEHAVIOR FIXTURE
-- ============================================================================
--
-- Everything in this section is TEST-ONLY data and is rolled back at the end
-- of this pgTAP file.
--
-- TEST006_INITIAL is not an approved production HelpHub status.
-- TEST006_INTERNAL is not an approved production Barangay handler.
-- No production workflow or routing policy is established by these fixtures.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- I1. Synthetic HelpHub identities
-- ----------------------------------------------------------------------------

insert into auth.users (
    id,
    email,
    raw_user_meta_data
)
values
(
    '55060000-1000-4000-8000-000000000001'::uuid,
    'test006.resident.one@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 006 Resident One'
    )
),
(
    '55060000-1000-4000-8000-000000000002'::uuid,
    'test006.resident.two@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 006 Resident Two'
    )
),
(
    '55060000-1000-4000-8000-000000000003'::uuid,
    'test006.pending.resident@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 006 Pending Resident'
    )
),
(
    '55060000-1000-4000-8000-000000000004'::uuid,
    'test006.admin@helphub.test',
    jsonb_build_object(
        'full_name',
        'Test 006 Barangay Administrator'
    )
);

update public.profiles
set
    role = 'resident',
    account_status = 'approved'
where id in (
    '55060000-1000-4000-8000-000000000001'::uuid,
    '55060000-1000-4000-8000-000000000002'::uuid
);

-- User 0003 intentionally remains Resident + pending.

update public.profiles
set
    role = 'barangay_admin',
    account_status = 'approved'
where id = '55060000-1000-4000-8000-000000000004'::uuid;


-- 23. Synthetic identities have the intended authoritative profile states.
select results_eq(
    $$
        select
            id::text,
            role,
            account_status
        from public.profiles
        where id in (
            '55060000-1000-4000-8000-000000000001'::uuid,
            '55060000-1000-4000-8000-000000000002'::uuid,
            '55060000-1000-4000-8000-000000000003'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid
        )
        order by id
    $$,
    $$
        values
            (
                '55060000-1000-4000-8000-000000000001',
                'resident',
                'approved'
            ),
            (
                '55060000-1000-4000-8000-000000000002',
                'resident',
                'approved'
            ),
            (
                '55060000-1000-4000-8000-000000000003',
                'resident',
                'pending'
            ),
            (
                '55060000-1000-4000-8000-000000000004',
                'barangay_admin',
                'approved'
            )
    $$,
    'synthetic Task 04.6 identities have intended role and account status'
);


-- ----------------------------------------------------------------------------
-- I2. Synthetic taxonomy and normal reports
-- ----------------------------------------------------------------------------

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
    '55060000-2000-4000-8000-000000000101'::uuid,
    606,
    'TEST 006 ACTIVE TAXONOMY',
    '55060000-1000-4000-8000-000000000004'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
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
    '55060000-2000-4000-8000-000000000111'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    'TEST006_NORMAL_CONCERN',
    'Test 006 Normal Concern',
    1,
    true
);

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
    '55060000-3000-4000-8000-000000000001'::uuid,
    '55060000-1000-4000-8000-000000000001'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-2000-4000-8000-000000000111'::uuid,
    'Synthetic Task 04.6 report belonging to Resident One.',
    'TEST006_URGENCY_ONLY',
    1,
    false,
    now() - interval '2 minutes'
),
(
    '55060000-3000-4000-8000-000000000002'::uuid,
    '55060000-1000-4000-8000-000000000002'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-2000-4000-8000-000000000111'::uuid,
    'Synthetic Task 04.6 report belonging to Resident Two.',
    'TEST006_URGENCY_ONLY',
    2,
    false,
    now() - interval '1 minute'
);


-- ----------------------------------------------------------------------------
-- I3. Synthetic lifecycle configuration
-- ----------------------------------------------------------------------------

insert into public.report_lifecycle_versions (
    id,
    version_number,
    version_label,
    created_by
)
values (
    '55060000-4000-4000-8000-000000000101'::uuid,
    606,
    'TEST 006 LIFECYCLE',
    '55060000-1000-4000-8000-000000000004'::uuid
);

insert into public.report_status_definitions (
    id,
    lifecycle_version_id,
    code,
    name,
    display_order,
    is_enabled,
    is_initial
)
values (
    '55060000-4000-4000-8000-000000000111'::uuid,
    '55060000-4000-4000-8000-000000000101'::uuid,
    'TEST006_INITIAL',
    'Test 006 Initial Status',
    1,
    true,
    true
);


-- ----------------------------------------------------------------------------
-- I4. Synthetic routing configuration
-- ----------------------------------------------------------------------------

insert into public.routing_config_versions (
    id,
    taxonomy_version_id,
    version_number,
    version_label,
    created_by
)
values (
    '55060000-5000-4000-8000-000000000101'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    606,
    'TEST 006 ROUTING',
    '55060000-1000-4000-8000-000000000004'::uuid
);

insert into public.routing_destinations (
    id,
    routing_version_id,
    code,
    name,
    destination_kind,
    display_order,
    is_enabled
)
values (
    '55060000-5000-4000-8000-000000000111'::uuid,
    '55060000-5000-4000-8000-000000000101'::uuid,
    'TEST006_INTERNAL',
    'Test 006 Internal Destination',
    'internal_handler',
    1,
    true
);


-- ----------------------------------------------------------------------------
-- I5. Immutable audit evidence
-- ----------------------------------------------------------------------------

insert into public.audit_events (
    id,
    actor_id,
    action,
    entity_type,
    entity_id,
    details
)
values
(
    '55060000-6000-4000-8000-000000000001'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_STATUS_ESTABLISHED',
    'report_status_history',
    '55060000-3000-4000-8000-000000000001'::uuid,
    jsonb_build_object('test_fixture', '006', 'resident', 'one')
),
(
    '55060000-6000-4000-8000-000000000002'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_ROUTING_ESTABLISHED',
    'report_routing_history',
    '55060000-3000-4000-8000-000000000001'::uuid,
    jsonb_build_object('test_fixture', '006', 'resident', 'one')
),
(
    '55060000-6000-4000-8000-000000000003'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_STATUS_ESTABLISHED',
    'report_status_history',
    '55060000-3000-4000-8000-000000000002'::uuid,
    jsonb_build_object('test_fixture', '006', 'resident', 'two')
),
(
    '55060000-6000-4000-8000-000000000004'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_ROUTING_ESTABLISHED',
    'report_routing_history',
    '55060000-3000-4000-8000-000000000002'::uuid,
    jsonb_build_object('test_fixture', '006', 'resident', 'two')
);


-- ----------------------------------------------------------------------------
-- I6. Append-only lifecycle history, then current lifecycle snapshots
-- ----------------------------------------------------------------------------

insert into public.report_status_history (
    id,
    report_id,
    sequence_number,
    lifecycle_version_id,
    from_status_id,
    to_status_id,
    transition_id,
    changed_by,
    changed_at,
    change_note,
    audit_event_id
)
values
(
    '55060000-7000-4000-8000-000000000001'::uuid,
    '55060000-3000-4000-8000-000000000001'::uuid,
    1,
    '55060000-4000-4000-8000-000000000101'::uuid,
    null,
    '55060000-4000-4000-8000-000000000111'::uuid,
    null,
    '55060000-1000-4000-8000-000000000004'::uuid,
    now() - interval '2 minutes',
    'TEST 006 lifecycle establishment for Resident One report',
    '55060000-6000-4000-8000-000000000001'::uuid
),
(
    '55060000-7000-4000-8000-000000000002'::uuid,
    '55060000-3000-4000-8000-000000000002'::uuid,
    1,
    '55060000-4000-4000-8000-000000000101'::uuid,
    null,
    '55060000-4000-4000-8000-000000000111'::uuid,
    null,
    '55060000-1000-4000-8000-000000000004'::uuid,
    now() - interval '1 minute',
    'TEST 006 lifecycle establishment for Resident Two report',
    '55060000-6000-4000-8000-000000000003'::uuid
);

insert into public.report_lifecycle_states (
    report_id,
    lifecycle_version_id,
    current_status_id,
    status_changed_by,
    source_history_id
)
values
(
    '55060000-3000-4000-8000-000000000001'::uuid,
    '55060000-4000-4000-8000-000000000101'::uuid,
    '55060000-4000-4000-8000-000000000111'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    '55060000-7000-4000-8000-000000000001'::uuid
),
(
    '55060000-3000-4000-8000-000000000002'::uuid,
    '55060000-4000-4000-8000-000000000101'::uuid,
    '55060000-4000-4000-8000-000000000111'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    '55060000-7000-4000-8000-000000000002'::uuid
);


-- ----------------------------------------------------------------------------
-- I7. Append-only routing history, then current routing snapshots
-- ----------------------------------------------------------------------------

insert into public.report_routing_history (
    id,
    report_id,
    sequence_number,
    taxonomy_version_id,
    routing_version_id,
    destination_id,
    routed_by,
    routed_at,
    routing_note,
    audit_event_id
)
values
(
    '55060000-8000-4000-8000-000000000001'::uuid,
    '55060000-3000-4000-8000-000000000001'::uuid,
    1,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000111'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    now() - interval '2 minutes',
    'TEST 006 routing establishment for Resident One report',
    '55060000-6000-4000-8000-000000000002'::uuid
),
(
    '55060000-8000-4000-8000-000000000002'::uuid,
    '55060000-3000-4000-8000-000000000002'::uuid,
    1,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000111'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    now() - interval '1 minute',
    'TEST 006 routing establishment for Resident Two report',
    '55060000-6000-4000-8000-000000000004'::uuid
);

insert into public.report_routing_states (
    report_id,
    taxonomy_version_id,
    routing_version_id,
    destination_id,
    routed_by,
    source_history_id
)
values
(
    '55060000-3000-4000-8000-000000000001'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000111'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    '55060000-8000-4000-8000-000000000001'::uuid
),
(
    '55060000-3000-4000-8000-000000000002'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000101'::uuid,
    '55060000-5000-4000-8000-000000000111'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    '55060000-8000-4000-8000-000000000002'::uuid
);


-- ============================================================================
-- J. RLS BEHAVIOR
-- ============================================================================


-- ----------------------------------------------------------------------------
-- J1. Approved Resident One
-- ----------------------------------------------------------------------------

set local role authenticated;

set local request.jwt.claim.sub =
    '55060000-1000-4000-8000-000000000001';


-- 24. Resident One sees exactly one row from each operational table.
select results_eq(
    $$
        select
            (select count(*) from public.report_lifecycle_states),
            (select count(*) from public.report_status_history),
            (select count(*) from public.report_routing_states),
            (select count(*) from public.report_routing_history)
    $$,
    $$
        values (
            1::bigint,
            1::bigint,
            1::bigint,
            1::bigint
        )
    $$,
    'approved Resident One sees exactly one own row in each operational table'
);


-- 25. The visible lifecycle state belongs to Resident One's exact report.
select results_eq(
    $$
        select report_id::text
        from public.report_lifecycle_states
    $$,
    $$
        values (
            '55060000-3000-4000-8000-000000000001'
        )
    $$,
    'approved Resident One sees only lifecycle state for Resident One report'
);


-- ----------------------------------------------------------------------------
-- J2. Approved Resident Two
-- ----------------------------------------------------------------------------

set local request.jwt.claim.sub =
    '55060000-1000-4000-8000-000000000002';


-- 26. Resident Two sees exactly one row from each operational table.
select results_eq(
    $$
        select
            (select count(*) from public.report_lifecycle_states),
            (select count(*) from public.report_status_history),
            (select count(*) from public.report_routing_states),
            (select count(*) from public.report_routing_history)
    $$,
    $$
        values (
            1::bigint,
            1::bigint,
            1::bigint,
            1::bigint
        )
    $$,
    'approved Resident Two sees exactly one own row in each operational table'
);


-- 27. The visible lifecycle state belongs to Resident Two's exact report.
select results_eq(
    $$
        select report_id::text
        from public.report_lifecycle_states
    $$,
    $$
        values (
            '55060000-3000-4000-8000-000000000002'
        )
    $$,
    'approved Resident Two sees only lifecycle state for Resident Two report'
);


-- ----------------------------------------------------------------------------
-- J3. Pending Resident
-- ----------------------------------------------------------------------------

set local request.jwt.claim.sub =
    '55060000-1000-4000-8000-000000000003';


-- 28. Pending Resident sees no operational records.
select results_eq(
    $$
        select
            (select count(*) from public.report_lifecycle_states),
            (select count(*) from public.report_status_history),
            (select count(*) from public.report_routing_states),
            (select count(*) from public.report_routing_history)
    $$,
    $$
        values (
            0::bigint,
            0::bigint,
            0::bigint,
            0::bigint
        )
    $$,
    'pending Resident sees no Task 04.6 operational tracking records'
);


-- ----------------------------------------------------------------------------
-- J4. Approved Barangay Administrator
-- ----------------------------------------------------------------------------

set local request.jwt.claim.sub =
    '55060000-1000-4000-8000-000000000004';


-- 29. Approved Administrator sees both synthetic reports in all four tables.
select results_eq(
    $$
        select
            (select count(*) from public.report_lifecycle_states),
            (select count(*) from public.report_status_history),
            (select count(*) from public.report_routing_states),
            (select count(*) from public.report_routing_history)
    $$,
    $$
        values (
            2::bigint,
            2::bigint,
            2::bigint,
            2::bigint
        )
    $$,
    'approved Barangay Administrator sees complete synthetic operational fixture'
);


reset role;


-- ============================================================================
-- K. ANONYMOUS AND DIRECT-CLIENT SECURITY BOUNDARY
-- ============================================================================


-- ----------------------------------------------------------------------------
-- K1. Anonymous read denial
-- ----------------------------------------------------------------------------

set local role anon;

set local request.jwt.claim.sub =
    '00000000-0000-0000-0000-000000000000';


-- 30. Anonymous clients cannot read operational lifecycle state.
select throws_like(
    $$
        select *
        from public.report_lifecycle_states
    $$,
    '%permission denied%report_lifecycle_states%',
    'anonymous client cannot SELECT report lifecycle state'
);


reset role;


-- ----------------------------------------------------------------------------
-- K2. Authenticated configuration read denial
-- ----------------------------------------------------------------------------

set local role authenticated;

set local request.jwt.claim.sub =
    '55060000-1000-4000-8000-000000000001';


-- 31. Residents cannot directly read protected lifecycle configuration.
select throws_like(
    $$
        select *
        from public.report_status_definitions
    $$,
    '%permission denied%report_status_definitions%',
    'authenticated Resident cannot directly SELECT lifecycle configuration'
);


-- ----------------------------------------------------------------------------
-- K3. Authenticated operational mutation denial
-- ----------------------------------------------------------------------------

-- 32. Residents cannot directly create lifecycle current-state rows.
select throws_like(
    $$
        insert into public.report_lifecycle_states (
            report_id,
            lifecycle_version_id,
            current_status_id,
            status_changed_by,
            source_history_id
        )
        values (
            '55060000-3000-4000-8000-000000000001'::uuid,
            '55060000-4000-4000-8000-000000000101'::uuid,
            '55060000-4000-4000-8000-000000000111'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            '55060000-7000-4000-8000-000000000001'::uuid
        )
    $$,
    '%permission denied%report_lifecycle_states%',
    'authenticated Resident cannot directly INSERT report lifecycle state'
);


-- 33. Residents cannot directly append lifecycle history.
select throws_like(
    $$
        insert into public.report_status_history (
            id,
            report_id,
            sequence_number,
            lifecycle_version_id,
            from_status_id,
            to_status_id,
            transition_id,
            changed_by,
            change_note,
            audit_event_id
        )
        values (
            '55060000-7000-4000-8000-000000000099'::uuid,
            '55060000-3000-4000-8000-000000000001'::uuid,
            2,
            '55060000-4000-4000-8000-000000000101'::uuid,
            '55060000-4000-4000-8000-000000000111'::uuid,
            '55060000-4000-4000-8000-000000000111'::uuid,
            null,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY direct status-history mutation attempt',
            '55060000-6000-4000-8000-000000000001'::uuid
        )
    $$,
    '%permission denied%report_status_history%',
    'authenticated Resident cannot directly INSERT report status history'
);


-- 34. Residents cannot directly create routing current-state rows.
select throws_like(
    $$
        insert into public.report_routing_states (
            report_id,
            taxonomy_version_id,
            routing_version_id,
            destination_id,
            routed_by,
            source_history_id
        )
        values (
            '55060000-3000-4000-8000-000000000001'::uuid,
            '55060000-2000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000111'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            '55060000-8000-4000-8000-000000000001'::uuid
        )
    $$,
    '%permission denied%report_routing_states%',
    'authenticated Resident cannot directly INSERT report routing state'
);


-- 35. Residents cannot directly append routing history.
select throws_like(
    $$
        insert into public.report_routing_history (
            id,
            report_id,
            sequence_number,
            taxonomy_version_id,
            routing_version_id,
            destination_id,
            routed_by,
            routing_note,
            audit_event_id
        )
        values (
            '55060000-8000-4000-8000-000000000099'::uuid,
            '55060000-3000-4000-8000-000000000001'::uuid,
            2,
            '55060000-2000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000111'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY direct routing-history mutation attempt',
            '55060000-6000-4000-8000-000000000002'::uuid
        )
    $$,
    '%permission denied%report_routing_history%',
    'authenticated Resident cannot directly INSERT report routing history'
);


reset role;


-- ============================================================================
-- L. DATABASE INTEGRITY ENFORCEMENT
-- ============================================================================


-- 36. One lifecycle version cannot define two initial statuses.
select throws_like(
    $$
        insert into public.report_status_definitions (
            id,
            lifecycle_version_id,
            code,
            name,
            display_order,
            is_enabled,
            is_initial
        )
        values (
            '55060000-4000-4000-8000-000000000112'::uuid,
            '55060000-4000-4000-8000-000000000101'::uuid,
            'TEST006_SECOND_INITIAL',
            'Test 006 Second Initial Status',
            2,
            true,
            true
        )
    $$,
    '%duplicate key value violates unique constraint "uq_report_status_definitions_one_initial"%',
    'one lifecycle version cannot contain two initial statuses'
);


-- 37. Existing lifecycle history is append-only and cannot be updated.
select throws_like(
    $$
        update public.report_status_history
        set change_note = 'TEST ONLY forbidden status-history rewrite'
        where id = '55060000-7000-4000-8000-000000000001'::uuid
    $$,
    '%HelpHub report status history is append-only and cannot be updated or deleted%',
    'existing report status history cannot be updated'
);


-- 38. Existing lifecycle history is append-only and cannot be deleted.
select throws_like(
    $$
        delete from public.report_status_history
        where id = '55060000-7000-4000-8000-000000000001'::uuid
    $$,
    '%HelpHub report status history is append-only and cannot be updated or deleted%',
    'existing report status history cannot be deleted'
);


-- 39. Existing routing history is append-only and cannot be updated.
select throws_like(
    $$
        update public.report_routing_history
        set routing_note = 'TEST ONLY forbidden routing-history rewrite'
        where id = '55060000-8000-4000-8000-000000000001'::uuid
    $$,
    '%HelpHub report routing history is append-only and cannot be updated or deleted%',
    'existing report routing history cannot be updated'
);

-- ============================================================================
-- M. DEEPER RELATIONAL-INTEGRITY ENFORCEMENT
-- ============================================================================
--
-- Additional lifecycle/routing values below are TEST-ONLY draft fixtures.
-- They do not define production HelpHub workflow or routing configuration.
-- ============================================================================


-- ----------------------------------------------------------------------------
-- M1. Additional test-only configuration required for mismatch tests
-- ----------------------------------------------------------------------------

insert into public.report_lifecycle_versions (
    id,
    version_number,
    version_label,
    created_by
)
values (
    '55060000-4000-4000-8000-000000000102'::uuid,
    607,
    'TEST 006 SECOND LIFECYCLE',
    '55060000-1000-4000-8000-000000000004'::uuid
);

insert into public.report_status_definitions (
    id,
    lifecycle_version_id,
    code,
    name,
    display_order,
    is_enabled,
    is_initial
)
values (
    '55060000-4000-4000-8000-000000000112'::uuid,
    '55060000-4000-4000-8000-000000000102'::uuid,
    'TEST006_OTHER_LIFECYCLE_STATUS',
    'Test 006 Other Lifecycle Status',
    1,
    true,
    false
);

insert into public.routing_config_versions (
    id,
    taxonomy_version_id,
    version_number,
    version_label,
    created_by
)
values (
    '55060000-5000-4000-8000-000000000102'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    607,
    'TEST 006 SECOND ROUTING',
    '55060000-1000-4000-8000-000000000004'::uuid
);

insert into public.routing_destinations (
    id,
    routing_version_id,
    code,
    name,
    destination_kind,
    display_order,
    is_enabled
)
values (
    '55060000-5000-4000-8000-000000000112'::uuid,
    '55060000-5000-4000-8000-000000000102'::uuid,
    'TEST006_SECOND_INTERNAL',
    'Test 006 Second Internal Destination',
    'internal_handler',
    1,
    true
);

-- A third raw report gives the cross-lifecycle rejection test a report
-- that has no existing lifecycle-establishment history.
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
    '55060000-3000-4000-8000-000000000003'::uuid,
    '55060000-1000-4000-8000-000000000001'::uuid,
    '55060000-2000-4000-8000-000000000101'::uuid,
    '55060000-2000-4000-8000-000000000111'::uuid,
    'Synthetic Task 04.6 target for lifecycle mismatch testing.',
    'TEST006_URGENCY_ONLY',
    1,
    false
);

insert into public.audit_events (
    id,
    actor_id,
    action,
    entity_type,
    entity_id,
    details
)
values
(
    '55060000-6000-4000-8000-000000000005'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_INVALID_SEQUENCE',
    'report_status_history',
    '55060000-3000-4000-8000-000000000001'::uuid,
    jsonb_build_object('test_fixture', '006', 'purpose', 'invalid-sequence')
),
(
    '55060000-6000-4000-8000-000000000006'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_CROSS_LIFECYCLE',
    'report_status_history',
    '55060000-3000-4000-8000-000000000003'::uuid,
    jsonb_build_object('test_fixture', '006', 'purpose', 'cross-lifecycle')
),
(
    '55060000-6000-4000-8000-000000000007'::uuid,
    '55060000-1000-4000-8000-000000000004'::uuid,
    'TEST006_DESTINATION_MISMATCH',
    'report_routing_history',
    '55060000-3000-4000-8000-000000000001'::uuid,
    jsonb_build_object('test_fixture', '006', 'purpose', 'destination-version')
);


-- 40. Existing routing history is append-only and cannot be deleted.
select throws_like(
    $$
        delete from public.report_routing_history
        where id = '55060000-8000-4000-8000-000000000001'::uuid
    $$,
    '%HelpHub report routing history is append-only and cannot be updated or deleted%',
    'existing report routing history cannot be deleted'
);


-- 41. sequence_number > 1 cannot use initial-establishment NULL fields.
select throws_like(
    $$
        insert into public.report_status_history (
            id,
            report_id,
            sequence_number,
            lifecycle_version_id,
            from_status_id,
            to_status_id,
            transition_id,
            changed_by,
            change_note,
            audit_event_id
        )
        values (
            '55060000-7000-4000-8000-000000000091'::uuid,
            '55060000-3000-4000-8000-000000000001'::uuid,
            2,
            '55060000-4000-4000-8000-000000000101'::uuid,
            null,
            '55060000-4000-4000-8000-000000000111'::uuid,
            null,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY invalid later-history row',
            '55060000-6000-4000-8000-000000000005'::uuid
        )
    $$,
    '%check constraint "chk_report_status_history_sequence_role"%',
    'later lifecycle history cannot use initial-establishment structure'
);


-- 42. A status belonging to another lifecycle version is rejected.
select throws_like(
    $$
        insert into public.report_status_history (
            id,
            report_id,
            sequence_number,
            lifecycle_version_id,
            from_status_id,
            to_status_id,
            transition_id,
            changed_by,
            change_note,
            audit_event_id
        )
        values (
            '55060000-7000-4000-8000-000000000092'::uuid,
            '55060000-3000-4000-8000-000000000003'::uuid,
            1,
            '55060000-4000-4000-8000-000000000101'::uuid,
            null,
            '55060000-4000-4000-8000-000000000112'::uuid,
            null,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY cross-lifecycle status attempt',
            '55060000-6000-4000-8000-000000000006'::uuid
        )
    $$,
    '%foreign key constraint "fk_report_status_history_to_status_version"%',
    'status history rejects a TO status from another lifecycle version'
);


-- 43. A destination from another routing version is rejected.
select throws_like(
    $$
        insert into public.report_routing_history (
            id,
            report_id,
            sequence_number,
            taxonomy_version_id,
            routing_version_id,
            destination_id,
            routed_by,
            routing_note,
            audit_event_id
        )
        values (
            '55060000-8000-4000-8000-000000000091'::uuid,
            '55060000-3000-4000-8000-000000000001'::uuid,
            2,
            '55060000-2000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000112'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY routing destination/version mismatch',
            '55060000-6000-4000-8000-000000000007'::uuid
        )
    $$,
    '%foreign key constraint "fk_report_routing_history_destination_version"%',
    'routing history rejects a destination from another routing version'
);

-- ============================================================================
-- N. SNAPSHOT / HISTORY / AUDIT TRACEABILITY ENFORCEMENT
-- ============================================================================


-- 44. A lifecycle snapshot cannot claim another report's history event.
select throws_like(
    $$
        insert into public.report_lifecycle_states (
            report_id,
            lifecycle_version_id,
            current_status_id,
            status_changed_by,
            source_history_id
        )
        values (
            '55060000-3000-4000-8000-000000000003'::uuid,
            '55060000-4000-4000-8000-000000000101'::uuid,
            '55060000-4000-4000-8000-000000000111'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            '55060000-7000-4000-8000-000000000001'::uuid
        )
    $$,
    '%foreign key constraint "fk_report_lifecycle_states_source_history"%',
    'lifecycle snapshot rejects source history belonging to another report'
);


-- 45. A routing snapshot cannot claim another report's routing-history event.
select throws_like(
    $$
        insert into public.report_routing_states (
            report_id,
            taxonomy_version_id,
            routing_version_id,
            destination_id,
            routed_by,
            source_history_id
        )
        values (
            '55060000-3000-4000-8000-000000000003'::uuid,
            '55060000-2000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000111'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            '55060000-8000-4000-8000-000000000001'::uuid
        )
    $$,
    '%foreign key constraint "fk_report_routing_states_source_history"%',
    'routing snapshot rejects source history belonging to another report'
);


-- 46. One audit event cannot represent two status-history events.
select throws_like(
    $$
        insert into public.report_status_history (
            id,
            report_id,
            sequence_number,
            lifecycle_version_id,
            from_status_id,
            to_status_id,
            transition_id,
            changed_by,
            change_note,
            audit_event_id
        )
        values (
            '55060000-7000-4000-8000-000000000093'::uuid,
            '55060000-3000-4000-8000-000000000003'::uuid,
            1,
            '55060000-4000-4000-8000-000000000101'::uuid,
            null,
            '55060000-4000-4000-8000-000000000111'::uuid,
            null,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY duplicate status-history audit linkage',
            '55060000-6000-4000-8000-000000000001'::uuid
        )
    $$,
    '%duplicate key value violates unique constraint "uq_report_status_history_audit_event"%',
    'one audit event cannot be reused by multiple status-history events'
);


-- 47. One audit event cannot represent two routing-history events.
select throws_like(
    $$
        insert into public.report_routing_history (
            id,
            report_id,
            sequence_number,
            taxonomy_version_id,
            routing_version_id,
            destination_id,
            routed_by,
            routing_note,
            audit_event_id
        )
        values (
            '55060000-8000-4000-8000-000000000093'::uuid,
            '55060000-3000-4000-8000-000000000003'::uuid,
            1,
            '55060000-2000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000101'::uuid,
            '55060000-5000-4000-8000-000000000111'::uuid,
            '55060000-1000-4000-8000-000000000004'::uuid,
            'TEST ONLY duplicate routing-history audit linkage',
            '55060000-6000-4000-8000-000000000002'::uuid
        )
    $$,
    '%duplicate key value violates unique constraint "uq_report_routing_history_audit_event"%',
    'one audit event cannot be reused by multiple routing-history events'
);

-- ============================================================================
-- FINISH
-- ============================================================================
select * from finish();

rollback;
