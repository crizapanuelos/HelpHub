# HelpHub Identity Foundation — Test Evidence

## Document Status

- Project: HelpHub
- Phase: Stage 4 — Supabase Schema, Migrations, Auth, Storage, and RLS
- Sprint: Sprint 4A — Database Foundation
- Task: 04.2 — Database Schema Foundation and Migration Strategy
- Evidence scope: Identity foundation
- Test date: 2026-08-14
- Environment: Local Supabase development environment
- Result: PASS for the identity-foundation test slice
- Final Task 04.2 repository gate: Pending final staged checks and commit

---

## 1. Purpose

This document records the technical verification performed for the initial
HelpHub identity database foundation.

The tested foundation covers:

- Supabase Auth user linkage
- HelpHub application profiles
- Resident and Barangay Administrator role vocabulary
- Resident account workflow state
- Resident verification request foundation
- Least-privilege PostgreSQL grants
- Row Level Security (RLS)
- Auth-to-profile automatic creation
- Database constraints
- Resident-to-resident isolation
- Anonymous access denial
- Database migration reproducibility
- Automated pgTAP regression tests

This evidence is limited to the identity foundation implemented by the
migration listed below.

It does not claim that later HelpHub modules such as concern reports,
priority scoring, SOS, assignments, notifications, audit events, or complete
administrator workflows have already been implemented.

---

## 2. Migration Under Test

Migration:

`supabase/migrations/20260814012435_create_identity_foundation.sql`

The migration establishes the current identity foundation for:

- `public.profiles`
- `public.resident_verifications`

It also creates or configures:

- profile-related CHECK constraints
- verification-related CHECK constraints
- foreign keys
- indexes
- partial uniqueness for pending verification requests
- Row Level Security
- resident-facing RLS policies
- least-privilege grants
- Auth user creation trigger
- profile write-preparation trigger
- supporting PostgreSQL functions

---

## 3. Identity Model Tested

### 3.1 Profiles

`public.profiles` is the HelpHub application-side representation of an
authenticated Supabase user.

Verified columns:

- `id`
- `full_name`
- `role`
- `account_status`
- `created_at`
- `updated_at`

Verified role vocabulary:

- `resident`
- `barangay_admin`

Verified account-status vocabulary:

- `pending`
- `approved`
- `rejected`
- `restricted`

Public signup is expected to begin as:

- role: `resident`
- account status: `pending`

The database does not allow the public signup metadata to directly assign
Barangay Administrator privileges.

---

### 3.2 Resident Verifications

`public.resident_verifications` provides the initial database foundation for
resident verification requests.

Verified columns:

- `id`
- `resident_id`
- `status`
- `submitted_at`
- `reviewed_at`
- `reviewed_by`

Verified verification-state vocabulary:

- `pending`
- `approved`
- `rejected`

A pending request must be unreviewed.

An approved or rejected request must contain both:

- `reviewed_at`
- `reviewed_by`

Only one pending verification request may exist for the same resident at the
same time.

---

## 4. Manual Authentication and Authorization Tests

Two synthetic local resident accounts were created during testing.

All synthetic accounts and records were later removed by a successful local
database reset.

No production resident information was used.

---

### 4.1 Public Signup and Profile Creation

#### Test: Resident One signup

Result: PASS

Observed:

- Supabase Auth signup succeeded.
- A matching HelpHub profile was automatically created.
- `full_name` was copied from expected signup metadata.
- role became `resident`.
- account status became `pending`.

---

### 4.2 Malicious Signup Metadata

Resident One deliberately supplied signup metadata attempting to claim:

`role = barangay_admin`

Result: PASS — privilege escalation prevented.

Observed stored values:

- role: `resident`
- account status: `pending`

The signup itself was allowed, but untrusted signup metadata did not control
the protected application role.

This verifies that public signup cannot self-promote a resident into a
Barangay Administrator account.

---

## 5. Profile RLS Tests

### 5.1 Resident Reads Own Profile

Resident One used an authenticated Supabase access token through the real
Data API.

Result: PASS

Resident One could read their own profile.

---

### 5.2 Resident Reads Another Resident Profile

Resident Two's profile was first independently verified to exist.

Resident One then requested Resident Two's profile through the Data API.

Result:

`RowsReturned = 0`

Status: PASS

This demonstrates row-level isolation between residents.

---

### 5.3 Resident Updates Own Full Name

Resident One updated:

`full_name = Test Resident One Updated`

Result: PASS

Observed after the operation:

- updated full name was stored
- role remained `resident`
- account status remained `pending`

---

### 5.4 Resident Attempts Role Self-Promotion

Resident One attempted:

`role = barangay_admin`

Result:

- Blocked: `True`
- HTTP status: `403`
- PostgreSQL code: `42501`

Status: PASS

The authenticated resident role did not have sufficient privilege to modify
the protected role column.

---

### 5.5 Resident Attempts Account Self-Approval

Resident One attempted:

`account_status = approved`

Result:

- Blocked: `True`
- HTTP status: `403`
- PostgreSQL code: `42501`

Status: PASS

The resident could not modify the protected account workflow state.

---

## 6. Resident Verification RLS Tests

### 6.1 Submit Own Verification Request

Resident One submitted a verification request for their own profile.

Result: PASS

Observed:

- `resident_id` matched Resident One
- status defaulted to `pending`
- `submitted_at` was database-generated
- `reviewed_at` was NULL
- `reviewed_by` was NULL

---

### 6.2 Submit Verification for Another Resident

Resident One attempted to submit a verification request using Resident Two's
ID.

Result:

- Blocked: `True`
- HTTP status: `403`
- PostgreSQL code: `42501`
- RLS violation reported

Status: PASS

The resident-verification ownership policy prevented cross-resident
submission.

---

### 6.3 Duplicate Pending Verification

Resident One already had one pending request and attempted to create a
second pending request.

Result:

- Blocked: `True`
- HTTP status: `409`
- PostgreSQL code: `23505`

Database protection:

`uq_resident_verifications_one_pending`

Status: PASS

The partial unique index prevented multiple simultaneous pending requests for
the same resident.

---

### 6.4 Resident Attempts Self-Approval

Resident One attempted to update their verification status to:

`approved`

Result:

- Blocked: `True`
- HTTP status: `403`
- PostgreSQL code: `42501`

Status: PASS

Residents do not have UPDATE privilege over resident verification decisions.

---

### 6.5 Resident Reads Own Verification History

Resident One requested their own verification history through the authenticated
Data API.

Result: PASS

The existing pending request was returned.

---

### 6.6 Cross-Resident Verification History

Resident Two first created a valid pending verification request.

Resident One then requested Resident Two's specific verification record.

Result:

`RowsReturned = 0`

Status: PASS

This verifies cross-resident verification-history isolation.

---

## 7. Anonymous Access Tests

### 7.1 Anonymous Profile Read

A request was made with the local publishable API key but without an
authenticated resident access token.

Result:

- Blocked: `True`
- HTTP status: `401`
- PostgreSQL code: `42501`

Status: PASS

Anonymous callers could not read `public.profiles`.

---

### 7.2 Anonymous Verification Read

An unauthenticated request attempted to read
`public.resident_verifications`.

Result:

- Blocked: `True`
- HTTP status: `401`
- PostgreSQL code: `42501`

Status: PASS

Anonymous callers could not read verification records.

---

## 8. Database Constraint Tests

The following tests were intentionally executed as the PostgreSQL database
owner.

This bypassed ordinary resident permissions so that the database constraints
could be tested independently from RLS and client grants.

---

### 8.1 Invalid Role

Attempted value:

`super_admin`

Expected constraint:

`chk_profiles_role`

Result: REJECTED

PostgreSQL reported that the candidate row violated:

`chk_profiles_role`

Status: PASS

A follow-up query confirmed the original valid role remained:

`resident`

The failed update was atomic.

---

### 8.2 Invalid Account Status

Attempted value:

`suspended`

Expected constraint:

`chk_profiles_account_status`

Result: REJECTED

PostgreSQL reported a CHECK-constraint violation.

Status: PASS

A follow-up query confirmed the original valid account status remained:

`pending`

The failed update was atomic.

---

## 9. Full Name Boundary Tests

Constraint:

`chk_profiles_full_name`

The implemented rule requires the trimmed full name length to be within the
configured lower and upper bounds.

Observed boundary results:

- 1 character: REJECTED
- 2 characters: ACCEPTED
- 150 characters: ACCEPTED
- 151 characters: REJECTED

Status: PASS

This verifies both invalid sides and both exact valid boundaries of the
implemented rule.

---

## 10. Verification Review-State Constraint Tests

Constraint:

`chk_resident_verifications_review_state`

---

### 10.1 Approved Without Reviewer Metadata

Attempted state:

- status: `approved`
- reviewed_at: NULL
- reviewed_by: NULL

Result: REJECTED

Status: PASS

A follow-up query confirmed the request remained:

- status: `pending`
- reviewed_at: NULL
- reviewed_by: NULL

---

### 10.2 Pending With Reviewer Metadata

Attempted state:

- status: `pending`
- reviewed_at: populated
- reviewed_by: populated

Result: REJECTED

Status: PASS

A follow-up query confirmed the pending record remained unchanged.

---

### 10.3 Structurally Valid Reviewed State

A controlled PostgreSQL transaction temporarily changed synthetic Resident
Two to:

`barangay_admin`

The transaction then temporarily updated Resident One's verification to:

- status: `approved`
- reviewed_at: populated
- reviewed_by: Resident Two

Observed inside the transaction:

- status: `approved`
- review time present: `true`
- reviewer matched expected profile: `true`
- reviewer temporary role: `barangay_admin`

Result: ACCEPTED

Status: PASS

The transaction ended with:

`ROLLBACK`

Follow-up verification confirmed:

Resident Two:

- role: `resident`
- account status: `pending`

Resident One verification:

- status: `pending`
- reviewed_at: NULL
- reviewed_by: NULL

No artificial administrator role or approval was left in the test database.

Important limitation:

This test proves review-state consistency only.

It does not by itself prove that `reviewed_by` is always an authorized
Barangay Administrator. Authorization of administrator review operations must
also be enforced by the protected HelpHub administrator/backend workflow.

---

## 11. Local Migration Reset and Reproducibility

Command executed:

`npx.cmd supabase db reset`

Observed process included:

- resetting local database
- recreating database
- initializing schema
- applying migration
  `20260814012435_create_identity_foundation.sql`
- restarting containers
- successful reset completion

Observed final message:

`Finished supabase db reset on branch master.`

Status: PASS

A warning indicated that no file matched:

`supabase/seed.sql`

This was not treated as a failure because no seed file had been created for
this slice.

The reset intentionally removed all synthetic users and records created during
manual testing.

---

## 12. Post-Reset Migration Verification

After the clean reset, the following were independently verified again.

### 12.1 Tables

Recreated:

- `public.profiles`
- `public.resident_verifications`

Status: PASS

---

### 12.2 Row Level Security

Observed:

- `profiles.relrowsecurity = true`
- `resident_verifications.relrowsecurity = true`

Status: PASS

---

### 12.3 Auth User Trigger

Recreated trigger:

`on_auth_user_created`

Observed definition invoked:

`handle_new_auth_user()`

Status: PASS

This confirms Auth-to-profile creation is reproducible from the migration.

---

### 12.4 Profiles Grants and Policies

Verified after reset:

- authenticated table SELECT privilege
- authenticated UPDATE privilege only for `full_name`
- no authenticated column UPDATE privilege for protected role/status fields

Expected policies recreated:

- `profiles_select_own`
- `profiles_update_own`

Status: PASS

---

### 12.5 Resident Verification Grants and Policies

Verified after reset:

- authenticated table SELECT privilege
- authenticated INSERT privilege for `resident_id`
- no unrestricted authenticated UPDATE
- no authenticated DELETE
- no anonymous table access

Expected policies recreated:

- `resident_verifications_select_own`
- `resident_verifications_insert_own`

Status: PASS

---

## 13. Automated Database Regression Tests

Supabase pgTAP database testing was enabled through the installed Supabase CLI.

Verified CLI capability:

`supabase test db`

---

### 13.1 Structural Identity Test

File:

`supabase/tests/001_identity_foundation.test.sql`

Purpose:

Automates structural checks for:

- profiles table
- profile columns
- profile primary and foreign keys
- defaults
- CHECK constraints
- RLS
- policy set
- least-privilege grants
- resident_verifications table
- verification columns
- verification primary and foreign keys
- verification defaults and constraints
- one-pending partial unique index
- verification RLS
- verification policy set
- verification grants
- Auth-to-profile trigger
- profile write trigger
- required database functions

Result:

- Files: 1
- Tests: 34
- Result: PASS

Status: 34/34 PASS

---

### 13.2 Behavioral Identity/RLS Test

File:

`supabase/tests/002_identity_rls_behavior.test.sql`

Purpose:

Automates behavior checks for:

- malicious signup metadata cannot self-promote
- profile defaults
- resident sees own profile
- resident cannot see another resident profile
- own full-name update
- cross-resident profile update isolation
- role tampering denial
- account-status tampering denial
- own verification submission
- pending default behavior
- cross-resident verification submission denial
- duplicate pending verification denial
- self-approval denial
- own verification visibility
- Resident Two independent submission
- Resident Two own-row visibility
- cross-resident verification-history isolation
- anonymous profile denial
- anonymous verification denial

The test changes PostgreSQL execution context to the Supabase
`authenticated` and `anon` roles to exercise the real permission and RLS
behavior.

All synthetic test data is executed inside a transaction and rolled back.

Result:

- Files: 1
- Tests: 22
- Result: PASS

Status: 22/22 PASS

---

### 13.3 Combined Regression Suite

Command:

`npx.cmd supabase test db ".\supabase\tests"`

Observed result:

- Files: 2
- Tests: 56
- All tests successful
- Result: PASS

Final automated identity-foundation result:

**56/56 PASS**

---

## 14. Security Properties Demonstrated

The evidence collected in this slice demonstrates the following implemented
properties:

1. Public signup cannot assign itself the Barangay Administrator role.
2. New public accounts begin as Resident accounts.
3. New resident accounts begin in the pending workflow state.
4. Residents can read their own profile.
5. Residents cannot read another resident's profile.
6. Residents can modify their permitted profile name field.
7. Residents cannot modify their protected role.
8. Residents cannot directly approve their own account.
9. Residents can submit verification only for themselves.
10. Residents cannot create multiple simultaneous pending verification
    requests.
11. Residents cannot approve their own verification request.
12. Residents can read their own verification history.
13. Residents cannot read another resident's verification history.
14. Anonymous callers cannot read resident profile information.
15. Anonymous callers cannot read verification information.
16. Unsupported role values are rejected by PostgreSQL.
17. Unsupported account-status values are rejected by PostgreSQL.
18. Profile-name boundaries are enforced by PostgreSQL.
19. Verification review-state consistency is enforced by PostgreSQL.
20. Failed constraint writes are atomic.
21. The identity schema can be rebuilt from migration history.
22. RLS, grants, policies, triggers, and functions survive a clean database
    reset/replay.
23. Structural database regression tests are automated.
24. Behavioral RLS regression tests are automated.

---

## 15. Security Architecture Notes

HelpHub uses multiple security layers rather than relying on the Flutter
interface alone.

### PostgreSQL grants

Control which operations or columns a database role may attempt.

Example:

- resident can update `full_name`
- resident cannot update `role`
- resident cannot update `account_status`

### Row Level Security

Controls which records the authenticated resident may access.

Example:

- resident can see their own profile
- resident cannot see another resident's profile

### Database constraints

Protect valid database state even when more privileged server-side code writes
to the database.

Example:

- invalid roles rejected
- invalid account statuses rejected
- duplicate pending verification requests rejected
- inconsistent reviewed states rejected

### FastAPI authorization

Later HelpHub server-side workflows remain responsible for protected business
operations, including administrator review actions and other authoritative
state transitions.

The Flutter client must not become the authority for protected roles,
verification decisions, priority values, report routing, deadlines, or other
server-controlled business rules.

---

## 16. Data and Privacy Notes

All identities used in these tests were synthetic local development records.

No real resident personal data was required.

The clean `supabase db reset` removed the manual synthetic test records.

Automated pgTAP test records are executed inside transactions and end with
`ROLLBACK`.

No passwords, service-role keys, Supabase secret keys, database passwords,
Firebase private keys, private certificates, or other production credentials
are intentionally stored in the migration or test files.

Credential-pattern scans were performed before the tested files were prepared
for commit.

---

## 17. Known Limitations and Deferred Work

This evidence does not yet prove:

- complete administrator verification-review API behavior
- administrator dashboard behavior
- production user provisioning
- production Supabase configuration
- concern-report database schema
- status-history records
- audit events
- evidence/photo storage policies
- report assignment
- concern routing
- weighted-priority calculation
- rule/weight configuration
- SOS emergency records
- notifications
- announcements
- production deployment behavior

Those belong to later HelpHub slices and must receive their own migrations,
RLS policies, tests, and evidence.

Exact verification-document fields are also intentionally deferred until their
requirements and privacy handling are formally defined within the project.

---

## 18. Reproduction Commands

From the HelpHub repository root:

### Rebuild the local database

`npx.cmd supabase db reset`

### Run all current database tests

`npx.cmd supabase test db ".\supabase\tests"`

Expected current identity-foundation automated result:

`Files=2, Tests=56, Result: PASS`

---

## 19. Evidence Summary

Identity migration application: PASS

Manual Auth/profile behavior: PASS

Resident profile RLS: PASS

Resident verification RLS: PASS

Anonymous denial tests: PASS

Least-privilege permission tests: PASS

Database constraint tests: PASS

Boundary tests: PASS

Verification state-consistency tests: PASS

Transaction rollback checks: PASS

Clean migration reset/replay: PASS

Post-reset RLS recreation: PASS

Post-reset grants/policies recreation: PASS

Post-reset Auth trigger recreation: PASS

Structural pgTAP suite: 34/34 PASS

Behavioral pgTAP suite: 22/22 PASS

Combined pgTAP suite: 56/56 PASS

---

## 20. Task Gate Status

The identity-foundation implementation and technical verification represented
by this document are considered:

**PASS**

for the tested database slice.

Task 04.2 as a repository change is not considered fully closed until:

- this evidence document is saved and reviewed
- final Git staged-integrity check passes
- final credential-value scan passes
- migration and test files remain staged correctly
- the documentation file is staged
- the final combined test result remains PASS
- the changes are committed

Only after those repository checks are verified should Task 04.2 be marked
complete and the team proceed to the next Stage 4 slice.