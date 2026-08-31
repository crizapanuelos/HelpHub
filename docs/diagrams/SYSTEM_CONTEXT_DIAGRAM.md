# HelpHub System Context Diagram

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — system-context baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related workflows: `docs/requirements/STATUS_TRANSITION_TABLES.md`
- Related use cases: `docs/diagrams/USE_CASE_DIAGRAM.md`
- Related conceptual model: `docs/diagrams/UPDATED_CONCEPTUAL_PARADIGM_NARRATIVE.md`

## 1. Purpose

This document defines the Stage 3 system context for HelpHub.

The system-context view identifies:

1. the HelpHub system boundary;
2. the two primary application actors;
3. the high-level information exchanged between those actors and HelpHub;
4. approved supporting technical services used by HelpHub; and
5. important external entities that must not be misrepresented as directly integrated HelpHub responders.

This is a context-level model.

It does not yet decompose HelpHub into detailed processes, database stores, APIs, screens, or internal software components. Those details belong in the Level 0 and Level 1 Data Flow Diagrams, component diagram, deployment diagram, data dictionary, and later implementation artifacts.

## 2. System Context Diagram

~~~mermaid
flowchart LR

    RES["Resident"]
    ADM["Barangay Administrator"]

    subgraph HB["HelpHub System Boundary"]
        HH(["HelpHub<br/>Barangay Concern Reporting and Emergency Coordination System"])
    end

    SUP["Supabase Platform<br/>Authentication, PostgreSQL, Storage,<br/>Realtime, and Row Level Security"]
    FCM["Firebase Cloud Messaging<br/>Push Notification Delivery Service"]
    OSM["OpenStreetMap Services<br/>Map Display Data"]

    RES -->|"Registration, login, profile, verification,<br/>normal concern reports, one-time location,<br/>optional photo evidence, confirmed SOS,<br/>tracking and announcement requests"| HH

    HH -->|"Authentication/account results,<br/>report status and complete status history,<br/>SOS acknowledgement/tracking,<br/>announcements and permitted notifications"| RES

    ADM -->|"Login, resident-verification decisions,<br/>report review, assignment/referral records,<br/>approved status updates, notes,<br/>emergency actions, announcements,<br/>authorized configuration changes"| HH

    HH -->|"Resident/account information,<br/>normal and emergency queues,<br/>report detail and algorithm explanation,<br/>status/audit evidence, configuration state"| ADM

    HH <-->|"Protected authentication, relational data,<br/>private evidence storage, realtime updates,<br/>and least-privilege data access"| SUP

    HH -->|"Permitted push-notification requests"| FCM
    FCM -.->|"Delivery attempt subject to device,<br/>network, and service availability"| RES
    FCM -.->|"Delivery attempt where applicable"| ADM

    HH <-->|"Map-display requests and map data"| OSM
~~~

## 3. Primary Application Actors

### 3.1 Resident

The Resident is a registered barangay resident who interacts with HelpHub to perform permitted resident functions.

At the context level, those interactions include:

- registration and authentication;
- profile management;
- resident-verification submission;
- normal concern reporting;
- one-time location capture when required;
- optional protected photo evidence;
- confirmed Emergency SOS reporting;
- viewing the resident's own reports;
- viewing complete permitted status history;
- receiving permitted status-related notifications; and
- viewing barangay announcements.

A Resident must not receive administrative privileges merely because the account is registered or verified.

### 3.2 Barangay Administrator

The Barangay Administrator is an authorized HelpHub administrative user.

At the context level, authorized administrator interactions may include:

- authentication;
- resident verification and account management;
- normal concern review;
- priority-queue review;
- algorithm explanation review;
- assignment;
- referral recording;
- approved status transitions;
- internal notes;
- emergency acknowledgement and tracking;
- approved emergency assignment/referral actions;
- false-alarm handling where authorized;
- announcement publication;
- audit-evidence review where authorized; and
- protected configuration management where explicitly authorized.

Protected configuration authority is a permission granted to an approved administrator.

It is not a third primary HelpHub role.

## 4. HelpHub System Boundary

At this level, HelpHub is treated as one application system that provides a protected digital workflow for barangay concern reporting and emergency coordination.

The HelpHub boundary includes responsibility for coordinating the required application behavior, including:

- resident and administrator access;
- concern-report intake;
- report validation;
- Rule-Based Weighted Priority Queue processing;
- resident tracking;
- status-history preservation;
- administrator queues and workflows;
- Emergency Response Module behavior;
- notification generation;
- announcements;
- audit evidence; and
- protected versioned configuration.

The context diagram intentionally does not expose detailed internal implementation components such as individual Flutter screens, FastAPI endpoints, database tables, repositories, services, rule-engine classes, or queue functions.

Those will be modeled in later diagrams and implementation artifacts.

## 5. Supporting Technical Systems

Supporting systems are technical dependencies.

They are not HelpHub application roles.

### 5.1 Supabase Platform

The approved architecture uses Supabase for:

- PostgreSQL relational data;
- authentication;
- private evidence storage;
- Realtime functionality; and
- Row Level Security.

Use of Supabase does not remove the requirement for FastAPI server-side authorization, validation, least privilege, or application-level security controls.

The later component and deployment diagrams will show the technical responsibility boundaries in more detail.

### 5.2 Firebase Cloud Messaging

Firebase Cloud Messaging is used for permitted push-notification attempts.

HelpHub must not describe push delivery as guaranteed.

Delivery may depend on:

- network availability;
- device settings;
- notification permissions;
- valid device tokens; and
- external service availability.

The authoritative state of a report remains in HelpHub even if a push notification cannot be delivered.

### 5.3 OpenStreetMap Services

OpenStreetMap-related services support map display through the approved Flutter mapping approach.

The map dependency does not authorize continuous resident location tracking.

HelpHub captures location only for an approved location-based report or Emergency SOS event when location permission is granted and the workflow requires it.

The required submitted location evidence includes the approved location fields such as latitude, longitude, accuracy, and capture time, with an optional human-readable address when available.

## 6. External Responders and Referral Destinations

Police, fire, medical services, disaster-response organizations, utility providers, barangay personnel, committees, city offices, and similar organizations may be relevant operational destinations outside HelpHub.

They are not shown as directly integrated systems in this context diagram.

An approved HelpHub workflow may allow an administrator to:

- assign an internal barangay handler;
- record an external referral destination;
- record contact or coordination actions; and
- preserve referral evidence and status history.

A referral record does not establish that:

- the external organization has a HelpHub account;
- HelpHub electronically transmitted the case to that organization;
- the organization accepted the referral;
- dispatch occurred;
- a response is guaranteed; or
- HelpHub replaces an official emergency service.

A future formal integration would require separate technical, operational, privacy, security, stakeholder, and study approval before this system context can be changed.

## 7. Normal Concern Context

For normal concern reporting, the Resident supplies the approved report information.

HelpHub then performs the protected processing required by the active approved configuration.

At context level, the resulting information made available to authorized administrators may include:

- report data;
- concern-type validation or recommendation;
- matched approved rules;
- normalized-factor evidence;
- weighted priority score;
- final priority;
- approved override reason where applicable;
- routing or referral recommendation;
- response deadline;
- deterministic queue position; and
- configuration-version evidence.

No provisional rule, weight, numerical threshold, handler, or response deadline is treated as approved merely because it appears in a design artifact.

## 8. Emergency Context

A confirmed SOS is a separate emergency interaction.

The Resident provides the approved emergency information, including:

- confirmed SOS action;
- selected emergency type;
- one-time current location;
- timestamp; and
- required registered-user information.

HelpHub applies the automatic Critical override and places the event in the Emergency Queue.

Authorized administrators may acknowledge and track the emergency according to the approved workflow.

HelpHub supports barangay-level alerting, routing, tracking, and coordination.

It does not replace police, fire, medical, disaster-response, or national emergency services.

## 9. Security and Privacy Boundary

The context model assumes the following controls throughout the HelpHub system:

- authenticated access where required;
- role and permission checks;
- least privilege;
- FastAPI server-side authorization for protected operations;
- Supabase Row Level Security;
- input validation;
- rate limits for sensitive operations;
- private evidence storage;
- restricted GPS and SOS access;
- traceable administrative actions;
- append-only required status history;
- audit evidence;
- no silent report deletion; and
- controlled retention and archival according to the approved policy.

The system must not expose sensitive resident, evidence, location, SOS, configuration, or audit information merely because a client interface can request it.

## 10. Context Boundaries and Non-Goals

This system context does not expand the approved study scope.

The following remain outside the current scope unless the study is formally revised:

- assistance-request functionality;
- multi-barangay production deployment;
- full offline operation;
- automatic SMS fallback;
- continuous resident tracking;
- automatic ordinance enforcement or penalties;
- guaranteed external-agency dispatch or response;
- replacement of official emergency services; and
- long-term post-study operation.

## 11. Relationship to the Data Flow Diagrams

The System Context Diagram and Data Flow Diagrams serve different purposes.

The System Context Diagram answers:

- Who uses HelpHub?
- What supporting systems does HelpHub depend on?
- What is inside or outside the overall application boundary?

The Level 0 DFD will answer:

- What major data enters and leaves HelpHub through the approved external business entities?

The Level 1 DFD will answer:

- Which major internal HelpHub processes transform that data?
- Which logical data stores participate in those flows?

Technical deployment details such as Flutter execution targets, FastAPI hosting, Supabase services, Firebase infrastructure, and network placement will be detailed separately in the deployment and component diagrams.

## 12. Traceability

| Context element | Related Stage 3 baseline |
| --- | --- |
| Resident | FR-UM, FR-CR, FR-LE, FR-RT, FR-SOS, FR-CM |
| Barangay Administrator | FR-UM, FR-AD, FR-SOS, FR-CM, FR-AU, FR-CFG |
| Normal concern processing | FR-CR, FR-ALG |
| Emergency processing | FR-SOS |
| Status and history | FR-RT, status-transition tables |
| Assignment/referral | FR-AD |
| Notifications/announcements | FR-CM |
| Audit evidence | FR-AU |
| Versioned configuration | FR-CFG |
| Security/privacy boundary | NFR-SEC, NFR-PRV |
| Deterministic/reproducible behavior | NFR-DET, NFR-TRC |
| External responder limitation | Scope and workflow constraints |

## 13. Approval-Sensitive Areas

This diagram does not approve:

- final concern taxonomy;
- final rule conditions;
- normalized rating anchors;
- factor weights;
- numerical priority thresholds;
- final handler or referral destinations;
- response deadlines;
- non-SOS Critical override rules;
- detailed escalation behavior;
- final workflow permissions;
- retention periods; or
- protected configuration privilege assignments.

Those decisions remain governed by documented stakeholder approval and version control.

## 14. Stage 3 Verification Checklist

Before Stage 3 approval, verify that:

- Resident and Barangay Administrator remain the only primary application roles;
- HelpHub is represented as the central application system;
- supporting technical systems are not confused with application roles;
- no external responder is represented as directly integrated;
- referrals remain administrator-recorded coordination actions unless formal integration is later approved;
- assistance requests are absent;
- normal concern processing is represented without inventing policy values;
- Emergency SOS remains a confirmed Critical-override path;
- HelpHub does not replace official emergency services;
- push notifications are not described as guaranteed;
- location handling does not imply continuous tracking;
- security and privacy controls remain part of the system boundary;
- the context view does not prematurely decompose detailed internal components; and
- the later DFDs can be derived from this boundary without contradiction.

## 15. Stage 3 System-Context Rule

This system-context model is the authoritative Stage 3 boundary view for the HelpHub requirements baseline.

If a future stakeholder decision introduces a new authenticated role, external-system integration, data-sharing relationship, emergency integration, or other material boundary change, this diagram and the affected DFD, privacy, security, deployment, component, and traceability artifacts must be reviewed before the relevant stage gate may pass.
