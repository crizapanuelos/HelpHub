# HelpHub Task 04.6 — Report Status and Assignment Foundation Test Evidence

## 1. Evidence Identification

- Project: HelpHub
- Current phase: Stage 4 — Supabase Schema, Migrations, Auth, Storage, and RLS
- Sprint: Sprint 4A — Database Foundation
- Task: 04.6 — Report Status and Assignment Foundation
- Evidence type: Local development database verification
- Database platform: Supabase PostgreSQL
- Migration:
  - `supabase/migrations/20260817131215_create_report_status_and_assignment_foundation.sql`
- Test:
  - `supabase/tests/006_report_status_and_assignment_foundation.test.sql`

This document records technical evidence obtained from the local HelpHub development database.

It does not claim production deployment, external stakeholder approval, final Barangay workflow approval, completed FastAPI workflow operations, completed Flutter UI behavior, SOS behavior, or complete end-to-end application readiness.

---

## 2. Task 04.6 Purpose

Task 04.6 establishes the database foundation required for normal-report lifecycle tracking, status history, routing/assignment tracking, immutable history, audit linkage, and protected read access.

The migration deliberately separates:

1. raw Resident concern-submission data;
2. current operational lifecycle state;
3. append-only lifecycle history;
4. current routing/assignment state;
5. append-only routing/assignment history;
6. lifecycle configuration;
7. audit evidence.

The existing `public.reports` table remains the raw Resident-submission record.

Mutable operational workflow data is not stored directly inside `public.reports`.

---

## 3. Governance Boundary

Task 04.6 does not invent final Barangay workflow values.

No production values are seeded for:

- final report status names;
- final status codes;
- final status-transition rules;
- final handler names;
- final offices or teams;
- final external referral organizations;
- final response deadlines;
- final manual-routing override rules;
- final workflow timing policies.

The migration provides versioned configuration structures so approved values can be introduced later without changing historical records.

All `TEST006_*` values used by the pgTAP suite are test-only fixtures and are rolled back.

---

## 4. Main Database Structures

Task 04.6 creates seven primary tables.

### 4.1 `public.report_lifecycle_versions`

Stores versioned lifecycle-configuration snapshots.

Important properties include:

- UUID primary key;
- positive version number;
- optional version label;
- optional administrative notes;
- optional creator profile;
- activation metadata;
- retirement metadata;
- at most one currently active lifecycle configuration.

No lifecycle configuration row is seeded by Task 04.6.

### 4.2 `public.report_status_definitions`

Stores versioned status definitions belonging to a lifecycle configuration.

Important properties include:

- lifecycle version ownership;
- machine-readable code;
- human-readable name;
- optional description;
- display order;
- enabled flag;
- configurable `is_initial` flag.

Task 04.6 does not select or seed the production initial status.

A partial unique index permits at most one status with `is_initial = true` per lifecycle version.

### 4.3 `public.report_status_transitions`

Stores configured status-to-status relationships within one lifecycle version.

Composite foreign keys ensure both FROM and TO statuses belong to the recorded lifecycle configuration.

Self-transitions are rejected by the structural constraint.

Task 04.6 seeds no production transition rows.

### 4.4 `public.report_lifecycle_states`

Stores the current operational lifecycle snapshot for a normal concern report.

One report has at most one current lifecycle-state row because `report_id` is the primary key.

The row records:

- report;
- lifecycle configuration version;
- current configured status;
- profile associated with the latest authoritative change when available;
- status-change timestamp;
- creation/update timestamps;
- immutable source-history record.

A composite foreign key ensures the current status belongs to the recorded lifecycle version.

A separate composite source-history foreign key ensures the current snapshot corresponds to the exact history event that produced the same report, lifecycle version, and current status.

### 4.5 `public.report_status_history`

Stores append-only lifecycle history.

Important properties include:

- positive per-report sequence number;
- lifecycle version;
- previous status;
- resulting status;
- configured transition when applicable;
- actor profile when applicable;
- timestamp;
- optional administrative note;
- immutable audit-event link.

Initial lifecycle establishment is structurally represented by:

- `sequence_number = 1`;
- `from_status_id = NULL`;
- `transition_id = NULL`.

Later history records must use:

- `sequence_number > 1`;
- non-NULL previous status;
- non-NULL configured transition.

The migration does not determine which configured status is the production initial status.

### 4.6 `public.report_routing_states`

Stores the current routing/assignment snapshot for a normal report.

The current destination is a versioned `routing_destinations` record.

Existing routing configuration distinguishes:

- `internal_handler`;
- `external_referral`.

`external_referral` means manual Barangay referral/coordination only.

It does not mean:

- an external HelpHub account;
- automatic dispatch;
- electronic integration;
- guaranteed acknowledgement;
- guaranteed acceptance by the outside organization.

Composite foreign keys ensure:

- the routing state uses the report's taxonomy version;
- the routing configuration belongs to that taxonomy;
- the destination belongs to the recorded routing version;
- the current snapshot corresponds to the exact immutable routing-history event that produced it.

### 4.7 `public.report_routing_history`

Stores append-only routing, assignment, reassignment, or referral history.

Important properties include:

- positive per-report sequence number;
- report;
- taxonomy version;
- routing configuration version;
- destination;
- actor profile when available;
- timestamp;
- optional routing note;
- immutable audit-event link.

Task 04.6 does not seed actual routing destinations or handler assignments.

---

## 5. Supporting Structural Changes

Task 04.6 also adds supporting integrity structures.

### 5.1 Report/Taxonomy Candidate Key

`public.reports` receives the candidate key:

`uq_reports_id_taxonomy`

This allows routing records to prove that their taxonomy version is the exact taxonomy snapshot recorded on the original report.

### 5.2 Configurable Initial Status

`public.report_status_definitions` receives:

`is_initial boolean not null default false`

The unique index:

`uq_report_status_definitions_one_initial`

allows at most one configured initial status per lifecycle version.

Draft lifecycle configurations may temporarily contain no initial status.

A later protected lifecycle-configuration activation operation must verify that an activated version contains exactly one approved enabled initial status.

### 5.3 Current Snapshot to Immutable History

`public.report_lifecycle_states` receives:

`source_history_id`

`public.report_routing_states` receives:

`source_history_id`

Composite foreign keys bind each current snapshot to the exact immutable history row that produced it.

---

## 6. Append-Only History Protection

Task 04.6 creates database-level mutation guards for both history tables.

### 6.1 Status History

Function:

`public.prevent_report_status_history_mutation()`

Trigger:

`trg_report_status_history_prevent_mutation`

The trigger rejects UPDATE and DELETE operations against existing `report_status_history` rows.

### 6.2 Routing History

Function:

`public.prevent_report_routing_history_mutation()`

Trigger:

`trg_report_routing_history_prevent_mutation`

The trigger rejects UPDATE and DELETE operations against existing `report_routing_history` rows.

These protections exist in addition to SQL privilege restrictions.

---

## 7. Row Level Security

RLS is enabled on all seven Task 04.6 tables.

Verified count:

`RlsTables=7`

The four operational tracking tables receive Resident/Admin SELECT policies:

- `report_lifecycle_states`
- `report_status_history`
- `report_routing_states`
- `report_routing_history`

Eight operational SELECT policies exist in total:

- four approved-Resident own-report policies;
- four approved-Barangay-Administrator policies.

Verified count:

`ReadPolicies=8`

Approved Residents may see an operational row only when the parent `public.reports` row belongs to `auth.uid()`.

Approved Barangay Administrators may read operational records for administrative handling.

Pending Residents do not satisfy the approved-Resident authorization helper.

Anonymous users do not receive operational table privileges.

---

## 8. SQL Privilege Boundary

Post-application privilege verification produced:

`AuthenticatedOperationalSelect=4`

Meaning authenticated clients may attempt SELECT on the four operational tracking tables, with actual visible rows controlled by RLS.

Post-application verification also produced:

`AuthenticatedConfigSelect=0`

Meaning authenticated Flutter clients cannot directly read the lifecycle configuration tables introduced by Task 04.6.

Post-application verification produced:

`AuthenticatedMutation=0`

Meaning authenticated clients receive no direct INSERT, UPDATE, or DELETE privilege on the four operational lifecycle/routing tracking tables.

Post-application verification produced:

`ServiceRoleSelect=7`

Meaning the protected backend service role can inspect all seven Task 04.6 tables.

Task 04.6 does not yet grant general service-role mutation access for authoritative lifecycle/routing operations.

Those writes are reserved for later protected database/server-side workflow operations.

---

## 9. No Invented Workflow Data

After migration application, the combined number of Task 04.6 lifecycle, status, transition, operational-state, history, and routing-state rows was verified as:

`Task046Rows=0`

Therefore Task 04.6 introduces database structure without seeding invented production workflow data.

---

## 10. Migration Transactional Compilation

Before application, the complete Task 04.6 migration was repeatedly compiled inside a transaction using:

- `BEGIN`;
- the migration source;
- `ROLLBACK`;
- PostgreSQL `ON_ERROR_STOP=1`.

The complete migration reached `ROLLBACK` without PostgreSQL errors after each final correction.

This verified SQL compilation without persisting the structures during pre-application validation.

---

## 11. Migration Application

The migration was applied locally using:

`npx.cmd supabase migration up`

Observed result:

- local database connection succeeded;
- migration `20260817131215_create_report_status_and_assignment_foundation.sql` was applied;
- Supabase reported the local database was up to date;
- no PostgreSQL error was reported.

The migration is therefore treated as an applied migration-history artifact.

---

## 12. Migration History Verification

`npx.cmd supabase migration list --local`

showed the following five migrations aligned between local migration files and local database history:

- `20260814012435`
- `20260814050812`
- `20260814110829`
- `20260815024417`
- `20260817131215`

Task 04.6 migration `20260817131215` was therefore verified as applied.

---

## 13. Post-Application Structural Verification

A direct PostgreSQL catalog query produced:

`Task046Tables=7|RlsTables=7|ReadPolicies=8|AppendOnlyFunctions=2|ReportsTaxonomyConstraint=1|InitialColumn=1|InitialIndex=1`

This verifies:

- seven Task 04.6 tables exist;
- all seven have RLS enabled;
- eight intended operational read policies exist;
- two append-only protection functions exist;
- the report/taxonomy candidate key exists;
- the configurable `is_initial` column exists;
- the one-initial-status unique index exists.

---

## 14. pgTAP Test File

Test file:

`supabase/tests/006_report_status_and_assignment_foundation.test.sql`

The finalized test file declares:

`select plan(47);`

Mechanical lifecycle verification produced:

- Plan47Count = 1
- OkCount = 10
- IsCount = 12
- ResultsEqCount = 7
- ThrowsLikeCount = 18
- AssertionTotal = 47
- FinishCount = 1
- RollbackCount = 1
- LastNonEmptyLine = `rollback;`

The file was also verified as valid UTF-8.

---

## 15. pgTAP Structural Coverage

The Task 04.6 pgTAP suite verifies:

- all seven Task 04.6 tables exist;
- RLS is enabled on all seven;
- eight operational read policies exist;
- lifecycle snapshot source-history column exists;
- routing snapshot source-history column exists;
- configurable initial-status marker exists;
- one-initial-status unique index exists;
- report/taxonomy candidate key exists;
- append-only status-history function exists;
- append-only routing-history function exists;
- both history mutation triggers exist;
- no production lifecycle/routing rows were seeded;
- authenticated operational SELECT privilege boundary;
- no authenticated lifecycle-configuration SELECT privilege;
- no authenticated operational mutation privilege;
- service-role SELECT visibility across all seven tables.

---

## 16. Synthetic Identity and RLS Coverage

The test creates transaction-scoped synthetic identities:

- approved Resident One;
- approved Resident Two;
- pending Resident;
- approved Barangay Administrator.

The test confirms authoritative `public.profiles` role/account-status values before RLS behavior is exercised.

Test JWT/RLS behavior follows the existing HelpHub database-test pattern:

1. switch to PostgreSQL `authenticated`;
2. set `request.jwt.claim.sub`;
3. allow `auth.uid()` to resolve the synthetic HelpHub identity;
4. execute the RLS-protected query;
5. change identity or reset role.

---

## 17. Resident Isolation Results

Approved Resident One sees exactly one own row in each of:

- `report_lifecycle_states`;
- `report_status_history`;
- `report_routing_states`;
- `report_routing_history`.

The visible lifecycle row is verified to belong to Resident One's exact report.

Approved Resident Two receives the equivalent isolation behavior for Resident Two's report.

This provides behavioral evidence that approved Residents cannot read another Resident's Task 04.6 operational records through these policies.

---

## 18. Pending Resident Result

The pending Resident sees zero rows across all four operational lifecycle/routing tracking tables.

This verifies that ownership alone is insufficient; the authoritative profile must also satisfy the approved-Resident requirement.

---

## 19. Administrator Visibility Result

The approved Barangay Administrator sees the complete two-report synthetic operational fixture across all four operational tracking tables.

This verifies the administrative read path separately from the Resident ownership path.

---

## 20. Anonymous Access Result

The pgTAP test verifies anonymous SELECT against `report_lifecycle_states` fails with PostgreSQL permission denial.

No anonymous direct operational read privilege is introduced by Task 04.6.

---

## 21. Authenticated Configuration Access Result

The test verifies an authenticated Resident cannot directly SELECT `report_status_definitions`.

Lifecycle configuration remains behind the protected backend/configuration-management boundary.

---

## 22. Direct Client Mutation Results

The test verifies an authenticated approved Resident cannot directly:

- INSERT `report_lifecycle_states`;
- INSERT `report_status_history`;
- INSERT `report_routing_states`;
- INSERT `report_routing_history`.

This preserves the architectural rule that authoritative lifecycle/routing mutation must occur through later protected server-side operations rather than Flutter direct table writes.

---

## 23. Initial-Status Uniqueness Result

The test attempts to create two `is_initial = true` statuses inside one lifecycle version.

PostgreSQL rejects the second initial status through:

`uq_report_status_definitions_one_initial`

This proves the at-most-one-initial structural rule is enforced by the database.

---

## 24. Status-History Append-Only Results

The test attempts to UPDATE an existing status-history row.

The database rejects the update through the append-only protection trigger.

The test also attempts to DELETE an existing status-history row.

The database rejects the deletion through the same append-only protection mechanism.

---

## 25. Routing-History Append-Only Results

The test attempts to UPDATE an existing routing-history row.

The database rejects the update.

The test separately attempts to DELETE an existing routing-history row.

The database rejects the deletion.

Thus both authoritative history tables are protected against silent rewriting and deletion.

---

## 26. Lifecycle Sequence-Role Integrity

The test attempts to create a status-history row with:

- `sequence_number > 1`;
- `from_status_id = NULL`;
- `transition_id = NULL`.

PostgreSQL rejects the malformed row through:

`chk_report_status_history_sequence_role`

This proves later lifecycle events cannot masquerade structurally as initial lifecycle establishment.

---

## 27. Cross-Lifecycle Status Rejection

The test creates a second test-only lifecycle version and status.

It then attempts to record that second lifecycle's status under the first lifecycle version.

PostgreSQL rejects the row through:

`fk_report_status_history_to_status_version`

This verifies lifecycle-version compatibility at the database layer.

---

## 28. Routing Destination/Version Rejection

The test creates a second test-only routing configuration and destination.

It attempts to record the second routing configuration's destination under the first routing version.

PostgreSQL rejects the row through:

`fk_report_routing_history_destination_version`

This verifies a routing destination cannot be detached from the routing configuration version that owns it.

---

## 29. Lifecycle Snapshot/History Traceability

The test attempts to create a lifecycle snapshot for one report while referencing another report's lifecycle-history row.

PostgreSQL rejects the mismatch through:

`fk_report_lifecycle_states_source_history`

This demonstrates that a current lifecycle snapshot cannot falsely claim unrelated immutable history as its source.

---

## 30. Routing Snapshot/History Traceability

The test attempts to create a routing snapshot for one report while referencing another report's routing-history row.

PostgreSQL rejects the mismatch through:

`fk_report_routing_states_source_history`

This demonstrates that a current routing snapshot cannot falsely claim unrelated immutable routing history as its source.

---

## 31. Status-History Audit Uniqueness

The test attempts to reuse an existing status-history audit event for a second status-history event.

PostgreSQL rejects the attempt through:

`uq_report_status_history_audit_event`

This provides one-to-one traceability from authoritative status-history events to their audit evidence.

---

## 32. Routing-History Audit Uniqueness

The test attempts to reuse an existing routing-history audit event for a second routing-history event.

PostgreSQL rejects the attempt through:

`uq_report_routing_history_audit_event`

This provides one-to-one traceability from authoritative routing-history events to their audit evidence.

---

## 33. Final Isolated Task 04.6 Test Result

The finalized isolated test command was:

`npx.cmd supabase test db ".\supabase\tests\006_report_status_and_assignment_foundation.test.sql"`

Observed final result:

- Files = 1
- Tests = 47
- All tests successful
- Result = PASS

The repeated notice that the `pgtap` extension already exists is expected and harmless.

---

## 34. Final Full Database Regression Result

The full database suite was executed using:

`npx.cmd supabase test db ".\supabase\tests"`

All six database test files passed:

1. `001_identity_foundation.test.sql`
2. `002_identity_rls_behavior.test.sql`
3. `003_admin_verification_review.test.sql`
4. `004_concern_taxonomy_routing_foundation.test.sql`
5. `005_normal_concern_report_foundation.test.sql`
6. `006_report_status_and_assignment_foundation.test.sql`

Observed final result:

- Files = 6
- Tests = 253
- All tests successful
- Result = PASS

This provides regression evidence that Task 04.6 did not break the previously verified Stage 4 database foundations.

---

## 35. pgTAP Rollback Cleanup Verification

After the finalized isolated/full test executions, direct PostgreSQL queries verified that Task 04.6 synthetic fixtures did not remain in the database.

Observed result:

`SyntheticAuthUsers=0|SyntheticReports=0|SyntheticLifecycleVersions=0|SyntheticStatusDefinitions=0|SyntheticStatusHistory=0|SyntheticLifecycleStates=0|SyntheticRoutingVersions=0|SyntheticRoutingDestinations=0|SyntheticRoutingHistory=0|SyntheticRoutingStates=0|SyntheticAuditEvents=0`

Therefore the transaction-scoped pgTAP fixture cleanup is verified.

---

## 36. Security and Privacy Interpretation

Task 04.6 strengthens HelpHub's security boundary by:

- keeping raw Resident report data separate from mutable operational state;
- enabling RLS on all new Task 04.6 tables;
- restricting Resident visibility to owned reports;
- requiring approved Resident status for Resident tracking access;
- giving approved Administrators operational read visibility;
- denying anonymous access;
- denying direct authenticated lifecycle/routing mutation;
- protecting configuration from direct authenticated reads;
- making lifecycle and routing histories append-only;
- linking history events to immutable audit evidence;
- linking current snapshots back to their exact immutable history source.

No continuous location tracking or additional Resident surveillance capability is introduced by this task.

---

## 37. Architecture Boundary

Task 04.6 provides database structures and protections only.

It does not yet implement the authoritative server-side lifecycle operation that must eventually perform an atomic transaction similar to:

1. authorize the operation;
2. lock the report/current state as needed;
3. validate the active lifecycle configuration;
4. validate the requested configured transition;
5. append an immutable audit event;
6. append status history;
7. update the current lifecycle snapshot;
8. append routing history where applicable;
9. update the current routing snapshot where applicable;
10. commit atomically.

That operation belongs to later protected backend/database implementation work.

---

## 38. Routing Policy Boundary

The database structure supports versioned routing destinations and histories.

Task 04.6 does not decide whether Barangay Administrators may manually override a configured concern-type route.

Any manual override rule must be formally established as approved configuration/policy before authoritative implementation.

---

## 39. Status Configuration Boundary

The migration supports configurable lifecycle versions, status definitions, transitions, and an initial-status marker.

Task 04.6 does not determine the actual production status vocabulary or state machine.

The final production lifecycle remains DEFERRED-CONFIG until documented approval is available.

---

## 40. Out-of-Scope Interpretations

Task 04.6 does not implement:

- SOS/emergency processing;
- algorithm scoring;
- priority assignment;
- response deadlines;
- notification delivery;
- announcement delivery;
- Firebase Cloud Messaging;
- automatic ordinance enforcement;
- penalties;
- external-agency system integration;
- automatic police/fire/medical dispatch;
- SMS fallback;
- multi-barangay operation;
- continuous GPS tracking.

---

## 41. Files Produced by Task 04.6

Task 04.6 currently produces:

- `supabase/migrations/20260817131215_create_report_status_and_assignment_foundation.sql`
- `supabase/tests/006_report_status_and_assignment_foundation.test.sql`
- `docs/database/REPORT_STATUS_AND_ASSIGNMENT_TEST_EVIDENCE.md`

---

## 42. Verification Summary

Verified locally:

- migration transactional compilation: PASS
- migration application: PASS
- migration-history alignment: PASS
- seven Task 04.6 tables: PASS
- RLS enabled on all seven tables: PASS
- eight operational Resident/Admin read policies: PASS
- no seeded lifecycle/routing operational data: PASS
- authenticated operational SELECT boundary: PASS
- authenticated configuration-read denial: PASS
- authenticated mutation denial: PASS
- service-role read boundary: PASS
- Resident ownership isolation: PASS
- pending Resident denial: PASS
- approved Administrator visibility: PASS
- anonymous access denial: PASS
- initial-status uniqueness: PASS
- lifecycle-history append-only enforcement: PASS
- routing-history append-only enforcement: PASS
- lifecycle sequence-role integrity: PASS
- cross-lifecycle status rejection: PASS
- routing destination/version rejection: PASS
- lifecycle snapshot/history linkage: PASS
- routing snapshot/history linkage: PASS
- status-history audit-event uniqueness: PASS
- routing-history audit-event uniqueness: PASS
- isolated Task 04.6 pgTAP suite, 47 tests: PASS
- complete database regression suite, 253 tests: PASS
- test-fixture rollback cleanup: PASS

---

## 43. Task Gate

Technical database verification status:

**PASS**

Scope of this PASS:

Task 04.6 report lifecycle, status-history, routing/assignment-history, RLS-read, append-only, relational-integrity, and traceability database foundation only.

This does not mark the complete HelpHub report-management feature as finished.

Remaining implementation work includes protected lifecycle/routing mutation operations, approved production lifecycle configuration, backend/API behavior, administrator workflow UI, Resident status-history UI, audit integration at the authoritative operation layer, and later application-level testing.
