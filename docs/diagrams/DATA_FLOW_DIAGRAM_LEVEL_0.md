# HelpHub Data Flow Diagram — Level 0

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — Level 0 DFD baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related workflows: `docs/requirements/STATUS_TRANSITION_TABLES.md`
- Related use cases: `docs/diagrams/USE_CASE_DIAGRAM.md`
- Related conceptual model: `docs/diagrams/UPDATED_CONCEPTUAL_PARADIGM_NARRATIVE.md`
- Related system context: `docs/diagrams/SYSTEM_CONTEXT_DIAGRAM.md`

## 1. Purpose

This document defines the Stage 3 Data Flow Diagram (DFD) at Level 0 for HelpHub.

The Level 0 DFD represents HelpHub as one logical process and shows the major business-data flows between the system and its two primary external authenticated entities:

1. Resident; and
2. Barangay Administrator.

This diagram focuses on logical information exchange.

It does not show individual application screens, FastAPI endpoints, Flutter components, Supabase services, database tables, Firebase Cloud Messaging infrastructure, OpenStreetMap services, or other deployment details.

Internal processes and logical data stores will be decomposed in the Level 1 DFD.

## 2. Level 0 Data Flow Diagram

~~~mermaid
flowchart LR

    RES["E1 — Resident"]
    ADM["E2 — Barangay Administrator"]

    HH(["0 — HelpHub System"])

    RES -->|"Registration/login data;<br/>profile and verification data"| HH

    HH -->|"Authentication, account,<br/>and verification results"| RES

    RES -->|"Normal concern report data:<br/>approved concern type, description,<br/>one-time location, resident-declared urgency,<br/>affected population, vulnerable-group indicator,<br/>optional photo evidence, timestamps"| HH

    HH -->|"Submission acknowledgement;<br/>report identifier; permitted report detail;<br/>status and complete status history"| RES

    RES -->|"Confirmed SOS data:<br/>confirmation, emergency type,<br/>one-time GPS location, timestamp,<br/>required registered-user details"| HH

    HH -->|"SOS submission confirmation;<br/>permitted acknowledgement<br/>and emergency tracking state"| RES

    RES -->|"Own-report tracking requests;<br/>announcement requests"| HH

    HH -->|"Permitted notifications;<br/>barangay announcements"| RES

    ADM -->|"Administrator login data;<br/>resident verification and<br/>authorized account actions"| HH

    HH -->|"Authentication result;<br/>resident verification queue;<br/>authorized account information"| ADM

    ADM -->|"Report review requests;<br/>assignment/referral actions;<br/>approved status updates;<br/>internal notes"| HH

    HH -->|"Normal concern queue;<br/>report details; classification/validation result;<br/>priority and algorithm explanation;<br/>status/assignment information"| ADM

    ADM -->|"Emergency acknowledgement;<br/>approved emergency workflow actions;<br/>assignment/referral records;<br/>false-alarm action where authorized"| HH

    HH -->|"Emergency alerts;<br/>Emergency Queue;<br/>SOS detail and tracking information"| ADM

    ADM -->|"Announcement content<br/>and publication actions"| HH

    HH -->|"Announcement publication state"| ADM

    ADM -->|"Authorized audit requests;<br/>protected versioned configuration actions<br/>where explicitly permitted"| HH

    HH -->|"Permitted audit evidence;<br/>active/versioned configuration state"| ADM
~~~

## 3. External Entity E1 — Resident

The Resident is the external entity that provides resident-originated information to HelpHub and receives information permitted for that resident.

### 3.1 Resident-to-HelpHub Data Flows

Resident-originated data may include:

- registration information;
- login credentials;
- profile information;
- resident-verification information;
- normal concern report information;
- one-time report location;
- optional permitted photo evidence;
- confirmed SOS information;
- one-time SOS location;
- own-report tracking requests; and
- announcement-view requests.

Normal concern report information includes the approved requirements-level fields:

- concern type;
- description;
- location;
- resident-declared urgency;
- affected population;
- vulnerable-group indicator;
- optional photo evidence; and
- timestamps.

The DFD does not assign final values to the concern taxonomy or other approval-sensitive configuration.

### 3.2 HelpHub-to-Resident Data Flows

HelpHub may return permitted resident information such as:

- authentication results;
- account and verification state;
- concern-submission acknowledgement;
- report identifier;
- resident-visible report detail;
- current report status;
- complete permitted status history;
- SOS submission confirmation;
- emergency acknowledgement or tracking information;
- permitted notifications; and
- barangay announcements.

A notification is not the authoritative report record.

The resident-visible report and status history remain the authoritative in-system source of report progress.

## 4. External Entity E2 — Barangay Administrator

The Barangay Administrator is the authorized administrative external entity that reviews and manages permitted HelpHub information.

### 4.1 Administrator-to-HelpHub Data Flows

Administrator-originated data may include:

- authentication information;
- resident-verification decisions;
- authorized resident-account actions;
- report-review requests;
- assignment actions;
- referral records;
- approved status updates;
- internal notes;
- emergency acknowledgements;
- approved emergency workflow actions;
- false-alarm decisions where authorized;
- announcement content and publication actions;
- audit-evidence requests; and
- protected configuration actions where explicitly authorized.

The presence of a possible administrative action in this DFD does not itself approve who may perform that action.

Final permissions remain controlled by the approved role-permission and stakeholder-decision artifacts.

### 4.2 HelpHub-to-Administrator Data Flows

HelpHub may make authorized administrative information available, including:

- authentication results;
- resident-verification information;
- authorized resident-account information;
- normal concern reports;
- classification or concern-type validation results;
- matched-rule and algorithm explanation evidence;
- priority results;
- deterministic queue information;
- assignment and referral information;
- report status and history;
- Emergency Queue information;
- SOS detail and tracking state;
- announcement publication state;
- permitted audit evidence; and
- approved active/versioned configuration information.

Sensitive data must remain subject to authorization, least privilege, Row Level Security, server-side access checks, and audit requirements.

## 5. Process 0 — HelpHub System

At Level 0, all internal HelpHub behavior is represented as one logical process:

`0 — HelpHub System`

This process encompasses the high-level responsibility for:

- identity and access handling;
- resident verification;
- normal concern intake;
- validation;
- concern-type validation or recommendation;
- rule matching;
- normalized factor processing;
- weighted priority scoring;
- priority assignment;
- approved routing and deadline assignment;
- deterministic queue ordering;
- resident report tracking;
- administrator concern-management workflow;
- Emergency SOS processing;
- Emergency Queue handling;
- notifications;
- announcements;
- status-history preservation;
- audit evidence; and
- protected versioned configuration.

These responsibilities are intentionally not separated into multiple DFD processes at Level 0.

They will be decomposed in the Level 1 DFD.

## 6. Normal Concern Data Flow

The high-level normal-report flow is:

1. the Resident submits the approved normal concern data;
2. HelpHub validates and processes the report using the active approved configuration;
3. HelpHub preserves the report and algorithm decision evidence;
4. the processed report becomes visible through the administrator's authorized queue;
5. the Barangay Administrator reviews and performs approved workflow actions;
6. HelpHub records required status history and audit evidence; and
7. the Resident can view the permitted updated report state and complete status history.

The protected algorithm processing within Process 0 must follow the approved deterministic algorithm contract.

This Level 0 diagram does not expose the algorithm as a separate external entity because the algorithm is internal HelpHub behavior.

## 7. Emergency SOS Data Flow

The high-level emergency flow is:

1. the Resident performs the required SOS confirmation;
2. the Resident supplies the selected emergency type and required one-time location data;
3. HelpHub creates the emergency report;
4. HelpHub applies the automatic Critical override;
5. HelpHub places the emergency in the Emergency Queue;
6. an authorized Barangay Administrator receives and reviews the emergency information;
7. acknowledgement and other approved workflow actions are recorded; and
8. the Resident receives the permitted confirmation and tracking state.

Confirmed SOS processing is distinct from the normal weighted-priority path.

HelpHub does not replace official emergency services and does not guarantee external dispatch or response.

## 8. Referral Data Flow Boundary

This DFD intentionally contains no direct HelpHub data-flow arrow to:

- police;
- fire services;
- medical services;
- disaster-response organizations;
- utility providers;
- city agencies;
- outside barangay personnel; or
- other external responders.

Where permitted, the Barangay Administrator records assignment, referral, contact, or coordination information through HelpHub.

The referral record may then form part of the report history and audit evidence.

A recorded referral does not prove:

- electronic integration with the destination;
- receipt by the destination;
- acceptance by the destination;
- dispatch;
- resolution; or
- guaranteed response.

A future direct integration requires formal stakeholder, technical, security, privacy, operational, and study approval before this DFD may be changed.

## 9. Data Store Boundary

No internal logical data stores are shown at Level 0.

This is intentional.

Information such as:

- user accounts;
- resident verification;
- concern reports;
- SOS reports;
- location data;
- protected photo evidence;
- algorithm-run evidence;
- status history;
- assignments;
- referrals;
- notes;
- announcements;
- notifications;
- audit events; and
- versioned configuration

will be decomposed into logical data stores in the Level 1 DFD and later database/data-dictionary artifacts.

A data store must not be represented as an external human actor.

## 10. Technology Boundary

The Level 0 DFD is technology-independent at the logical-flow level.

Therefore the diagram itself does not model:

- Flutter;
- FastAPI;
- Supabase;
- PostgreSQL;
- Supabase Auth;
- Supabase Storage;
- Supabase Realtime;
- Firebase Cloud Messaging;
- geolocator;
- flutter_map; or
- OpenStreetMap

as Level 0 business entities.

Those technologies remain part of the approved HelpHub architecture and will be represented where appropriate in the component and deployment diagrams.

## 11. Security and Privacy Requirements on Data Flows

All Level 0 flows are subject to the HelpHub security and privacy baseline.

Relevant requirements include:

- authentication for protected operations;
- role-based and permission-based authorization;
- least privilege;
- server-side authorization;
- Supabase Row Level Security;
- input validation;
- secure evidence-upload restrictions;
- rate limiting for sensitive endpoints;
- private handling of photo evidence;
- restricted location and SOS access;
- status-history preservation;
- audit logging;
- controlled configuration access; and
- no silent deletion of reports.

Location is captured only when required for an approved report or confirmed SOS workflow.

The DFD must not be interpreted as continuous resident tracking.

## 12. DFD Balancing Baseline

The later Level 1 DFD must remain balanced with this Level 0 diagram.

Every major external input or output shown here must be accounted for by one or more Level 1 processes without introducing an unexplained new external entity.

The Level 1 decomposition must therefore account for:

- identity and verification data;
- normal concern report data;
- SOS data;
- resident tracking data;
- administrator account-management data;
- normal report-management data;
- emergency-management data;
- announcement data;
- notification output;
- audit requests/evidence; and
- protected configuration data.

If Level 1 requires a new major external data flow, this Level 0 baseline must be reviewed first.

## 13. Traceability

| Level 0 flow area | Related baseline |
| --- | --- |
| Registration, authentication, profile, verification | FR-UM |
| Normal concern submission | FR-CR |
| Location and optional evidence | FR-LE, FR-CR |
| Resident report/status-history tracking | FR-RT |
| Rule-Based Weighted Priority Queue processing | FR-ALG |
| Administrator queue and workflow | FR-AD |
| Emergency SOS and Emergency Queue | FR-SOS |
| Notifications and announcements | FR-CM |
| Audit evidence | FR-AU |
| Protected versioned configuration | FR-CFG |
| Security and authorization | NFR-SEC |
| Location/SOS privacy | NFR-PRV |
| Determinism and reproducibility | NFR-DET, NFR-TRC |
| Workflow transitions | `STATUS_TRANSITION_TABLES.md` |
| Actor permissions | `ROLE_PERMISSION_MATRIX.md` |

## 14. Approval-Sensitive Areas

This Level 0 DFD does not approve final values for:

- complete concern taxonomy;
- detailed rule conditions;
- factor-rating anchors;
- weights;
- numerical priority thresholds;
- handlers;
- referral destinations;
- response deadlines;
- non-SOS Critical rules;
- escalation behavior;
- final transition permissions;
- false-alarm authority;
- retention periods;
- audit-view privilege; or
- protected configuration privilege.

Those remain governed by documented stakeholder approval and version control.

## 15. Stage 3 Verification Checklist

Before Stage 3 approval, verify that:

- Resident and Barangay Administrator are the only external authenticated entities;
- HelpHub is represented as one Level 0 process;
- no assistance-request flow exists;
- normal concern-report input matches the approved requirements;
- confirmed SOS is represented separately from normal concern submission;
- Emergency SOS receives the Critical-override path;
- resident output includes report tracking and complete status history;
- administrator output includes prioritized normal and emergency information;
- administrator input includes assignment/referral and approved workflow actions;
- no direct external-responder flow is shown;
- no internal data store is incorrectly represented as an external entity;
- no implementation technology is incorrectly represented as a business actor;
- no continuous location tracking is implied;
- no guaranteed push delivery or external response is implied;
- approval-sensitive configuration remains unresolved where approval is pending; and
- the planned Level 1 DFD can balance with all major external flows shown here.

## 16. Stage 3 Level-0 DFD Rule

This Level 0 DFD is the requirements-level business data-flow baseline for HelpHub.

The Level 1 DFD must decompose Process 0 without contradicting or bypassing the external flows defined here.

If stakeholder approval changes a primary actor, report input, emergency input, administrator capability, referral model, notification behavior, configuration authority, privacy boundary, or other major external data flow, this Level 0 diagram and all affected downstream artifacts must be reviewed before the relevant stage gate may pass.
