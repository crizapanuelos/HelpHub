-- HelpHub
-- Automated administrator verification-review regression tests
-- File: 003_admin_verification_review.test.sql
--
-- Task 04.3
--
-- Purpose:
--   Verify the administrator authorization, resident-verification
--   review workflow, audit ledger, RLS policies, execution privileges,
--   and transactional safety introduced by:
--
--   20260814050812_create_admin_verification_review_foundation.sql
--
-- This suite complements:
--
--   001_identity_foundation.test.sql
--   002_identity_rls_behavior.test.sql
--
-- All synthetic records exist only inside this transaction.
-- ROLLBACK removes them after the assertions complete.

begin;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(50);


-- ============================================================
-- A. STRUCTURAL AND SECURITY BASELINE
-- ============================================================

-- 01. Audit table exists.
select ok(
    to_regclass('public.audit_events') is not null,
    'public.audit_events exists'
);

-- 02. Approved-administrator helper exists.
select ok(
    to_regprocedure(
        'public.is_approved_barangay_admin()'
    ) is not null,
    'approved Barangay Administrator helper exists'
);

-- 03. Protected review function exists.
select ok(
    to_regprocedure(
        'public.review_resident_verification(uuid,uuid,text)'
    ) is not null,
    'protected resident verification review function exists'
);

-- 04. Append-only audit guard exists.
select ok(
    to_regprocedure(
        'public.prevent_audit_event_mutation()'
    ) is not null,
    'audit append-only guard function exists'
);

-- 05. RLS is enabled on the audit ledger.
select ok(
    (
        select c.relrowsecurity
        from pg_catalog.pg_class as c
        where c.oid = 'public.audit_events'::regclass
    ),
    'RLS is enabled on public.audit_events'
);

-- 06. Both administrator-read policies exist.
select results_eq(
    $$
        select count(*)::bigint
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and policyname in (
              'profiles_select_approved_admin_residents',
              'resident_verifications_select_approved_admin'
          )
    $$,
    array[2::bigint],
    'both approved-administrator read policies exist'
);

-- 07. Audit ledger intentionally has no client-facing RLS policies.
select results_eq(
    $$
        select count(*)::bigint
        from pg_catalog.pg_policies
        where schemaname = 'public'
          and tablename = 'audit_events'
    $$,
    array[0::bigint],
    'audit_events has no client-facing RLS policy'
);

-- 08. Authenticated users may execute the boolean admin helper.
select ok(
    has_function_privilege(
        'authenticated',
        'public.is_approved_barangay_admin()',
        'EXECUTE'
    ),
    'authenticated may execute approved-admin helper'
);

-- 09. Authenticated users must not execute the protected review RPC.
select ok(
    not has_function_privilege(
        'authenticated',
        'public.review_resident_verification(uuid,uuid,text)',
        'EXECUTE'
    ),
    'authenticated cannot execute protected review function'
);

-- 10. service_role may execute the protected review operation.
select ok(
    has_function_privilege(
        'service_role',
        'public.review_resident_verification(uuid,uuid,text)',
        'EXECUTE'
    ),
    'service_role may execute protected review function'
);

-- 11. Authenticated users cannot directly read audit evidence.
select ok(
    not has_table_privilege(
        'authenticated',
        'public.audit_events',
        'SELECT'
    ),
    'authenticated cannot directly SELECT audit_events'
);

-- 12. Authenticated users cannot directly append audit evidence.
select ok(
    not has_table_privilege(
        'authenticated',
        'public.audit_events',
        'INSERT'
    ),
    'authenticated cannot directly INSERT audit_events'
);

-- 13. service_role may inspect audit evidence.
select ok(
    has_table_privilege(
        'service_role',
        'public.audit_events',
        'SELECT'
    ),
    'service_role may SELECT audit_events'
);

-- 14. service_role may append audit evidence.
select ok(
    has_table_privilege(
        'service_role',
        'public.audit_events',
        'INSERT'
    ),
    'service_role may INSERT audit_events'
);

-- 15. service_role does not receive direct UPDATE privilege.
select ok(
    not has_table_privilege(
        'service_role',
        'public.audit_events',
        'UPDATE'
    ),
    'service_role has no direct UPDATE privilege on audit_events'
);

-- 16. service_role does not receive direct DELETE privilege.
select ok(
    not has_table_privilege(
        'service_role',
        'public.audit_events',
        'DELETE'
    ),
    'service_role has no direct DELETE privilege on audit_events'
);


-- ============================================================
-- B. APPEND-ONLY AUDIT BEHAVIOR
-- ============================================================

insert into public.audit_events (
    action,
    entity_type,
    entity_id,
    details
)
values (
    'test.audit.append_only',
    'test_entity',
    '01010101-0101-4101-8101-010101010101'::uuid,
    '{"source":"003_admin_verification_review"}'::jsonb
);

-- 17. Existing audit events cannot be updated.
select throws_like(
    $$
        update public.audit_events
        set action = 'test.audit.modified'
        where entity_id =
            '01010101-0101-4101-8101-010101010101'::uuid
    $$,
    '%append-only%cannot be updated or deleted%',
    'existing audit event cannot be updated'
);

-- 18. Existing audit events cannot be deleted.
select throws_like(
    $$
        delete from public.audit_events
        where entity_id =
            '01010101-0101-4101-8101-010101010101'::uuid
    $$,
    '%append-only%cannot be updated or deleted%',
    'existing audit event cannot be deleted'
);


-- ============================================================
-- C. SYNTHETIC IDENTITIES
-- ============================================================
--
-- Approved administrator
--   aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa
--
-- Pending administrator
--   bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb
--
-- Approved Resident used as unauthorized reviewer
--   cccccccc-cccc-4ccc-8ccc-cccccccccccc
--
-- Resident used for RLS visibility
--   dddddddd-dddd-4ddd-8ddd-dddddddddddd
--
-- Approval target
--   eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee
--
-- Rejection target
--   ffffffff-ffff-4fff-8fff-ffffffffffff
--
-- Shared negative-test target
--   11111111-2222-4111-8111-222222222222
--
-- Double-review target
--   33333333-4444-4333-8333-444444444444
--
-- Deliberately invalid non-Resident target
--   55555555-6666-4555-8555-666666666666

insert into auth.users (
    id,
    email,
    raw_user_meta_data
)
values
(
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
    'pgtap.admin.approved@helphub.test',
    '{"full_name":"pgTAP Approved Admin"}'::jsonb
),
(
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid,
    'pgtap.admin.pending@helphub.test',
    '{"full_name":"pgTAP Pending Admin"}'::jsonb
),
(
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc'::uuid,
    'pgtap.resident.approved@helphub.test',
    '{"full_name":"pgTAP Approved Resident"}'::jsonb
),
(
    'dddddddd-dddd-4ddd-8ddd-dddddddddddd'::uuid,
    'pgtap.resident.visibility@helphub.test',
    '{"full_name":"pgTAP Visibility Resident"}'::jsonb
),
(
    'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee'::uuid,
    'pgtap.resident.approve@helphub.test',
    '{"full_name":"pgTAP Approval Target"}'::jsonb
),
(
    'ffffffff-ffff-4fff-8fff-ffffffffffff'::uuid,
    'pgtap.resident.reject@helphub.test',
    '{"full_name":"pgTAP Rejection Target"}'::jsonb
),
(
    '11111111-2222-4111-8111-222222222222'::uuid,
    'pgtap.resident.negative@helphub.test',
    '{"full_name":"pgTAP Negative Target"}'::jsonb
),
(
    '33333333-4444-4333-8333-444444444444'::uuid,
    'pgtap.resident.double@helphub.test',
    '{"full_name":"pgTAP Double Review Target"}'::jsonb
),
(
    '55555555-6666-4555-8555-666666666666'::uuid,
    'pgtap.invalid.nonresident@helphub.test',
    '{"full_name":"pgTAP Invalid Non Resident"}'::jsonb
);


-- Establish authoritative HelpHub role/account states.

update public.profiles
set
    role = 'barangay_admin',
    account_status = 'approved'
where id =
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid;

update public.profiles
set
    role = 'barangay_admin',
    account_status = 'pending'
where id =
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid;

update public.profiles
set
    role = 'resident',
    account_status = 'approved'
where id =
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc'::uuid;

-- Deliberately invalid target for the atomicity test.
update public.profiles
set
    role = 'barangay_admin',
    account_status = 'pending'
where id =
    '55555555-6666-4555-8555-666666666666'::uuid;


-- Create one pending verification per target.

insert into public.resident_verifications (
    id,
    resident_id
)
values
(
    '10000000-0000-4000-8000-000000000001'::uuid,
    'dddddddd-dddd-4ddd-8ddd-dddddddddddd'::uuid
),
(
    '10000000-0000-4000-8000-000000000002'::uuid,
    'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee'::uuid
),
(
    '10000000-0000-4000-8000-000000000003'::uuid,
    'ffffffff-ffff-4fff-8fff-ffffffffffff'::uuid
),
(
    '10000000-0000-4000-8000-000000000004'::uuid,
    '11111111-2222-4111-8111-222222222222'::uuid
),
(
    '10000000-0000-4000-8000-000000000005'::uuid,
    '33333333-4444-4333-8333-444444444444'::uuid
),
(
    '10000000-0000-4000-8000-000000000006'::uuid,
    '55555555-6666-4555-8555-666666666666'::uuid
);


-- ============================================================
-- D. ADMIN AUTHORIZATION HELPER
-- ============================================================

set local role authenticated;


-- 19. Approved Barangay Administrator is authorized.
select set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

select ok(
    public.is_approved_barangay_admin(),
    'approved Barangay Administrator helper returns true'
);


-- 20. Pending Barangay Administrator is not authorized.
select set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

select ok(
    not public.is_approved_barangay_admin(),
    'pending Barangay Administrator helper returns false'
);


-- 21. Approved Resident is not an administrator.
select set_config(
    'request.jwt.claim.sub',
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    true
);

select ok(
    not public.is_approved_barangay_admin(),
    'approved Resident helper returns false'
);


-- ============================================================
-- E. RLS READ BEHAVIOR
-- ============================================================

-- Ordinary Resident identity.
select set_config(
    'request.jwt.claim.sub',
    'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
    true
);

-- 22. Ordinary Resident sees only their own profile.
select results_eq(
    $$
        select count(*)
        from public.profiles
    $$,
    array[1::bigint],
    'ordinary Resident sees exactly their own profile'
);

-- 23. Ordinary Resident sees only their own verification history.
select results_eq(
    $$
        select count(*)
        from public.resident_verifications
    $$,
    array[1::bigint],
    'ordinary Resident sees exactly their own verification history'
);


-- Approved Barangay Administrator identity.
select set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

-- 24. Approved administrator can read a Resident profile.
select results_eq(
    $$
        select count(*)
        from public.profiles
        where id =
            'dddddddd-dddd-4ddd-8ddd-dddddddddddd'::uuid
    $$,
    array[1::bigint],
    'approved administrator can read Resident profile'
);

-- 25. Approved administrator does not receive blanket access
--     to another administrator profile.
select is_empty(
    $$
        select id
        from public.profiles
        where id =
            'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid
    $$,
    'approved administrator cannot read another administrator through resident-wide policy'
);

-- 26. Approved administrator can read Resident verification queue data.
select results_eq(
    $$
        select count(*)
        from public.resident_verifications
        where id =
            '10000000-0000-4000-8000-000000000001'::uuid
    $$,
    array[1::bigint],
    'approved administrator can read Resident verification request'
);


-- Pending Barangay Administrator identity.
select set_config(
    'request.jwt.claim.sub',
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    true
);

-- 27. Pending administrator cannot read Resident profiles.
select is_empty(
    $$
        select id
        from public.profiles
        where id =
            'dddddddd-dddd-4ddd-8ddd-dddddddddddd'::uuid
    $$,
    'pending administrator cannot read Resident profile'
);

-- 28. Pending administrator cannot read verification queue.
select is_empty(
    $$
        select id
        from public.resident_verifications
        where id =
            '10000000-0000-4000-8000-000000000001'::uuid
    $$,
    'pending administrator cannot read Resident verification queue'
);


-- ============================================================
-- F. DIRECT CLIENT EXECUTION DENIAL
-- ============================================================

-- Restore the approved administrator JWT, but remain under the normal
-- authenticated PostgreSQL role.
select set_config(
    'request.jwt.claim.sub',
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    true
);

-- 29. Even an approved administrator cannot directly execute the
--     service-only review function as an authenticated client.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000004'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'approved'
        )
    $$,
    '%permission denied%review_resident_verification%',
    'authenticated client cannot directly execute protected review function'
);


-- ============================================================
-- G. SERVICE-ONLY NEGATIVE REVIEW CASES
-- ============================================================

reset role;
set local role service_role;


-- 30. Pending administrator cannot review.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000004'::uuid,
            'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'::uuid,
            'approved'
        )
    $$,
    '%requires an approved Barangay Administrator%',
    'pending administrator cannot review verification'
);

-- 31. Approved Resident cannot act as reviewer.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000004'::uuid,
            'cccccccc-cccc-4ccc-8ccc-cccccccccccc'::uuid,
            'approved'
        )
    $$,
    '%requires an approved Barangay Administrator%',
    'approved Resident cannot review verification'
);

-- 32. Unsupported review decision is rejected.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000004'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'cancelled'
        )
    $$,
    '%decision must be approved or rejected%',
    'unsupported verification decision is rejected'
);

reset role;

-- 33. All failed attempts above left the shared negative target
--     completely pending and produced no audit event.
select results_eq(
    $$
        select
            rv.status,
            rv.reviewed_at is null,
            rv.reviewed_by is null,
            p.account_status,
            (
                select count(*)
                from public.audit_events as ae
                where ae.entity_id = rv.id
            )
        from public.resident_verifications as rv
        join public.profiles as p
          on p.id = rv.resident_id
        where rv.id =
            '10000000-0000-4000-8000-000000000004'::uuid
    $$,
    $$
        values (
            'pending'::text,
            true,
            true,
            'pending'::text,
            0::bigint
        )
    $$,
    'failed review attempts create no partial state or audit evidence'
);


-- ============================================================
-- H. MISSING VERIFICATION
-- ============================================================

set local role service_role;

-- 34. A nonexistent verification ID is rejected.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '99999999-9999-4999-8999-999999999999'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'approved'
        )
    $$,
    '%verification request was not found%',
    'nonexistent verification request is rejected'
);


-- ============================================================
-- I. APPROVAL HAPPY PATH
-- ============================================================

-- 35. Approved administrator may approve a pending verification.
select lives_ok(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000002'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'approved'
        )
    $$,
    'approved administrator can approve pending verification'
);

reset role;

-- 36. Verification decision and reviewer metadata are synchronized.
select results_eq(
    $$
        select
            status,
            reviewed_at is not null,
            reviewed_by =
                'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid
        from public.resident_verifications
        where id =
            '10000000-0000-4000-8000-000000000002'::uuid
    $$,
    $$
        values (
            'approved'::text,
            true,
            true
        )
    $$,
    'approval stores approved status and reviewer metadata'
);

-- 37. Approval updates the Resident account state.
select results_eq(
    $$
        select account_status
        from public.profiles
        where id =
            'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee'::uuid
    $$,
    array['approved'::text],
    'approval updates Resident account status to approved'
);

-- 38. Approval creates exactly one matching audit event.
select results_eq(
    $$
        select
            count(*)::bigint,
            min(action),
            min(details ->> 'decision')
        from public.audit_events
        where entity_id =
            '10000000-0000-4000-8000-000000000002'::uuid
    $$,
    $$
        values (
            1::bigint,
            'resident_verification.reviewed'::text,
            'approved'::text
        )
    $$,
    'approval creates one correct audit event'
);


-- ============================================================
-- J. REJECTION HAPPY PATH
-- ============================================================

set local role service_role;

-- 39. Approved administrator may reject a pending verification.
select lives_ok(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000003'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'rejected'
        )
    $$,
    'approved administrator can reject pending verification'
);

reset role;

-- 40. Rejection stores status and reviewer metadata.
select results_eq(
    $$
        select
            status,
            reviewed_at is not null,
            reviewed_by =
                'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid
        from public.resident_verifications
        where id =
            '10000000-0000-4000-8000-000000000003'::uuid
    $$,
    $$
        values (
            'rejected'::text,
            true,
            true
        )
    $$,
    'rejection stores rejected status and reviewer metadata'
);

-- 41. Rejection updates Resident account state.
select results_eq(
    $$
        select account_status
        from public.profiles
        where id =
            'ffffffff-ffff-4fff-8fff-ffffffffffff'::uuid
    $$,
    array['rejected'::text],
    'rejection updates Resident account status to rejected'
);

-- 42. Rejection creates exactly one matching audit event.
select results_eq(
    $$
        select
            count(*)::bigint,
            min(action),
            min(details ->> 'decision')
        from public.audit_events
        where entity_id =
            '10000000-0000-4000-8000-000000000003'::uuid
    $$,
    $$
        values (
            1::bigint,
            'resident_verification.reviewed'::text,
            'rejected'::text
        )
    $$,
    'rejection creates one correct audit event'
);


-- ============================================================
-- K. COMPLETED REQUEST CANNOT BE REVIEWED TWICE
-- ============================================================

set local role service_role;

-- 43. First review succeeds.
select lives_ok(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000005'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'approved'
        )
    $$,
    'first review of pending verification succeeds'
);

-- 44. Second review of the same request is rejected.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000005'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'rejected'
        )
    $$,
    '%verification request is no longer pending%',
    'completed verification cannot be reviewed a second time'
);

reset role;

-- 45. Original approved state remains intact.
select results_eq(
    $$
        select
            rv.status,
            rv.reviewed_at is not null,
            p.account_status
        from public.resident_verifications as rv
        join public.profiles as p
          on p.id = rv.resident_id
        where rv.id =
            '10000000-0000-4000-8000-000000000005'::uuid
    $$,
    $$
        values (
            'approved'::text,
            true,
            'approved'::text
        )
    $$,
    'failed second review does not overwrite first decision'
);

-- 46. Exactly one audit event remains for the completed review.
select results_eq(
    $$
        select
            count(*)::bigint,
            min(details ->> 'decision')
        from public.audit_events
        where entity_id =
            '10000000-0000-4000-8000-000000000005'::uuid
    $$,
    $$
        values (
            1::bigint,
            'approved'::text
        )
    $$,
    'failed second review does not create duplicate audit evidence'
);


-- ============================================================
-- L. TRANSACTIONAL ATOMICITY
-- ============================================================
--
-- The target of verification 000006 deliberately has:
--
--   role = barangay_admin
--   account_status = pending
--
-- The review function updates the verification before validating that
-- its target is actually a Resident profile.
--
-- Therefore this failure proves PostgreSQL rolls the earlier write
-- back when a later step fails.

set local role service_role;

-- 47. Invalid non-Resident verification target causes failure.
select throws_like(
    $$
        select *
        from public.review_resident_verification(
            '10000000-0000-4000-8000-000000000006'::uuid,
            'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'::uuid,
            'approved'
        )
    $$,
    '%verification target is not a valid Resident profile%',
    'invalid non-Resident target causes review failure'
);

reset role;

-- 48. Earlier verification UPDATE was rolled back.
select results_eq(
    $$
        select
            status,
            reviewed_at is null,
            reviewed_by is null
        from public.resident_verifications
        where id =
            '10000000-0000-4000-8000-000000000006'::uuid
    $$,
    $$
        values (
            'pending'::text,
            true,
            true
        )
    $$,
    'failed later validation rolls back earlier verification update'
);

-- 49. Invalid target profile itself remains unchanged.
select results_eq(
    $$
        select
            role,
            account_status
        from public.profiles
        where id =
            '55555555-6666-4555-8555-666666666666'::uuid
    $$,
    $$
        values (
            'barangay_admin'::text,
            'pending'::text
        )
    $$,
    'failed atomic review leaves target profile unchanged'
);

-- 50. Failed atomic review creates no audit event.
select results_eq(
    $$
        select count(*)
        from public.audit_events
        where entity_id =
            '10000000-0000-4000-8000-000000000006'::uuid
    $$,
    array[0::bigint],
    'failed atomic review creates no audit evidence'
);


-- ============================================================
-- FINISH
-- ============================================================

reset role;

select * from finish();

rollback;