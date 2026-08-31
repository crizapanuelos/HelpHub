# HelpHub Data Dictionary

## Document Control

- Project: HelpHub — A Mobile-Based Barangay Concern Reporting Application Using a Rule-Based Weighted Priority Queue Algorithm with Emergency Response Module
- Roadmap phase: Stage 3 — Requirements, Diagrams, and Privacy Review
- Task: 03.13 — Data Dictionary
- GitHub issue: #14
- Status: DRAFT — NOT YET STAKEHOLDER APPROVED
- Scope: Requirements-level logical data definitions reconciled with the current repository schema foundations
- Physical-schema authority: Supabase migrations remain authoritative for structures already implemented
- Configuration authority: Approved, versioned stakeholder configuration remains authoritative for concern types, rules, weights, thresholds, routing, deadlines, statuses, transitions, and emergency policy

---

## 1. Purpose

This document defines the meaning, ownership, sensitivity, lifecycle, validation expectations, and relationships of data used by HelpHub.

It serves four purposes:

1. provide a common vocabulary for requirements, diagrams, implementation, tests, and documentation;
2. reconcile the approved study with database structures already present in the repository;
3. identify required data that has not yet been physically implemented;
4. prevent provisional engineering structures from being mistaken for final barangay policy.

This document is not a replacement for PostgreSQL migrations.

When this document describes a field as physically implemented, the applicable migration remains the technical source of truth for the actual PostgreSQL type, constraint, foreign key, privilege, and RLS behavior.

---

## 2. Data-Definition Status Labels

The following labels are used throughout this document.

| Label | Meaning |
|---|---|
| IMPLEMENTED | The repository already contains a database structure representing this data. |
| REQUIRED-FUTURE | The approved HelpHub scope requires this data, but its final physical schema has not yet been implemented. |
| DEFERRED-CONFIG | The structure or concept is known, but actual policy values must not be invented before documented approval. |
| ENGINEERING-DEFAULT | A technical value selected for security or implementation reasons rather than as barangay operational policy. |
| PROVISIONAL | Present in a design or proposed workflow but not yet documented as final stakeholder-approved policy. |

A data element may have more than one applicable label.

---

## 3. Global Data Rules

### 3.1 Identifiers

Repository entities currently use UUID identifiers unless another type is explicitly defined by a migration.

Identifiers used in URLs, APIs, logs, notifications, or client-side state must not be treated as authorization proof.

Server-side authorization must independently verify the authenticated identity and requested resource.

### 3.2 Timestamps

Authoritative server/database timestamps use timezone-aware values.

Device-captured time and server-received time are separate concepts and must not be silently substituted for one another.

Examples:

- `report_locations.captured_at` = device/location-provider capture time;
- `reports.submitted_at` = server-side report submission time.

### 3.3 Historical preservation

Reports, status histories, routing histories, emergency records, algorithm decision evidence, and audit evidence must not silently disappear because a profile or configuration record is removed.

Existing repository relationships therefore generally use deletion restriction where historical traceability is required.

Final retention, anonymization, archival, and lawful deletion rules remain subject to the Stage 3 privacy review and stakeholder decision process.

### 3.4 Configuration versioning

Operational policy that can change over time must be versioned rather than silently edited in place when historical reproducibility depends on it.

This applies to at least:

- concern taxonomy;
- rule configuration;
- algorithm version;
- factor-rating definitions;
- weights;
- score thresholds;
- routing configuration;
- response deadlines;
- report lifecycle configuration;
- approved non-SOS Critical override rules.

### 3.5 Current state versus history

HelpHub distinguishes current operational snapshots from permanent history.

A current-state record answers:

> What is true now?

A history record answers:

> What happened, in what order, under which configuration, and who or what caused it?

History must not be replaced by continually overwriting a single current-state value.

### 3.6 Audit evidence versus business history

Audit events and business history are related but not identical.

Business history records domain-specific changes such as status or routing history.

Audit evidence records authoritative actions for accountability and security traceability.

Where required, one authoritative operation must create both records atomically.

### 3.7 Secrets

Passwords, authentication credentials, access tokens, service-role keys, signing material, private certificates, and other secrets are not HelpHub application-profile fields and must never be copied into audit details, report notes, configuration notes, or other general application tables.

---

# 4. Identity and Authentication Data

## 4.1 Supabase Auth User

**Status:** IMPLEMENTED through Supabase Auth.

Authentication credentials are managed by Supabase Auth rather than duplicated in HelpHub application tables.

HelpHub application records reference the authenticated user through the matching profile UUID.

The exact internal Supabase Auth schema is outside the HelpHub application data dictionary.

---

## 4.2 `public.profiles`

**Status:** IMPLEMENTED.

**Purpose:** Application-side representation of a HelpHub authenticated identity.

**Cardinality:** One HelpHub profile corresponds to one Supabase Auth user.

| Field | Type | Required | Meaning / rule |
|---|---|---:|---|
| `id` | UUID | Yes | Primary key and exact matching `auth.users.id`. |
| `full_name` | Text | Yes | Resident/admin display name. Trimmed; current DB constraint is 2–150 characters. |
| `role` | Text | Yes | HelpHub application role. Current values: `resident`, `barangay_admin`. |
| `account_status` | Text | Yes | Current engineering-defined account workflow state. |
| `created_at` | Timestamp with time zone | Yes | Database creation timestamp. |
| `updated_at` | Timestamp with time zone | Yes | Most recent profile-update timestamp. |

### Current repository role values

- `resident`
- `barangay_admin`

These are the only HelpHub authenticated application roles in the approved scope.

External police, fire, medical, city, national, or other organizations are not HelpHub authenticated roles unless the study is formally revised.

### Current repository account-status values

- `pending`
- `approved`
- `rejected`
- `restricted`

**Governance note:** These are current implemented engineering workflow states. Final account-management transition policy must remain documented and traceable.

### Authorization rule

Public sign-up must never accept a client-supplied administrator role as authoritative.

New public accounts are created as:

- role = `resident`;
- account status = `pending`.

Role or protected account-state changes must be authoritative server/admin operations.

---

## 4.3 Approved Resident Authorization Condition

**Status:** IMPLEMENTED as `public.is_approved_resident()`.

An approved Resident currently means:

- authenticated HelpHub profile exists;
- `role = resident`;
- `account_status = approved`.

This is an authorization condition, not a third role.

---

## 4.4 Approved Barangay Administrator Authorization Condition

**Status:** IMPLEMENTED as `public.is_approved_barangay_admin()`.

An approved Barangay Administrator currently means:

- authenticated HelpHub profile exists;
- `role = barangay_admin`;
- `account_status = approved`.

This is an authorization condition, not a separate application role.

---

# 5. Resident Verification Data

## 5.1 `public.resident_verifications`

**Status:** IMPLEMENTED.

**Purpose:** Preserve Resident verification requests and their administrative review outcome.

| Field | Type | Required | Meaning / rule |
|---|---|---:|---|
| `id` | UUID | Yes | Unique verification-request identifier. |
| `resident_id` | UUID | Yes | Resident profile submitting the verification request. |
| `status` | Text | Yes | Current verification-request state. |
| `submitted_at` | Timestamp with time zone | Yes | Database timestamp when request was submitted. |
| `reviewed_at` | Timestamp with time zone | Conditional | Review timestamp; absent while pending. |
| `reviewed_by` | UUID | Conditional | Administrator profile responsible for completed review. |

### Current verification values

- `pending`
- `approved`
- `rejected`

A Resident may have verification history but may not have more than one pending verification request simultaneously.

Completed review requires both:

- `reviewed_at`;
- `reviewed_by`.

### Verification evidence

**Status:** REQUIRED-FUTURE / DEFERRED-CONFIG.

The current repository deliberately does not invent fields such as:

- national identification number;
- identification-document type;
- identification-document image;
- proof-of-residency document;
- document expiration date.

The actual verification evidence requirement, storage location, access rule, retention period, and privacy handling must be approved before such fields are introduced.

---

# 6. Audit Data

## 6.1 `public.audit_events`

**Status:** IMPLEMENTED.

**Purpose:** Append-only evidence of authoritative HelpHub actions.

| Field | Type | Required | Meaning / rule |
|---|---|---:|---|
| `id` | UUID | Yes | Unique audit-event identifier. |
| `actor_id` | UUID | No | HelpHub profile associated with the action; nullable for approved future system-generated actions. |
| `action` | Text | Yes | Audit action identifier/name. |
| `entity_type` | Text | Yes | Logical type of entity affected. |
| `entity_id` | UUID | No | Affected entity identifier when applicable. |
| `details` | JSON object | Yes | Minimal structured audit context. |
| `created_at` | Timestamp with time zone | Yes | Database-generated audit-event timestamp. |

### Audit rules

- Existing audit rows are append-only.
- Audit events must not contain passwords, credentials, authentication tokens, service keys, or unnecessary personal data.
- `action` and `entity_type` are extensible validated text, not a finalized audit taxonomy.
- `resident_verification.reviewed` is a currently implemented engineering audit action identifier.
- Final audit vocabulary may expand as modules are implemented.

---

# 7. Concern Taxonomy Data

## 7.1 `public.concern_taxonomy_versions`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG values.

**Purpose:** Version-container for one HelpHub concern taxonomy snapshot.

| Field | Meaning |
|---|---|
| `id` | Taxonomy-version UUID. |
| `version_number` | Positive unique engineering version number. |
| `version_label` | Optional human-readable version label. |
| `notes` | Optional non-secret administrative notes. |
| `created_by` | Administrator associated with creation when available. |
| `created_at` | Creation timestamp. |
| `activated_by` | Administrator associated with activation. |
| `activated_at` | Activation timestamp. |
| `retired_by` | Administrator associated with retirement. |
| `retired_at` | Retirement timestamp. |

### Repository lifecycle interpretation

Draft:

- `activated_at` is NULL;
- `retired_at` is NULL.

Active:

- `activated_at` is not NULL;
- `retired_at` is NULL.

Retired:

- `activated_at` is not NULL;
- `retired_at` is not NULL.

At most one taxonomy version may currently be active.

Actual concern-category values remain stakeholder-controlled configuration.

---

## 7.2 `public.concern_types`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG values.

**Purpose:** Versioned concern-type definition.

| Field | Meaning |
|---|---|
| `id` | Version-specific concern-type UUID. |
| `taxonomy_version_id` | Owning taxonomy version. |
| `code` | Machine-readable concern-type code within the version. |
| `name` | Human-readable concern-type label. |
| `description` | Optional description of scope. |
| `display_order` | Deterministic display order within the version. |
| `is_enabled` | Availability flag in the configuration snapshot. |
| `created_at` | Creation timestamp. |

No final concern-type names or codes are approved by this dictionary.

---

# 8. Routing Configuration Data

## 8.1 `public.routing_config_versions`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG values.

**Purpose:** Version-container for routing configuration associated with a concern taxonomy.

| Field | Meaning |
|---|---|
| `id` | Routing-version UUID. |
| `taxonomy_version_id` | Taxonomy for which the routing configuration is defined. |
| `version_number` | Positive engineering version number. |
| `version_label` | Optional human-readable label. |
| `notes` | Optional non-secret administrative notes. |
| `created_by` | Associated creator profile when available. |
| `created_at` | Creation timestamp. |
| `activated_by` | Associated activating administrator. |
| `activated_at` | Activation timestamp. |
| `retired_by` | Associated retiring administrator. |
| `retired_at` | Retirement timestamp. |

### Clarification required

The current schema does not make `routing_config_versions.version_number` unique.

Before final configuration-management implementation, the project must document whether routing version numbers are intended to be:

- globally unique; or
- unique only within one taxonomy version.

This dictionary does not choose between those policies.

---

## 8.2 `public.routing_destinations`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG actual destinations.

**Purpose:** Versioned routing destination used by HelpHub administrative handling.

| Field | Meaning |
|---|---|
| `id` | Routing-destination UUID. |
| `routing_version_id` | Owning routing version. |
| `code` | Machine-readable code within that routing version. |
| `name` | Human-readable destination name. |
| `destination_kind` | Structural kind of destination. |
| `description` | Optional administrative description. |
| `display_order` | Deterministic administrative display position. |
| `is_enabled` | Availability in the configuration snapshot. |
| `created_at` | Creation timestamp. |

### Current engineering-defined destination kinds

- `internal_handler`
- `external_referral`

`external_referral` means a HelpHub administrator may record manual referral or coordination with an outside organization.

It does not mean:

- that organization is a HelpHub user;
- HelpHub automatically dispatches the concern;
- HelpHub is electronically integrated with that organization;
- the organization accepted the concern;
- a response is guaranteed.

---

## 8.3 `public.concern_type_routes`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG mappings.

**Purpose:** Version-compatible concern-type-to-destination mapping.

| Field | Meaning |
|---|---|
| `id` | Route-mapping UUID. |
| `routing_version_id` | Routing version owning the mapping. |
| `taxonomy_version_id` | Taxonomy version used for compatibility enforcement. |
| `concern_type_id` | Versioned concern type being routed. |
| `destination_id` | Versioned routing destination. |
| `is_enabled` | Availability flag. |
| `notes` | Optional non-secret administrative notes. |
| `created_at` | Creation timestamp. |

### Current repository cardinality

At most one configured destination is currently permitted for one concern type in one routing version.

Final policy concerning:

- multiple handlers;
- secondary destinations;
- escalation destinations;
- manual routing overrides;

remains subject to documented stakeholder approval.

---

# 9. Normal Concern Report Data

## 9.1 `public.reports`

**Status:** IMPLEMENTED.

**Purpose:** Preserve raw Resident-submitted normal concern-report data.

| Field | Type | Required | Meaning / rule |
|---|---|---:|---|
| `id` | UUID | Yes | Unique normal-report identifier. |
| `resident_id` | UUID | Yes | Authoritative Resident profile that submitted the report. |
| `taxonomy_version_id` | UUID | Yes | Taxonomy version valid for the selected concern type. |
| `concern_type_id` | UUID | Yes | Resident-selected versioned concern type. |
| `description` | Text | Yes | Raw Resident description. |
| `resident_declared_urgency` | Text | Yes | Resident-provided urgency input. It is not authoritative system priority. |
| `affected_population` | Integer | Yes | Resident-declared number of affected people. Current DB minimum is zero. |
| `has_vulnerable_group` | Boolean | Yes | Resident indication that a vulnerable group is affected. |
| `submitted_at` | Timestamp with time zone | Yes | Server/database submission time. |

### Normal-report authority rules

`resident_id` must be derived or validated against the authenticated approved Resident by the protected backend.

Client-controlled input must never be allowed to submit a report on behalf of another Resident merely by supplying another UUID.

The selected concern type must be valid for the report's recorded taxonomy version.

### Resident urgency versus HelpHub priority

These are separate data concepts.

`resident_declared_urgency`:

- is Resident input;
- may become one factor considered by the algorithm;
- does not directly determine authoritative priority.

Authoritative HelpHub priority:

- is produced by protected deterministic algorithm processing;
- must preserve the configuration and calculation evidence that produced it.

Final urgency choices/rating anchors remain DEFERRED-CONFIG.

---

# 10. Normal Report Location Data

## 10.1 `public.report_locations`

**Status:** IMPLEMENTED.

**Purpose:** One-time normal-report location snapshot.

**Cardinality:** At most one stored location snapshot for one normal report.

| Field | Meaning / rule |
|---|---|
| `report_id` | Report owning the location snapshot. |
| `latitude` | WGS84 latitude; current valid range -90 to 90. |
| `longitude` | WGS84 longitude; current valid range -180 to 180. |
| `accuracy_meters` | Device-reported horizontal accuracy in meters; non-negative. |
| `captured_at` | Location-provider/device capture timestamp. |
| `address` | Optional human-readable address. |

### Privacy rule

This record represents location captured for a specific report.

It must not be used as a basis for continuous Resident tracking.

Location data is privacy-sensitive and requires least-privilege access, appropriate retention rules, and special consideration in the Stage 3 privacy review.

---

# 11. Normal Report Photo Evidence Data

## 11.1 `public.report_evidence`

**Status:** IMPLEMENTED.

**Purpose:** Metadata referencing optional normal-report photo evidence stored in private Supabase Storage.

**Current cardinality:** Zero or one photo-evidence record per report.

| Field | Meaning |
|---|---|
| `report_id` | Associated normal report. |
| `bucket_id` | Private Supabase Storage bucket identifier. |
| `object_path` | Storage object path. |
| `content_type` | Recorded MIME type. |
| `size_bytes` | Uploaded object size in bytes. |
| `uploaded_at` | Server-side evidence-metadata creation timestamp. |

### Current engineering defaults

Storage bucket:

- `report-evidence`

Allowed MIME types:

- `image/jpeg`
- `image/png`
- `image/webp`

Maximum file size:

- 5 MiB

These are ENGINEERING-DEFAULT security controls, not barangay policy values.

The actual image bytes are not stored in PostgreSQL.

Private bucket status alone is not sufficient proof of complete object-level security. Storage upload/read policies must also be implemented and tested.

---

# 12. Report Lifecycle Configuration

## 12.1 `public.report_lifecycle_versions`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG workflow.

**Purpose:** Version one complete report-lifecycle configuration.

Important fields include:

- `id`;
- `version_number`;
- `version_label`;
- `notes`;
- creation metadata;
- activation metadata;
- retirement metadata.

At most one lifecycle configuration may currently be active.

Final normal-report status vocabulary and transition policy are not established by this dictionary.

---

## 12.2 `public.report_status_definitions`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG values.

**Purpose:** Define statuses belonging to one lifecycle configuration version.

Important fields:

- `id`;
- `lifecycle_version_id`;
- `code`;
- `name`;
- `description`;
- `display_order`;
- `is_enabled`;
- `is_initial`;
- `created_at`.

The database currently permits at most one status per lifecycle version to have `is_initial = true`.

A future lifecycle-activation operation must verify that an activated production version contains exactly one enabled initial status.

### Proposed status terminology

Any status terminology described elsewhere in Stage 3 requirements remains PROVISIONAL until stakeholder approval is documented.

This dictionary does not seed or approve final status names.

---

## 12.3 `public.report_status_transitions`

**Status:** IMPLEMENTED structure / DEFERRED-CONFIG values.

**Purpose:** Define permitted status-to-status transitions within one lifecycle version.

Important fields:

- `id`;
- `lifecycle_version_id`;
- `from_status_id`;
- `to_status_id`;
- `notes`;
- `is_enabled`;
- `created_at`.

A transition cannot move a status to itself.

Both FROM and TO statuses must belong to the same lifecycle version.

---

# 13. Current Report Lifecycle State

## 13.1 `public.report_lifecycle_states`

**Status:** IMPLEMENTED structure.

**Purpose:** Fast operational snapshot of a report's current lifecycle status.

| Field | Meaning |
|---|---|
| `report_id` | Normal report represented by the snapshot. |
| `lifecycle_version_id` | Lifecycle configuration governing the report state. |
| `current_status_id` | Current configured status. |
| `status_changed_by` | Profile associated with latest status change; may be NULL for approved future system actions. |
| `status_changed_at` | Time the report entered the current status. |
| `created_at` | Time lifecycle tracking was established. |
| `updated_at` | Most recent snapshot update time. |
| `source_history_id` | Immutable status-history row that produced the current snapshot. |

A current lifecycle snapshot is mutable operational data.

It must never replace the complete status history.

---

# 14. Report Status History

## 14.1 `public.report_status_history`

**Status:** IMPLEMENTED structure.

**Purpose:** Append-only ordered history of normal-report lifecycle events.

| Field | Meaning |
|---|---|
| `id` | Status-history event UUID. |
| `report_id` | Parent normal report. |
| `sequence_number` | Positive deterministic per-report order. |
| `lifecycle_version_id` | Lifecycle version governing the event. |
| `from_status_id` | Previous status; NULL only for initial lifecycle establishment. |
| `to_status_id` | Status entered by the event. |
| `transition_id` | Configured transition used; NULL only for initial lifecycle establishment. |
| `changed_by` | Profile associated with the action; nullable for approved future system actions. |
| `changed_at` | Authoritative history timestamp. |
| `change_note` | Optional non-secret administrative note. |
| `audit_event_id` | Immutable audit event corresponding to the status-history event. |

### History ordering rules

Initial event:

- `sequence_number = 1`;
- `from_status_id = NULL`;
- `transition_id = NULL`.

Later events:

- `sequence_number > 1`;
- previous status is required;
- configured transition is required.

The schema guarantees unique positive sequence values but does not alone guarantee a gap-free sequence.

The protected status-transition operation must therefore assign sequence numbers transactionally and handle concurrency.

---

# 15. Current Report Routing / Assignment State

## 15.1 `public.report_routing_states`

**Status:** IMPLEMENTED structure.

**Purpose:** Current operational routing destination for a normal report.

| Field | Meaning |
|---|---|
| `report_id` | Parent normal report. |
| `taxonomy_version_id` | Taxonomy snapshot matching the raw report. |
| `routing_version_id` | Routing configuration governing the route. |
| `destination_id` | Current versioned routing destination. |
| `routed_by` | Profile associated with latest authoritative routing action. |
| `routed_at` | Time current routing destination became effective. |
| `created_at` | Time routing tracking was established. |
| `updated_at` | Most recent snapshot update time. |
| `source_history_id` | Immutable routing-history event that produced this snapshot. |

The current snapshot must remain traceable to its immutable source history.

---

# 16. Report Routing / Assignment History

## 16.1 `public.report_routing_history`

**Status:** IMPLEMENTED structure.

**Purpose:** Append-only ordered history of assignment, reassignment, routing, and referral actions.

| Field | Meaning |
|---|---|
| `id` | Routing-history UUID. |
| `report_id` | Parent normal report. |
| `sequence_number` | Positive deterministic per-report routing order. |
| `taxonomy_version_id` | Taxonomy preserved for compatibility. |
| `routing_version_id` | Routing configuration used. |
| `destination_id` | Versioned destination recorded by the event. |
| `routed_by` | Profile associated with the routing action. |
| `routed_at` | Authoritative routing-event timestamp. |
| `routing_note` | Optional non-secret administrative note. |
| `audit_event_id` | Corresponding immutable audit evidence. |

Existing routing-history records are append-only.

The future authoritative routing operation must validate the applicable concern-type routing map and any approved manual-override policy before writing the history/current state.

---

# 17. Rule-Based Weighted Priority Queue Algorithm Data

The following data is required by the approved HelpHub algorithm contract but is not yet represented by the five reconciled foundation migrations.

The physical schema must be designed during the algorithm/configuration implementation stages without losing these logical requirements.

## 17.1 Algorithm Decision Record

**Status:** REQUIRED-FUTURE.

**Purpose:** Preserve the complete deterministic result of algorithm processing for one normal report.

Required logical data includes:

| Logical element | Requirement |
|---|---|
| `report_id` | Report processed. |
| `algorithm_version` | Exact algorithm implementation/version used. |
| `rule_version` | Exact rule configuration used. |
| `weight_version` | Exact weight configuration used. |
| taxonomy/classification version reference | Exact concern-type/classification configuration used. |
| factor values | Raw approved factors used by the calculation. |
| normalized ratings | Normalized rating assigned to each factor. |
| matched rules | Rules matched by the report. |
| score breakdown | Per-factor contribution to total score. |
| priority score | Deterministic weighted score. |
| override reason | Reason for Critical override when applied; otherwise absent. |
| classification | Authoritative validated/classified concern result required by the algorithm contract. |
| priority | Low, Medium, High, or Critical according to the approved threshold version. |
| route | Approved versioned handling destination/result. |
| deadline | Response deadline assigned according to approved configuration. |
| queue key | Persisted deterministic ordering key/evidence sufficient to reproduce queue order. |
| processed_at | Authoritative processing timestamp. |

### Formula

The approved computation contract is:

`score = sum(weight_i * rating_i)`

Actual factor names, rating anchors, numeric weights, score thresholds, handler mappings, and deadlines remain DEFERRED-CONFIG until documented approval.

---

## 17.2 Rule Configuration

**Status:** REQUIRED-FUTURE / DEFERRED-CONFIG.

Required logical concepts include:

- rule configuration version;
- rule identifier;
- rule source/category where approved;
- rule condition;
- enabled/disabled state;
- concern classification effect where applicable;
- Critical-override eligibility where approved;
- creation/activation/retirement evidence.

The system must support versioned matching of system, city-ordinance, and barangay-specific rules where formally approved.

No final rules are defined by this dictionary.

---

## 17.3 Factor-Rating Configuration

**Status:** REQUIRED-FUTURE / DEFERRED-CONFIG.

Required logical concepts include:

- factor identifier;
- factor definition;
- normalization/rating scale;
- input condition/range;
- normalized rating;
- configuration version.

Current report inputs known to contribute potential factor information include:

- resident-declared urgency;
- affected population;
- vulnerable-group indicator.

Final approved factors and rating anchors must not be invented.

---

## 17.4 Weight Configuration

**Status:** REQUIRED-FUTURE / DEFERRED-CONFIG.

Required logical concepts include:

- weight-version identifier;
- factor reference;
- configured weight;
- activation/retirement metadata;
- administrative change/audit evidence.

No production weight values are defined by this dictionary.

---

## 17.5 Priority Threshold Configuration

**Status:** REQUIRED-FUTURE / DEFERRED-CONFIG.

The algorithm must map the calculated score to:

- Low;
- Medium;
- High;
- Critical.

The numeric score boundaries remain stakeholder-controlled configuration and must be versioned.

---

## 17.6 Queue Ordering Data

**Status:** REQUIRED-FUTURE.

Normal reports must be ordered deterministically by:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending;
5. report ID ascending.

The same input under the same algorithm/rule/weight/configuration versions must produce the same ordering result.

---

# 18. Emergency Response / SOS Data

The Emergency Response Module is required by the approved scope but is not implemented by the five reconciled foundation migrations.

## 18.1 SOS / Emergency Event

**Status:** REQUIRED-FUTURE.

Required logical data includes:

| Logical element | Meaning |
|---|---|
| emergency event ID | Unique SOS/emergency record identifier. |
| resident ID | Registered Resident activating SOS. |
| emergency type | Resident-selected emergency type from approved configuration. |
| confirmation evidence | Evidence that required SOS hold/confirmation completed. |
| submitted/activated timestamp | Authoritative emergency activation time. |
| latitude | One-time emergency GPS latitude. |
| longitude | One-time emergency GPS longitude. |
| accuracy | Device-reported emergency-location accuracy. |
| location capture time | Timestamp of emergency GPS capture. |
| optional address | Human-readable emergency location when available. |
| registered-user details/reference | Data required for administrator emergency handling, minimized according to privacy review. |
| priority/override | Automatic Critical override. |
| override reason | SOS/emergency override evidence. |
| acknowledgement data | Administrator acknowledgement actor/time. |
| emergency state/history | Complete emergency workflow tracking. |
| routing/referral data | Versioned emergency handling/referral evidence where approved. |
| audit evidence | Immutable authoritative emergency-action audit records. |

### SOS safety boundary

HelpHub does not replace official police, fire, medical, disaster-response, or national emergency services.

SOS activation must use a brief hold or confirmation mechanism to reduce accidental activation without making urgent use impractical.

Location capture is event-specific and must not become continuous Resident tracking.

Final emergency types, workflow statuses, escalation behavior, acknowledgement rules, routes, and deadlines remain DEFERRED-CONFIG.

---

# 19. Notifications Data

## 19.1 Notification

**Status:** REQUIRED-FUTURE.

Logical data must support notifying relevant users about approved HelpHub events, including report and emergency updates.

Likely required concepts include:

- notification ID;
- recipient profile;
- event/reference type;
- referenced HelpHub entity;
- notification title/body or template reference;
- creation timestamp;
- delivery-attempt state;
- read/unread state where required.

Exact schema and retention policy must be designed during the notifications stage.

Notification content must follow data minimization and must not expose sensitive GPS/SOS information unnecessarily on device lock screens or push payloads.

---

## 19.2 Push Device Registration

**Status:** REQUIRED-FUTURE.

Firebase Cloud Messaging requires device-delivery registration information.

Device tokens are security/privacy-sensitive operational identifiers.

They must:

- be associated only with the authenticated user/device context required for delivery;
- be replaceable/invalidated;
- not be exposed to other users;
- not be written into ordinary audit details.

Final schema is deferred to the notifications implementation stage.

---

# 20. Announcements Data

## 20.1 Announcement

**Status:** REQUIRED-FUTURE.

Logical requirements include:

- announcement ID;
- author/administrator reference;
- title;
- body/content;
- publication state;
- publication timestamp;
- creation/update timestamps;
- audit evidence for authoritative publishing changes where required.

Final publication workflow and retention rules remain subject to requirements confirmation.

---

# 21. Privacy and Sensitivity Notes

This section uses descriptive sensitivity notes rather than declaring a formal government data-classification policy.

| Data | Privacy/sensitivity consideration |
|---|---|
| Authentication credentials | Secret; managed by Supabase Auth and never copied into application records. |
| Full name | Personal identifying information. |
| Verification records/evidence | Personal and potentially high-sensitivity identity/residency information. |
| Normal report description | May contain personal, incident, or location-sensitive information entered by the Resident. |
| GPS latitude/longitude | Location-sensitive personal data. |
| Address | Location-sensitive data. |
| Photo evidence | May contain identifiable people, homes, vehicles, documents, or other sensitive context. |
| SOS location/details | High-sensitivity emergency and location information. |
| FCM/device tokens | Sensitive technical delivery identifiers. |
| Admin notes | Must exclude secrets and unnecessary personal information. |
| Audit details | Must contain only the minimum context necessary for traceability. |
| Algorithm evidence | Operational decision evidence; access should be role-appropriate. |

Final retention periods, anonymization rules, data-subject handling, verification-evidence requirements, and Resident-visible internal routing details must be addressed by the Stage 3 Privacy Impact Review.

---

# 22. Access and Ownership Summary

## Resident

An approved Resident may require access to:

- own profile;
- own verification history;
- active enabled concern taxonomy needed for submission;
- own normal reports;
- own report location/evidence metadata where appropriate;
- own report tracking/status history;
- Resident-appropriate routing/referral information;
- own SOS tracking information;
- notifications;
- published announcements.

Residents must not:

- change their own role;
- approve/restrict accounts;
- alter algorithm configuration;
- alter protected workflow configuration;
- directly rewrite status/routing/audit histories;
- view another Resident's private reports, locations, evidence, or emergency data.

## Barangay Administrator

An approved Barangay Administrator may require authorized access to:

- Resident verification records;
- Resident/report information needed for administration;
- concern and emergency queues;
- report lifecycle history;
- routing/assignment information;
- configuration history;
- audit evidence according to approved privileges;
- announcement management.

Administrator access does not remove the requirement for least privilege, server-side authorization, RLS, auditability, or privacy controls.

---

# 23. Key Relationships and Cardinalities

| Relationship | Current / required rule |
|---|---|
| Auth user → HelpHub profile | One-to-one. |
| Resident → verification requests | One-to-many history; at most one pending request at a time. |
| Taxonomy version → concern types | One-to-many. |
| Taxonomy version → routing versions | One-to-many structurally. |
| Routing version → destinations | One-to-many. |
| Concern type → route mapping | Current repository: at most one destination per routing version. |
| Resident → normal reports | One-to-many. |
| Normal report → normal-report location | Zero/one structurally; report requirements determine when capture is mandatory. |
| Normal report → photo evidence | Zero or one in current repository. |
| Normal report → current lifecycle state | At most one. |
| Normal report → status history | One-to-many after lifecycle establishment. |
| Current lifecycle state → source history | Exactly one immutable source history event once state exists. |
| Normal report → current routing state | At most one. |
| Normal report → routing history | One-to-many after routing begins. |
| Current routing state → source history | Exactly one immutable source routing-history event once state exists. |
| Status-history event → audit event | One-to-one for authoritative history rows in current structure. |
| Routing-history event → audit event | One-to-one for authoritative history rows in current structure. |
| Normal report → algorithm decision evidence | Required future relationship; final reprocessing/version-history cardinality must be designed explicitly. |
| Resident → SOS events | Required future one-to-many. |
| Administrator → announcements | Required future one-to-many author relationship. |

---

# 24. Approval-Sensitive and Deferred Data Decisions

The following values must not be silently finalized by implementation:

- final concern taxonomy;
- concern classification responsibility and rules;
- rule vocabulary and rule conditions;
- factor definitions;
- factor normalization/rating anchors;
- algorithm weights;
- Low/Medium/High/Critical score thresholds;
- non-SOS Critical override rules;
- routing destinations;
- concern-to-route mappings;
- internal handler model;
- referral and escalation policy;
- response deadlines;
- manual routing override permission;
- lifecycle status names;
- lifecycle transitions;
- initial lifecycle status;
- emergency types;
- emergency workflow transitions;
- emergency acknowledgement/escalation policy;
- protected configuration privileges;
- verification evidence requirements;
- retention/anonymization periods;
- Resident visibility of internal routing details.

Each approved configuration change must be versioned and traceable to documented approval evidence.

---

# 25. Repository Reconciliation / Correction Register

The Stage 3 migration reconciliation identified the following items for later implementation or decision.

## DD-C01 — Routing version-number uniqueness

`routing_config_versions.version_number` is positive but currently not unique.

Required action before final configuration implementation:

- document whether the number is globally unique or unique within a taxonomy version;
- enforce the approved interpretation consistently.

## DD-C02 — Activated configuration immutability

Taxonomy, routing, and lifecycle versions are designed as immutable historical snapshots after activation.

Current foundation migrations do not yet provide all protected mutation/activation operations required to enforce that rule.

Required action:

- implement server/database protections during protected configuration management.

## DD-C03 — Concern type to destination cardinality

The current route map allows at most one destination per concern type per routing version.

Required action:

- confirm that this matches stakeholder routing policy before treating the cardinality as final.

## DD-C04 — Exactly one lifecycle initial status

The current schema guarantees at most one `is_initial` status.

Required action:

- lifecycle activation must verify exactly one enabled initial status.

## DD-C05 — History sequence allocation

Status and routing history use positive unique per-report sequence numbers.

Required action:

- authoritative server/database operations must assign sequence numbers transactionally and handle concurrency.

## DD-C06 — Routing-map enforcement

Current routing-state/history foreign keys enforce version compatibility but do not themselves prove that the selected destination is the configured `concern_type_routes` result.

Required action:

- protected routing processing must validate the configured mapping and any approved override policy.

## DD-C07 — Manual route overrides

Whether an administrator may override algorithm/configured routing remains undecided.

Required action:

- obtain documented approval before implementing override behavior.

## DD-C08 — Resident routing-detail visibility

Current RLS structures can permit Residents to read routing state/history for their own report.

Required action:

- privacy and UX review must determine which internal destination/note details should actually be exposed to the Resident.

## DD-C09 — Storage object authorization

The normal-report evidence bucket is private.

Required action:

- implement and test object-level upload/download policies and ownership rules; do not treat `public = false` alone as complete evidence security.

## DD-C10 — Retention and anonymization

Existing history-preserving foreign-key choices prevent silent deletion.

Required action:

- document final retention, archival, anonymization, and lawful deletion rules before production deployment.

## DD-C11 — Verification evidence schema

Exact verification-document/evidence fields remain intentionally absent.

Required action:

- privacy and stakeholder approval must precede schema implementation.

## DD-C12 — Algorithm evidence schema

The normal-report foundation contains raw inputs but not the complete algorithm decision record.

Required action:

- Stage 8/12 implementation must preserve every version and calculation element required to reproduce the result.

---

# 26. Data Dictionary Verification Checklist

The Stage 3 Data Dictionary is ready for gate review only when all of the following are true:

- [ ] two and only two authenticated HelpHub roles are documented;
- [ ] existing profile and verification structures match migrations;
- [ ] audit events are distinguished from domain history;
- [ ] taxonomy and routing configuration are documented as versioned;
- [ ] no final concern categories or destinations are invented;
- [ ] normal-report raw fields match the repository;
- [ ] Resident urgency is clearly distinguished from authoritative priority;
- [ ] GPS capture includes latitude, longitude, accuracy, and capture time;
- [ ] one-time location is distinguished from continuous tracking;
- [ ] optional photo evidence and private storage are documented;
- [ ] current lifecycle state is distinguished from status history;
- [ ] current routing state is distinguished from routing history;
- [ ] external referral is documented as non-integrated manual coordination;
- [ ] algorithm decision evidence includes algorithm/rule/weight versions and calculation evidence;
- [ ] deterministic queue ordering is documented exactly;
- [ ] SOS required data and Critical override are documented;
- [ ] notifications and announcements are represented as required future data;
- [ ] secrets are explicitly excluded from general application/audit data;
- [ ] approval-sensitive values remain deferred;
- [ ] migration reconciliation corrections are recorded rather than silently ignored;
- [ ] Data Dictionary remains requirements-level and does not pretend unimplemented logical entities are existing PostgreSQL tables.

---

# 27. Stage 4+ Implementation Rule

This Data Dictionary does not authorize developers to create final policy values.

When later stages implement a REQUIRED-FUTURE structure:

1. reconcile the implementation with this dictionary and the approved study;
2. confirm all applicable stakeholder decisions;
3. create a versioned migration;
4. apply least-privilege grants and RLS;
5. implement protected FastAPI authorization where required;
6. add normal, boundary, invalid, unauthorized, and failure tests;
7. update this dictionary when the physical schema becomes authoritative;
8. preserve historical reproducibility and auditability.

If the study, stakeholder decision record, migration, implementation, test, and this dictionary disagree, the contradiction must be explicitly resolved rather than silently choosing one source.
