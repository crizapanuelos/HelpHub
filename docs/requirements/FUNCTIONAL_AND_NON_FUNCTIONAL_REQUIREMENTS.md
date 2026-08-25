# HelpHub Functional and Non-Functional Requirements

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — requirements baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related document: `docs/requirements/STAKEHOLDER_VALIDATION_NOTES.md`

## 1. Purpose

This document defines the functional and non-functional requirements for HelpHub.

Requirements are derived from the approved revised study, the approved project scope, the development roadmap, recorded decisions, and the current repository.

This document does not convert provisional barangay policy values into approved configuration.

Detailed concern taxonomy values, factor rating anchors, factor weights, numerical priority thresholds, handlers or referral destinations, acknowledgement and response durations, detailed workflow transitions, non-SOS Critical rules, escalation timing, configuration privileges, retention periods, and algorithm-validation acceptance thresholds remain subject to recorded stakeholder approval where required.

## 2. Requirement Status Terms

| Status | Meaning |
|---|---|
| Established | Directly required by the approved study or canonical project scope |
| Approval-dependent | Capability is required, but one or more policy/configuration values require stakeholder approval |
| Pending validation | Detailed workflow behavior requires barangay/adviser confirmation before implementation is frozen |

## 3. Actors and Authority Boundary

### 3.1 Resident

A Resident is a registered barangay resident who may use authorized resident functions such as account management, concern submission, personal report tracking, announcements, notifications, and Emergency SOS.

### 3.2 Barangay Administrator

A Barangay Administrator is an authorized administrative user who may perform functions allowed by the approved role and workflow policy, including resident verification, report review, emergency acknowledgement, assignment/referral, approved status changes, announcements, audit-supported administration, and protected configuration where specifically authorized.

### 3.3 Assignment and Referral Destinations

Barangay personnel and external organizations may be recorded as assignment or referral destinations when supported by the approved workflow.

They are not automatically HelpHub user roles and must not be represented as guaranteed technically integrated responders unless a formal integration actually exists.

## 4. Functional Requirements

### 4.1 User Management and Access Control

| ID | Requirement | Status |
|---|---|---|
| FR-UM-001 | The system shall allow a prospective resident to create a resident account using the required registration information. | Established |
| FR-UM-002 | The system shall validate required registration data before account creation. | Established |
| FR-UM-003 | The system shall allow registered users to authenticate securely using approved credentials. | Established |
| FR-UM-004 | The system shall provide a secure logout capability. | Established |
| FR-UM-005 | The system shall allow residents to view and manage permitted profile information. | Established |
| FR-UM-006 | The system shall allow residents to submit the verification information required by the approved barangay verification process. | Approval-dependent |
| FR-UM-007 | The system shall allow authorized administrators to review resident verification submissions. | Established |
| FR-UM-008 | The system shall allow authorized administrators to approve or otherwise manage resident verification according to the approved workflow. | Approval-dependent |
| FR-UM-009 | The system shall allow authorized administrators to restrict accounts where permitted by the approved governance policy. | Approval-dependent |
| FR-UM-010 | The system shall enforce role-based authorization so residents cannot access administrator-only functions. | Established |
| FR-UM-011 | The system shall prevent client-side role information from being the sole authority for protected operations. | Established |
| FR-UM-012 | Sensitive administrative authorization shall also be enforced server-side and through applicable database access controls. | Established |

### 4.2 Normal Concern Reporting

| ID | Requirement | Status |
|---|---|---|
| FR-CR-001 | The system shall allow an authorized registered resident to create a normal concern report. | Established |
| FR-CR-002 | A normal report shall capture the resident-selected concern type from the active approved taxonomy. | Approval-dependent |
| FR-CR-003 | A normal report shall capture a description of the concern. | Established |
| FR-CR-004 | A normal report shall capture location information when location is required for the report. | Established |
| FR-CR-005 | Stored location data shall include latitude, longitude, accuracy, and capture time when GPS is captured. | Established |
| FR-CR-006 | The system may store an optional human-readable address when available. | Established |
| FR-CR-007 | A normal report shall capture resident-declared urgency. | Established |
| FR-CR-008 | A normal report shall capture affected-population information. | Established |
| FR-CR-009 | A normal report shall capture the vulnerable-group indicator required by the approved report model. | Established |
| FR-CR-010 | The system shall allow optional permitted photo evidence to be attached to a normal report. | Established |
| FR-CR-011 | The system shall preserve submission and relevant processing timestamps. | Established |
| FR-CR-012 | The system shall validate required report input before protected report processing. | Established |
| FR-CR-013 | Invalid report data shall not silently enter the priority-processing pipeline as a valid report. | Established |
| FR-CR-014 | The system shall provide clear submission confirmation after successful report creation. | Established |

### 4.3 Location and Evidence Handling

| ID | Requirement | Status |
|---|---|---|
| FR-LE-001 | The system shall request location access only when a location-based report or SOS requires location. | Established |
| FR-LE-002 | The system shall not continuously track resident location. | Established |
| FR-LE-003 | The system shall handle location-permission denial without falsely reporting successful location capture. | Established |
| FR-LE-004 | The system shall distinguish unavailable or failed location capture from a valid captured location. | Established |
| FR-LE-005 | Optional report evidence shall use restricted/private storage rather than public unrestricted storage. | Established |
| FR-LE-006 | Evidence access shall be restricted to users authorized to access the related report evidence. | Established |
| FR-LE-007 | The system shall enforce approved upload type and size restrictions. | Established |
| FR-LE-008 | Evidence paths or object identifiers shall not rely on predictable public naming as an access-control mechanism. | Established |

### 4.4 Resident Report Tracking

| ID | Requirement | Status |
|---|---|---|
| FR-RT-001 | A resident shall be able to view reports that the resident is authorized to access. | Established |
| FR-RT-002 | A resident shall not be able to use normal client access to view another resident's protected reports. | Established |
| FR-RT-003 | The system shall display the current approved status of a resident's report. | Established |
| FR-RT-004 | The system shall provide the resident with the complete permitted status history of the resident's own report. | Established |
| FR-RT-005 | Report tracking shall use near-real-time synchronization when network and service conditions permit. | Established |
| FR-RT-006 | The interface shall not represent near-real-time synchronization as guaranteed zero-delay delivery. | Established |

### 4.5 Rule-Based Weighted Priority Queue Algorithm

| ID | Requirement | Status |
|---|---|---|
| FR-ALG-001 | Protected server-side processing shall validate required normal-report input before algorithm execution. | Established |
| FR-ALG-002 | The algorithm shall preserve the concern type initially selected by the resident. | Established |
| FR-ALG-003 | The algorithm shall validate the selected concern type or recommend another approved concern type using the active versioned rules. | Approval-dependent |
| FR-ALG-004 | The algorithm shall support administrator review where an approved workflow requires classification review. | Approval-dependent |
| FR-ALG-005 | The algorithm shall match applicable approved system rules. | Approval-dependent |
| FR-ALG-006 | The algorithm shall match applicable approved city-ordinance rules. | Approval-dependent |
| FR-ALG-007 | The algorithm shall match applicable approved barangay-specific rules. | Approval-dependent |
| FR-ALG-008 | Approved factor inputs shall be converted to normalized ratings using the active approved rating anchors. | Approval-dependent |
| FR-ALG-009 | The priority score shall be calculated as the deterministic sum of each active weight multiplied by its corresponding normalized rating. | Established |
| FR-ALG-010 | The algorithm shall use an active versioned weight set. | Approval-dependent |
| FR-ALG-011 | The algorithm shall map the weighted result to one of the four study-approved priority names: Low, Medium, High, or Critical. | Established |
| FR-ALG-012 | Numerical score ranges used for priority mapping shall come from an approved versioned threshold configuration. | Approval-dependent |
| FR-ALG-013 | The algorithm shall support an automatic Critical override for a confirmed SOS. | Established |
| FR-ALG-014 | A normal non-SOS report shall receive an automatic Critical override only when an approved and testable life-threatening rule is satisfied. | Approval-dependent |
| FR-ALG-015 | Uncertain text-only or keyword-only safety indicators shall not silently become a Critical override unless an approved deterministic rule authorizes that behavior. | Approval-dependent |
| FR-ALG-016 | The algorithm shall assign an approved internal handler or referral destination when required by the active routing configuration. | Approval-dependent |
| FR-ALG-017 | The algorithm shall assign applicable response deadlines using approved versioned deadline configuration. | Approval-dependent |
| FR-ALG-018 | Reports shall be ordered by override rank descending. | Established |
| FR-ALG-019 | Reports with equal override rank shall next be ordered by priority score descending. | Established |
| FR-ALG-020 | Remaining ties shall next be ordered by nearest response deadline ascending. | Established |
| FR-ALG-021 | Remaining ties shall next be ordered by submission time ascending. | Established |
| FR-ALG-022 | Report ID ascending shall be the final deterministic tie-breaker. | Established |
| FR-ALG-023 | Identical inputs processed using identical algorithm and configuration versions shall produce identical deterministic outputs. | Established |
| FR-ALG-024 | Each completed algorithm run shall preserve the algorithm version. | Established |
| FR-ALG-025 | Each completed algorithm run shall preserve applicable rule, weight, threshold, route, and deadline configuration versions. | Established |
| FR-ALG-026 | Each completed algorithm run shall preserve raw factor values and normalized ratings. | Established |
| FR-ALG-027 | Each completed algorithm run shall preserve matched rules and score contributions. | Established |
| FR-ALG-028 | Each completed algorithm run shall preserve total score and priority before and after any override. | Established |
| FR-ALG-029 | Each completed algorithm run shall preserve any override reason. | Established |
| FR-ALG-030 | Each completed algorithm run shall preserve classification validation/recommendation evidence. | Established |
| FR-ALG-031 | Each completed algorithm run shall preserve routing, deadline, and deterministic queue-key evidence. | Established |

### 4.6 Administrator Dashboard and Normal Report Management

| ID | Requirement | Status |
|---|---|---|
| FR-AD-001 | The system shall provide authorized administrators with a dashboard for permitted concern-management information. | Established |
| FR-AD-002 | The administrator interface shall provide queue views ordered using the approved deterministic queue rules. | Established |
| FR-AD-003 | Authorized administrators shall be able to open permitted report details. | Established |
| FR-AD-004 | Report details shall expose sufficient algorithm explanation evidence to authorized administrators for review. | Established |
| FR-AD-005 | Authorized administrators shall be able to assign a report according to approved workflow permissions. | Approval-dependent |
| FR-AD-006 | Authorized administrators shall be able to record an external referral when permitted by the approved workflow. | Approval-dependent |
| FR-AD-007 | Referral records shall represent a coordination/contact action rather than guaranteed external dispatch. | Established |
| FR-AD-008 | Authorized administrators shall be able to perform approved status transitions. | Approval-dependent |
| FR-AD-009 | Invalid or unauthorized status transitions shall be rejected. | Established |
| FR-AD-010 | Every successful status change shall create a status-history record. | Established |
| FR-AD-011 | Every successful status change shall create an associated audit event. | Established |
| FR-AD-012 | Authorized administrators shall be able to add permitted internal notes. | Established |
| FR-AD-013 | Internal notes shall not automatically be exposed to residents unless an approved requirement explicitly permits such exposure. | Established |
| FR-AD-014 | Reports shall not be silently deleted through the normal administrative workflow. | Established |
| FR-AD-015 | Closed or archived states shall preserve required historical traceability. | Established |

### 4.7 Emergency Response Module

| ID | Requirement | Status |
|---|---|---|
| FR-SOS-001 | The resident interface shall provide an Emergency SOS capability for urgent situations. | Established |
| FR-SOS-002 | SOS activation shall use a brief hold or confirmation mechanism intended to reduce accidental activation without making urgent use impractical. | Established |
| FR-SOS-003 | The Emergency SOS interface shall clearly state that HelpHub does not replace official emergency services. | Established |
| FR-SOS-004 | A confirmed SOS shall capture an emergency type from the approved active emergency taxonomy. | Approval-dependent |
| FR-SOS-005 | A confirmed SOS shall capture one-time current GPS location when available and permitted. | Established |
| FR-SOS-006 | A confirmed SOS shall capture the location accuracy and capture time associated with the GPS result. | Established |
| FR-SOS-007 | A confirmed SOS shall associate the submission timestamp and registered-user details needed by the approved workflow. | Established |
| FR-SOS-008 | A confirmed SOS shall receive an automatic Critical override. | Established |
| FR-SOS-009 | A confirmed SOS shall be placed in the emergency queue. | Established |
| FR-SOS-010 | Authorized administrators shall be able to acknowledge an emergency according to the approved workflow. | Approval-dependent |
| FR-SOS-011 | Emergency acknowledgement shall be traceable. | Established |
| FR-SOS-012 | The system shall support emergency status tracking according to approved transitions. | Approval-dependent |
| FR-SOS-013 | The system shall support approved emergency assignment or referral actions. | Approval-dependent |
| FR-SOS-014 | If emergency escalation is enabled, recipients, timing, retries, acknowledgement cancellation behavior, and stop conditions shall come from approved configuration. | Approval-dependent |
| FR-SOS-015 | Each emergency escalation attempt shall be traceable. | Established |
| FR-SOS-016 | Authorized administrators may classify an emergency as a false alarm only according to the approved workflow. | Approval-dependent |
| FR-SOS-017 | A false-alarm action shall require a reason and shall preserve the emergency record, history, and audit evidence. | Established |
| FR-SOS-018 | HelpHub shall not claim guaranteed response or dispatch by police, fire, medical, disaster-response, or other external agencies. | Established |

### 4.8 Notifications and Announcements

| ID | Requirement | Status |
|---|---|---|
| FR-CM-001 | The system shall support notifications for approved report and emergency events. | Established |
| FR-CM-002 | The system shall treat push notifications as delivery attempts and shall not claim guaranteed delivery. | Established |
| FR-CM-003 | Sensitive push-notification content shall avoid exposing unnecessary protected GPS, SOS, identity, or report details on a device lock screen. | Established |
| FR-CM-004 | The system shall allow authorized administrators to publish barangay announcements. | Established |
| FR-CM-005 | Residents shall be able to view announcements that they are authorized to receive. | Established |
| FR-CM-006 | Where applicable, near-real-time synchronization shall update permitted report and queue information when service and network conditions allow. | Established |

### 4.9 Audit and Traceability

| ID | Requirement | Status |
|---|---|---|
| FR-AU-001 | The system shall maintain audit evidence for security-sensitive and workflow-sensitive administrator actions. | Established |
| FR-AU-002 | Assignment and referral actions shall be traceable. | Established |
| FR-AU-003 | Status changes shall be traceable. | Established |
| FR-AU-004 | Emergency acknowledgement, escalation, false-alarm, and referral actions shall be traceable. | Established |
| FR-AU-005 | Protected configuration changes shall be traceable. | Established |
| FR-AU-006 | Audit information shall be accessible only to appropriately authorized users. | Established |

### 4.10 Protected Configuration

| ID | Requirement | Status |
|---|---|---|
| FR-CFG-001 | Concern taxonomy and related routing configuration shall support approved versioning rather than permanent hard-coding. | Approval-dependent |
| FR-CFG-002 | Rule sets shall be stored as versioned configuration. | Approval-dependent |
| FR-CFG-003 | Rating anchors shall be stored as versioned configuration. | Approval-dependent |
| FR-CFG-004 | Factor weights shall be stored as versioned configuration. | Approval-dependent |
| FR-CFG-005 | Numerical priority thresholds shall be stored as versioned configuration. | Approval-dependent |
| FR-CFG-006 | Routing configuration shall be versioned. | Approval-dependent |
| FR-CFG-007 | Deadline configuration shall be versioned. | Approval-dependent |
| FR-CFG-008 | Emergency escalation configuration shall be versioned when used. | Approval-dependent |
| FR-CFG-009 | Configuration editing shall be restricted to administrators specifically authorized by the approved governance policy. | Approval-dependent |
| FR-CFG-010 | A configuration change shall preserve required reason, approval, activation, and audit evidence. | Approval-dependent |
| FR-CFG-011 | A configuration version already used by a completed algorithm run shall not be modified in place. | Established |
| FR-CFG-012 | A material configuration change shall create a new version. | Established |

## 5. Cross-Cutting User Interface State Requirements

Every user-facing feature shall explicitly account for applicable states rather than assuming only the successful path.

| ID | State | Requirement |
|---|---|---|
| UI-STATE-001 | Loading | The interface shall show an understandable loading/progress state when an operation is pending. |
| UI-STATE-002 | Success | The interface shall clearly communicate successful completion where user confirmation is necessary. |
| UI-STATE-003 | Empty | Data-list and history screens shall provide an intentional empty state when no authorized records exist. |
| UI-STATE-004 | Validation error | Invalid user input shall produce actionable validation feedback without falsely reporting success. |
| UI-STATE-005 | Permission denied | Permission denial shall be handled explicitly and shall not expose protected information. |
| UI-STATE-006 | Network failure | Network failure shall produce an understandable failure state and safe retry behavior where appropriate. |
| UI-STATE-007 | Timeout | Operations subject to timeout shall display an understandable timeout/failure state rather than indefinite loading. |
| UI-STATE-008 | Unauthorized/session failure | Expired or invalid authentication shall be handled without allowing protected operations to continue. |
| UI-STATE-009 | Server error | Server-side failures shall produce a controlled error state and shall not falsely indicate that a protected write succeeded. |

Full offline operation is not required. A weak/offline-network state is therefore a failure/recovery requirement, not a requirement to support complete offline concern or SOS submission.

## 6. Non-Functional Requirements

### 6.1 Security

| ID | Requirement | Status |
|---|---|---|
| NFR-SEC-001 | The system shall apply least-privilege access principles. | Established |
| NFR-SEC-002 | Supabase Row Level Security shall protect applicable client-accessible data domains. | Established |
| NFR-SEC-003 | FastAPI shall perform server-side authorization for protected business operations. | Established |
| NFR-SEC-004 | The Flutter client shall not be the sole authority for roles, priority, routing, deadlines, protected configuration, or security-sensitive administrative writes. | Established |
| NFR-SEC-005 | Inputs shall be validated at appropriate trust boundaries. | Established |
| NFR-SEC-006 | Sensitive write operations shall be protected by appropriate rate limiting. | Established |
| NFR-SEC-007 | Report and SOS submission endpoints shall be included in rate-limit/security review. | Established |
| NFR-SEC-008 | Private evidence uploads shall enforce approved file-type and file-size restrictions. | Established |
| NFR-SEC-009 | Sensitive evidence access shall use restricted/private access mechanisms. | Established |
| NFR-SEC-010 | Secrets, service-account credentials, database secrets, signing keys, and private certificates shall not be committed to source control. | Established |
| NFR-SEC-011 | Security-sensitive administrator actions shall generate appropriate audit evidence. | Established |
| NFR-SEC-012 | GPS and SOS information shall be restricted to appropriately authorized users. | Established |

### 6.2 Privacy

| ID | Requirement | Status |
|---|---|---|
| NFR-PRV-001 | HelpHub shall collect location only when required for a location-based report or SOS interaction. | Established |
| NFR-PRV-002 | HelpHub shall not continuously track resident location. | Established |
| NFR-PRV-003 | The system shall minimize unnecessary exposure of resident identity, evidence, GPS, and SOS information. | Established |
| NFR-PRV-004 | Notification content shall minimize sensitive information visible outside the authenticated application. | Established |
| NFR-PRV-005 | Retention, anonymization, archival, and secure-deletion periods shall follow the institutionally and stakeholder-approved retention policy. | Approval-dependent |
| NFR-PRV-006 | Research/evaluation exports shall use appropriate privacy controls and minimize unnecessary direct identifiers. | Established |

### 6.3 Reliability and Failure Handling

| ID | Requirement | Status |
|---|---|---|
| NFR-REL-001 | The system shall handle expected network failures without falsely reporting protected writes as successful. | Established |
| NFR-REL-002 | Notification failure shall not corrupt report or emergency state. | Established |
| NFR-REL-003 | Near-real-time synchronization failure shall not redefine the authoritative stored report status. | Established |
| NFR-REL-004 | Duplicate or repeated user actions on sensitive operations shall be tested and handled safely. | Established |
| NFR-REL-005 | Backup and restoration procedures shall be tested before controlled deployment where applicable. | Established |
| NFR-REL-006 | Failure and recovery behavior shall be objectively tested rather than evaluated only by respondent opinion. | Established |

### 6.4 Performance Efficiency

| ID | Requirement | Status |
|---|---|---|
| NFR-PERF-001 | User-facing operations shall respond within measurable and acceptable response-time targets defined before final performance evaluation. | Pending validation |
| NFR-PERF-002 | Performance testing shall use defined workloads and measured response times rather than respondent perception alone. | Established |
| NFR-PERF-003 | Performance targets and workload definitions shall be documented before final performance results are interpreted. | Pending validation |

No numerical response-time threshold is invented in this requirements baseline.

### 6.5 Interaction Capability and Usability

| ID | Requirement | Status |
|---|---|---|
| NFR-UX-001 | The resident experience shall be mobile-first and understandable to users with varying levels of digital familiarity. | Established |
| NFR-UX-002 | The administrator interface shall be responsive and usable on its approved web-capable interface. | Established |
| NFR-UX-003 | Navigation, reporting, status information, and emergency controls shall use understandable labels and feedback. | Established |
| NFR-UX-004 | Emergency controls shall be prominent while incorporating the approved accidental-activation safeguard. | Established |
| NFR-UX-005 | Error messages shall be understandable and shall not unnecessarily expose technical or sensitive information. | Established |
| NFR-UX-006 | User-facing features shall satisfy the applicable cross-cutting UI states defined in Section 5. | Established |

### 6.6 Determinism, Reproducibility, and Explainability

| ID | Requirement | Status |
|---|---|---|
| NFR-DET-001 | Identical algorithm inputs and identical active configuration versions shall produce identical algorithm outputs. | Established |
| NFR-DET-002 | Deterministic queue ordering shall use the complete approved tie-breaking sequence. | Established |
| NFR-DET-003 | Historical algorithm results shall remain reproducible after newer configuration versions are activated. | Established |
| NFR-DET-004 | Algorithm output shall contain sufficient explanation evidence for the defined explanation-completeness validation. | Established |

### 6.7 Auditability and Traceability

| ID | Requirement | Status |
|---|---|---|
| NFR-TRC-001 | Requirements shall use stable identifiers suitable for inclusion in the Requirements Traceability Matrix. | Established |
| NFR-TRC-002 | Implemented features shall be traceable to one or more approved requirements and study objectives. | Established |
| NFR-TRC-003 | Database, API, interface, test, and documentation artifacts shall be traceable to applicable requirements where relevant. | Established |
| NFR-TRC-004 | Status, assignment/referral, emergency, protected-configuration, and security-sensitive administrative actions shall preserve traceability. | Established |

### 6.8 Technology and Architecture Constraints

| ID | Requirement | Status |
|---|---|---|
| NFR-ARC-001 | Flutter/Dart shall provide the Android resident application and responsive web-capable administrator interface in one repository. | Established |
| NFR-ARC-002 | Python/FastAPI shall provide protected API operations, server-side business rules, and the priority algorithm. | Established |
| NFR-ARC-003 | Supabase PostgreSQL shall provide the relational database. | Established |
| NFR-ARC-004 | Supabase Auth shall provide the approved authentication foundation. | Established |
| NFR-ARC-005 | Supabase Storage shall provide private permitted evidence storage. | Established |
| NFR-ARC-006 | Supabase Realtime shall support near-real-time database-driven updates where applicable. | Established |
| NFR-ARC-007 | Supabase Row Level Security shall enforce applicable client data-isolation policies. | Established |
| NFR-ARC-008 | Firebase Cloud Messaging shall provide push-notification attempts. | Established |
| NFR-ARC-009 | `geolocator` shall support one-time location capture. | Established |
| NFR-ARC-010 | `flutter_map` with OpenStreetMap shall support the approved mapping interface. | Established |

### 6.9 Evaluation and Testability

| ID | Requirement | Status |
|---|---|---|
| NFR-EVAL-001 | HelpHub shall be evaluated using the adviser-approved ISO/IEC 25010:2023-based evaluation approach. | Approval-dependent |
| NFR-EVAL-002 | The evaluation shall address Functional Suitability. | Established |
| NFR-EVAL-003 | The evaluation shall address Performance Efficiency. | Established |
| NFR-EVAL-004 | The evaluation shall address Interaction Capability using the terminology confirmed for the final instrument. | Approval-dependent |
| NFR-EVAL-005 | The evaluation shall address Reliability. | Established |
| NFR-EVAL-006 | The evaluation shall address Security. | Established |
| NFR-EVAL-007 | Technical evidence shall supplement user-perception evaluation for security, reliability, performance, authorization, and algorithm correctness. | Established |
| NFR-EVAL-008 | Algorithm validation shall evaluate concern-type agreement. | Established |
| NFR-EVAL-009 | Algorithm validation shall evaluate rule-match correctness. | Established |
| NFR-EVAL-010 | Algorithm validation shall evaluate score-calculation correctness. | Established |
| NFR-EVAL-011 | Algorithm validation shall evaluate final priority agreement. | Established |
| NFR-EVAL-012 | Algorithm validation shall evaluate emergency-override correctness. | Established |
| NFR-EVAL-013 | Algorithm validation shall evaluate deterministic queue-ordering correctness. | Established |
| NFR-EVAL-014 | Algorithm validation shall evaluate reproducibility. | Established |
| NFR-EVAL-015 | Algorithm validation shall evaluate explanation completeness. | Established |
| NFR-EVAL-016 | Final algorithm-validation dataset size, balance, evaluator qualification, disagreement process, and pass thresholds shall be approved before final validation results are collected. | Approval-dependent |

## 7. Scope Constraints

The following are explicitly outside the current HelpHub scope unless the approved study is formally revised:

| ID | Out-of-scope capability |
|---|---|
| OOS-001 | Assistance-request module |
| OOS-002 | Multi-barangay production deployment |
| OOS-003 | Full offline operation |
| OOS-004 | Automatic SMS fallback |
| OOS-005 | Automatic ordinance enforcement or penalties |
| OOS-006 | Replacement of police, fire, medical, disaster-response, or national emergency services |
| OOS-007 | Guaranteed external-agency dispatch or response |
| OOS-008 | Continuous resident location tracking |
| OOS-009 | Long-term post-study operations |

## 8. Unresolved Approval Dependencies

The following must remain configurable or unresolved until approval evidence exists:

1. Final concern taxonomy.
2. Detailed concern-type validation/recommendation rules.
3. Final handlers and referral destinations.
4. Factor definitions where stakeholder validation remains necessary.
5. Normalized rating anchors.
6. Factor weights.
7. Numerical Low/Medium/High/Critical score thresholds.
8. Acknowledgement and response deadlines.
9. Detailed normal-status transitions and permissions.
10. Detailed emergency-status transitions and permissions.
11. Approved non-SOS life-threatening Critical-override rules.
12. Emergency escalation recipients, timing, retry, cancellation, and stop rules.
13. Protected configuration privilege.
14. Data-retention, anonymization, archival, and secure-deletion periods.
15. Final ISO/IEC 25010:2023 instrument terminology and scope where adviser approval is required.
16. Algorithm-validation dataset design and pass criteria.
17. Numerical performance targets and final workload definitions.

These dependencies shall be reconciled with `STAKEHOLDER_VALIDATION_NOTES.md`.

## 9. Requirements Baseline Rule

A requirement marked `Established` may be used as a design constraint, subject to contradiction review.

A requirement marked `Approval-dependent` establishes the required capability but does not approve a policy value.

A requirement marked `Pending validation` shall not be converted into an invented implementation constant.

If later stakeholder evidence changes a material requirement, the affected requirements, diagrams, database design, algorithm configuration, tests, and Requirements Traceability Matrix shall be reviewed and updated before the applicable stage gate passes.
