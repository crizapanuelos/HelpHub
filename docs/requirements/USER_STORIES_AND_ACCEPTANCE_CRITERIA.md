# HelpHub User Stories and Acceptance Criteria

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — user-story baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related stakeholder record: `docs/requirements/STAKEHOLDER_VALIDATION_NOTES.md`

## 1. Purpose

This document converts the approved HelpHub requirements baseline into testable user stories and acceptance criteria.

The stories describe required user outcomes without inventing approval-sensitive barangay policy values.

Where a story depends on concern taxonomy, weights, numerical priority thresholds, routing, deadlines, status transitions, non-SOS Critical rules, emergency escalation, retention, or protected configuration privilege, the acceptance criteria require the active approved version rather than a hard-coded provisional value.

## 2. User Story Format

Each story contains:

- Story ID.
- Actor.
- User story.
- Linked requirement IDs.
- Study objective.
- Approval dependency where applicable.
- Testable acceptance criteria.

A story is not considered implementation-complete merely because its main success path works.

## 3. Cross-Cutting Acceptance Criteria

The following criteria apply to every user-facing story where the state is relevant.

| ID | Acceptance criterion |
|---|---|
| AC-X-001 | A pending operation presents an understandable loading or progress state. |
| AC-X-002 | A successful operation provides clear confirmation where confirmation is necessary. |
| AC-X-003 | A list, history, or dashboard with no authorized records presents an intentional empty state rather than a broken layout. |
| AC-X-004 | Invalid user input produces actionable validation feedback and does not falsely report success. |
| AC-X-005 | Permission denial prevents the protected action and does not expose protected information. |
| AC-X-006 | Network failure results in a controlled failure state and safe retry behavior where appropriate. |
| AC-X-007 | A timeout does not leave the interface indefinitely loading or falsely report completion. |
| AC-X-008 | An expired or invalid session prevents the protected operation and requires appropriate re-authentication behavior. |
| AC-X-009 | A server failure produces a controlled error state and does not falsely indicate that a protected write succeeded. |

Full offline operation is not required. Offline or weak-network behavior is handled as failure/recovery behavior.

## 4. User Management Stories

### US-UM-001 — Resident Registration

**Actor:** Prospective Resident

**Story:**
As a prospective resident, I want to create a HelpHub resident account so that I can access authorized barangay concern-reporting functions.

**Linked requirements:** FR-UM-001, FR-UM-002, NFR-SEC-005

**Study objective:** Objective 1

**Acceptance criteria:**

1. The registration interface requests the required approved registration information.
2. Missing or invalid required information prevents successful registration and displays validation feedback.
3. Valid registration data results in creation of the intended resident account through the approved authentication workflow.
4. The client cannot choose or grant itself an administrator role during resident registration.
5. A failed network, timeout, authentication-service, or server operation does not falsely show account creation as successful.
6. Applicable cross-cutting criteria AC-X-001 through AC-X-009 are satisfied.

### US-UM-002 — Secure Login and Logout

**Actor:** Registered User

**Story:**
As a registered user, I want to log in and log out securely so that I can access only the HelpHub functions authorized for my account.

**Linked requirements:** FR-UM-003, FR-UM-004, FR-UM-010, FR-UM-011, FR-UM-012

**Study objective:** Objective 1

**Acceptance criteria:**

1. Valid approved credentials establish an authenticated session.
2. Invalid credentials do not authenticate the user.
3. The authenticated role determines the permitted application area.
4. Resident users cannot obtain administrator privileges by modifying client-side state.
5. Logout ends the local authenticated session according to the approved authentication design.
6. Protected operations reject expired or invalid authentication.
7. Applicable cross-cutting criteria are satisfied.

### US-UM-003 — Resident Profile Management

**Actor:** Resident

**Story:**
As a resident, I want to view and manage permitted profile information so that my HelpHub account information remains accurate.

**Linked requirements:** FR-UM-005, NFR-SEC-001, NFR-PRV-003

**Study objective:** Objective 1

**Acceptance criteria:**

1. The resident can view only profile fields permitted by the approved profile model.
2. Permitted editable fields can be updated using valid values.
3. Invalid changes are rejected with validation feedback.
4. A resident cannot use profile editing to change protected role or verification authority fields.
5. Unauthorized users cannot modify another resident's protected profile through normal client access.
6. Applicable cross-cutting criteria are satisfied.

### US-UM-004 — Resident Verification Submission

**Actor:** Resident

**Story:**
As a resident, I want to submit the approved verification information so that the barangay can determine whether my account is eligible for verified-resident functions.

**Linked requirements:** FR-UM-006

**Study objective:** Objective 1

**Approval dependency:** Required verification fields and detailed workflow require approval.

**Acceptance criteria:**

1. Only the verification information defined by the approved verification process is requested.
2. Required verification information is validated before submission.
3. A successful submission produces a traceable verification record or state.
4. The resident cannot approve the resident's own verification.
5. Missing approval-sensitive fields are not replaced with invented implementation values.
6. Applicable cross-cutting criteria are satisfied.

### US-ADM-001 — Review Resident Verification

**Actor:** Barangay Administrator

**Story:**
As an authorized barangay administrator, I want to review resident verification submissions so that account verification decisions follow the approved barangay process.

**Linked requirements:** FR-UM-007, FR-UM-008, FR-UM-009, FR-UM-012

**Study objective:** Objective 1

**Approval dependency:** Detailed decision states and restriction rules require approval.

**Acceptance criteria:**

1. Only an authorized administrator can access protected verification-review information.
2. The administrator can review the verification information permitted by the approved process.
3. The administrator can perform only verification decisions allowed by the approved workflow.
4. Unauthorized decision values are rejected.
5. Security-sensitive account decisions generate appropriate traceability or audit evidence.
6. A resident cannot perform administrator verification actions.
7. Applicable cross-cutting criteria are satisfied.

## 5. Concern Reporting and Tracking Stories

### US-CR-001 — Submit a Normal Concern

**Actor:** Verified/Authorized Resident

**Story:**
As a resident, I want to submit a structured barangay concern so that the barangay can review, prioritize, and track the issue.

**Linked requirements:** FR-CR-001 through FR-CR-014

**Study objective:** Objective 2

**Approval dependency:** Active concern taxonomy remains stakeholder-controlled.

**Acceptance criteria:**

1. The resident selects an initial concern type from the active approved taxonomy.
2. The report captures description, resident-declared urgency, affected population, vulnerable-group indicator, required location information, optional photo evidence, and relevant timestamps.
3. Required fields are validated before protected processing begins.
4. Invalid required input does not enter the valid priority-processing pipeline.
5. Successful submission creates the report and provides clear confirmation.
6. The resident-selected concern type is preserved for later explanation and audit.
7. A failed write does not present the report as successfully submitted.
8. Applicable cross-cutting criteria are satisfied.

### US-CR-002 — Provide One-Time Location

**Actor:** Resident

**Story:**
As a resident, I want to provide my current location only when a report or SOS needs it so that HelpHub can locate the submitted event without continuously tracking me.

**Linked requirements:** FR-LE-001 through FR-LE-004, NFR-PRV-001, NFR-PRV-002

**Study objectives:** Objectives 2 and 3

**Acceptance criteria:**

1. Location access is requested only when the current interaction requires location.
2. A successful GPS capture stores latitude, longitude, accuracy, and capture time.
3. An optional human-readable address may be stored when available.
4. Location-permission denial is distinguishable from successful capture.
5. Location-unavailable or location-failure states are distinguishable from a valid GPS result.
6. HelpHub does not continuously collect resident location in the background as part of normal operation.
7. Applicable cross-cutting criteria are satisfied.

### US-CR-003 — Attach Optional Photo Evidence

**Actor:** Resident

**Story:**
As a resident, I want to attach permitted optional photo evidence so that I can provide useful context for my concern.

**Linked requirements:** FR-CR-010, FR-LE-005 through FR-LE-008, NFR-SEC-008, NFR-SEC-009

**Study objective:** Objective 2

**Acceptance criteria:**

1. A normal report can be submitted without a photo when evidence is optional.
2. A permitted photo can be selected and uploaded subject to approved restrictions.
3. Invalid file types or files exceeding the approved limit are rejected.
4. Evidence is stored using restricted/private storage controls.
5. Evidence is not made publicly accessible merely by knowing or guessing its storage path.
6. Only users authorized for the related report can access protected evidence.
7. Applicable cross-cutting criteria are satisfied.

### US-RT-001 — Track My Reports

**Actor:** Resident

**Story:**
As a resident, I want to view my submitted reports and their current states so that I know what is happening with my concerns.

**Linked requirements:** FR-RT-001 through FR-RT-006

**Study objective:** Objective 2

**Acceptance criteria:**

1. The resident can view reports the resident is authorized to access.
2. The resident cannot use normal client access to read another resident's protected reports.
3. Each report displays its current approved status.
4. A resident with no reports receives an intentional empty state.
5. Near-real-time updates may refresh permitted information when network and service conditions allow.
6. The interface does not claim guaranteed zero-delay synchronization.
7. Applicable cross-cutting criteria are satisfied.

### US-RT-002 — View Complete Status History

**Actor:** Resident

**Story:**
As a resident, I want to view the permitted status history of my report so that I can understand how it progressed over time.

**Linked requirements:** FR-RT-004, FR-AD-010, FR-AD-011

**Study objective:** Objective 2

**Acceptance criteria:**

1. The resident can open the permitted history for the resident's own report.
2. The history is ordered in a consistent chronological presentation.
3. Each successful status transition has a corresponding persisted history record.
4. Missing history is not fabricated from the current status alone.
5. Protected internal-only information is not exposed merely because the resident can view status history.
6. Applicable cross-cutting criteria are satisfied.

## 6. Priority Algorithm Stories

### US-ALG-001 — Transparent Concern-Type Validation

**Actor:** Barangay Administrator

**Story:**
As a barangay administrator, I want HelpHub to preserve the resident-selected type and show the system's validation or recommendation so that classification remains explainable and reviewable.

**Linked requirements:** FR-ALG-001 through FR-ALG-007, FR-ALG-030

**Study objective:** Objective 4

**Approval dependency:** Detailed taxonomy and matching rules require approved versions.

**Acceptance criteria:**

1. The resident-selected type is preserved.
2. The active rule version is used for validation/recommendation.
3. Applicable approved system, city-ordinance, and barangay-specific rules can be evaluated.
4. The result distinguishes validation, recommendation, and required administrator review where supported by the approved workflow.
5. Matched-rule evidence is preserved.
6. The system does not claim that uncertain classification automatically determines legal liability.
7. Reprocessing the same input using the same active versions produces the same deterministic classification result.

### US-ALG-002 — Weighted Priority Calculation

**Actor:** Barangay Administrator

**Story:**
As a barangay administrator, I want reports to receive a reproducible weighted priority result so that queue ordering is transparent rather than based on undocumented manual sorting.

**Linked requirements:** FR-ALG-008 through FR-ALG-017, FR-ALG-024 through FR-ALG-031

**Study objective:** Objective 4

**Approval dependency:** Rating anchors, weights, numerical thresholds, routes, and deadlines require approved versions.

**Acceptance criteria:**

1. Raw approved factor values are converted using the active rating-anchor version.
2. The engine calculates the score as the sum of active weight multiplied by corresponding normalized rating.
3. The active weight and threshold versions are preserved.
4. The resulting priority is one of Low, Medium, High, or Critical.
5. No provisional numerical threshold is hard-coded as final policy.
6. Routing and deadline results use approved active configuration.
7. Raw factors, normalized ratings, weights, score contributions, total score, route, deadline, and version identifiers are preserved.
8. Identical input under identical versions produces an identical result.

### US-ALG-003 — Deterministic Queue Ordering

**Actor:** Barangay Administrator

**Story:**
As a barangay administrator, I want reports ordered deterministically so that the queue is reproducible and ties are resolved consistently.

**Linked requirements:** FR-ALG-018 through FR-ALG-023, NFR-DET-001 through NFR-DET-003

**Study objective:** Objective 4

**Acceptance criteria:**

1. Override rank is compared first in descending order.
2. Priority score is compared next in descending order.
3. Response deadline is compared next in ascending order.
4. Submission time is compared next in ascending order.
5. Report ID ascending is the final tie-breaker.
6. Repeated ordering of the same report set using the same configuration produces the same sequence.
7. Queue tests include ties that reach the deadline, submission-time, and report-ID tie-breakers.

## 7. Administrator Workflow Stories

### US-AD-001 — View Dashboard and Priority Queues

**Actor:** Barangay Administrator

**Story:**
As an authorized administrator, I want dashboard and queue views so that I can review incoming concerns in the approved priority order.

**Linked requirements:** FR-AD-001 through FR-AD-004

**Study objective:** Objective 5

**Acceptance criteria:**

1. Only authorized administrators can access protected administrator queue information.
2. Queue results use the approved deterministic ordering.
3. An empty queue has an intentional empty state.
4. An administrator can open an authorized report detail.
5. Report detail exposes the permitted explanation evidence needed to understand the algorithm result.
6. Applicable cross-cutting criteria are satisfied.

### US-AD-002 — Assign or Refer a Concern

**Actor:** Barangay Administrator

**Story:**
As an authorized administrator, I want to assign a concern internally or record an approved external referral so that responsibility and coordination are traceable.

**Linked requirements:** FR-AD-005 through FR-AD-007, FR-AU-002

**Study objective:** Objective 5

**Approval dependency:** Final handlers and referral procedure require approval.

**Acceptance criteria:**

1. Only authorized users may perform assignment/referral actions.
2. Available internal assignments come from the approved workflow/configuration.
3. External referrals are recorded as coordination/contact actions.
4. HelpHub does not represent a referral record as guaranteed external dispatch.
5. Successful assignment/referral actions are traceable.
6. Invalid or unauthorized destinations/actions are rejected.
7. Applicable cross-cutting criteria are satisfied.

### US-AD-003 — Update Report Status and Add Internal Notes

**Actor:** Barangay Administrator

**Story:**
As an authorized administrator, I want to update a report using approved transitions and record internal notes so that report handling remains organized and auditable.

**Linked requirements:** FR-AD-008 through FR-AD-015

**Study objective:** Objective 5

**Approval dependency:** Final status labels, transitions, and permissions require approval.

**Acceptance criteria:**

1. Only status transitions permitted by the active approved workflow can succeed.
2. Invalid or unauthorized transitions are rejected.
3. Every successful status transition creates a status-history record.
4. Every successful status transition creates required audit evidence.
5. Permitted internal notes can be recorded by authorized administrators.
6. Internal notes are not automatically exposed to residents unless an approved requirement permits it.
7. Reports are closed or archived rather than silently deleted.
8. Applicable cross-cutting criteria are satisfied.

## 8. Emergency Response Stories

### US-SOS-001 — Send a Confirmed SOS

**Actor:** Resident

**Story:**
As a resident facing an urgent situation, I want to send a confirmed SOS so that the barangay receives a Critical emergency report with the information needed for barangay-level coordination.

**Linked requirements:** FR-SOS-001 through FR-SOS-009

**Study objective:** Objective 3

**Approval dependency:** Final emergency taxonomy remains approval-controlled.

**Acceptance criteria:**

1. The SOS interface clearly states that HelpHub does not replace official emergency services.
2. Activation uses the required brief hold or confirmation safeguard.
3. The resident selects an emergency type from the active approved emergency taxonomy.
4. The confirmed SOS captures one-time current GPS information when available and permitted.
5. The submission associates the timestamp and required registered-user details.
6. A confirmed SOS receives an automatic Critical override.
7. A confirmed SOS enters the dedicated emergency queue.
8. Rapid repeated interaction does not silently create unintended duplicate emergency records.
9. A failed SOS network/server write is not falsely presented as successfully delivered.
10. Applicable cross-cutting criteria are satisfied.

### US-SOS-002 — Acknowledge and Track an Emergency

**Actor:** Barangay Administrator

**Story:**
As an authorized administrator, I want to acknowledge and track emergency reports so that emergency handling actions remain visible and traceable.

**Linked requirements:** FR-SOS-010 through FR-SOS-018

**Study objectives:** Objectives 3 and 5

**Approval dependency:** Detailed emergency transitions and escalation behavior require approval.

**Acceptance criteria:**

1. Only authorized administrators can access protected emergency queue details.
2. An authorized administrator can acknowledge an emergency according to the approved workflow.
3. Acknowledgement is traceable.
4. Permitted emergency status changes use approved transitions.
5. Assignment/referral actions remain traceable.
6. If escalation is configured, recipients, timing, retry, cancellation, and stop behavior come from approved versioned configuration.
7. Each escalation attempt is traceable.
8. A false-alarm action requires an authorized user and mandatory reason.
9. False alarm does not silently delete the emergency record or its history.
10. The interface does not claim guaranteed external-agency response.
11. Applicable cross-cutting criteria are satisfied.

## 9. Communication Stories

### US-CM-001 — Receive Notifications

**Actor:** Resident

**Story:**
As a resident, I want to receive appropriate notifications about my reports so that I can notice important changes without repeatedly opening the application.

**Linked requirements:** FR-CM-001 through FR-CM-003

**Study objectives:** Objectives 2, 3, and 5

**Acceptance criteria:**

1. Approved report or emergency events can create notification attempts.
2. Notification failure does not alter or corrupt authoritative report state.
3. HelpHub does not claim guaranteed push delivery.
4. Lock-screen notification content avoids unnecessary sensitive identity, GPS, SOS, or report details.
5. Opening a notification does not bypass authentication or authorization for protected content.

### US-CM-002 — View Barangay Announcements

**Actor:** Resident

**Story:**
As a resident, I want to view barangay announcements so that I can receive community information published through HelpHub.

**Linked requirements:** FR-CM-004, FR-CM-005

**Study objective:** Objective 5

**Acceptance criteria:**

1. A resident can view announcements the resident is authorized to receive.
2. No available announcements produces an intentional empty state.
3. Only authorized administrators can use protected announcement-publishing functions.
4. A failed announcement load or network request has a controlled error state.
5. Applicable cross-cutting criteria are satisfied.

## 10. Protected Configuration Story

### US-CFG-001 — Manage Versioned Algorithm Configuration

**Actor:** Specifically Authorized Barangay Administrator

**Story:**
As an administrator explicitly authorized for configuration governance, I want approved rules and algorithm configuration stored as immutable versions so that historical report results remain reproducible.

**Linked requirements:** FR-CFG-001 through FR-CFG-012, NFR-DET-003

**Study objectives:** Objectives 4 and 5

**Approval dependency:** Configuration-editing privilege and final policy values require approval.

**Acceptance criteria:**

1. Ordinary resident users cannot access protected configuration editing.
2. Administrator status alone does not automatically grant configuration-editing privilege when the approved governance policy requires additional authorization.
3. Taxonomy, rule, rating-anchor, weight, threshold, route, deadline, and applicable escalation values are versioned when used.
4. Required reason, approval, activation, and audit evidence are preserved according to the approved governance process.
5. A version already referenced by a completed algorithm run is not edited in place.
6. A material approved change creates a new version.
7. Historical reports remain linked to the configuration versions used when they were processed.
8. Unauthorized configuration writes are rejected and do not alter active policy.

## 11. Audit and Traceability Story

### US-AU-001 — Review Audit Evidence

**Actor:** Authorized Barangay Administrator

**Story:**
As an authorized administrator, I want permitted audit evidence so that sensitive workflow and administrative actions can be reviewed and traced.

**Linked requirements:** FR-AU-001 through FR-AU-006, NFR-TRC-004

**Study objective:** Objective 5

**Acceptance criteria:**

1. Audit access is restricted to appropriately authorized users.
2. Required status-change events are represented in audit evidence.
3. Required assignment/referral events are represented.
4. Required emergency acknowledgement, escalation, false-alarm, and referral events are represented.
5. Required protected-configuration changes are represented.
6. Audit evidence is not silently modified or removed through ordinary resident workflows.
7. An empty authorized audit result is distinguishable from an access failure.
8. Applicable cross-cutting criteria are satisfied.

## 12. Story-to-Objective Summary

| Story group | Study objective |
|---|---|
| US-UM / US-ADM-001 | Objective 1 — User management |
| US-CR / US-RT | Objective 2 — Concern reporting and tracking |
| US-SOS | Objective 3 — Emergency Response Module |
| US-ALG / US-CFG | Objective 4 — Rule-Based Weighted Priority Queue Algorithm |
| US-AD / US-CM / US-AU | Objective 5 — Administrator and communication module |

Objective 6 is addressed through the acceptance criteria, technical tests, algorithm validation, and later ISO/IEC 25010:2023 evaluation artifacts.

## 13. Story Completion Rule

A user story may be marked implementation-complete only when:

1. its story and acceptance criteria are approved;
2. applicable loading, success, empty, validation, permission-denied, network-failure, timeout, unauthorized/session, and server-error states are implemented;
3. required database migration and Row Level Security controls exist where applicable;
4. required protected FastAPI behavior and server-side authorization exist where applicable;
5. normal, boundary, invalid, unauthorized, and failure tests exist where applicable;
6. documentation and required screenshots/evidence exist;
7. the implementation is traceable to the relevant requirement IDs and study objective;
8. the demonstration checklist is satisfied; and
9. the code has been committed and reviewed through the approved pull-request workflow.

A story that depends on unresolved stakeholder configuration cannot be declared fully approved merely because a provisional value works in code.

## 14. Stage 3 Approval Rule

These user stories form the draft backlog baseline.

Approval-sensitive values remain governed by `STAKEHOLDER_VALIDATION_NOTES.md`.

If stakeholder validation materially changes a requirement, affected user stories and acceptance criteria must be revised before Stage 3 can pass.
