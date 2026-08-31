# HelpHub Component Diagram

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — component baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related system context: `docs/diagrams/SYSTEM_CONTEXT_DIAGRAM.md`
- Related Level 0 DFD: `docs/diagrams/DATA_FLOW_DIAGRAM_LEVEL_0.md`
- Related Level 1 DFD: `docs/diagrams/DATA_FLOW_DIAGRAM_LEVEL_1.md`
- Related deployment model: `docs/diagrams/DEPLOYMENT_DIAGRAM.md`
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related workflows: `docs/requirements/STATUS_TRANSITION_TABLES.md`

## 1. Purpose

This document defines the Stage 3 logical software-component baseline for HelpHub.

The component model identifies the major software responsibilities inside the approved architecture and the interfaces through which those responsibilities interact.

It establishes boundaries among:

1. Flutter client components;
2. FastAPI protected application components;
3. persistence and platform adapters;
4. the Rule-Based Weighted Priority Queue implementation;
5. Emergency SOS processing;
6. workflow, audit, and configuration responsibilities; and
7. approved external technical services.

This diagram does not prescribe final Dart class names, Python package names, database tables, endpoint paths, dependency-injection framework, hosting provider, or exact folder structure.

Those implementation details will be derived and verified during later development stages.

## 2. Component Diagram

~~~mermaid
flowchart LR

    subgraph FL["Flutter Application Repository"]
        APP["Application Shell<br/>Navigation, Session and Shared UI State"]

        AUTHUI["Identity and Profile UI"]
        CONCERNUI["Concern Reporting UI"]
        TRACKUI["Resident Tracking UI"]
        SOSUI["Emergency SOS UI"]
        ADMINUI["Administrator Dashboard<br/>and Workflow UI"]
        COMMUI["Notifications and<br/>Announcements UI"]

        LOCAD["Location Adapter<br/>geolocator"]
        MAPAD["Map Adapter<br/>flutter_map / OpenStreetMap"]
        APICLIENT["Protected API Client"]
        AUTHCLIENT["Supabase Auth Client"]
        RTCLIENT["Realtime Client"]

        APP --> AUTHUI
        APP --> CONCERNUI
        APP --> TRACKUI
        APP --> SOSUI
        APP --> ADMINUI
        APP --> COMMUI

        CONCERNUI --> LOCAD
        CONCERNUI --> MAPAD
        SOSUI --> LOCAD
        SOSUI --> MAPAD

        AUTHUI --> AUTHCLIENT

        AUTHUI --> APICLIENT
        CONCERNUI --> APICLIENT
        TRACKUI --> APICLIENT
        SOSUI --> APICLIENT
        ADMINUI --> APICLIENT
        COMMUI --> APICLIENT

        TRACKUI --> RTCLIENT
        ADMINUI --> RTCLIENT
        COMMUI --> RTCLIENT
    end

    subgraph BE["FastAPI Protected Application"]
        APILAYER["API Routing, Validation<br/>and Authorization Boundary"]

        USER["User and Verification Service"]
        CONCERN["Concern Application Service"]
        PRIORITY["Rule-Based Weighted<br/>Priority Engine"]
        WORKFLOW["Report Workflow Service"]
        EMERGENCY["Emergency SOS Service"]
        COMM["Communication Service"]
        AUDIT["Audit Service"]
        CONFIG["Versioned Configuration Service"]

        APILAYER --> USER
        APILAYER --> CONCERN
        APILAYER --> WORKFLOW
        APILAYER --> EMERGENCY
        APILAYER --> COMM
        APILAYER --> AUDIT
        APILAYER --> CONFIG

        CONCERN --> PRIORITY
        PRIORITY --> CONFIG

        CONCERN --> WORKFLOW
        WORKFLOW --> AUDIT

        EMERGENCY --> WORKFLOW
        EMERGENCY --> AUDIT

        USER --> AUDIT
        CONCERN --> AUDIT
        COMM --> AUDIT
        CONFIG --> AUDIT

        WORKFLOW --> COMM
        EMERGENCY --> COMM
        CONCERN --> COMM
    end

    subgraph DAL["Persistence and Platform Adapters"]
        AUTHAD["Supabase Auth Adapter"]
        DBAD["PostgreSQL Data Access"]
        STORAGEAD["Private Storage Adapter"]
        RTAD["Realtime Adapter"]
        FCMAD["FCM Notification Adapter"]
    end

    subgraph SUP["Supabase Managed Services"]
        SUPAUTH["Supabase Auth"]
        PG[("PostgreSQL + RLS")]
        STORE["Supabase Storage"]
        REALTIME["Supabase Realtime"]
    end

    FCM["Firebase Cloud Messaging"]
    OSM["OpenStreetMap / Approved Map Data Service"]
    DEVICELOC["Android Device Location Services"]

    APICLIENT <-->|"HTTPS protected requests/responses"| APILAYER
    AUTHCLIENT <-->|"Authentication/session operations"| SUPAUTH
    RTCLIENT <-->|"Authorized subscriptions"| REALTIME

    USER --> AUTHAD
    USER --> DBAD

    CONCERN --> DBAD
    CONCERN --> STORAGEAD

    PRIORITY --> DBAD

    WORKFLOW --> DBAD
    EMERGENCY --> DBAD
    COMM --> DBAD
    AUDIT --> DBAD
    CONFIG --> DBAD

    COMM --> FCMAD

    AUTHAD <-->|"Identity operations"| SUPAUTH
    DBAD <-->|"Authorized relational operations"| PG
    STORAGEAD <-->|"Protected evidence operations"| STORE
    RTAD <-->|"Approved realtime operations"| REALTIME
    FCMAD -->|"Permitted push requests"| FCM

    WORKFLOW --> RTAD
    EMERGENCY --> RTAD
    COMM --> RTAD

    LOCAD <-->|"One-time location request"| DEVICELOC
    MAPAD <-->|"Map data"| OSM
~~~

## 3. Component-Layer Rules

The HelpHub component model follows these high-level responsibility rules:

1. Flutter components handle presentation, interaction, local UI state, and client-safe integrations.
2. FastAPI components enforce protected application behavior and authorization.
3. The priority algorithm executes behind the protected backend boundary.
4. Protected workflow and configuration actions must not rely on client-side checks alone.
5. Supabase provides managed persistence, authentication, storage, realtime, and Row Level Security capabilities.
6. Firebase Cloud Messaging is a notification-delivery dependency rather than the authoritative source of report state.
7. Device location is accessed only for approved event-based location capture.
8. Map services provide display data and are not the authoritative storage location for report coordinates.
9. Audit evidence and user-visible workflow history remain logically distinct responsibilities.
10. External police, fire, medical, disaster-response, utility, or other responder systems are not represented as directly integrated HelpHub components.

## 4. Flutter Application Components

The Flutter repository supports both the resident Android application and the responsive web-capable administrator interface.

The diagram identifies logical client responsibilities rather than separate repositories.

### 4.1 Application Shell

The Application Shell coordinates shared client responsibilities such as:

- application startup;
- authenticated-session state;
- role-aware navigation;
- common loading and error behavior;
- shared design-system usage; and
- routing to authorized resident or administrator features.

The Application Shell must not be treated as an authorization authority.

Hidden navigation items or screens do not replace backend authorization.

### 4.2 Identity and Profile UI

This component supports applicable:

- registration;
- login/logout;
- resident profile management;
- verification submission;
- verification-state display; and
- administrator resident-verification workflows.

Authentication communicates with Supabase Auth through the approved client authentication integration.

Protected application operations continue through FastAPI where required.

### 4.3 Concern Reporting UI

This component collects normal concern information.

It supports the approved report inputs, including:

- concern type;
- description;
- location;
- resident-declared urgency;
- affected population;
- vulnerable-group indicator;
- optional photo evidence; and
- timestamps.

The client may validate input for usability.

Client validation does not replace server-side validation.

The client does not authoritatively calculate the final priority score or queue position.

### 4.4 Resident Tracking UI

This component displays permitted information about the resident's own reports and emergencies.

It may present:

- submission information;
- current status;
- complete permitted status history;
- assignment/referral information where resident-visible;
- emergency acknowledgement/tracking state; and
- relevant notifications.

Ownership and authorization must be enforced by protected backend/database rules rather than by possession of a report identifier.

### 4.5 Emergency SOS UI

The Emergency SOS UI handles the resident-facing emergency interaction.

It must support:

- brief hold or confirmation;
- selected approved emergency type;
- one-time current GPS capture;
- timestamp;
- clear emergency-services disclaimer; and
- confirmation/tracking feedback.

The client must not implement continuous resident tracking.

The automatic Critical override is a protected system behavior and must not depend on a client-supplied priority value.

### 4.6 Administrator Dashboard and Workflow UI

The administrator component may expose authorized:

- resident-verification review;
- normal concern queue;
- emergency queue;
- report details;
- algorithm explanation;
- assignments;
- referrals;
- approved status updates;
- internal notes;
- emergency acknowledgement/tracking;
- announcements;
- audit information; and
- protected configuration interfaces.

Visible controls must be permission-aware.

The backend remains authoritative for whether an action is allowed.

### 4.7 Notifications and Announcements UI

This component displays permitted:

- barangay announcements;
- notification information; and
- communication-related states.

Push delivery is supplementary.

The authoritative status of a report or emergency must be retrieved from HelpHub's stored application state.

## 5. Client Integration Components

### 5.1 Protected API Client

The API client is the common Flutter integration boundary for protected FastAPI operations.

Its responsibilities may include:

- authenticated HTTPS requests;
- request serialization;
- response parsing;
- API error mapping;
- timeout handling; and
- propagation of network/authentication failures to presentation components.

The API client must not contain server secrets.

### 5.2 Supabase Auth Client

The authentication client supports approved Supabase authentication/session operations.

A valid authenticated session establishes identity.

It does not automatically grant permission to perform protected administrator or configuration actions.

### 5.3 Realtime Client

The Realtime client supports permitted subscriptions for timely UI refresh.

Realtime access remains subject to authentication, RLS, ownership, and authorization rules.

Realtime events are not a replacement for authoritative stored state.

### 5.4 Location Adapter

The Location Adapter isolates Flutter UI code from direct location-plugin concerns.

It supports approved one-time location capture and applicable:

- permission handling;
- latitude;
- longitude;
- accuracy; and
- capture time.

Continuous/background resident tracking is outside the approved scope.

### 5.5 Map Adapter

The Map Adapter isolates presentation components from the selected map-display implementation.

The approved baseline uses `flutter_map` with OpenStreetMap-related data.

This adapter does not determine the authoritative persisted location of a report.

## 6. FastAPI API Boundary

The API Routing, Validation and Authorization Boundary is the protected entry point for server-controlled operations.

Its responsibilities include applicable:

- request parsing;
- input validation;
- authentication-context handling;
- authorization checks;
- request routing;
- consistent API errors;
- rate-limit enforcement where required; and
- propagation of trace/audit context.

The API boundary must not permit clients to bypass protected business rules by directly submitting calculated priority, route, deadline, configuration activation, or unauthorized workflow values.

## 7. User and Verification Service

The User and Verification Service handles protected application logic related to:

- application profile data;
- resident-verification workflow;
- approved resident-account administration; and
- role/permission-related application checks.

Managed credential authentication remains a Supabase Auth responsibility.

Application authorization and resident-verification logic remain HelpHub responsibilities.

Security-relevant administrative actions must generate required audit evidence.

## 8. Concern Application Service

The Concern Application Service orchestrates normal concern submission.

Its responsibilities include:

1. validate the protected report request;
2. preserve required report information;
3. coordinate protected evidence handling;
4. invoke the Rule-Based Weighted Priority Engine;
5. preserve algorithm-result references/evidence;
6. establish the initial approved workflow state;
7. generate applicable audit evidence; and
8. publish permitted downstream workflow/communication events.

The Concern Application Service coordinates the normal-report use case.

It does not hard-code unapproved policy values.

## 9. Rule-Based Weighted Priority Engine

The Rule-Based Weighted Priority Engine is a protected FastAPI-side component.

For normal reports it must implement the approved algorithm contract:

1. validate required algorithm input;
2. determine or validate concern type using the active approved rule version;
3. match applicable approved system, city-ordinance, and barangay-specific rules;
4. convert approved factors into normalized ratings;
5. calculate the weighted score using the active weight version;
6. map the score to Low, Medium, High, or Critical according to the active approved thresholds;
7. apply an approved Critical override where applicable;
8. determine the approved route/handler and response deadline; and
9. generate the deterministic queue key.

Queue ordering remains:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending; and
5. report ID ascending.

The same input with the same applicable algorithm and configuration versions must produce the same result.

The priority engine obtains active policy from the Versioned Configuration Service rather than from Flutter UI constants.

## 10. Report Workflow Service

The Report Workflow Service handles protected normal-report workflow behavior.

It may coordinate:

- current workflow state;
- assignments;
- referral records;
- approved status transitions;
- internal notes;
- resident-visible tracking state;
- status-history preservation; and
- workflow-triggered communication events.

Every status change must preserve the required status-history record and audit event.

The Workflow Service must reject transitions that are not permitted by the active approved workflow policy.

## 11. Emergency SOS Service

The Emergency SOS Service handles confirmed SOS events separately from normal weighted-priority processing.

Responsibilities include:

- validate confirmed SOS requests;
- obtain required registered-user context;
- validate/capture required emergency data;
- apply the automatic Critical override;
- persist the emergency record;
- maintain Emergency Queue state;
- support authorized acknowledgement/tracking;
- support approved assignment/referral behavior;
- support approved false-alarm handling where permitted;
- coordinate status-history and audit evidence; and
- generate permitted emergency communication events.

The Emergency SOS Service must not depend on a resident-supplied priority score.

HelpHub does not replace official emergency services.

No direct responder-system integration is represented in this component baseline.

## 12. Communication Service

The Communication Service handles application-level communication behavior.

It may coordinate:

- notification records;
- report-status notifications;
- emergency-related notification attempts;
- announcement publication; and
- delivery-state recording.

The service uses the FCM Notification Adapter for permitted push requests.

A push failure must not silently alter the authoritative workflow result.

Announcements and notifications remain distinct from report/status-history records.

## 13. Audit Service

The Audit Service preserves required accountability evidence for protected actions.

Audit-worthy events may originate from:

- user/verification operations;
- report submission and algorithm processing;
- administrator workflow actions;
- emergency operations;
- announcement/publication actions; and
- configuration operations.

Audit evidence must be protected from unauthorized resident access.

Audit-view permissions remain approval-sensitive.

The Audit Service is distinct from status-history functionality.

## 14. Versioned Configuration Service

The Versioned Configuration Service manages protected access to approved algorithm and workflow policy.

Configuration domains may include:

- concern taxonomy or validation rules;
- system rules;
- city-ordinance rules;
- barangay-specific rules;
- factor definitions;
- normalized rating anchors;
- factor weights;
- priority thresholds;
- Critical-override rules;
- routing definitions;
- referral definitions;
- response deadlines; and
- applicable workflow configuration.

This list identifies configurable domains.

It does not approve their final values.

The service must preserve version identity and must not silently mutate an activated historical configuration in a way that changes the interpretation of already-processed reports.

Configuration changes require protected authorization and audit evidence.

## 15. Persistence and Platform Adapters

Persistence/platform adapters separate application logic from vendor-specific service access.

This helps keep core business behavior testable without embedding Supabase or Firebase calls throughout every service.

### 15.1 Supabase Auth Adapter

This adapter supports backend interaction with authentication/identity functions required by protected HelpHub behavior.

### 15.2 PostgreSQL Data Access

The relational data-access layer provides controlled persistence access for application services.

It must support the later Stage 4 schema, constraints, transactions, authorization design, and reproducibility requirements.

The component diagram does not require one repository class per DFD logical store.

### 15.3 Private Storage Adapter

This adapter manages protected optional evidence workflows.

It must support applicable:

- private storage;
- allowed file types;
- file-size restrictions;
- non-guessable paths;
- ownership/permission checks; and
- protected access mechanisms.

### 15.4 Realtime Adapter

This adapter coordinates server-side or application-level realtime publishing where needed.

It must not bypass authorization or make transient realtime events authoritative over stored state.

### 15.5 FCM Notification Adapter

The FCM adapter isolates Firebase-specific push-delivery behavior from HelpHub communication business logic.

It handles permitted delivery requests and associated delivery-attempt outcomes.

Notification delivery is not guaranteed.

## 16. Supabase Boundary

Supabase provides:

- Auth;
- PostgreSQL;
- Storage;
- Realtime; and
- Row Level Security.

These capabilities support HelpHub but do not replace application-layer authorization and business rules.

RLS is especially important for client-accessible data paths.

FastAPI remains responsible for authorization of protected application operations under the approved architecture.

## 17. Dependency Direction Rules

To prevent architecture drift, implementation should preserve the following dependency direction principles:

1. UI components depend on client integration interfaces.
2. UI components do not depend directly on database credentials or privileged persistence APIs.
3. FastAPI API handlers delegate protected business behavior to application/domain services.
4. The priority engine depends on approved configuration abstractions rather than Flutter values.
5. application services depend on persistence/platform adapters rather than scattering vendor calls throughout business logic;
6. workflow and emergency components emit audit/communication responsibilities through controlled service interfaces;
7. storage, notification, realtime, and identity integrations remain replaceable at the adapter boundary where practical; and
8. protected configuration cannot be changed through an unprotected client-only path.

The exact dependency-injection technique will be selected during implementation without changing these architectural responsibilities.

## 18. Algorithm Evidence Boundary

The Priority Engine produces decision evidence that must be persisted for reproducibility.

For a normal report, applicable evidence includes:

- algorithm version;
- rule version;
- weight version;
- factor values;
- normalized ratings;
- matched rules;
- score breakdown;
- override reason where applicable;
- classification/validation result;
- priority;
- route;
- deadline; and
- deterministic queue key.

The component architecture must not allow later configuration changes to erase the version context associated with earlier algorithm runs.

## 19. Workflow History and Audit Boundary

Workflow history and audit evidence are related but different responsibilities.

The Report Workflow Service and Emergency SOS Service preserve user/workflow history.

The Audit Service preserves broader accountability evidence.

For every required status change:

1. the workflow operation must create the appropriate status-history record; and
2. the required audit evidence must also be created.

Later implementation must safely handle failure so one required record is not silently committed while the other is lost.

## 20. Security Boundaries

All client environments are treated as untrusted.

Therefore:

- authorization must be enforced server-side for protected operations;
- Supabase RLS must restrict applicable direct client data paths;
- service-role keys must never be shipped in Flutter;
- Firebase server credentials must remain server-side;
- database administrative credentials must remain server-side;
- secrets must remain outside source control;
- evidence access must be protected;
- GPS/SOS information must be restricted;
- configuration operations must be protected;
- audit evidence must be protected; and
- client-controlled values must not override protected priority or workflow decisions.

## 21. Error and Failure Responsibilities

The component design must support explicit failure handling.

Flutter presentation components must be capable of representing applicable:

- loading;
- success;
- empty;
- validation failure;
- permission denied;
- authentication/session failure;
- weak/offline network;
- timeout; and
- server error

states.

Backend components must return controlled errors rather than leaking internal secrets, database details, or stack traces.

Operations affecting multiple authoritative records must use appropriate consistency/transaction strategies during implementation.

Notification or map-service failure must not silently corrupt authoritative report, emergency, workflow, audit, or configuration state.

## 22. External Responder Boundary

No component in this diagram represents:

- police integration;
- fire-service integration;
- medical-service integration;
- disaster-response integration;
- utility-system integration; or
- another external agency API.

Approved referrals are recorded by HelpHub administrators through the normal or emergency workflow.

A referral record does not prove electronic delivery, acceptance, dispatch, or guaranteed external response.

A future direct integration requires formal architecture, privacy, security, workflow, operational, and study approval.

## 23. Relationship to the Level 1 DFD

The component model implements responsibilities represented logically by the Level 1 DFD, but there is intentionally no one-to-one mapping.

Examples:

- DFD Process 2.0 maps primarily to the Concern Application Service and Priority Engine.
- DFD Process 4.0 maps primarily to the Report Workflow Service and supporting Audit/Communication services.
- DFD Process 5.0 maps primarily to the Emergency SOS Service plus Workflow, Audit, and Communication responsibilities.
- DFD Process 7.0 is represented through separate Audit and Versioned Configuration services.
- logical DFD data stores are implemented through persistence components and the later normalized physical schema rather than being converted directly into software-service components.

This prevents the DFD from becoming an accidental code-package specification.

## 24. Relationship to Deployment Diagram

The Component Diagram describes software responsibilities.

The Deployment Diagram describes runtime placement.

At the approved Stage 3 baseline:

- Flutter components execute on the resident Android device or administrator browser environment;
- FastAPI protected components execute on the FastAPI application host;
- persistence/platform adapters connect to managed Supabase services;
- notification integration communicates with Firebase Cloud Messaging;
- map display communicates with approved OpenStreetMap-related services; and
- the resident location adapter communicates with Android device location services.

The deployment host providers remain unresolved where documented as `TBD`.

## 25. Traceability

| Component | Primary requirements |
| --- | --- |
| Identity and Profile UI / User and Verification Service | FR-UM |
| Concern Reporting UI / Concern Application Service | FR-CR, FR-LE |
| Rule-Based Weighted Priority Engine | FR-ALG, NFR-DET, NFR-TRC |
| Resident Tracking UI | FR-RT |
| Report Workflow Service / Admin UI | FR-AD |
| Emergency SOS UI / Emergency SOS Service | FR-SOS |
| Communication Service / Communication UI | FR-CM |
| Audit Service | FR-AU, NFR-SEC, NFR-TRC |
| Versioned Configuration Service | FR-CFG, NFR-DET, NFR-TRC |
| Location Adapter | FR-LE, FR-SOS, NFR-PRV |
| Private Storage Adapter | FR-CR, NFR-SEC, NFR-PRV |
| Protected API boundary | NFR-SEC, NFR-REL |
| Persistence adapters | NFR-REL, NFR-ARC |
| Realtime integration | FR-RT, FR-AD, FR-SOS |
| FCM integration | FR-CM |

## 26. Approval-Sensitive Areas

This component diagram does not approve:

- final concern taxonomy;
- final rule conditions;
- factor-rating anchors;
- factor weights;
- numerical priority thresholds;
- handler/referral destinations;
- response deadlines;
- non-SOS Critical override rules;
- emergency escalation rules;
- final workflow permissions;
- false-alarm authority;
- audit-view scope;
- protected configuration privilege;
- exact endpoint design;
- exact source-code package structure;
- specific dependency-injection framework; or
- an unapproved change to the canonical technology stack.

## 27. Stage 3 Verification Checklist

Before Stage 3 approval, verify that:

- Flutter remains the client application layer;
- Android Resident and responsive Web Administrator capabilities are supported by the same Flutter repository;
- FastAPI remains the protected API/business-rule boundary;
- the Priority Engine is server-side;
- the normal concern flow and SOS flow remain distinct;
- algorithm policy comes from approved versioned configuration;
- historical algorithm evidence is preserved;
- Report Workflow and Audit responsibilities remain distinct;
- every required status change can produce both history and audit evidence;
- Supabase Auth, PostgreSQL, Storage, Realtime, and RLS responsibilities remain represented;
- Firebase Cloud Messaging remains a notification dependency rather than authoritative state;
- one-time location and map-display integrations remain client-safe adapters;
- protected evidence access is isolated;
- no service-role or server secret is required by Flutter;
- no direct external-responder integration is introduced;
- no assistance-request component exists;
- no logical DFD store is blindly converted into one physical software component;
- no provisional policy value is shown as final;
- the component model is compatible with the verified Deployment Diagram; and
- later source-code structure can be derived without contradicting these responsibility boundaries.

## 28. Stage 3 Component Rule

This Component Diagram is the Stage 3 software-responsibility baseline for HelpHub.

Later Flutter architecture, FastAPI package structure, Supabase schema/RLS design, notification integration, algorithm implementation, SOS implementation, testing, and deployment artifacts must remain traceable to these responsibilities.

The exact code structure may evolve during implementation, but protected responsibility boundaries must not be weakened merely for convenience.

If an approved stakeholder or architectural decision changes the application roles, algorithm boundary, client/server responsibility, persistence strategy, emergency behavior, notification architecture, location handling, configuration governance, audit obligation, external integration, or canonical technology stack, this diagram and all affected downstream artifacts must be reviewed before the relevant stage gate may pass.
