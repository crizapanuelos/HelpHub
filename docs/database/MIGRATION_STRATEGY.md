# HelpHub Database Migration Strategy

Last reviewed: 2026-08-14

## 1. Purpose

This document defines how database schema changes for HelpHub are created, reviewed, tested, versioned, and committed.

The objective is to keep the Supabase PostgreSQL database:

- reproducible;
- auditable;
- secure;
- deterministic;
- compatible with the approved HelpHub architecture;
- traceable to system requirements and study objectives.

The database schema must be reproducible from source-controlled migration files.

Manual database changes made only through Supabase Studio are not considered the source of truth.

---

## 2. Database Technology

HelpHub uses:

- Supabase PostgreSQL;
- Supabase Auth;
- Supabase Storage;
- Supabase Realtime;
- Supabase Row Level Security (RLS).

The application database will be accessed through:

- Flutter for permitted client operations;
- FastAPI for protected server-side operations and business rules.

FastAPI remains the authoritative backend boundary for protected workflow and priority-algorithm decisions.

---

## 3. Migration Source of Truth

All application schema migrations must be stored under:

```text
supabase/migrations/
```

Migration files are committed to Git.

A schema change that exists only in a developer's local database or Supabase Studio is incomplete until it is represented in a migration.

The expected migration filename format is:

```text
YYYYMMDDHHMMSS_descriptive_name.sql
```

Migration names must use lowercase `snake_case`.

Good examples:

```text
create_identity_foundation
create_report_foundation
create_status_history_and_audit
create_algorithm_configuration
create_emergency_foundation
add_report_assignment_indexes
```

Avoid vague names such as:

```text
migration1
database_update
final
final_final
test
changes
new_tables
```

---

## 4. Creating a Migration

Use the repository-local Supabase CLI.

From the HelpHub repository:

```powershell
npx.cmd supabase migration new <descriptive_name>
```

Example:

```powershell
npx.cmd supabase migration new create_identity_foundation
```

The generated SQL file must be reviewed before it is applied.

Do not manually invent migration timestamps when the Supabase CLI can generate them.

---

## 5. Migration History Rule

Migration history is treated as forward-moving.

While a migration is still local, unshared, and not part of an agreed development checkpoint, it may be corrected during implementation.

Once a migration has been:

- committed as an accepted checkpoint;
- shared with the team;
- applied to a shared environment; or
- used as part of deployment history,

do not silently rewrite it.

Create a new migration for subsequent changes.

Examples:

```text
create_identity_foundation
add_profile_verification_fields
add_profile_lookup_index
```

This preserves database history and makes failures easier to trace.

---

## 6. Application Schema

HelpHub application tables will normally use the PostgreSQL:

```text
public
```

schema unless a specific Supabase-managed or security-related requirement justifies another schema.

Do not create application tables inside Supabase-managed schemas such as:

```text
auth
storage
```

Those schemas are owned by their respective Supabase services.

Application tables may reference Supabase-managed records where appropriate.

---

## 7. Naming Conventions

### Tables

Use plural lowercase `snake_case` names.

Examples:

```text
profiles
resident_verifications
reports
report_locations
report_evidence
status_history
assignments
admin_notes
audit_events
algorithm_runs
```

### Columns

Use lowercase `snake_case`.

Examples:

```text
created_at
updated_at
resident_id
report_id
priority_score
algorithm_version
```

### Primary keys

Use:

```text
id
```

unless a strong database-design reason requires otherwise.

### Foreign keys

Use the referenced entity name followed by `_id`.

Examples:

```text
resident_id
report_id
assigned_admin_id
rule_version_id
```

### Indexes

Use descriptive names such as:

```text
idx_reports_resident_id
idx_reports_created_at
idx_status_history_report_id
```

### Unique constraints

Use descriptive names such as:

```text
uq_profiles_user_id
```

### Check constraints

Use descriptive names such as:

```text
chk_reports_affected_population_nonnegative
```

Names should explain what the database object protects.

---

## 8. Identifier Strategy

Application entities will normally use PostgreSQL UUID primary keys.

Use PostgreSQL/Supabase-supported UUID generation rather than generating authoritative database identifiers in Flutter.

Supabase-authenticated users are identified by:

```text
auth.users.id
```

Application profile/account tables may reference that UUID.

The exact foreign-key behavior for user deletion must be chosen deliberately based on privacy, retention, and audit requirements.

Do not add destructive cascading behavior merely for convenience.

---

## 9. Timestamp Strategy

Use:

```text
timestamptz
```

for application timestamps.

Store timestamps in a timezone-aware format.

Typical columns include:

```text
created_at
updated_at
submitted_at
acknowledged_at
closed_at
deadline_at
captured_at
```

Where appropriate, creation timestamps should default to:

```sql
now()
```

Do not store important system timestamps as free-form text.

Client-provided timestamps must not automatically be trusted as authoritative server timestamps.

---

## 10. Nullability

Use `NOT NULL` when the system requires a value for a valid record.

Allow `NULL` only when absence has a clear meaning.

Do not make every column nullable merely to avoid validation errors.

Required fields should be protected at multiple layers:

1. Flutter validation;
2. FastAPI validation;
3. PostgreSQL constraints where appropriate.

Database constraints are the final integrity boundary.

---

## 11. Foreign Keys

Relationships must use explicit foreign-key constraints where applicable.

Every foreign key must deliberately define its deletion behavior.

Possible behaviors include:

```text
RESTRICT
NO ACTION
SET NULL
CASCADE
```

Do not choose `CASCADE` automatically.

HelpHub requires traceability, especially for:

- reports;
- status history;
- emergency records;
- algorithm runs;
- assignments;
- audit events.

Records required for traceability must not disappear silently because a parent record was deleted.

---

## 12. Deletion and Retention

HelpHub must not silently delete reports.

Report lifecycle should use traceable states such as closed or archived when required by the approved workflow.

Historical records needed for:

- status history;
- algorithm reproducibility;
- emergency tracking;
- audit evidence;

must be preserved according to the eventual approved retention policy.

Physical deletion must be deliberate and justified.

Do not implement convenience delete buttons that bypass retention and audit requirements.

---

## 13. Constraints

Use database constraints to protect valid data.

Appropriate mechanisms include:

```text
NOT NULL
FOREIGN KEY
UNIQUE
CHECK
```

Examples of appropriate constraint categories include:

- nonnegative counts;
- valid numeric ranges;
- required relationships;
- one-to-one relationships;
- uniqueness requirements.

Do not use constraints to invent unresolved study decisions.

For example, do not hard-code unapproved:

- priority thresholds;
- rating anchors;
- handlers;
- response deadlines;
- concern categories.

Those decisions must come from documented HelpHub configuration.

---

## 14. Domain Values and Enums

Do not use PostgreSQL enums casually for values likely to change through project configuration.

Mutable or administratively controlled values should normally use reference/configuration tables.

Examples include:

- concern classifications;
- algorithm factors;
- rule definitions;
- routing definitions;
- threshold configurations;
- deadline configurations.

Stable internal technical states may use constrained values when appropriate, but the exact states must first be defined by the approved workflow.

Do not invent missing workflow states during migration design.

---

## 15. Algorithm Configuration

The Rule-Based Weighted Priority Queue Algorithm must use versioned configuration.

Do not hard-code final rules, weights, normalized rating anchors, thresholds, handlers, or deadlines into unrelated application tables.

The schema must eventually support preservation of:

```text
algorithm_version
rule_version
weight_version
factor values
normalized ratings
matched rules
score breakdown
override reason
classification
priority
route
deadline
queue key
```

Historical algorithm runs must remain interpretable using the configuration versions that produced them.

The same input with the same algorithm, rule, and weight versions must be reproducible.

---

## 16. Priority Levels

The current HelpHub priority names are:

```text
Low
Medium
High
Critical
```

Do not reintroduce the obsolete:

```text
Minimal
```

Numeric threshold boundaries must not be invented merely to satisfy a database migration.

They will be stored only after documented development configuration decisions exist.

---

## 17. Emergency Override

Confirmed SOS events or approved verified life-threatening rules may produce a Critical override.

The database must eventually preserve:

- whether an override occurred;
- the reason;
- the configuration/rule responsible;
- the algorithm run;
- the resulting priority.

SOS information must remain traceable.

HelpHub does not replace official police, fire, medical, or national emergency services.

---

## 18. Status History

Every report status transition must eventually produce a persistent status-history record.

A report's current status alone is insufficient.

The schema must preserve:

```text
previous status
new status
actor
timestamp
relevant note/reason when applicable
```

The exact approved status values will be defined before the corresponding migration is finalized.

---

## 19. Audit Events

Protected administrative and workflow actions must produce audit records.

Audit events must eventually cover operations such as:

- verification decisions;
- assignments;
- report status changes;
- emergency acknowledgements;
- protected configuration changes;
- rule/weight activation;
- other privileged administrative actions.

Audit history must not be silently editable by normal client users.

---

## 20. Location Data

HelpHub does not continuously track residents.

Location records must support one-time/on-demand capture associated with the relevant action.

Required location fields will include, where available:

```text
latitude
longitude
accuracy
capture time
optional human-readable address
```

Location and SOS information are sensitive data.

Access must be restricted through RLS and backend authorization.

---

## 21. Evidence Storage

Report photo evidence will use Supabase Storage.

Evidence must not be placed in a public bucket by default.

Database records should eventually store metadata and controlled references to Storage objects rather than treating a public URL as the security model.

Upload restrictions will later include:

- permitted MIME types;
- size limits;
- authenticated ownership/access rules;
- protected retrieval rules.

---

## 22. Row Level Security

RLS must be enabled on application-facing tables where users could otherwise access records through Supabase APIs.

RLS is not optional merely because FastAPI exists.

HelpHub uses defense in depth:

```text
Flutter validation
+
FastAPI authorization
+
PostgreSQL constraints
+
Supabase RLS
```

Policies must follow least privilege.

Residents must not gain administrator access by manipulating client requests.

Administrators must receive only the privileges required for their role.

Sensitive GPS, emergency, verification, and evidence data require especially careful policies.

---

## 23. Security-Definer Functions

PostgreSQL functions using:

```sql
SECURITY DEFINER
```

must be used only when necessary.

Such functions require careful review because they execute with elevated database privileges.

When used, explicitly control the function `search_path` and validate authorization assumptions.

Do not use elevated functions as an easy replacement for proper RLS design.

---

## 24. Index Strategy

Indexes should support demonstrated query patterns.

Likely index categories include:

- foreign-key lookups;
- report-owner queries;
- status-history queries;
- administrator queue queries;
- deadline ordering;
- priority ordering;
- submission-time ordering.

Do not add indexes blindly to every column.

Each index adds storage and write overhead.

The deterministic report queue will eventually require efficient support for ordering by:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending;
5. report ID ascending.

The final queue index design will be validated when the algorithm schema is implemented.

---

## 25. RLS and Migration Order

A table exposed through Supabase APIs must not remain unintentionally open.

The preferred implementation slice is:

1. create table;
2. add constraints;
3. add required indexes;
4. enable RLS;
5. add policies;
6. test authorized behavior;
7. test unauthorized behavior;
8. commit only after verification.

When practical, schema and its minimum safe RLS configuration should be part of the same verified development slice.

---

## 26. Supabase Studio

Supabase Studio may be used for:

- inspecting schema;
- inspecting data;
- debugging;
- reviewing RLS;
- running controlled development queries.

Do not use Studio as the primary way to permanently create application tables.

If an experimental Studio change is worth keeping, reproduce it in a migration before considering the work complete.

---

## 27. Local Reset Verification

A key definition of success is that a fresh local database can be rebuilt from repository migrations.

The eventual verification command is:

```powershell
npx.cmd supabase db reset
```

This command is destructive to local development data.

Do not run it casually once useful local test data exists.

Before running a reset:

1. confirm the environment is local;
2. verify no needed local-only data will be lost;
3. ensure migrations are committed or intentionally staged;
4. record required test evidence.

A successful reset should recreate the expected schema from migration history.

---

## 28. Seed Data

Seed data must not contain:

- real resident personal information;
- real GPS histories;
- production credentials;
- private evidence;
- secret API keys.

Development seed records should be synthetic.

Algorithm configuration seed data must not pretend unresolved candidate values are formally approved.

Where values are still undecided, leave them absent or clearly documented as development configuration.

---

## 29. Secret Safety

Never place credentials in migration files.

Do not commit:

```text
Supabase secret keys
database passwords
service-role credentials
Firebase service-account credentials
private keys
production connection strings
```

Migration SQL must remain safe to store in Git.

---

## 30. Migration Verification Checklist

Before committing a migration, verify:

- the SQL syntax is valid;
- the migration applies successfully;
- required tables/columns exist;
- primary keys exist;
- foreign keys are correct;
- deletion behavior is intentional;
- required constraints exist;
- required indexes exist;
- RLS is enabled where applicable;
- policies permit valid access;
- policies deny invalid/unauthorized access;
- no credentials are present;
- `git diff --check` passes;
- local reset/rebuild succeeds when required for the slice;
- documentation is updated.

Do not claim a migration is complete without evidence.

---

## 31. Git Commit Strategy

Keep migration commits focused.

Examples:

```text
feat(db): create identity foundation
feat(db): add resident verification schema
feat(db): create report foundation
feat(db): add status history and audit schema
feat(db): create algorithm configuration schema
```

Avoid combining unrelated Flutter UI work, FastAPI implementation, and multiple database modules into one migration commit.

Small commits improve review, testing, traceability, and rollback analysis.

---

## 32. HelpHub Initial Migration Order

The current planned database implementation order is:

```text
1. identity/profile/resident verification foundation
2. concern/reference-data foundation
3. reports/location/evidence foundation
4. status history/assignment/audit foundation
5. algorithm/versioning foundation
6. emergency response foundation
7. notifications/announcements/supporting tables
8. configuration-management structures
9. RLS/security verification
10. reset/reproducibility verification
```

This order may be adjusted only when a dependency requires it.

Do not implement several unverified modules in one migration simply to move faster.

---

## 33. Current Baseline

At the start of Task 04.2:

- local Supabase is operational;
- PostgreSQL is running;
- Auth is available;
- Storage is available;
- Realtime is available;
- Studio uses local port `44323`;
- Mailpit uses local port `44324`;
- local Analytics is disabled for the verified Windows development configuration;
- no HelpHub application migrations exist yet;
- no HelpHub production tables have been created;
- no HelpHub RLS policies have been created;
- no production/cloud project has been linked.

This is the clean starting point for database implementation.