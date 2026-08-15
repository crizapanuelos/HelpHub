# HelpHub — Concern Taxonomy and Routing Foundation Test Evidence

## 1. Purpose

This document records local implementation and verification evidence for HelpHub Task 04.4: Concern Taxonomy and Handler/Routing Foundation.

The evidence is based on executed PostgreSQL/Supabase compilation tests, transactional rollback tests, compatibility tests, Row Level Security checks, privilege checks, migration application, migration-history verification, and pgTAP regression tests.

This document records verified local development evidence only.

It does not claim:

- production deployment;
- hosted Supabase deployment;
- external stakeholder approval;
- final barangay-approved concern categories;
- final routing assignments;
- final emergency-handler assignments;
- final priority thresholds;
- final response deadlines.


## 2. Task Identification

Phase:

Stage 4 — Supabase Schema, Migrations, Auth, Storage, and RLS

Sprint:

Sprint 4A — Database Foundation

Task:

04.4 — Concern Taxonomy and Handler/Routing Foundation

Primary migration:

supabase/migrations/20260814110829_create_concern_taxonomy_and_handler_foundation.sql

Primary automated test:

supabase/tests/004_concern_taxonomy_routing_foundation.test.sql

Related existing automated tests:

- supabase/tests/001_identity_foundation.test.sql
- supabase/tests/002_identity_rls_behavior.test.sql
- supabase/tests/003_admin_verification_review.test.sql


## 3. Scope Implemented

Task 04.4 establishes the database-side foundation for:

1. Versioned concern-taxonomy configuration.
2. Versioned concern-type configuration.
3. Versioned routing configuration.
4. Versioned routing destinations.
5. Concern-type to routing-destination mappings.
6. Compatibility enforcement between taxonomy and routing versions.
7. Single-active-version controls.
8. Resident-facing taxonomy read access.
9. Administrator configuration read access.
10. Explicit least-privilege table privileges.
11. Row Level Security protection.
12. Regression tests for structural, behavioral, compatibility, and access-control requirements.

Task 04.4 deliberately does not seed final concern categories, handlers, or routing mappings.


## 4. Concern Taxonomy Version Foundation

The migration creates:

public.concern_taxonomy_versions

The table provides the versioned configuration foundation for concern taxonomy snapshots.

The implemented design includes version-related information and lifecycle state so configuration can be preserved historically rather than silently overwritten.

The migration supports draft, active, and retired lifecycle behavior through activation and retirement fields.

Historical taxonomy records are intended to remain available for reproducibility.


## 5. Concern Type Foundation

The migration creates:

public.concern_types

Each concern type belongs to one concern-taxonomy version.

The table provides configuration fields including:

- taxonomy version relationship;
- code;
- name;
- optional description;
- display order;
- enabled state.

The migration does not contain final concern-type seed data.

Therefore Task 04.4 creates the mechanism for versioned concern types without inventing final categories that have not yet been formally configured.


## 6. Routing Configuration Version Foundation

The migration creates:

public.routing_config_versions

Each routing configuration is associated with a specific concern-taxonomy version.

This relationship makes it possible to preserve routing configuration together with the taxonomy for which the routing rules were designed.

The table supports version lifecycle data and prevents routing configuration from being treated as an unversioned mutable global setting.


## 7. Routing Destination Foundation

The migration creates:

public.routing_destinations

Routing destinations represent versioned configured destinations that may later be used for:

- internal Barangay handling; or
- external manual referral.

The implemented destination-kind model distinguishes:

internal_handler

and:

external_referral

This does not create external system integrations.

External destinations remain routing/referral configuration only.


## 8. Concern-Type Routing Map

The migration creates:

public.concern_type_routes

This table maps a versioned concern type to a configured routing destination under a routing configuration version.

The mapping includes compatibility fields for:

- routing version;
- taxonomy version;
- concern type;
- destination.

The repeated version identifiers are intentional because they allow PostgreSQL composite foreign keys to enforce cross-version compatibility directly in the database.


## 9. Routing Compatibility Keys

The database exposes compatibility keys required by the routing map.

Verified compatibility constraints include:

- uq_concern_types_id_taxonomy
- uq_routing_config_versions_id_taxonomy
- uq_routing_destinations_id_version

These keys allow the routing-map foreign keys to verify that referenced records belong to the expected configuration versions.


## 10. Routing Compatibility Foreign Keys

The routing map includes the following verified foreign-key protections:

- fk_concern_type_routes_routing_taxonomy
- fk_concern_type_routes_concern_taxonomy
- fk_concern_type_routes_destination_version

These constraints enforce the following requirements.

A routing configuration must belong to the taxonomy version recorded by the route.

A concern type must belong to the taxonomy version recorded by the route.

A routing destination must belong to the routing version recorded by the route.

This provides database-side protection against accidental cross-version configuration.


## 11. Duplicate Route Prevention

The migration includes:

uq_concern_type_routes_version_concern

This constraint prevents one concern type from receiving multiple destination mappings inside the same routing configuration version.

The constraint was verified structurally and behaviorally.


## 12. Single-Active-Version Controls

The migration includes single-active-version unique indexes for taxonomy and routing configuration.

Verified indexes include:

- uq_concern_taxonomy_versions_one_active
- uq_routing_config_versions_one_active

These controls support the rule that only one configuration version in each applicable configuration domain may be active at a time.


## 13. No Seed Configuration

The Task 04.4 migration was repeatedly checked for INSERT statements.

Verified result:

No final concern taxonomy data is seeded.

No final concern types are seeded.

No final routing destinations are seeded.

No final concern-to-routing mappings are seeded.

The synthetic values used during testing exist only inside test transactions and are rolled back.

This preserves the project rule that final categories, handlers, and routing assignments must not be invented during engineering implementation.


## 14. Row Level Security Baseline

Row Level Security is enabled on all five Task 04.4 configuration tables:

- public.concern_taxonomy_versions
- public.concern_types
- public.routing_config_versions
- public.routing_destinations
- public.concern_type_routes

The RLS baseline was first compiled without policies to establish deny-by-default protection before selective read access was introduced.


## 15. Resident Taxonomy Read Policies

Two Resident-facing SELECT policies were implemented:

concern_taxonomy_versions_select_approved_resident_active

concern_types_select_approved_resident_active_enabled

The Resident policy logic requires an authoritative profile with:

role = resident

and:

account_status = approved

Approved Residents may read only:

- the active concern-taxonomy version; and
- enabled concern types belonging to the active taxonomy.

Approved Residents are not given routing configuration policies.


## 16. Resident Routing Privacy Boundary

No Resident SELECT policy is defined for:

- public.routing_config_versions
- public.routing_destinations
- public.concern_type_routes

Behavioral testing verified that an approved Resident receives zero visible rows from these routing-configuration tables.

This prevents the Resident application from directly exposing internal routing configuration.


## 17. Pending Resident Access Boundary

Behavioral RLS testing used a synthetic profile with:

role = resident

account_status = pending

The pending Resident received zero visible rows from all five Task 04.4 configuration tables.

Verified pending-Resident visibility:

- taxonomy versions: 0
- concern types: 0
- routing versions: 0
- routing destinations: 0
- routing mappings: 0


## 18. Approved Administrator Read Policies

Five approved-administrator SELECT policies were implemented:

- concern_taxonomy_versions_select_approved_admin
- concern_types_select_approved_admin
- routing_config_versions_select_approved_admin
- routing_destinations_select_approved_admin
- concern_type_routes_select_approved_admin

The policies reuse the previously verified authorization helper:

public.is_approved_barangay_admin()

This prevents repeated administrator-role logic from being reimplemented independently in each policy.


## 19. Approved Administrator Visibility

Behavioral testing verified that an approved Barangay Administrator can read the complete synthetic configuration fixture.

Verified synthetic fixture visibility:

- taxonomy versions: 3
- concern types: 4
- routing configuration versions: 1
- routing destinations: 2
- concern-type routing mappings: 1

The Administrator therefore receives configuration-history visibility required for future administrative configuration management.


## 20. Anonymous Access Boundary

Task 04.4 explicitly removes direct configuration-table privileges from the anon PostgreSQL role.

Behavioral testing verified that an anonymous client cannot SELECT the concern-taxonomy configuration.

The pgTAP suite also verifies anonymous SELECT denial.


## 21. Explicit Table Privileges

The migration explicitly performs:

REVOKE ALL

before granting the intended access.

SELECT is then granted only to:

- authenticated
- service_role

No INSERT, UPDATE, or DELETE table privilege is granted by Task 04.4.


## 22. Verified Privilege Matrix

The PostgreSQL privilege matrix was tested across all five Task 04.4 configuration tables.

Verified result:

| Role | SELECT | INSERT | UPDATE | DELETE |
|---|---|---|---|---|
| anon | No | No | No | No |
| authenticated | Yes | No | No | No |
| service_role | Yes | No | No | No |

For authenticated users, Row Level Security determines which rows are actually visible.


## 23. No Client Configuration Mutation Path

Task 04.4 defines no INSERT, UPDATE, or DELETE RLS policy for the five configuration tables.

Task 04.4 also grants no INSERT, UPDATE, or DELETE table privilege.

Therefore this foundation does not introduce direct Flutter/client-side configuration mutation.

Protected configuration mutation will be implemented separately in a later configuration-management task.


## 24. Transactional Migration Compilation

The complete migration was repeatedly compiled inside:

BEGIN

and:

ROLLBACK

before permanent local application.

The final transactional compile included:

- five configuration tables;
- compatibility constraints;
- indexes;
- comments;
- five RLS enable statements;
- seven SELECT policies;
- privilege revocation;
- SELECT-only grants.

Verified result:

- no PostgreSQL ERROR;
- successful ROLLBACK;
- no Task 04.4 tables remained after rollback;
- no Task 04.4 policies remained after rollback.


## 25. Routing Compatibility Behavioral Tests

Synthetic Taxonomy A and Taxonomy B fixtures were created inside a transaction.

Synthetic Routing A and Routing B fixtures were also created.

The following behavior was verified.

Compatible route:

PASS — accepted.

Cross-taxonomy concern mapping:

PASS — rejected.

Cross-routing destination mapping:

PASS — rejected.

Routing-version/taxonomy mismatch:

PASS — rejected.

Duplicate concern route inside one routing version:

PASS — rejected.

After the test transaction:

- only the intended valid mapping existed before rollback;
- all temporary tables and records were removed by rollback.


## 26. Approved Resident Behavioral Test

A synthetic approved Resident was created using the existing HelpHub test pattern.

The authoritative profile state was:

role = resident

account_status = approved

The Resident saw:

- exactly one active taxonomy version from the synthetic fixture;
- exactly one enabled concern type from the active taxonomy.

The Resident did not see:

- draft taxonomy configuration;
- retired taxonomy configuration;
- disabled concern types;
- routing configuration versions;
- routing destinations;
- concern-type routing mappings.

The only visible synthetic concern code was:

TEST004_RLS_ACTIVE_ENABLED


## 27. Pending Resident Behavioral Test

A synthetic pending Resident was tested using:

role = resident

account_status = pending

The Resident received zero Task 04.4 configuration rows.

This verifies that authentication alone is insufficient; the Resident must also be approved.


## 28. Approved Administrator Behavioral Test

A synthetic approved Barangay Administrator was tested using:

role = barangay_admin

account_status = approved

The Administrator was able to read all synthetic Task 04.4 taxonomy and routing configuration records.

This confirms the administrator helper and SELECT policies operate together correctly.


## 29. Anonymous Behavioral Test

The pgTAP regression suite switches to the anon PostgreSQL role and verifies that an anonymous client cannot SELECT Task 04.4 concern-taxonomy configuration.

Verified result:

PASS — permission denied as expected.


## 30. pgTAP Regression Suite

The automated Task 04.4 regression file is:

supabase/tests/004_concern_taxonomy_routing_foundation.test.sql

The suite uses:

BEGIN;

create extension if not exists pgtap with schema extensions;

set local search_path = public, extensions;

select plan(38);

The suite contains exactly 38 assertions.

Assertion groups cover:

1–5:
Task 04.4 table existence.

6–10:
RLS enabled on all five tables.

11–12:
Expected SELECT policy count and absence of mutation policies.

13–18:
PostgreSQL table privilege matrix.

19–27:
Compatibility constraints and single-active-version controls.

28–32:
Routing compatibility behavior.

33:
Synthetic authoritative profile states.

34–35:
Approved Resident visibility.

36:
Pending Resident denial.

37:
Approved Barangay Administrator visibility.

38:
Anonymous SELECT denial.

The test concludes with:

reset role;

select * from finish();

rollback;


## 31. Temporary Migration + pgTAP Execution

Before permanent migration application, the Task 04.4 migration and the finalized 38-test pgTAP suite were executed together inside one temporary transaction.

Verified results:

- pgTAP plan: 1..38
- assertions: ok 1 through ok 38
- failed assertions: 0
- PostgreSQL ERROR: none
- ROLLBACK: completed
- PSQL_EXIT_CODE: 0

Post-test cleanup verification confirmed:

- synthetic auth users remaining: 0
- synthetic profiles remaining: 0
- Task 04.4 tables remaining: none
- Task 04.4 policies remaining: 0


## 32. Local Migration Application

After the temporary regression run passed, the migration was permanently applied to the local Supabase development database using:

npx.cmd supabase migration up

Verified output included:

Applying migration 20260814110829_create_concern_taxonomy_and_handler_foundation.sql...

and:

Local database is up to date.

This application was local development only.


## 33. Local Migration History Verification

Local migration history was verified using:

npx.cmd supabase migration list --local

The local migration history included:

- 20260814012435
- 20260814050812
- 20260814110829

The Task 04.4 migration timestamp is:

20260814110829

The migration remained present after a clean:

npx.cmd supabase stop

followed by a later:

npx.cmd supabase start

This confirmed preservation of the local database state through the Docker volume.


## 34. Individual Task 04.4 Regression Result

The applied local schema was tested using:

npx.cmd supabase test db ".\supabase\tests\004_concern_taxonomy_routing_foundation.test.sql"

Verified result:

- Files = 1
- Tests = 38
- failed tests = 0
- Result = PASS

Output included:

004_concern_taxonomy_routing_foundation.test.sql .. ok

All tests successful.

Result: PASS


## 35. Final Combined Database Regression Suite

The complete database regression suite was executed using:

npx.cmd supabase test db ".\supabase\tests"

Executed suites:

- 001_identity_foundation.test.sql
- 002_identity_rls_behavior.test.sql
- 003_admin_verification_review.test.sql
- 004_concern_taxonomy_routing_foundation.test.sql

Verified result:

- Files = 4
- Tests = 144
- failed tests = 0
- Result = PASS

Output included:

All tests successful.

Files=4, Tests=144

Result: PASS

This confirms Task 04.4 introduced no detected regression into the previously verified identity, Resident RLS, or administrator-verification foundations.


## 36. Security Controls Verified

The following Task 04.4 security controls were verified:

1. Row Level Security enabled on all five configuration tables.
2. Anonymous direct configuration-table access denied.
3. Pending Residents cannot read configuration.
4. Approved Residents see only active/enabled taxonomy data required for concern submission.
5. Residents cannot read routing configuration.
6. Approved Barangay Administrators may read taxonomy and routing configuration.
7. Administrator policies reuse the established approved-administrator helper.
8. No client INSERT policy exists.
9. No client UPDATE policy exists.
10. No client DELETE policy exists.
11. No INSERT table privilege is granted.
12. No UPDATE table privilege is granted.
13. No DELETE table privilege is granted.
14. Cross-version taxonomy/routing combinations are rejected by PostgreSQL.
15. Duplicate concern routing inside one routing version is rejected.
16. No final concern/routing configuration is seeded.


## 37. Verified Architecture Boundary

Task 04.4 preserves the HelpHub architecture boundary.

Flutter is not made authoritative for:

- concern taxonomy versioning;
- routing configuration versioning;
- handler/referral configuration;
- compatibility validation;
- protected configuration mutation.

PostgreSQL enforces configuration compatibility and RLS.

The protected backend will remain responsible for future privileged configuration mutation and algorithm/business-rule authority.

Residents receive only the taxonomy data required for concern reporting.

Routing internals remain hidden from Residents.

Approved Barangay Administrators receive read visibility required for future administration features.


## 38. Files Changed by Task 04.4

Task 04.4 currently changes:

1. Migration:

supabase/migrations/20260814110829_create_concern_taxonomy_and_handler_foundation.sql

2. Automated regression test:

supabase/tests/004_concern_taxonomy_routing_foundation.test.sql

3. Verification evidence:

docs/database/CONCERN_TAXONOMY_ROUTING_TEST_EVIDENCE.md


## 39. Verification Summary

Task 04.4 verification status:

- Migration syntax/integrity checks: PASS
- PostgreSQL transactional compilation: PASS
- Rollback cleanup: PASS
- Concern taxonomy version foundation: PASS
- Concern-type foundation: PASS
- Routing configuration version foundation: PASS
- Routing-destination foundation: PASS
- Concern-type routing map: PASS
- Compatibility keys: PASS
- Compatibility foreign keys: PASS
- Valid routing mapping behavior: PASS
- Cross-taxonomy rejection: PASS
- Cross-routing rejection: PASS
- Routing/taxonomy mismatch rejection: PASS
- Duplicate-route rejection: PASS
- Single-active taxonomy control: PASS
- Single-active routing control: PASS
- RLS enabled on all five tables: PASS
- Approved Resident visibility: PASS
- Pending Resident denial: PASS
- Resident routing privacy: PASS
- Approved Administrator visibility: PASS
- Anonymous access denial: PASS
- Table privilege matrix: PASS
- Client mutation denial: PASS
- No final seed configuration: PASS
- Temporary pgTAP execution: 38/38 PASS
- PostgreSQL temporary-run exit code: 0
- Local migration application: PASS
- Local migration-history verification: PASS
- Individual applied-schema regression suite: 38/38 PASS
- Combined database regression suite: 144/144 PASS
- Existing database-suite regression: none detected


## 40. Task Gate Status

Current Task 04.4 technical verification:

PASS

The implementation has passed local migration, compatibility, RLS, privilege, behavioral, and regression testing.

Task 04.4 is not yet considered fully closed in source control until the final documentation review, secret scan, Git staging review, and Git commit are completed.

This evidence represents local HelpHub development verification only.

No hosted production deployment or external stakeholder approval is claimed by this document.