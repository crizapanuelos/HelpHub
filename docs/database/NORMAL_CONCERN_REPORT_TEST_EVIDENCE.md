# HelpHub Task 04.5 — Normal Concern Report Foundation Test Evidence

## 1. Purpose

This document records local implementation and verification evidence for HelpHub Task 04.5: Normal Concern Report Foundation.

The evidence is based on executed PostgreSQL/Supabase migration checks, transactional compilation, pgTAP regression tests, Row Level Security behavior tests, privilege tests, constraint tests, Storage configuration checks, and post-test rollback verification.

This document records local development evidence only.

It does not claim:

- production deployment;
- external stakeholder approval;
- completion of the FastAPI report-submission endpoint;
- completion of Flutter report-submission UI;
- completion of the rule-based weighted priority algorithm;
- completion of report status-history workflow;
- completion of SOS/emergency behavior;
- completion of Storage object upload/read authorization.

---

## 2. Task Identification

Phase:

Stage 4 — Supabase Schema, Migrations, Auth, Storage, and RLS

Sprint:

Sprint 4A — Database Foundation

Task:

04.5 — Normal Concern Report Data Foundation

Primary migration:

`supabase/migrations/20260815024417_create_normal_concern_report_foundation.sql`

Primary automated test:

`supabase/tests/005_normal_concern_report_foundation.test.sql`

Related previously applied migrations:

- `supabase/migrations/20260814012435_create_identity_foundation.sql`
- `supabase/migrations/20260814050812_create_admin_verification_review_foundation.sql`
- `supabase/migrations/20260814110829_create_concern_taxonomy_and_handler_foundation.sql`

---

## 3. Scope Implemented

Task 04.5 establishes the database-side foundation for normal HelpHub concern reports.

The migration introduces:

1. normal concern report records;
2. one-time report-location snapshots;
3. optional private photo-evidence metadata;
4. a dedicated private Supabase Storage bucket;
5. an approved-Resident authorization helper;
6. Resident and Administrator SELECT RLS policies;
7. explicit least-privilege table grants;
8. concern-type/taxonomy version compatibility enforcement;
9. report input validation;
10. GPS coordinate validation;
11. evidence type and size validation;
12. rollback-safe automated regression tests.

The migration intentionally does not implement:

- authoritative priority calculation;
- weighted scoring;
- rule matching;
- priority classification;
- handler routing;
- response deadlines;
- status history;
- assignments;
- administrative notes;
- SOS/emergency records;
- automatic continuous resident tracking;
- final production concern-category seed data.

---

## 4. Normal Report Foundation

The migration creates:

`public.reports`

The table stores raw Resident-submitted normal concern information.

Implemented fields include:

- `id`
- `resident_id`
- `taxonomy_version_id`
- `concern_type_id`
- `description`
- `resident_declared_urgency`
- `affected_population`
- `has_vulnerable_group`
- `submitted_at`

The table intentionally does not contain authoritative algorithm result fields such as:

- priority score;
- priority classification;
- handler;
- deadline;
- rule version;
- weight version;
- algorithm version.

This preserves the architecture boundary in which raw Resident input is stored separately from later FastAPI-controlled algorithm results.

---

## 5. Concern-Type and Taxonomy Compatibility

The report stores both:

- `concern_type_id`
- `taxonomy_version_id`

The migration defines:

`fk_reports_concern_type_taxonomy`

This composite foreign key references:

`public.concern_types(id, taxonomy_version_id)`

This prevents a report from associating a concern type with the wrong taxonomy version.

Behavioral regression testing confirmed that a cross-taxonomy report insertion is rejected.

---

## 6. Resident-Declared Urgency Boundary

`resident_declared_urgency` is stored as raw Resident input.

It is intentionally not named or treated as the authoritative HelpHub priority.

The migration does not invent a production urgency rating enum or final factor scale.

The database currently validates only that the value is not blank.

Authoritative priority will be generated later by the protected versioned priority algorithm.

---

## 7. Affected Population Boundary

`affected_population` is stored as an integer.

The database constraint requires:

`affected_population >= 0`

The Task 04.5 foundation accepts zero.

This is an engineering/database foundation behavior and does not establish a final priority-factor rating interpretation.

Automated tests verified:

- zero is accepted;
- negative values are rejected.

---

## 8. One-Time Report Location

The migration creates:

`public.report_locations`

The relationship is one report to at most one persisted normal-report location row because:

`report_id`

is the table primary key.

Stored location fields include:

- `report_id`
- `latitude`
- `longitude`
- `accuracy_meters`
- `captured_at`
- optional `address`

This table represents one-time location capture associated with a report.

It does not implement continuous resident tracking.

---

## 9. Location Validation

The migration enforces:

Latitude:

`-90 <= latitude <= 90`

Longitude:

`-180 <= longitude <= 180`

Accuracy:

`accuracy_meters >= 0`

Optional address:

- may be `NULL`;
- when supplied, it may not be blank.

Automated tests verified:

- valid geographic boundary values are accepted;
- latitude greater than `90` is rejected;
- longitude greater than `180` is rejected;
- negative accuracy is rejected;
- blank non-null addresses are rejected;
- duplicate location rows for one report are rejected.

---

## 10. Optional Photo-Evidence Metadata

The migration creates:

`public.report_evidence`

Actual image bytes are not stored in PostgreSQL.

The table stores metadata for the private Supabase Storage object.

Fields include:

- `report_id`
- `bucket_id`
- `object_path`
- `content_type`
- `size_bytes`
- `uploaded_at`

`report_id` is the primary key.

Therefore one normal report may have:

- zero evidence metadata rows; or
- one evidence metadata row.

Automated testing confirmed that a second evidence metadata row for the same report is rejected.

---

## 11. Private Evidence Storage Bucket

The migration creates the Supabase Storage bucket:

`report-evidence`

Verified bucket configuration:

- bucket ID: `report-evidence`
- bucket name: `report-evidence`
- public: `false`
- type: standard Storage bucket

The bucket is therefore private.

After pgTAP cleanup verification, the real migrated private bucket remained present.

Observed result:

`real_private_bucket_remaining = 1`

---

## 12. Engineering-Defined Photo Upload Restrictions

The study requires restricted/private evidence handling but does not define an exact production file-size limit or MIME allow-list.

Task 04.5 therefore adopts the following ENGINEERING-DEFINED security defaults:

Maximum file size:

`5 MiB`

Equivalent bytes:

`5,242,880`

Allowed MIME types:

- `image/jpeg`
- `image/png`
- `image/webp`

These are technical security controls rather than barangay policy values.

They may be revised later through a documented migration if compatibility testing or evaluation evidence requires a change.

---

## 13. Evidence Metadata Validation

The database metadata constraints mirror the Storage restrictions.

`content_type` must be one of:

- `image/jpeg`
- `image/png`
- `image/webp`

`size_bytes` must satisfy:

`size_bytes > 0`

and:

`size_bytes <= 5242880`

Automated tests verified:

- the exact 5 MiB boundary is accepted;
- a size above 5 MiB is rejected;
- zero-byte metadata is rejected;
- unsupported MIME types are rejected;
- blank object paths are rejected.

---

## 14. Fixed Evidence Bucket

Evidence metadata is restricted to:

`report-evidence`

The migration defines:

`chk_report_evidence_bucket_fixed`

and:

`fk_report_evidence_bucket`

The foreign key references:

`storage.buckets(id)`

This prevents normal-report evidence metadata from pointing to an unrelated Storage bucket.

Automated tests verified that another bucket identifier is rejected.

---

## 15. Approved Resident Authorization Helper

The migration creates:

`public.is_approved_resident()`

The helper returns true only when the current authenticated identity has an authoritative HelpHub profile satisfying:

`role = 'resident'`

and:

`account_status = 'approved'`

The helper follows the previously established hardened function pattern.

Verified properties include:

- `language sql`
- `STABLE`
- `SECURITY DEFINER`
- empty `search_path`
- schema-qualified profile lookup
- uses `auth.uid()`
- no data mutation

Broad function EXECUTE access is revoked.

EXECUTE is granted to:

`authenticated`

EXECUTE is not granted to:

`anon`

---

## 16. Row Level Security

RLS is enabled on:

- `public.reports`
- `public.report_locations`
- `public.report_evidence`

Task 04.5 defines exactly six report-table SELECT policies.

Resident policies:

- `reports_select_own_approved_resident`
- `report_locations_select_own_approved_resident`
- `report_evidence_select_own_approved_resident`

Administrator policies:

- `reports_select_approved_admin`
- `report_locations_select_approved_admin`
- `report_evidence_select_approved_admin`

No direct client INSERT, UPDATE, or DELETE RLS policy is introduced by this migration.

---

## 17. Resident Read Behavior

Behavioral RLS tests used synthetic authenticated identities.

Approved Resident One was verified to:

- satisfy `public.is_approved_resident()`;
- read exactly their own report;
- read exactly their own location row;
- read exactly their own evidence metadata row;
- not read Resident Two's report.

Approved Resident Two was verified to:

- satisfy `public.is_approved_resident()`;
- read exactly their own report;
- read exactly their own location row;
- read exactly their own evidence metadata row;
- not read Resident One's report.

This verifies cross-Resident isolation.

---

## 18. Pending Resident Behavior

A synthetic Resident with:

`role = resident`

and:

`account_status = pending`

was verified to:

- fail the approved-Resident helper;
- read zero normal reports;
- read zero normal-report locations;
- read zero normal-report evidence metadata rows.

This verifies that authentication alone is not sufficient for normal-report read authorization.

---

## 19. Administrator Read Behavior

A synthetic profile with:

`role = barangay_admin`

and:

`account_status = approved`

was verified to satisfy:

`public.is_approved_barangay_admin()`

The approved Administrator could read the complete synthetic normal-report fixture.

This included:

- both reports;
- both report locations;
- both evidence metadata rows.

---

## 20. Anonymous Access

Task 04.5 grants no direct normal-report table privilege to:

`anon`

Automated behavior testing confirmed an anonymous client cannot SELECT normal reports.

---

## 21. Explicit Table Privileges

Task 04.5 explicitly revokes table privileges before granting the required operations.

Tables covered:

- `public.reports`
- `public.report_locations`
- `public.report_evidence`

### anon

Verified:

- no SELECT;
- no INSERT;
- no UPDATE;
- no DELETE.

### authenticated

Verified:

- SELECT granted;
- INSERT not granted;
- UPDATE not granted;
- DELETE not granted.

RLS determines which SELECT rows are visible.

### service_role

Verified:

- SELECT granted;
- INSERT granted;
- UPDATE not granted;
- DELETE not granted.

This supports the protected FastAPI write boundary for raw report creation.

---

## 22. Direct Resident Mutation Denial

Automated tests confirmed that an approved authenticated Resident cannot directly:

- INSERT a normal report;
- UPDATE an existing submitted raw report;
- DELETE an existing submitted raw report.

The database therefore does not depend only on Flutter behavior for this protection.

---

## 23. Protected Backend Creation Boundary

The `service_role` privilege boundary was behaviorally tested.

A `service_role` session successfully created:

1. a valid raw report;
2. its one-time location record;
3. valid evidence metadata.

A direct `service_role` UPDATE of an already submitted raw report was rejected because Task 04.5 does not grant UPDATE on these raw-report tables.

This preserves submitted raw input from ordinary later rewriting.

---

## 24. Raw Report Validation

Behavioral tests verified rejection of:

- blank descriptions;
- blank Resident-declared urgency;
- negative affected population;
- concern-type/taxonomy mismatch.

Valid boundary behavior verified:

- affected population of zero is accepted.

---

## 25. Duplicate Child Record Prevention

The database relationship design was tested behaviorally.

Verified:

- one report cannot contain two `report_locations` rows;
- one report cannot contain two `report_evidence` rows.

The one-to-one relationships are enforced through primary keys on:

`report_locations.report_id`

and:

`report_evidence.report_id`

---

## 26. Migration Transactional Compilation

Before permanent application, the entire Task 04.5 migration was executed inside:

`BEGIN`

and:

`ROLLBACK`

using:

`ON_ERROR_STOP=1`

Observed result:

`PSQL_EXIT_CODE=0`

No SQL compilation error was observed.

The compile transaction completed with:

`ROLLBACK`

---

## 27. Transactional Compilation Cleanup

After the compile-only transaction, the database was checked for Task 04.5 objects.

Verified absent after rollback:

- `public.reports`
- `public.report_locations`
- `public.report_evidence`
- `public.is_approved_resident()`
- `report-evidence` Storage bucket
- Task 04.5 report policies

This proved the compile test did not partially modify the local database.

---

## 28. Migration Application

Task 04.5 was permanently applied to the local development database using:

`npx.cmd supabase migration up`

Applied migration:

`20260815024417_create_normal_concern_report_foundation.sql`

Observed command result:

`Local database is up to date.`

No migration error was observed.

---

## 29. Task 04.5 pgTAP Suite

Automated test file:

`supabase/tests/005_normal_concern_report_foundation.test.sql`

The final suite contains:

- `27` `ok()` assertions;
- `9` `results_eq()` assertions;
- `20` `throws_like()` assertions;
- `6` `lives_ok()` assertions.

Total:

`62 assertions`

The test lifecycle is fixed as:

`plan(62)`

followed by all 62 assertions, then:

`finish()`

and finally:

`rollback`

Verified source lifecycle:

- `Plan62Count = 1`
- `NoPlanCount = 0`
- `FinishCount = 1`
- `RollbackCount = 1`
- `FinishLine = 1583`
- `RollbackLine = 1590`
- final non-empty line = `rollback;`

---

## 30. Isolated Task 04.5 Test Result

Executed command:

`npx.cmd supabase test db ".\supabase\tests\005_normal_concern_report_foundation.test.sql"`

Observed result:

`All tests successful.`

Observed test summary:

`Files=1, Tests=62`

Observed final status:

`Result: PASS`

Therefore:

Task 04.5 isolated pgTAP result:

`62 / 62 PASS`

---

## 31. Full Database Regression Result

Executed command:

`npx.cmd supabase test db ".\supabase\tests"`

The following suites all passed:

1. `001_identity_foundation.test.sql`
2. `002_identity_rls_behavior.test.sql`
3. `003_admin_verification_review.test.sql`
4. `004_concern_taxonomy_routing_foundation.test.sql`
5. `005_normal_concern_report_foundation.test.sql`

Observed summary:

`Files=5, Tests=206`

Observed final status:

`Result: PASS`

Therefore:

Full Stage 4 database regression result:

`206 / 206 PASS`

No regression was observed in the previously completed database foundations.

---

## 32. pgTAP Rollback Cleanup Verification

The `005` suite creates synthetic data inside its transaction.

Post-test verification confirmed the following counts:

Synthetic Auth users remaining:

`0`

Synthetic profiles remaining:

`0`

Synthetic taxonomy versions remaining:

`0`

Synthetic concern types remaining:

`0`

Synthetic normal reports remaining:

`0`

Synthetic report locations remaining:

`0`

Synthetic report evidence metadata remaining:

`0`

The real migrated private evidence bucket remained:

`1`

Therefore the automated test suite successfully cleans up its synthetic records while preserving the actual Task 04.5 schema/configuration.

---

## 33. Privacy and Security Controls Verified

Task 04.5 verifies or preserves the following HelpHub security boundaries:

- one-time GPS capture only;
- no continuous resident tracking;
- private evidence Storage bucket;
- photo MIME restrictions;
- photo size restriction;
- evidence object references stored as metadata rather than image bytes;
- approved-Resident authorization;
- cross-Resident RLS isolation;
- pending-Resident denial;
- approved Administrator read access;
- anonymous denial;
- no direct authenticated client mutation of raw report records;
- no silent UPDATE/DELETE privilege for submitted raw report data;
- protected server-side INSERT boundary;
- taxonomy-version compatibility protection.

---

## 34. Architecture Boundary Verified

The database foundation preserves the HelpHub authority boundary:

Resident-submitted raw input:

`Flutter → protected backend → reports/location/evidence`

Authoritative processing remains separate:

`FastAPI → validation → rule matching → normalized ratings → weighted scoring → priority → route → deadline`

Task 04.5 does not permit Flutter to submit authoritative:

- priority;
- score;
- route;
- deadline;
- algorithm version.

Those will be introduced through later protected backend and algorithm slices.

---

## 35. Storage Access Boundary

The `report-evidence` bucket is private.

Task 04.5 does not yet introduce direct `storage.objects` client policies for production upload/download behavior.

Actual protected Storage object upload/read authorization, object-path authorization, and signed/private retrieval remain separate implementation work.

The current Task 04.5 evidence tests database metadata, bucket configuration, and access foundations only.

---

## 36. Files Created by Task 04.5

Migration:

`supabase/migrations/20260815024417_create_normal_concern_report_foundation.sql`

Automated test:

`supabase/tests/005_normal_concern_report_foundation.test.sql`

Evidence document:

`docs/database/NORMAL_CONCERN_REPORT_TEST_EVIDENCE.md`

---

## 37. Verification Summary

| Verification | Result |
|---|---|
| Migration source structure | PASS |
| Normal report table | PASS |
| One-time location table | PASS |
| Evidence metadata table | PASS |
| Concern taxonomy compatibility | PASS |
| GPS constraints | PASS |
| Evidence MIME constraints | PASS |
| Evidence size constraints | PASS |
| Private Storage bucket | PASS |
| Approved-Resident helper | PASS |
| RLS enabled | PASS |
| Resident own-row access | PASS |
| Cross-Resident denial | PASS |
| Pending Resident denial | PASS |
| Administrator read access | PASS |
| Anonymous denial | PASS |
| Authenticated mutation denial | PASS |
| service_role INSERT boundary | PASS |
| Raw-report UPDATE denial | PASS |
| Transactional compilation | PASS |
| Compilation exit code | 0 |
| Compilation rollback cleanup | PASS |
| Local migration application | PASS |
| Isolated Task 04.5 pgTAP suite | 62 / 62 PASS |
| Full database regression suite | 206 / 206 PASS |
| Synthetic post-test cleanup | PASS |
| Real private bucket retained | PASS |

---

## 38. Task Gate Status

Technical database verification status:

`PASS`

Task 04.5 establishes and verifies the local database foundation for normal HelpHub concern reporting.

This status applies only to the Task 04.5 database-foundation scope.

It does not mark the complete end-user concern-reporting feature as finished.

Remaining later work includes protected API integration, Flutter UI states, actual Storage-object upload/read flow, algorithm execution, status history, administrative workflow, integration testing, documentation screenshots, and demonstration/UAT evidence.