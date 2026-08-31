# HelpHub Deployment Diagram

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — deployment baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Deployment audience/provider decision: PENDING APPROVAL
- Related system context: `docs/diagrams/SYSTEM_CONTEXT_DIAGRAM.md`
- Related Level 0 DFD: `docs/diagrams/DATA_FLOW_DIAGRAM_LEVEL_0.md`
- Related Level 1 DFD: `docs/diagrams/DATA_FLOW_DIAGRAM_LEVEL_1.md`
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`

## 1. Purpose

This document defines the Stage 3 logical deployment baseline for HelpHub.

The deployment model identifies:

1. user-device execution environments;
2. client application artifacts;
3. protected backend execution;
4. managed data and platform services;
5. notification and map dependencies;
6. major trusted network relationships; and
7. deployment decisions that remain unresolved.

This diagram does not select a commercial hosting provider that has not been approved.

Provider names, production domains, regions, infrastructure sizing, backup schedules, monitoring services, and final operational ownership remain deployment-stage decisions unless documented approval exists.

## 2. Deployment Diagram

~~~mermaid
flowchart TB

    subgraph RD["Resident Android Device"]
        RA["Flutter Android<br/>Resident Application"]
        LOC["Android Location Services<br/>accessed through geolocator"]
    end

    subgraph AD["Administrator Workstation"]
        WB["Supported Web Browser"]
        WA["Flutter Web<br/>Administrator Interface"]
        WB --> WA
    end

    subgraph WH["Static Web Hosting<br/>Provider TBD"]
        WEB["Deployed Flutter Web Build"]
    end

    subgraph APIHOST["FastAPI Application Host<br/>Provider TBD"]
        API["Python / FastAPI<br/>Protected API"]
    end

    subgraph SUP["Supabase Managed Project"]
        AUTH["Supabase Auth"]
        DB[("Supabase PostgreSQL")]
        STORAGE["Supabase Storage<br/>Private Evidence"]
        RT["Supabase Realtime"]
        RLS["Row Level Security<br/>Policies"]
    end

    FCM["Firebase Cloud Messaging<br/>Push Delivery Service"]
    OSM["OpenStreetMap / Approved Map Data Service"]

    RA <-->|"HTTPS<br/>protected application requests"| API

    WA <-->|"HTTPS<br/>protected administrator requests"| API

    WB <-->|"HTTPS<br/>load Flutter web application"| WEB

    RA <-->|"Authentication/session flow<br/>as approved"| AUTH
    WA <-->|"Authentication/session flow<br/>as approved"| AUTH

    RA <-->|"Authorized realtime subscriptions<br/>subject to RLS"| RT
    WA <-->|"Authorized realtime subscriptions<br/>subject to RLS"| RT

    API <-->|"Authorized relational operations"| DB
    API <-->|"Protected evidence operations<br/>and signed-access workflow"| STORAGE
    API <-->|"Identity/token validation<br/>and authorized account operations"| AUTH

    RLS -.->|"enforces permitted client data access"| DB
    RLS -.->|"least-privilege access boundary"| RT

    API -->|"Permitted push-notification requests"| FCM
    FCM -.->|"Delivery attempt;<br/>not guaranteed"| RA

    RA <-->|"One-time location request"| LOC

    RA <-->|"Map-display requests/data"| OSM
    WA <-->|"Map-display requests/data<br/>where required"| OSM
~~~

## 3. Deployment Nodes

### 3.1 Resident Android Device

The resident-facing HelpHub application is deployed as a Flutter Android application.

The resident device is responsible for:

- rendering the resident interface;
- collecting resident input;
- performing local input-state handling;
- requesting location permission when an approved workflow needs location;
- obtaining one-time device location through the approved location plugin;
- displaying permitted map information;
- receiving permitted notification attempts; and
- communicating with protected remote services.

The resident client is not a trusted authority for:

- administrative authorization;
- algorithm policy;
- priority calculation authority;
- protected status-transition authorization;
- protected configuration changes;
- unrestricted evidence access; or
- unrestricted database operations.

Sensitive decisions must be enforced by server-side and database security controls.

### 3.2 Administrator Workstation

The Barangay Administrator accesses the responsive Flutter web-capable interface through a supported browser.

The administrator workstation is responsible for:

- rendering authorized dashboard views;
- submitting administrator actions;
- displaying normal and emergency queues;
- displaying permitted report and algorithm explanations;
- supporting authorized account, workflow, announcement, audit, and configuration interfaces; and
- receiving authorized near-real-time updates.

Possession of the administrator web client does not itself grant administrative authority.

Authentication and authorization must be enforced remotely.

### 3.3 Static Web Hosting

The compiled Flutter web application requires a web-accessible static hosting environment for administrator browser access.

The final hosting provider is not yet approved.

Therefore this deployment baseline uses:

`Static Web Hosting — Provider TBD`

rather than inventing Firebase Hosting, Vercel, Netlify, Cloudflare Pages, a private barangay server, or another provider.

The final deployment decision must consider:

- HTTPS;
- custom-domain requirements;
- availability;
- deployment workflow;
- access to configuration;
- cost;
- logging;
- rollback;
- compatibility with Flutter Web; and
- study/post-study operational ownership.

Public client configuration required for application connectivity must be distinguished from secrets.

Server secrets must never be embedded in the deployed Flutter web bundle.

## 4. FastAPI Application Host

Protected HelpHub business behavior is deployed through Python/FastAPI.

The backend is responsible for protected operations including applicable:

- authorization;
- request validation;
- normal concern processing;
- concern-type validation/recommendation;
- configurable rule matching;
- factor normalization;
- weighted scoring;
- priority assignment;
- Critical-override processing;
- route/deadline assignment;
- deterministic queue processing;
- protected workflow actions;
- emergency processing;
- protected audit operations;
- configuration operations; and
- notification-generation logic.

The production FastAPI hosting provider is not yet approved.

Therefore the deployment node remains:

`FastAPI Application Host — Provider TBD`

The later deployment stage must approve the actual host before production release.

## 5. Supabase Managed Project

Supabase provides the approved managed data platform.

### 5.1 Supabase Auth

Supabase Auth supports HelpHub authentication and session identity.

FastAPI must independently enforce authorization for protected operations rather than trusting that a client is authorized merely because it possesses a valid session.

### 5.2 Supabase PostgreSQL

PostgreSQL is the authoritative relational data platform for application records and approved versioned configuration.

Database constraints, migrations, authorization design, and Row Level Security will be defined and verified during Stage 4.

### 5.3 Supabase Storage

Supabase Storage is used for protected evidence such as optional report photos.

Evidence access must use approved:

- private storage;
- type restrictions;
- size restrictions;
- randomized or non-guessable paths;
- ownership/permission checks; and
- signed or otherwise protected access.

### 5.4 Supabase Realtime

Supabase Realtime supports near-real-time data-driven interface updates where permitted.

Realtime does not mean guaranteed immediate delivery.

Network, device, browser, and platform conditions may delay updates.

### 5.5 Row Level Security

Row Level Security forms an additional data-access boundary for client-accessible Supabase data.

RLS does not replace FastAPI server-side authorization for protected business operations.

Both layers must implement least privilege.

## 6. Firebase Cloud Messaging

Firebase Cloud Messaging supports permitted push-notification attempts.

The protected server side may request delivery for approved notification events.

For the resident Android application, delivery remains dependent on conditions such as:

- network connectivity;
- valid registration token;
- notification permission;
- device configuration;
- operating-system restrictions; and
- FCM availability.

A successful HelpHub report or status operation must not be represented as failed merely because an informational push notification could not be delivered, unless a later approved requirement explicitly states otherwise.

The authoritative report and workflow records remain in HelpHub.

Browser push for the administrator interface is not assumed by this diagram.

If administrator web push is later required, its browser/platform support and security design must be separately verified.

## 7. Location Deployment Boundary

The resident Android application accesses device location through the approved location-library approach.

Location capture is event-based.

HelpHub must not continuously track a resident.

For an approved location-based normal report or confirmed SOS, required location evidence includes applicable:

- latitude;
- longitude;
- accuracy;
- capture time; and
- optional human-readable address when available.

The deployment model does not add an unapproved background-location service.

## 8. Map Deployment Boundary

The Flutter clients may use `flutter_map` with OpenStreetMap-based map data for approved map-display functionality.

Map-display access is separate from HelpHub's authoritative report storage.

The map provider must not be treated as the authoritative source of stored report location.

Any production tile or map-data usage must comply with the selected provider's operational requirements and acceptable-use limits.

A different paid or hosted map provider must not be substituted without documenting the reason and impact on the approved stack.

## 9. Trust and Network Boundaries

Production communication involving protected HelpHub data must use encrypted transport such as HTTPS/TLS.

Important trust boundaries include:

1. resident device to FastAPI;
2. administrator browser to FastAPI;
3. clients to approved Supabase client-facing services;
4. FastAPI to Supabase;
5. FastAPI to Firebase Cloud Messaging; and
6. clients to the approved map-data service.

The implementation must assume that client devices and browsers are untrusted execution environments.

Therefore:

- service-role secrets must never be packaged in Flutter;
- backend credentials must remain server-side;
- database administrative credentials must remain server-side;
- Firebase server credentials must remain server-side;
- signing keys and private certificates must not be committed;
- environment-specific secrets must remain outside source control; and
- authorization must not rely only on hidden UI controls.

## 10. Client-to-Supabase Boundary

HelpHub may use approved direct client interaction with Supabase for functions such as:

- authentication;
- authorized realtime subscriptions; and
- other specifically approved client-safe operations protected by RLS.

This does not authorize arbitrary direct database writes from the client.

Protected business operations that require algorithm execution, privileged workflow checks, configuration enforcement, or administrative authority must pass through the FastAPI protected boundary where required by the architecture.

The exact API-versus-direct-Supabase responsibility matrix must be documented before each Stage 4 or later feature is considered complete.

## 11. FastAPI-to-Supabase Boundary

FastAPI communicates with Supabase for protected application operations.

Depending on the final implementation, this may include:

- authenticated user-context operations;
- server-authorized database access;
- protected evidence workflows;
- token/identity verification; and
- privileged operations restricted to the server.

Server-side credentials must be scoped to the minimum necessary privilege.

Use of a powerful credential does not eliminate the need for application authorization and audit controls.

## 12. Emergency Deployment Safety

A confirmed SOS travels through the same protected HelpHub deployment boundary but follows the separate emergency-processing path.

The deployment architecture must support:

- brief SOS confirmation;
- one-time location capture;
- registered-user context;
- automatic Critical override;
- persistence of the emergency record;
- Emergency Queue visibility;
- administrator acknowledgement/tracking; and
- permitted notification attempts.

HelpHub remains a barangay-level coordination system.

The deployment diagram intentionally contains no direct police, fire, medical, disaster-response, or national-emergency-service integration.

A future direct emergency integration requires formal operational, technical, privacy, security, and stakeholder approval.

## 13. Availability and Failure Boundaries

HelpHub depends on network-accessible services.

Possible failures include:

- resident internet failure;
- barangay/admin internet failure;
- FastAPI host outage;
- Supabase service or connectivity failure;
- FCM delivery failure;
- map-data availability failure; and
- browser/device-specific failure.

Full offline operation is outside the approved current scope.

The UI must therefore plan applicable:

- loading;
- success;
- empty;
- validation error;
- permission denied;
- weak/offline network;
- timeout; and
- server error

states.

Failure of a non-authoritative supporting service such as map display or push delivery must not silently corrupt authoritative report data.

## 14. Deployment Decisions Still Pending

The following deployment-specific decisions are not approved by the current study baseline:

- FastAPI production hosting provider;
- Flutter web hosting provider;
- production domain and DNS ownership;
- production cloud region;
- compute sizing;
- scaling policy;
- health-monitoring provider;
- centralized log/alert provider;
- backup implementation beyond managed-platform capabilities;
- disaster-recovery target;
- production CI/CD destination;
- certificate-management approach;
- final web-browser support matrix;
- administrator web-push support;
- final deployment audience and access window;
- post-study hosting ownership; and
- long-term operational funding.

These items must not be silently decided by this diagram.

They should be resolved through the appropriate stakeholder/deployment decision process before Stage 16 production deployment.

## 15. Environment Separation Rule

Development credentials and local-development resources must not be reused casually as production credentials.

Where multiple environments are introduced, each environment must have appropriately isolated:

- secrets;
- Supabase project/configuration;
- Firebase configuration;
- API deployment;
- web deployment;
- storage access;
- database data; and
- logging/audit boundaries.

The repository must never contain production secrets.

## 16. Deployment Traceability

| Deployment node/service | Primary responsibility |
| --- | --- |
| Resident Android device | Resident Flutter application and one-time device-location interaction |
| Administrator workstation | Browser-hosted responsive administrator interface |
| Static web hosting — TBD | Delivery of compiled Flutter web artifacts |
| FastAPI application host — TBD | Protected API, authorization, algorithm, workflow and governance operations |
| Supabase Auth | Authentication/session identity |
| Supabase PostgreSQL | Authoritative relational application data |
| Supabase Storage | Private optional evidence storage |
| Supabase Realtime | Permitted near-real-time data updates |
| Supabase RLS | Client data-isolation enforcement |
| Firebase Cloud Messaging | Push-notification attempts |
| OpenStreetMap/map service | Map-display data |

## 17. Relationship to Other Stage 3 Diagrams

The deployment diagram should be read together with:

- `SYSTEM_CONTEXT_DIAGRAM.md` for the overall external system boundary;
- `DATA_FLOW_DIAGRAM_LEVEL_0.md` for high-level business data flows;
- `DATA_FLOW_DIAGRAM_LEVEL_1.md` for logical processes and logical stores; and
- the upcoming Component Diagram for internal software responsibility boundaries.

The DFD logical data stores must not be interpreted as physical deployment machines.

Likewise, deployment services must not be interpreted as new application roles.

## 18. Approval-Sensitive Areas

This deployment diagram does not approve:

- a particular commercial hosting provider;
- a permanent production domain;
- a cloud region;
- production capacity;
- long-term operations;
- direct external-responder integration;
- administrator browser push;
- unrestricted direct client database writes; or
- any change to the canonical HelpHub technology stack.

A stack change requires documented blocker analysis, alternatives, trade-offs, migration cost, and study impact before adoption.

## 19. Stage 3 Verification Checklist

Before Stage 3 approval, verify that:

- the Android resident application is represented;
- the responsive web-capable administrator interface is represented;
- FastAPI is the protected backend boundary;
- Supabase Auth, PostgreSQL, Storage, Realtime, and RLS are represented;
- Firebase Cloud Messaging is represented as push attempts rather than guaranteed delivery;
- `geolocator`/device location is represented without continuous tracking;
- OpenStreetMap-related map display is represented;
- HTTPS/TLS trust boundaries are recognized;
- client devices are treated as untrusted;
- secrets remain server-side or outside source control;
- service-role or administrator secrets are not placed in Flutter;
- no direct external responder integration is implied;
- no assistance-request deployment component exists;
- unspecified web/API hosting providers remain explicitly TBD;
- full offline operation is not implied;
- deployment services are not confused with application roles; and
- the component diagram can be derived without contradicting this deployment model.

## 20. Stage 3 Deployment Rule

This diagram is the Stage 3 deployment baseline for HelpHub's approved architecture.

It establishes technology and trust boundaries without selecting infrastructure decisions that remain unapproved.

The later implementation and Stage 16 deployment must replace applicable `TBD` deployment nodes with documented, tested, and approved infrastructure choices.

If the approved technology stack, deployment audience, security boundary, hosting model, data location, notification architecture, map service, or operational ownership changes, this diagram and all affected security, privacy, component, testing, and deployment documentation must be reviewed before the relevant stage gate may pass.
