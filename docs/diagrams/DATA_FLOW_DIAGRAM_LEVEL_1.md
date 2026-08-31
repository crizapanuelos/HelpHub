# HelpHub Data Flow Diagram — Level 1

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — Level 1 DFD baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Parent process: `0 — HelpHub System`
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related workflows: `docs/requirements/STATUS_TRANSITION_TABLES.md`
- Related use cases: `docs/diagrams/USE_CASE_DIAGRAM.md`
- Related conceptual model: `docs/diagrams/UPDATED_CONCEPTUAL_PARADIGM_NARRATIVE.md`
- Related system context: `docs/diagrams/SYSTEM_CONTEXT_DIAGRAM.md`
- Parent DFD: `docs/diagrams/DATA_FLOW_DIAGRAM_LEVEL_0.md`

## 1. Purpose

This document defines the Stage 3 Data Flow Diagram at Level 1 for HelpHub.

The Level 1 DFD decomposes the Level 0 process:

`0 — HelpHub System`

into major logical processes and logical data stores.

The Level 1 model must remain balanced with the verified Level 0 DFD.

The external authenticated entities remain:

1. Resident; and
2. Barangay Administrator.

No new external responder entity is introduced.

This is a logical data-flow model.

It does not define final PostgreSQL table names, FastAPI endpoints, Flutter classes, Supabase policies, storage buckets, Firebase implementation details, or deployment topology.

Those implementation decisions belong to later database, component, deployment, API, and code artifacts.

## 2. Level 1 Data Flow Diagram

~~~mermaid
flowchart LR

    RES["E1 — Resident"]
    ADM["E2 — Barangay Administrator"]

    P1(["1.0 — Identity and<br/>Resident Verification"])
    P2(["2.0 — Normal Concern Intake<br/>and Priority Processing"])
    P3(["3.0 — Resident Tracking<br/>and Status History"])
    P4(["4.0 — Administrator<br/>Concern Workflow"])
    P5(["5.0 — Emergency<br/>SOS Processing"])
    P6(["6.0 — Communications<br/>and Announcements"])
    P7(["7.0 — Audit and<br/>Configuration Governance"])

    D1[("D1 — Identity and<br/>Verification")]
    D2[("D2 — Concern Reports and<br/>Evidence References")]
    D3[("D3 — Algorithm<br/>Decision Evidence")]
    D4[("D4 — Versioned<br/>Configuration")]
    D5[("D5 — Workflow and<br/>Status History")]
    D6[("D6 — Emergency<br/>Records")]
    D7[("D7 — Communications")]
    D8[("D8 — Audit Events")]

    RES -->|"Registration, login,<br/>profile and verification data"| P1
    P1 -->|"Authentication, account<br/>and verification results"| RES
    P1 <-->|"Identity, profile, role<br/>and verification records"| D1

    ADM -->|"Administrator login;<br/>verification decisions and<br/>authorized account actions"| P1
    P1 -->|"Authentication result;<br/>verification queue and<br/>authorized account information"| ADM
    P1 -->|"Audit-worthy identity<br/>and verification actions"| P7

    RES -->|"Normal concern data:<br/>approved concern type, description,<br/>one-time location, urgency,<br/>affected population, vulnerable indicator,<br/>optional evidence, timestamps"| P2

    P2 <-->|"Normal concern record<br/>and evidence references"| D2
    P2 <-->|"Active approved rules,<br/>ratings, weights, thresholds,<br/>routing and deadline configuration"| D4
    P2 -->|"Algorithm versions, factors,<br/>ratings, matched rules, score breakdown,<br/>override, priority, route, deadline,<br/>deterministic queue key"| D3
    P2 -->|"Initial report workflow<br/>and status-history evidence"| D5
    P2 -->|"Submission acknowledgement<br/>and report identifier"| RES
    P2 -->|"Audit-worthy report<br/>and algorithm event"| P7
    P2 -->|"New processed-report event"| P6

    RES -->|"Own-report and<br/>status-history requests"| P3
    D2 -->|"Permitted report data"| P3
    D5 -->|"Permitted status history<br/>and workflow state"| P3
    D6 -->|"Permitted emergency<br/>tracking state"| P3
    P3 -->|"Own report detail,<br/>current status, complete permitted history,<br/>and emergency tracking state"| RES

    ADM -->|"Normal queue/detail requests;<br/>assignment/referral actions;<br/>approved status updates;<br/>internal notes"| P4
    D2 -->|"Concern report data"| P4
    D3 -->|"Priority, queue key and<br/>algorithm explanation evidence"| P4
    D5 -->|"Current workflow,<br/>history, assignment, referral<br/>and note information"| P4
    P4 -->|"Normal concern queue;<br/>report detail; algorithm explanation;<br/>workflow and assignment state"| ADM
    P4 -->|"Approved assignment, referral,<br/>status and note records"| D5
    P4 -->|"Audit-worthy administrator<br/>workflow actions"| P7
    P4 -->|"Status/assignment/referral<br/>communication event"| P6

    RES -->|"Confirmed SOS data:<br/>confirmation, emergency type,<br/>one-time GPS location, timestamp"| P5
    D1 -->|"Required registered-user details"| P5
    D4 -->|"Approved emergency types<br/>and applicable workflow configuration"| P5
    P5 -->|"Emergency record,<br/>Critical override and tracking state"| D6
    P5 -->|"Emergency status-history<br/>and workflow evidence"| D5
    P5 -->|"SOS submission confirmation"| RES
    P5 -->|"Emergency alert;<br/>Emergency Queue and SOS detail"| ADM

    ADM -->|"Emergency acknowledgement;<br/>approved assignment/referral;<br/>tracking/status action;<br/>false-alarm action where authorized"| P5
    D6 -->|"Current emergency record<br/>and tracking state"| P5
    D5 -->|"Emergency workflow history"| P5
    P5 -->|"Updated emergency state"| D6
    P5 -->|"Approved emergency workflow<br/>and history records"| D5
    P5 -->|"Audit-worthy emergency action"| P7
    P5 -->|"Emergency communication event"| P6

    RES -->|"Announcement request"| P6
    ADM -->|"Announcement content<br/>and publication action"| P6
    P6 <-->|"Announcements, notification records<br/>and communication state"| D7
    P6 -->|"Permitted announcements<br/>and notification information"| RES
    P6 -->|"Announcement publication<br/>and permitted notification state"| ADM
    P6 -->|"Audit-worthy publication<br/>or communication action"| P7

    ADM -->|"Authorized audit requests;<br/>protected configuration actions<br/>where explicitly permitted"| P7
    P7 <-->|"Approved versioned rules,<br/>ratings, weights, thresholds,<br/>routing, deadlines and workflow configuration"| D4
    P7 -->|"Append-only required<br/>audit evidence"| D8
    D8 -->|"Permitted audit evidence"| P7
    P7 -->|"Permitted audit evidence;<br/>active/versioned configuration state"| ADM
~~~

## 3. External Entities

### 3.1 E1 — Resident

The Resident remains the same external entity represented in the Level 0 DFD.

Resident-originated Level 1 flows are distributed among the appropriate internal processes:

- identity/profile/verification data to Process 1.0;
- normal concern data to Process 2.0;
- own-report and history requests to Process 3.0;
- confirmed SOS data to Process 5.0; and
- announcement requests to Process 6.0.

The Level 1 decomposition does not give the Resident direct access to a logical data store.

All protected reads and writes pass through an authorized HelpHub process.

### 3.2 E2 — Barangay Administrator

The Barangay Administrator remains the administrative external entity represented at Level 0.

Administrator-originated Level 1 flows are distributed among:

- Process 1.0 for authentication, resident verification, and permitted account actions;
- Process 4.0 for normal report review and workflow actions;
- Process 5.0 for emergency acknowledgement and approved emergency actions;
- Process 6.0 for announcement publication; and
- Process 7.0 for permitted audit review and protected configuration management.

The existence of a flow does not itself authorize every administrator to perform every represented action.

Final permissions remain governed by the approved role-permission, workflow, and stakeholder-decision artifacts.

## 4. Process 1.0 — Identity and Resident Verification

Process 1.0 is responsible for logical identity and resident-verification data flow.

Inputs may include:

- resident registration information;
- login credentials;
- profile updates;
- resident-verification submissions;
- administrator credentials;
- resident-verification decisions; and
- authorized account-management actions.

Outputs may include:

- authentication results;
- account information;
- verification state;
- verification-review information; and
- authorized account-management results.

Process 1.0 reads from and writes to D1.

Administrative and security-relevant actions produce audit-worthy events for Process 7.0.

This DFD does not prescribe the internal implementation boundary between Supabase Auth, FastAPI authorization, and application profile records.

Those details belong in later component, deployment, API, schema, and RLS artifacts.

## 5. Process 2.0 — Normal Concern Intake and Priority Processing

Process 2.0 handles submission and protected decision-support processing for normal concern reports.

The resident submits the approved normal concern information, including:

- initial concern type;
- description;
- required location information when applicable;
- resident-declared urgency;
- affected population;
- vulnerable-group indicator;
- optional permitted photo evidence; and
- timestamps.

Process 2.0 must follow the active approved algorithm contract:

1. validate required input;
2. validate or recommend concern type using the active approved rule version;
3. match applicable approved system, city-ordinance, and barangay-specific rules;
4. convert approved factors to normalized ratings;
5. compute the weighted priority score;
6. map the result to an approved Low, Medium, High, or Critical level;
7. apply an approved Critical override where applicable;
8. assign the approved route or referral and response deadline; and
9. generate the deterministic queue key.

Deterministic ordering remains:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending; and
5. report ID ascending.

Process 2.0 reads active approved policy from D4.

It writes the normal report record and evidence references to D2.

It writes reproducibility and explanation evidence to D3.

It writes the initial report workflow/status-history evidence to D5.

It produces the resident submission acknowledgement and an event that may result in a permitted administrator notification.

## 6. Process 3.0 — Resident Tracking and Status History

Process 3.0 provides permitted resident tracking data.

It may read:

- report information from D2;
- workflow/status-history information from D5; and
- permitted emergency tracking information from D6.

It may return:

- resident-visible report detail;
- current report status;
- complete permitted report status history; and
- permitted Emergency SOS tracking state.

Process 3.0 must enforce ownership and authorization rules.

A Resident must not be able to use a report identifier alone to retrieve another resident's protected report, evidence, location, emergency, note, audit, or workflow information.

Status history is a persisted system record and is not equivalent to a transient push notification.

## 7. Process 4.0 — Administrator Concern Workflow

Process 4.0 handles authorized non-SOS report-management activities.

It may receive:

- queue requests;
- report-detail requests;
- assignment actions;
- referral records;
- approved status-transition actions; and
- internal notes.

Process 4.0 may read:

- report information from D2;
- algorithm decision and explanation evidence from D3; and
- current workflow/status history from D5.

It may write approved:

- assignments;
- referral records;
- status changes; and
- internal notes

to D5.

Every approved status change must preserve required status-history evidence.

Audit-worthy administrative actions are sent to Process 7.0.

Relevant report changes may also generate communication events for Process 6.0.

An external referral record does not create a direct data-flow integration with the referral destination.

## 8. Process 5.0 — Emergency SOS Processing

Process 5.0 handles the distinct confirmed-SOS path.

Resident input includes the approved emergency information:

- required SOS hold or confirmation result;
- selected emergency type;
- one-time current GPS location; and
- event timestamp.

The process obtains the registered-user information required for the emergency record from D1.

Process 5.0 applies the automatic Critical override to a confirmed SOS and places the event in the logical Emergency Queue.

It stores the emergency record and tracking state in D6.

It preserves emergency workflow/status-history evidence in D5.

Authorized administrator inputs may include:

- acknowledgement;
- approved status actions;
- assignment;
- referral recording;
- tracking actions; and
- false-alarm action where permitted by the final approved workflow.

Emergency actions that require audit evidence are forwarded to Process 7.0.

Relevant emergency events are forwarded to Process 6.0 for permitted communication handling.

HelpHub remains a barangay-level alerting, routing, tracking, and coordination system.

It does not replace official emergency services and does not guarantee outside-agency dispatch or response.

## 9. Process 6.0 — Communications and Announcements

Process 6.0 handles logical announcement and permitted notification data.

Inputs may include:

- administrator announcement content;
- publication actions;
- normal-report change events;
- emergency events; and
- resident announcement requests.

D7 preserves logical communication information such as:

- announcements;
- notification records;
- notification-attempt state; and
- other approved communication metadata.

Process 6.0 may output permitted:

- barangay announcements;
- report-related notification information;
- emergency-related notification information; and
- publication state.

A push-notification attempt is not the authoritative report or workflow record.

Notification delivery may fail due to connectivity, device state, permissions, token validity, or service availability.

The system's stored report and status history remain authoritative.

## 10. Process 7.0 — Audit and Configuration Governance

Process 7.0 handles two related governance responsibilities:

1. required audit-event preservation; and
2. protected versioned configuration management.

Audit-worthy events may originate from:

- Process 1.0;
- Process 2.0;
- Process 4.0;
- Process 5.0; and
- Process 6.0.

Required audit evidence is preserved in D8.

Authorized administrators may request permitted audit evidence through Process 7.0.

Protected configuration actions also pass through Process 7.0.

D4 may contain approved versioned configuration for:

- concern taxonomy or concern-type validation rules;
- system rules;
- city-ordinance rules;
- barangay-specific rules;
- factor definitions;
- normalized rating anchors;
- weights;
- priority thresholds;
- Critical-override rules;
- routing or referral definitions;
- response deadlines; and
- applicable workflow configuration.

This list describes configuration domains.

It does not approve final values.

Configuration authority is limited to administrators explicitly authorized by the final approved governance policy.

Activated configuration used by already-processed reports must not be silently changed in place.

## 11. Logical Data Store D1 — Identity and Verification

D1 represents logical persisted identity-related application data.

It may include:

- account linkage;
- profile information;
- role information;
- resident-verification submissions;
- verification status;
- verification decision metadata; and
- permitted account state.

D1 does not imply that authentication credentials themselves are stored in an application-defined plaintext database table.

The technical identity split between managed authentication and application profile data will be defined during schema and architecture implementation.

## 12. Logical Data Store D2 — Concern Reports and Evidence References

D2 represents persisted normal concern records and references to protected evidence.

Logical information may include:

- resident/report ownership;
- submitted concern type;
- description;
- location fields;
- resident-declared urgency;
- affected population;
- vulnerable-group indicator;
- timestamps;
- current report state where appropriate; and
- protected evidence references and metadata.

Optional photos are protected evidence.

The DFD does not imply that binary photo content must be stored directly in the relational report record.

The later schema and storage design will define the physical implementation.

## 13. Logical Data Store D3 — Algorithm Decision Evidence

D3 preserves the information necessary to explain and reproduce normal-report priority processing.

Required logical evidence includes the applicable:

- algorithm version;
- rule version;
- weight version;
- factor values;
- normalized ratings;
- matched rules;
- score breakdown;
- override reason where applicable;
- classification or validation result;
- priority;
- route;
- deadline; and
- deterministic queue key.

Where additional approved configuration-version references are required for exact reproducibility, those references must also be preserved.

The same input processed under the same applicable versions must produce the same deterministic result.

## 14. Logical Data Store D4 — Versioned Configuration

D4 represents governance-controlled configuration.

It is logically separate from ordinary concern-report input.

D4 may contain approved versions of:

- concern-type rules;
- rule sets;
- factor definitions;
- normalized rating anchors;
- factor weights;
- priority thresholds;
- Critical-override rules;
- routing definitions;
- referral definitions;
- response deadlines; and
- applicable workflow configuration.

Values shown in study or design materials remain provisional until approved according to the stakeholder-decision process.

An activated historical configuration must not be edited in place when doing so would change the interpretation of reports previously processed under that version.

## 15. Logical Data Store D5 — Workflow and Status History

D5 represents logical workflow records associated with normal reports and emergencies.

It may include:

- status-history entries;
- assignments;
- referral records;
- internal notes;
- acknowledgement information;
- permitted workflow-transition metadata;
- reasons required for particular transitions; and
- actor/timestamp evidence.

Every status change must create the required status-history record.

A report must not lose its traceability through silent deletion.

Approved closed and archived states must retain the history required by policy.

## 16. Logical Data Store D6 — Emergency Records

D6 represents persisted Emergency SOS information.

Logical emergency information may include:

- resident/account linkage;
- selected approved emergency type;
- one-time GPS location;
- location accuracy and capture information where required;
- event timestamp;
- confirmation evidence;
- automatic Critical override;
- emergency queue/tracking state;
- acknowledgement state; and
- other approved emergency-processing information.

D6 does not imply continuous location collection.

Location is collected only for the approved emergency event when required and permitted.

## 17. Logical Data Store D7 — Communications

D7 represents persisted announcement and notification-related information.

It may include:

- barangay announcements;
- publication metadata;
- notification records;
- notification-attempt state; and
- permitted communication metadata.

D7 must not be interpreted as the authoritative source of report status.

Report and workflow state remain represented by the appropriate report, emergency, and status-history stores.

## 18. Logical Data Store D8 — Audit Events

D8 represents required security, administrative, workflow, and governance audit evidence.

Audit records should preserve the information required to establish:

- who performed the action;
- what protected action occurred;
- which relevant record was affected;
- when the action occurred; and
- other approved before/after, reason, configuration, or contextual evidence required by the audit policy.

Audit evidence must be protected from ordinary resident access.

Audit viewing itself remains subject to approved permissions.

## 19. Status History and Audit Distinction

D5 and D8 serve different purposes.

D5 preserves the user/workflow history of a report or emergency.

D8 preserves broader accountability and security evidence about protected actions.

A status transition therefore requires:

1. the appropriate new workflow/status-history record in D5; and
2. the required audit event in D8.

Neither store replaces the other.

## 20. External Referral Boundary

There is intentionally no Level 1 process-to-external-responder arrow.

Police, fire, medical, disaster-response, utility, city, and other outside organizations remain outside the authenticated HelpHub boundary unless a future formal integration is approved.

Where the workflow permits a referral:

1. the Barangay Administrator enters the referral or coordination action through Process 4.0 or Process 5.0;
2. the record is preserved in the relevant workflow history;
3. required audit evidence is preserved; and
4. any resident-visible status information is provided through the normal HelpHub tracking process.

The referral record does not prove external electronic delivery, acceptance, dispatch, or guaranteed response.

## 21. Level 0 / Level 1 Balancing Matrix

| Level 0 external flow | Level 1 process |
| --- | --- |
| Resident registration/login/profile/verification data | 1.0 Identity and Resident Verification |
| Authentication/account/verification results to Resident | 1.0 Identity and Resident Verification |
| Normal concern report data | 2.0 Normal Concern Intake and Priority Processing |
| Submission acknowledgement/report identifier | 2.0 Normal Concern Intake and Priority Processing |
| Own-report/status-history requests | 3.0 Resident Tracking and Status History |
| Report detail/status/history to Resident | 3.0 Resident Tracking and Status History |
| Confirmed SOS data | 5.0 Emergency SOS Processing |
| SOS confirmation/emergency tracking | 5.0 and 3.0 |
| Resident announcement request | 6.0 Communications and Announcements |
| Notifications/announcements to Resident | 6.0 Communications and Announcements |
| Administrator authentication/verification/account actions | 1.0 Identity and Resident Verification |
| Verification/account information to Administrator | 1.0 Identity and Resident Verification |
| Normal queue/detail/workflow requests and actions | 4.0 Administrator Concern Workflow |
| Normal queue/report/algorithm/workflow information | 4.0 Administrator Concern Workflow |
| Emergency administrator actions | 5.0 Emergency SOS Processing |
| Emergency alerts/queue/detail | 5.0 Emergency SOS Processing |
| Announcement publication | 6.0 Communications and Announcements |
| Announcement publication state | 6.0 Communications and Announcements |
| Audit requests/configuration actions | 7.0 Audit and Configuration Governance |
| Audit evidence/configuration state | 7.0 Audit and Configuration Governance |

Every major Level 0 external flow is accounted for by the Level 1 decomposition.

No new primary external authenticated entity is introduced.

## 22. Logical-to-Implementation Boundary

The logical stores in this DFD are intentionally broader than future physical tables.

For example:

`D5 — Workflow and Status History`

may later require several relational tables for:

- status-history entries;
- assignments;
- referrals; and
- internal notes.

Likewise:

`D4 — Versioned Configuration`

may later require separate tables for rule versions, weights, thresholds, factors, routes, deadlines, and activation records.

The Stage 4 schema must derive from these logical responsibilities, but it must not mechanically create one database table per DFD store without normalization, authorization, reproducibility, and audit analysis.

## 23. Security and Privacy Requirements

Every Level 1 process and store is subject to the HelpHub security and privacy baseline.

The implementation must provide applicable:

- authentication;
- server-side authorization;
- least privilege;
- Supabase Row Level Security;
- secure input validation;
- rate limiting for sensitive operations;
- private evidence storage;
- location/SOS access restrictions;
- ownership checks;
- protected configuration authorization;
- audit logging; and
- controlled retention and archival.

There must be no client-side-only authorization for protected operations.

Resident-visible processes must never expose another resident's protected data merely because an identifier is known.

The DFD does not authorize continuous location tracking.

## 24. Failure and Consistency Requirements

Later implementation must account for failure cases where one logical operation affects multiple stores.

Examples include:

- a report record succeeds but algorithm evidence fails;
- a status update succeeds but status history fails;
- a status update succeeds but required audit persistence fails;
- an SOS record succeeds but its Critical queue state fails;
- a configuration activation succeeds without preserving its version;
- an announcement is stored but notification delivery fails.

Implementation must prevent or safely handle inconsistent partial state according to the selected transaction and reliability design.

Push-notification failure must not roll back an otherwise valid authoritative report/status change unless an approved requirement explicitly requires that behavior.

## 25. Traceability

| Level 1 process/store | Related requirements |
| --- | --- |
| 1.0 Identity and Resident Verification | FR-UM |
| 2.0 Normal Concern Intake and Priority Processing | FR-CR, FR-LE, FR-ALG |
| 3.0 Resident Tracking and Status History | FR-RT |
| 4.0 Administrator Concern Workflow | FR-AD |
| 5.0 Emergency SOS Processing | FR-SOS |
| 6.0 Communications and Announcements | FR-CM |
| 7.0 Audit and Configuration Governance | FR-AU, FR-CFG |
| D1 Identity and Verification | FR-UM, NFR-SEC |
| D2 Concern Reports and Evidence References | FR-CR, FR-LE, NFR-PRV |
| D3 Algorithm Decision Evidence | FR-ALG, NFR-DET, NFR-TRC |
| D4 Versioned Configuration | FR-CFG, NFR-DET, NFR-TRC |
| D5 Workflow and Status History | FR-RT, FR-AD, FR-SOS |
| D6 Emergency Records | FR-SOS, NFR-PRV |
| D7 Communications | FR-CM |
| D8 Audit Events | FR-AU, NFR-SEC, NFR-TRC |

## 26. Approval-Sensitive Areas

This Level 1 DFD intentionally does not approve final values for:

- complete concern taxonomy;
- detailed rule conditions;
- normalized factor-rating anchors;
- factor weights;
- numerical priority thresholds;
- handlers;
- referral destinations;
- response deadlines;
- non-SOS Critical rules;
- emergency escalation behavior;
- final normal workflow permissions;
- final emergency workflow permissions;
- false-alarm authority;
- retention periods;
- audit-view scope; or
- protected configuration privilege.

The logical DFD may identify where these data categories participate without declaring their final policy values.

## 27. Stage 3 Verification Checklist

Before Stage 3 approval, verify that:

- the Level 1 diagram remains balanced with the Level 0 DFD;
- Resident and Barangay Administrator are still the only external authenticated entities;
- all external data accesses pass through a process rather than directly to a store;
- normal concern intake is separate from resident tracking;
- normal algorithm processing uses versioned configuration;
- algorithm explanation and reproducibility evidence is explicitly preserved;
- confirmed SOS follows the separate Critical-override path;
- emergency information includes required registered-user data without continuous tracking;
- status changes preserve status-history evidence;
- status changes and other required protected actions preserve audit evidence;
- workflow/status history and audit data remain logically distinct;
- protected configuration is separate from normal report data;
- activated historical configuration is preserved for reproducibility;
- administrator referral is represented without direct external-system integration;
- communication records are not treated as authoritative report status;
- no assistance-request process or data store exists;
- no provisional policy value is represented as final;
- the logical stores do not prematurely prescribe the Stage 4 physical schema; and
- all Level 0 major input/output flows have a corresponding Level 1 process.

## 28. Stage 3 Level-1 DFD Rule

This Level 1 DFD is the requirements-level logical decomposition of:

`0 — HelpHub System`

defined by the Level 0 DFD.

The Stage 4 schema, RLS design, FastAPI authorization boundaries, storage design, and later component and deployment models must be traceable to these logical responsibilities without treating the DFD as a one-to-one physical database specification.

If an approved stakeholder decision changes a primary data flow, logical process responsibility, workflow, configuration domain, emergency behavior, privacy boundary, or audit obligation, the Level 0 and Level 1 DFDs and all affected downstream artifacts must be reviewed before the relevant stage gate may pass.
