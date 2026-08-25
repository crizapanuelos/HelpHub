# HelpHub Requirements Traceability Matrix

## Document Control

- Project: HelpHub — A Mobile-Based Barangay Concern Reporting Application Using a Rule-Based Weighted Priority Queue Algorithm with Emergency Response Module
- Roadmap phase: Stage 3 — Requirements, Diagrams, and Privacy Review
- Task: 03.14 — Requirements Traceability Matrix
- GitHub issue: #14
- Status: DRAFT — NOT YET STAKEHOLDER APPROVED
- Traceability baseline: Approved revised study, Stage 3 requirements/user stories, Stage 3 diagrams, current repository migrations, and future roadmap implementation/test stages

---

## 1. Purpose

This Requirements Traceability Matrix (RTM) connects HelpHub's study objectives to requirements, user stories, acceptance criteria, design artifacts, existing schema evidence, future implementation targets, and verification evidence.

The RTM exists to prevent three common project failures:

1. implementing features that cannot be traced to an approved requirement;
2. claiming an unimplemented or untested feature is complete merely because it appears in a requirements document or diagram;
3. losing approved requirements during later database, API, Flutter, algorithm, security, evaluation, or deployment work.

This is a living traceability artifact.

A future implementation is complete only when its applicable RTM row can point to verified implementation and test evidence.

---

## 2. Source-of-Truth Hierarchy

The RTM uses the following evidence hierarchy.

| Source | Role in traceability |
|---|---|
| Approved revised HelpHub study | Defines project objectives, scope, core functional outcomes, algorithm contract, evaluation approach, and research boundaries. |
| Stakeholder validation / decision evidence | Governs approval-sensitive policy such as taxonomy, rules, weights, thresholds, routing, deadlines, workflow, emergency policy, retention, and configuration privilege. |
| `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md` | Defines stable requirement IDs and requirement baseline status. |
| `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md` | Defines user stories, explicit linked requirements, study-objective mappings, and acceptance criteria. |
| Stage 3 diagrams and data dictionary | Define logical architecture, actors, processes, data, component boundaries, workflow, and traceability expectations. |
| Supabase migrations | Technical source of truth for physical database structures already implemented. |
| Future application/API code and tests | Technical proof that requirements have actually been implemented and verified. |

A lower-level artifact must not silently redefine an approval-sensitive decision established by an approved higher-level source.

---

## 3. RTM Status Terms

| RTM status | Meaning |
|---|---|
| BASELINED | Requirement exists in the Stage 3 requirements baseline. |
| DESIGN-EVIDENCE | Stage 3 requirements/diagram/data artifacts represent the requirement. |
| PARTIAL-SCHEMA | Some supporting database structure exists, but the full feature is not implemented. |
| PLANNED | Implementation or verification belongs to a later roadmap stage. |
| APPROVAL-DEPENDENT | Final operational value or policy requires documented approval before implementation. |
| PENDING-VALIDATION | A target or criterion must be established before final evaluation. |
| SCOPE-GUARD | Requirement prevents out-of-scope behavior rather than requesting a module. |
| VERIFIED | Reserved for later use only after objective evidence demonstrates the implemented requirement. |

`Established` in the requirements baseline means the requirement itself is established; it does not mean the software implementation is complete.

---

## 4. Objective Baseline

| Objective | Approved outcome |
|---|---|
| Objective 1 | User management: registration, secure login, profile management, resident verification, approval/account management, restriction, and role-based access control. |
| Objective 2 | Concern reporting and tracking: approved concern type, description, location, resident-declared urgency, affected population, vulnerable-group indicator, optional evidence, timestamps, and complete resident-visible status history. |
| Objective 3 | Emergency Response Module: brief SOS hold/confirmation, emergency type, one-time GPS, timestamp, registered-user details, automatic Critical override, emergency queue, acknowledgement, tracking, and official-services disclaimer. |
| Objective 4 | Versioned Rule-Based Weighted Priority Queue Algorithm: validation/classification, approved rule matching, normalization, weighted score, Low/Medium/High/Critical assignment, overrides, routing, deadline assignment, and deterministic ordering. |
| Objective 5 | Administrator and communication module: dashboard/queues, assignment/referral, status updates, internal notes, audit logs, protected configuration, notifications, announcements, least privilege, and traceability. |
| Objective 6 | ISO/IEC 25010:2023 evaluation plus algorithm-specific validation for concern-type agreement, rule matching, scoring, priority, emergency override, queue ordering, reproducibility, and explanation completeness. |

---

# 5. User Story Traceability

These mappings are taken from the existing user-story baseline rather than inferred from matching prefixes.

| User story | Linked requirements | Study objective(s) |
|---|---|---|
| `US-UM-001` Resident Registration | `FR-UM-001`, `FR-UM-002`, `NFR-SEC-005` | Objective 1 |
| `US-UM-002` Secure Login and Logout | `FR-UM-003`, `FR-UM-004`, `FR-UM-010`, `FR-UM-011`, `FR-UM-012` | Objective 1 |
| `US-UM-003` Resident Profile Management | `FR-UM-005`, `NFR-SEC-001`, `NFR-PRV-003` | Objective 1 |
| `US-UM-004` Resident Verification Submission | `FR-UM-006` | Objective 1 |
| `US-ADM-001` Review Resident Verification | `FR-UM-007`, `FR-UM-008`, `FR-UM-009`, `FR-UM-012` | Objective 1 |
| `US-CR-001` Submit a Normal Concern | `FR-CR-001` through `FR-CR-014` | Objective 2 |
| `US-CR-002` Provide One-Time Location | `FR-LE-001` through `FR-LE-004`, `NFR-PRV-001`, `NFR-PRV-002` | Objectives 2 and 3 |
| `US-CR-003` Attach Optional Photo Evidence | `FR-CR-010`, `FR-LE-005` through `FR-LE-008`, `NFR-SEC-008`, `NFR-SEC-009` | Objective 2 |
| `US-RT-001` Track My Reports | `FR-RT-001` through `FR-RT-006` | Objective 2 |
| `US-RT-002` View Complete Status History | `FR-RT-004`, `FR-AD-010`, `FR-AD-011` | Objective 2 |
| `US-ALG-001` Transparent Concern-Type Validation | `FR-ALG-001` through `FR-ALG-007`, `FR-ALG-030` | Objective 4 |
| `US-ALG-002` Weighted Priority Calculation | `FR-ALG-008` through `FR-ALG-017`, `FR-ALG-024` through `FR-ALG-031` | Objective 4 |
| `US-ALG-003` Deterministic Queue Ordering | `FR-ALG-018` through `FR-ALG-023`, `NFR-DET-001` through `NFR-DET-003` | Objective 4 |
| `US-AD-001` View Dashboard and Priority Queues | `FR-AD-001` through `FR-AD-004` | Objective 5 |
| `US-AD-002` Assign or Refer a Concern | `FR-AD-005` through `FR-AD-007`, `FR-AU-002` | Objective 5 |
| `US-AD-003` Update Report Status and Add Internal Notes | `FR-AD-008` through `FR-AD-015` | Objective 5 |
| `US-SOS-001` Send a Confirmed SOS | `FR-SOS-001` through `FR-SOS-009` | Objective 3 |
| `US-SOS-002` Acknowledge and Track an Emergency | `FR-SOS-010` through `FR-SOS-018` | Objectives 3 and 5 |
| `US-CM-001` Receive Notifications | `FR-CM-001` through `FR-CM-003` | Objectives 2, 3, and 5 |
| `US-CM-002` View Barangay Announcements | `FR-CM-004`, `FR-CM-005` | Objective 5 |
| `US-CFG-001` Manage Versioned Algorithm Configuration | `FR-CFG-001` through `FR-CFG-012`, `NFR-DET-003` | Objectives 4 and 5 |
| `US-AU-001` Review Audit Evidence | `FR-AU-001` through `FR-AU-006`, `NFR-TRC-004` | Objective 5 |

### 5.1 Cross-Cutting Acceptance Criteria

`AC-X-001` through `AC-X-009` are the existing cross-cutting acceptance-criteria identifiers.

Applicable user-facing stories must satisfy those criteria in addition to their story-specific numbered acceptance criteria.

---

# 6. Functional Requirements RTM

Range notation such as `FR-UM-001–012` means every stable requirement ID in that inclusive range.

## 6.1 User Management

| Trace item | Mapping |
|---|---|
| Requirements | `FR-UM-001`–`FR-UM-012` |
| Baseline status | Established except `FR-UM-006`, `FR-UM-008`, `FR-UM-009` are Approval-dependent. |
| Explicit stories | `US-UM-001`, `US-UM-002`, `US-UM-003`, `US-UM-004`, `US-ADM-001` |
| Objective | Objective 1 |
| Requirements evidence | `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`, `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`, `ROLE_PERMISSION_MATRIX.md` |
| Design evidence | `USE_CASE_DIAGRAM.md`, `SYSTEM_CONTEXT_DIAGRAM.md`, `DATA_FLOW_DIAGRAM_LEVEL_0.md`, `DATA_FLOW_DIAGRAM_LEVEL_1.md`, `COMPONENT_DIAGRAM.md`, `DEPLOYMENT_DIAGRAM.md` |
| Data evidence | `DATA_DICTIONARY.md` |
| Existing schema evidence | `20260814012435_create_identity_foundation.sql`; `20260814050812_create_admin_verification_review_foundation.sql` |
| Implementation target | Roadmap Stage 6 — User Management |
| Verification target | Flutter tests; authentication/API tests; RLS tests; unauthorized-role tests; verification workflow tests; UAT |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 6.2 Normal Concern Reporting

| Trace item | Mapping |
|---|---|
| Requirements | `FR-CR-001`–`FR-CR-014` |
| Baseline status | Established except `FR-CR-002` is Approval-dependent. |
| Explicit stories | `US-CR-001`; `US-CR-003` additionally traces `FR-CR-010` |
| Objective | Objective 2 |
| Requirements evidence | `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`, `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md` |
| Design evidence | `USE_CASE_DIAGRAM.md`, `UPDATED_CONCEPTUAL_PARADIGM_NARRATIVE.md`, `SYSTEM_CONTEXT_DIAGRAM.md`, `DATA_FLOW_DIAGRAM_LEVEL_0.md`, `DATA_FLOW_DIAGRAM_LEVEL_1.md`, `COMPONENT_DIAGRAM.md` |
| Data evidence | `DATA_DICTIONARY.md` |
| Existing schema evidence | `20260814110829_create_concern_taxonomy_and_handler_foundation.sql`; `20260815024417_create_normal_concern_report_foundation.sql` |
| Implementation target | Roadmap Stage 7 — Concern Submission |
| Verification target | Flutter form/widget tests; API input validation; authorization tests; database/RLS tests; evidence upload tests; integration/UAT |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 6.3 Location and Evidence Handling

| Trace item | Mapping |
|---|---|
| Requirements | `FR-LE-001`–`FR-LE-008` |
| Baseline status | Established |
| Explicit stories | `US-CR-002`, `US-CR-003` |
| Objective | Objectives 2 and 3 through explicit story mapping |
| Requirements evidence | `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`, `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md` |
| Design evidence | `SYSTEM_CONTEXT_DIAGRAM.md`, `DATA_FLOW_DIAGRAM_LEVEL_1.md`, `COMPONENT_DIAGRAM.md`, `DEPLOYMENT_DIAGRAM.md` |
| Data evidence | `DATA_DICTIONARY.md` |
| Existing schema evidence | Normal-report location and evidence structures in `20260815024417_create_normal_concern_report_foundation.sql` |
| Future schema evidence | SOS location/evidence remains REQUIRED-FUTURE |
| Implementation target | Stages 7 and 10 |
| Verification target | Permission-denied tests; GPS capture tests; no-background-tracking checks; private Storage/RLS tests; file type/size checks |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 6.4 Resident Report Tracking

| Trace item | Mapping |
|---|---|
| Requirements | `FR-RT-001`–`FR-RT-006` |
| Baseline status | Established |
| Explicit stories | `US-RT-001`, `US-RT-002` |
| Objective | Objective 2 |
| Requirements evidence | `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`, `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`, `STATUS_TRANSITION_TABLES.md` |
| Design evidence | `USE_CASE_DIAGRAM.md`, `DATA_FLOW_DIAGRAM_LEVEL_0.md`, `DATA_FLOW_DIAGRAM_LEVEL_1.md`, `COMPONENT_DIAGRAM.md` |
| Data evidence | `DATA_DICTIONARY.md` |
| Existing schema evidence | Current lifecycle state and append-only history structures in `20260817131215_create_report_status_and_assignment_foundation.sql` |
| Implementation target | Stages 7, 9, and 11 |
| Verification target | Ownership/RLS tests; status-history tests; realtime failure tests; empty/network/server-error UI tests; UAT |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 6.5 Rule-Based Weighted Priority Queue Algorithm

| Trace item | Mapping |
|---|---|
| Requirements | `FR-ALG-001`–`FR-ALG-031` |
| Baseline status | Mixed Established and Approval-dependent; all final policy inputs remain version-controlled. |
| Explicit stories | `US-ALG-001`, `US-ALG-002`, `US-ALG-003` |
| Objective | Objective 4 |
| Requirements evidence | `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`, `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md` |
| Design evidence | `UPDATED_CONCEPTUAL_PARADIGM_NARRATIVE.md`, `USE_CASE_DIAGRAM.md`, `DATA_FLOW_DIAGRAM_LEVEL_0.md`, `DATA_FLOW_DIAGRAM_LEVEL_1.md`, `COMPONENT_DIAGRAM.md`, `DEPLOYMENT_DIAGRAM.md` |
| Data evidence | Algorithm decision/configuration requirements in `DATA_DICTIONARY.md` |
| Existing schema evidence | Taxonomy/routing configuration foundations only; no complete priority decision record or weighted-engine schema yet |
| Implementation target | Stage 8 — FastAPI and Algorithm; Stage 12 — Rule/Weight Configuration |
| Verification target | Pytest; API tests; independent score calculations; rule-match validation; override tests; deterministic ordering; reproducibility; explanation-completeness validation |
| Evaluation target | Stage 14 — Algorithm Validation |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + APPROVAL-DEPENDENT + PLANNED |

### Algorithm ordering contract

The required deterministic order is:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending;
5. report ID ascending.

Identical input under identical algorithm/configuration versions must produce identical output.

---

## 6.6 Administrator Dashboard and Normal Report Management

| Trace item | Mapping |
|---|---|
| Requirements | `FR-AD-001`–`FR-AD-015` |
| Baseline status | Established except assignment/status policy requirements `FR-AD-005`, `FR-AD-006`, and `FR-AD-008` are Approval-dependent. |
| Explicit stories | `US-AD-001`, `US-AD-002`, `US-AD-003`; `US-RT-002` additionally links `FR-AD-010` and `FR-AD-011` |
| Objective | Objective 5; status-history visibility also supports Objective 2 |
| Requirements evidence | Requirements, stories, role matrix, status-transition tables |
| Design evidence | Use case, DFD L0/L1, component, deployment |
| Data evidence | `DATA_DICTIONARY.md` |
| Existing schema evidence | Audit, lifecycle, status-history, routing-state, and routing-history foundations |
| Implementation target | Stage 9 — Admin Dashboard/Status/Audit |
| Verification target | Admin authorization tests; invalid-transition tests; assignment/referral tests; audit/history atomicity tests; Flutter web tests; UAT |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + APPROVAL-DEPENDENT + PLANNED |

---

## 6.7 Emergency Response Module

| Trace item | Mapping |
|---|---|
| Requirements | `FR-SOS-001`–`FR-SOS-018` |
| Baseline status | Mixed Established and Approval-dependent |
| Explicit stories | `US-SOS-001`, `US-SOS-002` |
| Objective | Objective 3; administrative emergency handling also supports Objective 5 |
| Requirements evidence | Requirements, stories, status-transition tables |
| Design evidence | Use case, conceptual paradigm, context, DFD L0/L1, component, deployment |
| Data evidence | SOS logical data requirements in `DATA_DICTIONARY.md` |
| Existing schema evidence | None for complete SOS/emergency records yet |
| Implementation target | Stage 10 — SOS |
| Verification target | Hold/confirmation tests; accidental-activation tests; location tests; Critical override tests; emergency queue tests; acknowledgement/history/audit tests; authorization tests; official-services disclaimer verification |
| Evaluation target | Stage 14 emergency-override validation |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + APPROVAL-DEPENDENT + PLANNED |

---

## 6.8 Notifications and Announcements

| Trace item | Mapping |
|---|---|
| Requirements | `FR-CM-001`–`FR-CM-006` |
| Baseline status | Established |
| Explicit stories | `US-CM-001` links `FR-CM-001`–`003`; `US-CM-002` links `FR-CM-004`–`005` |
| Story-gap note | `FR-CM-006` currently has no explicit user-story link in the story baseline. This RTM does not fabricate one. |
| Objective | Explicit story mapping: Objectives 2, 3, and 5 for notifications; Objective 5 for announcements. `FR-CM-006` remains direct requirement traceability without an invented story link. |
| Design evidence | Context, DFD L0/L1, component, deployment, use case |
| Data evidence | Notification/announcement REQUIRED-FUTURE definitions in `DATA_DICTIONARY.md` |
| Existing schema evidence | No complete notification/announcement application schema yet |
| Implementation target | Stage 11 — Realtime/Notifications/Announcements |
| Verification target | FCM attempt/failure tests; lock-screen privacy review; authentication-on-open tests; realtime synchronization/failure tests; announcement authorization/UAT |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PLANNED |

---

## 6.9 Audit and Traceability

| Trace item | Mapping |
|---|---|
| Requirements | `FR-AU-001`–`FR-AU-006` |
| Baseline status | Established |
| Explicit story | `US-AU-001`; `US-AD-002` also links `FR-AU-002` |
| Objective | Objective 5 |
| Design evidence | Use case, DFD L1, component, data dictionary |
| Existing schema evidence | `public.audit_events`; status-history/audit linkage; routing-history/audit linkage |
| Implementation target | Stages 9, 10, and 12 depending on audited operation |
| Verification target | Append-only tests; authorization tests; action/entity traceability; mutation-rejection tests; privacy review of audit details |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 6.10 Protected Configuration

| Trace item | Mapping |
|---|---|
| Requirements | `FR-CFG-001`–`FR-CFG-012` |
| Baseline status | `FR-CFG-001`–`010` Approval-dependent; `FR-CFG-011`–`012` Established |
| Explicit story | `US-CFG-001` |
| Objective | Objectives 4 and 5 |
| Design evidence | Conceptual paradigm, DFD L1, component, data dictionary |
| Existing schema evidence | Taxonomy, routing, and lifecycle version foundations |
| Required future schema | Rule sets, rating anchors, weights, thresholds, deadlines, emergency escalation, protected configuration mutation/activation operations |
| Implementation target | Stage 12 — Rule/Weight Configuration |
| Verification target | Authorization tests; version activation/retirement tests; historical immutability tests; audit tests; reproducibility regression tests |
| Current RTM state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + APPROVAL-DEPENDENT + PLANNED |

---

# 7. Cross-Cutting UI State RTM

| Requirements | Traceability |
|---|---|
| `UI-STATE-001` Loading | Applies to asynchronous user-facing operations; verified through Flutter/widget/integration tests. |
| `UI-STATE-002` Success | Applies where successful completion requires confirmation. |
| `UI-STATE-003` Empty | Applies to authorized lists/history/queue screens with no records. |
| `UI-STATE-004` Validation error | Applies to input-based workflows. |
| `UI-STATE-005` Permission denied | Applies to protected features and sensitive data. |
| `UI-STATE-006` Network failure | Applies to network-dependent workflows. |
| `UI-STATE-007` Timeout | Applies to operations that can time out. |
| `UI-STATE-008` Unauthorized/session failure | Applies to authenticated/protected workflows. |
| `UI-STATE-009` Server error | Applies to protected backend operations. |

### UI-state objective mapping

The requirements source does not assign each `UI-STATE-*` requirement to one specific study objective.

They are therefore recorded as **cross-cutting support** for Objectives 1–5 and as verification evidence relevant to Objective 6, rather than being assigned fabricated one-to-one objective mappings.

### Implementation and verification

- Primary implementation target: Stage 5 design system/navigation and every later user-facing module.
- Verification: Flutter widget/integration tests, API failure injection where applicable, UAT, and demonstration checklists.
- Cross-cutting acceptance-criteria source: `AC-X-001`–`AC-X-009`.

Current state: BASELINED + DESIGN-EVIDENCE + PLANNED.

---

# 8. Non-Functional Requirements RTM

## 8.1 Security

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-SEC-001`–`NFR-SEC-012` |
| Baseline status | Established |
| Explicit story links | `NFR-SEC-001` → `US-UM-003`; `NFR-SEC-005` → `US-UM-001`; `NFR-SEC-008` and `009` → `US-CR-003` |
| Objective relation | Cross-cutting Objectives 1–5; direct Objective 6 Security evaluation support |
| Design evidence | Role matrix, context, deployment, component, data dictionary |
| Existing technical evidence | RLS foundations, grants, service-only functions, private evidence bucket, audit immutability |
| Implementation target | Every implementation stage; consolidated Stage 13 security review |
| Verification target | Authentication/authorization tests; RLS tests; rate-limit tests; secure-upload tests; secret scan; GPS/SOS access tests |
| Current state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 8.2 Privacy

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-PRV-001`–`NFR-PRV-006` |
| Baseline status | Established except `NFR-PRV-005` is Approval-dependent |
| Explicit story links | `NFR-PRV-001` and `002` → `US-CR-002`; `NFR-PRV-003` → `US-UM-003` |
| Objective relation | Cross-cutting Objectives 1–5; supports Objective 6 Security |
| Design evidence | Context, deployment, component, data dictionary |
| Stage 3 evidence target | Privacy Impact Review |
| Future verification | Data minimization review; location/no-continuous-tracking tests; retention checks; research-export privacy review |
| Current state | BASELINED + DESIGN-EVIDENCE + APPROVAL-DEPENDENT + PLANNED |

---

## 8.3 Reliability and Failure Handling

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-REL-001`–`NFR-REL-006` |
| Baseline status | Established |
| Objective relation | Cross-cutting implementation support and Objective 6 Reliability |
| Design evidence | Component and deployment diagrams; UI-state baseline |
| Implementation target | All runtime stages |
| Verification target | Failure/recovery tests, duplicate-action tests, notification/realtime failure tests, backup/restore tests |
| Current state | BASELINED + DESIGN-EVIDENCE + PLANNED |

---

## 8.4 Performance Efficiency

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-PERF-001`–`NFR-PERF-003` |
| Baseline status | `NFR-PERF-001` and `003` Pending validation; `NFR-PERF-002` Established |
| Objective relation | Objective 6 Performance Efficiency |
| Implementation target | Runtime architecture throughout development |
| Verification target | Stage 13 performance tests with documented workload and measurable response-time targets |
| Evaluation target | Stage 15 ISO/IEC 25010 evaluation |
| Current state | BASELINED + PENDING-VALIDATION + PLANNED |

---

## 8.5 Interaction Capability and Usability

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-UX-001`–`NFR-UX-006` |
| Baseline status | Established |
| Objective relation | Cross-cutting Objectives 1–5; Objective 6 Interaction Capability |
| Design evidence | Use case, role matrix, Stage 5 future design system/navigation |
| Verification target | Widget/integration tests, accessibility/usability checks, UAT, adviser-approved evaluation instrument |
| Current state | BASELINED + DESIGN-EVIDENCE + PLANNED |

---

## 8.6 Determinism, Reproducibility, and Explainability

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-DET-001`–`NFR-DET-004` |
| Baseline status | Established |
| Explicit story links | `NFR-DET-001`–`003` → `US-ALG-003`; `NFR-DET-003` → `US-CFG-001` |
| Objective relation | Objective 4 and Objective 6 algorithm validation |
| Design evidence | Conceptual paradigm, component, data dictionary |
| Implementation target | Stages 8 and 12 |
| Verification target | Repeated identical runs; saved version evidence; queue-order tests; explanation-completeness tests |
| Evaluation target | Stage 14 |
| Current state | BASELINED + DESIGN-EVIDENCE + PLANNED |

---

## 8.7 Auditability and Traceability

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-TRC-001`–`NFR-TRC-004` |
| Baseline status | Established |
| Explicit story link | `NFR-TRC-004` → `US-AU-001` |
| Objective relation | Cross-cutting; strongly supports Objective 5 and evidence for Objective 6 |
| Existing evidence | Stable requirement IDs, this RTM, audit/status/routing history structures |
| Implementation target | All roadmap stages |
| Verification target | Requirement-to-code/test/document review during PRs and stage gates |
| Current state | BASELINED + DESIGN-EVIDENCE + PARTIAL-SCHEMA + PLANNED |

---

## 8.8 Technology and Architecture Constraints

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-ARC-001`–`NFR-ARC-010` |
| Baseline status | Established |
| Objective relation | Cross-cutting implementation constraint; no fabricated single-objective mapping |
| Design evidence | System context, deployment, component |
| Implementation evidence target | Flutter/Dart; Python/FastAPI; Supabase PostgreSQL/Auth/Storage/Realtime/RLS; FCM; geolocator; flutter_map/OpenStreetMap |
| Verification target | Environment checks, builds, API integration, deployment validation |
| Current state | BASELINED + DESIGN-EVIDENCE + PLANNED |

---

## 8.9 Evaluation and Testability

| Trace item | Mapping |
|---|---|
| Requirements | `NFR-EVAL-001`–`NFR-EVAL-016` |
| Baseline status | `NFR-EVAL-001`, `004`, and `016` Approval-dependent; remaining requirements Established |
| Objective relation | Direct Objective 6 alignment |
| Evaluation areas | Functional Suitability, Performance Efficiency, Interaction Capability terminology as approved, Reliability, Security |
| Algorithm validation | Concern-type agreement, rule-match correctness, score correctness, final-priority agreement, emergency override correctness, deterministic ordering, reproducibility, explanation completeness |
| Implementation target | Stage 13 preparation; Stage 14 algorithm validation; Stage 15 ISO/IEC 25010 evaluation |
| Verification evidence | Automated tests, technical measurements, validation dataset/checklists, survey instrument, evaluator records, documented pass criteria |
| Current state | BASELINED + APPROVAL-DEPENDENT + PLANNED |

---

# 9. Out-of-Scope Traceability

These requirements are scope guards. They must remain visible so implementation does not accidentally expand the approved study.

| Requirement | Guard |
|---|---|
| `OOS-001` | No assistance-request module. |
| `OOS-002` | No multi-barangay production deployment. |
| `OOS-003` | No full offline operation. |
| `OOS-004` | No automatic SMS fallback. |
| `OOS-005` | No automatic ordinance enforcement or penalties. |
| `OOS-006` | HelpHub does not replace official emergency services. |
| `OOS-007` | No guaranteed external-agency dispatch or response. |
| `OOS-008` | No continuous resident location tracking. |
| `OOS-009` | No long-term post-study operations commitment. |

### Scope-guard verification

Relevant design reviews, pull requests, UAT scripts, technical documentation, and defense demonstrations must be checked to ensure they do not contradict these boundaries.

Current state: SCOPE-GUARD.

---

# 10. Current Physical-Schema Evidence Register

Existing migrations provide partial implementation evidence only.

| Migration | RTM coverage |
|---|---|
| `20260814012435_create_identity_foundation.sql` | User identity/profile, two-role constraint, Resident verification foundation, RLS |
| `20260814050812_create_admin_verification_review_foundation.sql` | Approved-admin authorization, verification review, append-only audit foundation |
| `20260814110829_create_concern_taxonomy_and_handler_foundation.sql` | Versioned concern taxonomy, routing versions/destinations/maps |
| `20260815024417_create_normal_concern_report_foundation.sql` | Raw normal reports, one-time location, optional private photo evidence |
| `20260817131215_create_report_status_and_assignment_foundation.sql` | Versioned lifecycle structure, current state, append-only status/routing histories |

These migrations do not by themselves prove that the corresponding complete application modules are implemented.

---

# 11. Stage 3 Design Artifact Register

| Artifact | Main traceability role |
|---|---|
| `STAKEHOLDER_VALIDATION_NOTES.md` | Approval dependencies and unresolved stakeholder decisions |
| `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md` | Stable requirement baseline |
| `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md` | Story, objective, linked-requirement, and acceptance-criteria evidence |
| `ROLE_PERMISSION_MATRIX.md` | Resident/Administrator authorization boundary |
| `STATUS_TRANSITION_TABLES.md` | Proposed lifecycle/emergency workflow and approval-sensitive transitions |
| `DATA_DICTIONARY.md` | Logical data meaning, existing schema reconciliation, future data requirements |
| `USE_CASE_DIAGRAM.md` | Actor/system responsibility and use-case boundary |
| `UPDATED_CONCEPTUAL_PARADIGM_NARRATIVE.md` | IPO/feedback model and algorithm/configuration relationships |
| `SYSTEM_CONTEXT_DIAGRAM.md` | System boundary and supporting external technical services |
| `DATA_FLOW_DIAGRAM_LEVEL_0.md` | Balanced high-level business data flows |
| `DATA_FLOW_DIAGRAM_LEVEL_1.md` | Process/data-store decomposition |
| `DEPLOYMENT_DIAGRAM.md` | Runtime nodes, trust boundaries, hosting/provider dependencies |
| `COMPONENT_DIAGRAM.md` | Flutter/FastAPI/adapters/services/component responsibilities |

---

# 12. Implementation and Verification Stage Map

| Roadmap stage | RTM responsibility |
|---|---|
| Stage 4 | Supabase schema/Auth/Storage/RLS implementation and database/RLS evidence |
| Stage 5 | Flutter design system/navigation and cross-cutting UI-state evidence |
| Stage 6 | User-management implementation |
| Stage 7 | Normal concern submission and resident tracking foundation |
| Stage 8 | FastAPI protected API and Rule-Based Weighted Priority Queue Algorithm |
| Stage 9 | Admin dashboard, assignment, status, notes, audit |
| Stage 10 | Emergency SOS |
| Stage 11 | Realtime, notifications, announcements |
| Stage 12 | Protected rule/weight/configuration management |
| Stage 13 | Testing, security, privacy implementation checks, reliability, performance |
| Stage 14 | Algorithm-specific validation |
| Stage 15 | ISO/IEC 25010:2023 evaluation |
| Stage 16 | Deployment, manuals, technical documentation, demonstration, defense |

---

# 13. Required Verification Evidence Types

A requirement may not move to VERIFIED solely because code exists.

Applicable evidence may include:

- Flutter unit/widget/integration tests;
- Pytest;
- protected API tests;
- database constraint tests;
- Supabase RLS tests;
- authorization/permission-denied tests;
- secure-upload tests;
- rate-limit/security checks;
- failure/recovery tests;
- performance measurements;
- algorithm validation datasets/checklists;
- deterministic/reproducibility tests;
- UAT results;
- screenshots;
- demonstration checklist;
- privacy/threat-review findings;
- ISO/IEC 25010:2023 evaluation evidence;
- reviewed pull request and commit history.

---

# 14. Traceability Gaps and Follow-Up Items

## RTM-G01 — `FR-CM-006` has no explicit user-story link

`FR-CM-006` exists in the functional-requirements baseline but is not explicitly linked by the current set of user stories.

Current handling:

- retain `FR-CM-006` as a valid requirement;
- trace it directly to communication/realtime design and Stage 11 implementation;
- do not fabricate a user-story ID.

Before final Stage 3 gate review, decide whether a story update is useful or whether direct requirement traceability is sufficient.

## RTM-G02 — Cross-cutting NFRs do not have explicit objective labels in the requirements source

Current handling:

- preserve explicit objective mappings from user stories;
- record security, privacy, reliability, performance, usability, architecture, and traceability NFRs as cross-cutting support where no explicit source mapping exists;
- use Objective 6 directly where the study clearly defines the corresponding evaluation quality characteristic or algorithm-validation outcome.

## RTM-G03 — Approval-dependent configuration remains unresolved

No RTM row may convert an Approval-dependent rule, weight, threshold, taxonomy, route, deadline, lifecycle, emergency configuration, retention policy, or privilege into a final production value without approval evidence.

## RTM-G04 — Existing migrations are partial implementation evidence

Schema foundations exist for several areas, but the RTM must not mark their full features VERIFIED until Flutter/API/business logic/test evidence exists.

## RTM-G05 — Objective 6 terminology and final validation criteria

The final ISO/IEC 25010:2023 evaluation instrument terminology and algorithm validation dataset size, balance, evaluator qualifications, disagreement procedure, and pass thresholds remain subject to required approval.

---

# 15. RTM Coverage Checklist

The RTM is ready for Stage 3 gate review only when:

- [ ] `FR-UM-001`–`012` are represented;
- [ ] `FR-CR-001`–`014` are represented;
- [ ] `FR-LE-001`–`008` are represented;
- [ ] `FR-RT-001`–`006` are represented;
- [ ] `FR-ALG-001`–`031` are represented;
- [ ] `FR-AD-001`–`015` are represented;
- [ ] `FR-SOS-001`–`018` are represented;
- [ ] `FR-CM-001`–`006` are represented;
- [ ] `FR-AU-001`–`006` are represented;
- [ ] `FR-CFG-001`–`012` are represented;
- [ ] `UI-STATE-001`–`009` are represented;
- [ ] `NFR-SEC-001`–`012` are represented;
- [ ] `NFR-PRV-001`–`006` are represented;
- [ ] `NFR-REL-001`–`006` are represented;
- [ ] `NFR-PERF-001`–`003` are represented;
- [ ] `NFR-UX-001`–`006` are represented;
- [ ] `NFR-DET-001`–`004` are represented;
- [ ] `NFR-TRC-001`–`004` are represented;
- [ ] `NFR-ARC-001`–`010` are represented;
- [ ] `NFR-EVAL-001`–`016` are represented;
- [ ] `OOS-001`–`009` are represented;
- [ ] all 22 existing individual user-story IDs are represented;
- [ ] `AC-X-001`–`009` are represented as cross-cutting acceptance criteria;
- [ ] all six approved study objectives are represented;
- [ ] approval-dependent requirements remain visibly approval-dependent;
- [ ] pending-validation requirements remain visibly pending;
- [ ] existing schema evidence is not confused with feature completion;
- [ ] future implementation and verification stages are identified;
- [ ] known traceability gaps are recorded rather than silently filled.

---

# 16. Maintenance Rule

Whenever a requirement, user story, approved stakeholder decision, schema migration, API endpoint, UI flow, algorithm configuration, test, evaluation criterion, or deployment artifact changes:

1. identify every affected stable requirement ID;
2. update the corresponding RTM trace;
3. preserve historical approval/version evidence where applicable;
4. add or update implementation and verification evidence;
5. run the relevant regression tests;
6. include the RTM/documentation change in the same reviewed pull request when practical.

A requirement must never be marked VERIFIED without objective implementation and test evidence.

A feature must never be considered complete merely because its requirement, diagram, migration foundation, or user interface exists.
