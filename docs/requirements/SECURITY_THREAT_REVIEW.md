# HelpHub Security Threat Review

## Document Control

- Project: HelpHub — A Mobile-Based Barangay Concern Reporting Application Using a Rule-Based Weighted Priority Queue Algorithm with Emergency Response Module
- Roadmap phase: Stage 3 — Requirements, Diagrams, and Privacy Review
- Task: 03.16 — Security Threat Review
- GitHub issue: #14
- Status: DRAFT — NOT YET FINAL SECURITY APPROVAL
- Scope: One selected barangay and the controlled HelpHub study/evaluation deployment
- Primary authenticated roles: Resident and Barangay Administrator

---

# 1. Purpose

This Security Threat Review identifies security-sensitive assets, trust boundaries, abuse scenarios, existing defensive foundations, required future controls, and verification evidence for HelpHub.

The purpose is to prevent security decisions from being treated as implicit assumptions during Flutter, FastAPI, Supabase, Firebase Cloud Messaging, location, algorithm, emergency, configuration, or deployment implementation.

This review does not claim that HelpHub is secure merely because a requirement, migration, policy, diagram, or control design exists.

Security controls must later be implemented and objectively tested.

---

# 2. Threat-Review Method

This review uses source-grounded abuse scenarios rather than an unapproved numerical risk-scoring model.

For each relevant threat, the review records:

1. the protected asset or operation;
2. the trust boundary involved;
3. a realistic abuse or failure scenario;
4. the required defensive control;
5. existing repository evidence;
6. remaining implementation or verification work.

Threats are not assigned invented probability, severity, or numeric risk scores.

Where policy behavior remains approval-dependent, this review records the dependency rather than selecting a value on behalf of stakeholders.

---

# 3. Security Objectives

HelpHub security design must protect the following properties.

## 3.1 Authentication integrity

Protected actions must be associated with an authenticated identity when authentication is required.

## 3.2 Authorization integrity

Authentication alone must not grant access to protected Resident, administrator, emergency, configuration, audit, or workflow functions.

## 3.3 Resident isolation

A Resident must not gain normal client access to another Resident's protected:

- profile information;
- reports;
- location;
- evidence;
- lifecycle/status history;
- routing information where protected;
- SOS/emergency information.

## 3.4 Administrative least privilege

Barangay Administrator access remains limited to approved administrative purposes and permissions.

Administrator possession of the web client does not itself grant authority.

## 3.5 Protected business-rule integrity

Clients must not authoritatively supply or override protected:

- role;
- account approval status;
- final priority;
- algorithm score;
- Critical override;
- routing destination;
- deadline;
- queue position;
- lifecycle transition;
- emergency acknowledgement;
- false-alarm action;
- configuration activation.

## 3.6 Data integrity

Authoritative report, emergency, workflow, routing, algorithm, and configuration state must not be silently corrupted by client manipulation or supporting-service failure.

## 3.7 Audit/history integrity

Required audit, status-history, and routing-history evidence must remain protected from unauthorized modification or deletion.

## 3.8 Confidentiality

Sensitive identity, verification, GPS, SOS, evidence, audit, configuration, secret, and notification data must use least-privilege access.

## 3.9 Availability and failure containment

Failure of a dependency such as FCM or map display must not falsely report authoritative state changes or corrupt stored report/emergency state.

## 3.10 Secret protection

Service-role credentials, backend credentials, Firebase server credentials, signing keys, private certificates, database administrative credentials, and other secrets must remain outside client artifacts and source control.

---

# 4. Security-Sensitive Assets

| Asset | Security concern |
|---|---|
| Supabase authentication/session state | Prevent identity spoofing and unauthorized protected operations. |
| Resident profile | Prevent cross-Resident exposure and unauthorized role/account manipulation. |
| Verification records | Prevent unauthorized review, disclosure, or decision manipulation. |
| Normal reports | Preserve ownership, confidentiality, validity, and authoritative submission state. |
| GPS/location | Protect location-sensitive information and prevent fabricated success states. |
| Photo evidence | Prevent unrestricted access, malicious uploads, and unauthorized object access. |
| Status history | Preserve immutable workflow evidence. |
| Routing history | Preserve immutable assignment/referral evidence. |
| Algorithm configuration | Prevent unauthorized rule/weight/threshold/routing/deadline changes. |
| Algorithm decision evidence | Preserve deterministic/reproducible decision evidence. |
| Priority queue | Prevent client manipulation of ordering or Critical status. |
| SOS/emergency records | Protect high-sensitivity data and authoritative emergency state. |
| Emergency queue | Prevent unauthorized visibility and acknowledgement/manipulation. |
| Administrator notes | Prevent Resident exposure and unnecessary sensitive content. |
| Audit evidence | Preserve accountability and prevent unauthorized mutation/access. |
| FCM/device tokens | Protect technical delivery identifiers. |
| Notification payloads | Prevent unnecessary lock-screen disclosure. |
| Server secrets | Prevent complete backend privilege compromise. |
| Deployment/configuration environment | Prevent unintended exposure or privilege escalation. |

---

# 5. Trust and Network Boundaries

Protected HelpHub communication must use encrypted transport such as HTTPS/TLS.

Important architectural trust boundaries are:

1. Resident device → FastAPI;
2. Administrator browser → FastAPI;
3. approved clients → Supabase client-facing services;
4. FastAPI → Supabase;
5. FastAPI → Firebase Cloud Messaging;
6. clients → approved map-data service.

Client devices and browsers are untrusted execution environments.

Therefore:

- hidden/disabled UI controls are not authorization;
- editable client state is not authorization;
- request payloads are untrusted;
- route parameters are untrusted;
- locally stored role information is untrusted;
- client-calculated priority or workflow values are untrusted.

---

# 6. Client-to-Supabase Security Boundary

Direct client interaction with Supabase may be used only for specifically approved client-safe operations such as:

- authentication;
- permitted Realtime subscriptions;
- other explicitly approved operations protected by Row Level Security.

This does not authorize arbitrary client database writes.

Applicable controls include:

- PostgreSQL grants;
- Supabase RLS;
- ownership checks;
- approved-Resident checks;
- approved-Administrator checks;
- restricted table/function privileges.

Protected business operations requiring privileged workflow enforcement, algorithm execution, configuration enforcement, or administrative authority must use the protected server boundary where required.

RLS is an additional data-isolation boundary.

RLS does not replace FastAPI business authorization.

---

# 7. FastAPI Security Boundary

FastAPI is responsible for protected business operations.

The server must independently:

1. authenticate or validate trusted identity context;
2. authorize the requested operation;
3. validate untrusted input;
4. load authoritative server/database state;
5. enforce the approved workflow or configuration;
6. reject client attempts to override protected values;
7. perform the protected transaction;
8. create required audit/history evidence;
9. return controlled output and errors.

A valid authenticated session does not automatically authorize every protected operation.

Use of a powerful database credential does not remove the need for application-level authorization.

---

# 8. Existing Defensive Foundation

The current repository already contains partial security implementation evidence.

## 8.1 Identity/profile isolation

Current migration foundations include:

- RLS on identity tables;
- Resident ownership policies using authenticated identity;
- restricted profile update columns;
- no anonymous access to protected identity tables;
- protected role/account-state handling.

## 8.2 Approved-role predicates

Current foundations include server/database predicates for:

- approved Resident checks;
- approved Barangay Administrator checks.

These support policy enforcement but do not replace later API authorization tests.

## 8.3 Verification review

Resident-verification review uses a protected operation with restricted execution privileges.

The operation performs the review/account update and creates required audit evidence.

## 8.4 Audit immutability

`audit_events` is designed as append-only.

Current safeguards include:

- restricted grants;
- no ordinary UPDATE/DELETE privilege;
- mutation-blocking trigger behavior.

## 8.5 Report ownership

Current report/location/evidence metadata policies distinguish:

- approved Resident access to owned records;
- approved Administrator access.

Direct client report writes are intentionally restricted in the foundation.

## 8.6 Status-history integrity

Report status history is designed as append-only and includes mutation-blocking protection.

## 8.7 Routing-history integrity

Report routing history is also designed as append-only and includes mutation-blocking protection.

## 8.8 Private evidence bucket

The current report-evidence Storage bucket is private.

However, a private bucket alone is not complete evidence-object security.

Object-level Storage policies remain required and must be tested.

## 8.9 Configuration foundations

Concern taxonomy/routing/lifecycle structures use RLS and restricted direct mutation.

Complete protected activation/mutation operations and immutable activated-version enforcement remain future work.

---

# 9. Security Threat Register

## THR-001 — Client-side role manipulation

### Target

Resident/Administrator authorization boundary.

### Abuse scenario

A Resident modifies local Flutter state, browser state, stored values, route parameters, or request payloads so the client appears to be an Administrator.

### Required controls

- never trust client role values as authority;
- validate authenticated identity server-side;
- enforce role/approval through authoritative database state;
- use RLS for direct client data paths;
- require protected FastAPI authorization for privileged operations.

### Current evidence

Role/permission requirements and approved-role database predicates exist.

### Remaining verification

- modified-role client test;
- protected API authorization tests;
- RLS privilege-escalation tests.

---

## THR-002 — Cross-Resident data access

### Target

Reports, location, evidence metadata, lifecycle history, routing data, and future SOS records.

### Abuse scenario

A Resident changes a report ID or direct query parameter to attempt access to another Resident's protected data.

### Required controls

- ownership checks;
- RLS;
- server-side authorization;
- non-enumeration-safe authorization behavior;
- controlled error responses.

### Current evidence

Current report/location/evidence/lifecycle/routing foundations include Resident ownership policies.

### Remaining verification

Explicit database/RLS and API tests must prove that one Resident cannot access another Resident's records.

---

## THR-003 — Unauthorized direct database writes

### Target

Reports, statuses, routing, audit, configuration, and administrative data.

### Abuse scenario

A client attempts to bypass protected workflows by writing directly to Supabase tables.

### Required controls

- restrictive PostgreSQL grants;
- RLS;
- no direct client mutation policy for protected domains;
- protected FastAPI/server operations.

### Current evidence

Several current migration domains deliberately omit direct authenticated-client INSERT/UPDATE/DELETE permissions.

### Remaining verification

Database/RLS negative tests must prove direct writes fail.

---

## THR-004 — Client manipulation of priority or queue values

### Target

Rule-Based Weighted Priority Queue Algorithm.

### Abuse scenario

A malicious or modified client submits:

- a higher priority;
- a fabricated score;
- a Critical flag;
- a preferred queue position;
- a manipulated deadline.

### Required controls

The server must derive protected algorithm output from validated input and active approved configuration.

The client must not be authoritative for:

- score;
- priority;
- Critical override;
- route;
- deadline;
- queue key.

### Current evidence

Architecture and requirement baselines establish server authority.

### Remaining verification

Stage 8 API and algorithm tests must prove supplied protected output values are ignored/rejected.

---

## THR-005 — Unapproved configuration tampering

### Target

Taxonomy, rules, rating anchors, weights, thresholds, routing, deadlines, lifecycle, and emergency escalation configuration.

### Abuse scenario

An ordinary Resident or insufficiently authorized Administrator attempts to edit or activate protected configuration.

### Required controls

- specific configuration privilege;
- server-side authorization;
- versioned configuration;
- protected activation/mutation operation;
- audit evidence;
- historical immutability.

### Current evidence

Configuration foundations restrict direct mutation and support versioned structures.

### Remaining issues

- final configuration privilege remains approval-dependent;
- complete immutable activation enforcement remains future work.

Reference:

- `D-015 — Protected configuration privilege`
- `DD-C02 — Activated configuration immutability`

---

## THR-006 — Workflow/status tampering

### Target

Current report lifecycle and status history.

### Abuse scenario

A user directly changes a status, skips required transitions, backdates an event, or rewrites history.

### Required controls

- protected transition operation;
- approved transition validation;
- authoritative timestamping;
- append-only history;
- associated audit evidence;
- no direct client write path.

### Current evidence

Append-only status-history foundation exists.

### Remaining work

Final transition policy and protected transition implementation/testing remain required.

---

## THR-007 — Routing/referral tampering

### Target

Current routing state and routing history.

### Abuse scenario

A client chooses an arbitrary destination or changes routing history without the approved rule/administrator process.

### Required controls

- protected routing operation;
- active routing-version validation;
- approved concern-to-route mapping validation;
- approved override policy where applicable;
- append-only routing history;
- audit evidence.

### Remaining decisions

- configured-map enforcement requires protected implementation;
- manual routing overrides remain undecided.

References:

- `DD-C06 — Routing-map enforcement`
- `DD-C07 — Manual route overrides`

---

## THR-008 — Audit evidence modification or deletion

### Target

Audit trail.

### Abuse scenario

A user attempts to modify or delete evidence of an administrative or security-sensitive action.

### Required controls

- append-only model;
- restricted privileges;
- mutation-blocking database protection;
- restricted audit viewing.

### Current evidence

Append-only audit table protections exist in current migrations.

### Remaining verification

- UPDATE rejection test;
- DELETE rejection test;
- unauthorized audit-read test;
- protected-workflow audit generation tests.

---

## THR-009 — Fabricated verification review

### Target

Resident verification/account approval.

### Abuse scenario

A Resident or unauthorized caller attempts to approve a verification record or alter account status.

### Required controls

- protected review function/API;
- authoritative reviewer identity;
- row locking/transaction safety;
- server authorization;
- audit event.

### Current evidence

Protected service-only verification review foundation exists.

### Remaining verification

Unauthorized caller, duplicate/concurrent review, invalid transition, and audit tests remain required.

---

## THR-010 — Report submission abuse or flooding

### Target

Concern submission API and database.

### Abuse scenario

A user repeatedly submits excessive or automated reports to consume resources or distort administrative queues.

### Required controls

- authentication/authorization;
- input validation;
- appropriate rate limiting;
- duplicate/repeated-action handling;
- monitoring/audit where applicable.

### Existing requirement

Report submission is explicitly included in rate-limit/security review.

### Remaining work

Actual FastAPI rate-limit design, limits, responses, and tests belong to later implementation/security stages.

No arbitrary rate threshold is defined by this review.

---

## THR-011 — SOS submission abuse or flooding

### Target

Emergency submission path and Emergency Queue.

### Abuse scenario

A malicious or automated caller repeatedly triggers SOS submissions.

### Required controls

- authenticated registered-user context;
- brief hold/confirmation in the legitimate UI;
- protected server validation;
- appropriate rate limiting;
- authoritative Critical override;
- traceability.

### Remaining work

SOS does not yet have complete application/schema implementation.

Rate-limit behavior must preserve urgent usability and must not be invented without appropriate design/testing.

---

## THR-012 — False or replayed SOS action

### Target

Emergency processing.

### Abuse scenario

A previously valid request, repeated client action, or manipulated payload results in unintended duplicate SOS processing.

### Required controls

- authoritative server-side event creation;
- duplicate/repeated-action safety;
- traceability;
- controlled acknowledgement workflow;
- false-alarm workflow requiring reason when used.

### Remaining verification

Duplicate/replay behavior must be explicitly tested during SOS implementation and Stage 13 security testing.

---

## THR-013 — Malicious or unsafe evidence upload

### Target

Report evidence Storage.

### Abuse scenario

A user uploads an unsupported, oversized, misleading, or otherwise disallowed object.

### Required controls

- approved type restriction;
- approved size restriction;
- protected upload path;
- ownership validation;
- private Storage.

### Current evidence

The evidence model/bucket establishes private storage and engineering upload constraints.

### Remaining verification

Storage upload policies and server-side/client-independent enforcement must be tested.

---

## THR-014 — Unauthorized evidence-object access

### Target

Private report photo evidence.

### Abuse scenario

A user obtains or guesses an object path and attempts to download evidence belonging to another Resident.

### Required controls

- private bucket;
- object-level authorization;
- report ownership/admin authorization;
- signed/protected access mechanism as approved;
- no reliance on unpredictable names as the only authorization mechanism.

### Current evidence

Private bucket exists.

### Remaining gap

Object-level upload/download policies are not yet complete.

Reference:

- `DD-C09 — Storage object authorization`

---

## THR-015 — Sensitive notification disclosure

### Target

Notification payload and lock screen.

### Abuse scenario

A third party with physical view of a device sees GPS, SOS, identity, report, or evidence information in a notification.

### Required controls

Notification content must minimize sensitive data and direct the authenticated user into the protected application for details.

### Remaining verification

Stage 11 must inspect actual FCM payloads and lock-screen presentation.

---

## THR-016 — Realtime subscription data leakage

### Target

Supabase Realtime.

### Abuse scenario

An authenticated user subscribes to records outside their authorized ownership/role scope.

### Required controls

- authentication;
- RLS;
- ownership/admin policies;
- minimum subscription scope.

### Remaining verification

Realtime/RLS tests must prove subscriptions do not disclose unauthorized report, workflow, or emergency data.

---

## THR-017 — Server-secret exposure

### Target

Service-role keys, backend credentials, Firebase server credentials, signing keys, private certificates, database administrative credentials.

### Abuse scenario

A secret is committed to Git, packaged into Flutter, exposed in a web bundle, screenshot, log, or configuration artifact.

### Required controls

- secrets outside source control;
- server-side secret storage;
- no service-role key in Flutter;
- no backend secret in web bundle;
- repository secret-protection checks;
- least-privilege credentials.

### Current evidence

Secret-protection requirements and deployment rules are established.

### Remaining verification

Secret scanning and deployment configuration inspection remain required.

---

## THR-018 — Abuse of powerful server credentials

### Target

FastAPI → Supabase privileged boundary.

### Abuse scenario

Server code uses a powerful credential to perform an operation without checking the authenticated user's actual authority.

### Required controls

- application-level authorization before privileged action;
- narrow service interfaces;
- least privilege;
- audit evidence;
- controlled transaction logic.

### Security rule

Possession of a powerful server credential must never be treated as authorization.

### Remaining verification

Protected endpoint tests must exercise authenticated-but-unauthorized users.

---

## THR-019 — Sensitive error or log leakage

### Target

API errors, application logs, deployment logs, debugging output.

### Abuse scenario

A server error exposes:

- database internals;
- stack traces;
- secrets;
- GPS;
- SOS details;
- authentication data;
- private report content.

### Required controls

- controlled errors;
- data-minimized logging;
- no secrets in logs;
- environment-appropriate diagnostics;
- authorization before protected error context.

### Remaining work

FastAPI error handling and deployment logging must be reviewed during implementation/security testing.

---

## THR-020 — Duplicate administrative action

### Target

Verification, status, routing, emergency acknowledgement, configuration operations.

### Abuse scenario

Double-clicks, retries, network retransmission, or concurrent requests perform a protected action more than once.

### Required controls

- transactional operations;
- row locking/concurrency handling where appropriate;
- safe repeated-action behavior;
- history/audit consistency.

### Current evidence

The verification-review foundation already uses row-locking behavior.

### Remaining verification

Every later protected mutation requires boundary and concurrency tests appropriate to the operation.

---

## THR-021 — Availability attack or dependency outage

### Target

Resident reporting, Administrator workflow, FastAPI, Supabase, FCM, map service.

### Abuse/failure scenario

A dependency is unavailable or a service becomes overloaded.

### Required controls

- controlled failure states;
- timeouts;
- safe retries where appropriate;
- no false success;
- authoritative state preservation;
- operational monitoring as later approved.

### Scope boundary

Full offline operation is outside scope.

### Remaining deployment decisions

Monitoring provider, backup implementation, disaster-recovery targets, scaling policy, and hosting details remain pending.

---

## THR-022 — Supporting-service failure corrupts authoritative state

### Target

FCM and map-display integrations.

### Abuse/failure scenario

Notification or map failure is accidentally treated as a failed or successful authoritative report/emergency mutation.

### Required controls

Supporting services must remain non-authoritative.

Failure of map display or notification delivery must not corrupt the authoritative stored state.

### Remaining verification

Failure-injection/integration tests are required during later stages.

---

## THR-023 — Unauthorized emergency-queue access

### Target

Emergency Queue and SOS details.

### Abuse scenario

A Resident, unapproved administrator, or other unauthorized caller attempts to inspect emergency information.

### Required controls

- protected authorization;
- least privilege;
- RLS where applicable;
- server-side emergency access controls;
- audit where required.

### Remaining work

Complete SOS data/schema/API authorization remains future Stage 10 work.

---

## THR-024 — Unapproved external emergency integration

### Target

SOS/referral boundary.

### Abuse/design scenario

Implementation directly sends protected SOS data to police, fire, medical, disaster-response, or another external agency without approved operational/privacy/security design.

### Required control

No direct emergency-service integration exists in the approved current scope.

External referral is a HelpHub administrative coordination record, not guaranteed dispatch.

A direct future integration requires formal:

- operational approval;
- technical design;
- privacy review;
- security review;
- stakeholder approval.

---

## THR-025 — Continuous location tracking introduced accidentally

### Target

Resident privacy/location boundary.

### Abuse/design scenario

Background location polling is added for convenience or SOS tracking.

### Required control

HelpHub uses one-time location capture and must not continuously track Residents.

### Verification

Flutter/location implementation must be checked for absence of continuous/background tracking behavior.

---

## THR-026 — Excessive long-term sensitive-data exposure

### Target

Reports, evidence, GPS, SOS, verification, audit, notification, and evaluation data.

### Abuse/failure scenario

Sensitive information is retained indefinitely because no deletion implementation was designed.

### Required control

Retention, archival, anonymization, and lawful deletion must follow approved policy.

### Current dependency

No final retention schedule is approved.

References:

- `D-013`
- `DD-C10`

This review does not invent one.

---

# 10. Algorithm and Queue Integrity Review

The priority algorithm is a protected server-side business function.

The following must not be trusted from the client:

- normalized factor rating;
- weight;
- threshold;
- matched-rule result;
- score;
- priority;
- override;
- handler/route;
- deadline;
- queue rank/key.

The protected algorithm must use the active approved versions of its configuration.

The same input under the same algorithm/configuration versions must produce the same output.

Security testing must include attempts to:

- submit a fabricated final priority;
- submit a fabricated Critical override;
- submit a preferred route;
- submit a preferred deadline;
- alter configuration identifiers;
- bypass classification validation;
- manipulate deterministic queue order.

Historical algorithm evidence must remain linked to the versions used for processing.

---

# 11. Emergency Security Review

The SOS path has elevated security and safety importance.

A confirmed SOS requires:

- registered-user context;
- brief hold/confirmation;
- selected approved emergency type;
- one-time location when available/permitted;
- timestamp;
- automatic Critical override;
- Emergency Queue persistence;
- protected acknowledgement/tracking.

The Critical override is a protected system action.

A client-supplied priority value cannot authorize it.

Emergency data must be restricted to appropriately authorized users.

HelpHub must not claim guaranteed external dispatch.

---

# 12. Configuration Security Review

Protected configuration includes, where applicable:

- concern taxonomy;
- rules;
- rating anchors;
- weights;
- thresholds;
- routing;
- deadlines;
- lifecycle configuration;
- emergency escalation configuration.

Security properties required for configuration include:

- explicit authorization;
- versioning;
- reason/approval evidence where required;
- controlled activation;
- audit evidence;
- historical immutability after use;
- no direct unprotected client mutation.

Ordinary Administrator status does not automatically grant configuration-editing privilege where the approved governance process requires additional authorization.

---

# 13. History and Audit Integrity Review

Status history, routing history, and audit evidence serve different purposes.

A successful protected status change must create:

1. the required status-history record; and
2. the required audit event.

A successful protected routing/assignment/referral action must create the required routing/history and audit evidence where applicable.

Current database history/audit foundations use append-only protections.

Future protected operations must preserve transaction consistency so the authoritative state cannot change without its required traceability evidence.

---

# 14. Evidence Storage Security Review

Report evidence is sensitive because it may reveal identifiable people, homes, vehicles, documents, or other private context.

Required controls include:

- private Storage;
- restricted object access;
- ownership/admin authorization;
- approved type/size enforcement;
- no unrestricted public URL;
- no reliance on object-name unpredictability as authorization.

Current state:

- private bucket foundation: present;
- report-evidence metadata access controls: partial/present;
- Storage object-level upload/download authorization: future implementation/testing required.

Reference:

- `DD-C09`

---

# 15. Secrets and Credential Review

The following must never be committed or packaged into client code:

- `.env` secrets;
- Supabase service-role keys;
- database administrative credentials;
- Firebase server credentials/service-account keys;
- signing keys;
- private certificates;
- deployment/provider secrets.

Flutter web output is publicly inspectable client code.

Therefore, any value shipped in Flutter must be treated as client-visible.

Public client configuration needed to connect to an approved service must be distinguished from secret credentials.

---

# 16. Failure and Availability Security

Expected failure conditions include:

- Resident internet failure;
- administrator internet failure;
- FastAPI outage;
- Supabase outage/connectivity failure;
- FCM delivery failure;
- map-data failure;
- browser/device failure.

The UI must provide applicable:

- loading;
- success;
- empty;
- validation-error;
- permission-denied;
- network-failure;
- timeout;
- unauthorized/session-failure;
- server-error

states.

Security-sensitive writes must never report success when authoritative persistence failed.

Supporting-service failure must not redefine authoritative database state.

---

# 17. Deployment Security Decisions Still Pending

The current Stage 3 baseline does not finalize:

- FastAPI production hosting provider;
- Flutter web hosting provider;
- production domain/DNS ownership;
- production cloud region;
- compute sizing;
- scaling policy;
- monitoring provider;
- centralized logging/alerting provider;
- backup implementation;
- disaster-recovery target;
- production CI/CD destination;
- certificate-management approach;
- final supported browser matrix;
- administrator web-push support;
- final deployment audience/access window;
- post-study hosting ownership;
- long-term operational funding.

The threat review therefore must not claim provider-specific controls that have not been selected.

Once those decisions are approved, the deployment-specific threat model must be updated.

---

# 18. Security Verification Plan

Security requirements must be supported by objective evidence.

Future verification must include, where applicable:

## Authentication and authorization

- unauthenticated protected-endpoint tests;
- authenticated-but-unauthorized tests;
- Resident-vs-Administrator tests;
- unapproved-account tests;
- modified client-role tests;
- protected configuration privilege tests.

## RLS and ownership

- Resident A cannot read Resident B's report;
- Resident A cannot read Resident B's location;
- Resident A cannot read Resident B's evidence metadata/object;
- Resident A cannot read Resident B's lifecycle history;
- Resident A cannot read Resident B's routing details where restricted;
- future SOS ownership/access tests;
- direct unauthorized writes are rejected.

## API input and protected-value integrity

- malformed/invalid inputs rejected;
- client-supplied priority ignored/rejected;
- client-supplied route ignored/rejected;
- client-supplied deadline ignored/rejected;
- client-supplied Critical override ignored/rejected;
- invalid status transitions rejected;
- invalid routing actions rejected.

## Rate limiting and abuse

- report-submission rate-limit behavior;
- SOS rate-limit/security behavior;
- repeated-action handling;
- controlled error response;
- no corruption of valid authoritative state.

## Evidence Storage

- unauthorized upload rejected;
- unauthorized download rejected;
- cross-Resident object access rejected;
- approved type validation;
- approved size validation;
- no public unrestricted evidence access.

## History and audit

- audit UPDATE rejected;
- audit DELETE rejected;
- status-history UPDATE rejected;
- status-history DELETE rejected;
- routing-history UPDATE rejected;
- routing-history DELETE rejected;
- required audit event created with protected workflow action;
- unauthorized audit read rejected.

## Secrets

- repository secret scan;
- built Flutter web inspection for server secrets;
- deployment environment review;
- service-account/private-key review.

## Error handling

- controlled 4xx/5xx responses;
- no stack traces/secrets in production responses;
- logging review for sensitive-data minimization.

## Availability/failure

- API timeout;
- network loss;
- Supabase failure;
- FCM failure;
- map failure;
- duplicate/retry behavior;
- no false success;
- no authoritative-state corruption.

---

# 19. Security Findings

## SEC-F01 — Client environments are explicitly untrusted

Flutter clients and browsers cannot be authoritative for protected identity, role, algorithm, workflow, or configuration decisions.

## SEC-F02 — Defense in depth is required

RLS and FastAPI authorization are complementary controls.

Neither layer replaces the other for the responsibilities assigned to it.

## SEC-F03 — Current database foundations already provide partial isolation

RLS, ownership/admin policies, restricted privileges, and protected functions exist for several current schema domains.

These foundations require explicit negative tests before they can be treated as verified security controls.

## SEC-F04 — Audit and workflow histories have meaningful integrity foundations

Audit, status history, and routing history include append-only protections.

Future application operations must preserve those guarantees transactionally.

## SEC-F05 — Evidence Storage security remains incomplete

The report-evidence bucket is private, but object-level Storage authorization still requires implementation and testing.

Reference:

- `DD-C09`

## SEC-F06 — FastAPI authorization is architecturally required but not yet complete application evidence

Protected API authorization must be implemented and tested during later vertical slices.

## SEC-F07 — Rate limiting is required but no arbitrary threshold is approved here

Sensitive writes, specifically report and SOS submission, require rate-limit/security review.

Actual limits must be designed and tested without inventing unsupported values in Stage 3.

## SEC-F08 — Configuration authorization/immutability still requires later enforcement

Version foundations exist, but protected mutation, activation, governance privilege, and historical immutability require later implementation.

## SEC-F09 — SOS security remains future implementation work

Emergency authorization, queue isolation, acknowledgement, rate-limit behavior, false-alarm workflow, and audit evidence must be tested during Stage 10 and Stage 13.

## SEC-F10 — Deployment/provider threats require review after infrastructure decisions

Hosting, certificate, monitoring, backup, DR, and CI/CD decisions are not yet finalized.

Provider-specific threat controls must be added after approval.

---

# 20. Traceability to Existing Requirements

Primary security requirements include:

- `NFR-SEC-001` — least privilege;
- `NFR-SEC-002` — Supabase RLS;
- `NFR-SEC-003` — FastAPI authorization;
- `NFR-SEC-004` — Flutter is not sole protected authority;
- `NFR-SEC-005` — trust-boundary validation;
- `NFR-SEC-006` — rate limiting for sensitive writes;
- `NFR-SEC-007` — report/SOS rate-limit/security review;
- `NFR-SEC-008` — private upload restrictions;
- `NFR-SEC-009` — restricted evidence access;
- `NFR-SEC-010` — secret protection;
- `NFR-SEC-011` — administrator security-action audit;
- `NFR-SEC-012` — protected GPS/SOS access.

Related functional requirements include:

- `FR-UM-010`–`FR-UM-012`;
- `FR-LE-005`–`FR-LE-008`;
- `FR-RT-002`;
- `FR-AD-009`–`FR-AD-015`;
- `FR-SOS-011`, `FR-SOS-015`, `FR-SOS-017`;
- `FR-AU-001`–`FR-AU-006`;
- `FR-CFG-009`–`FR-CFG-012`.

---

# 21. Roadmap Verification Ownership

| Roadmap stage | Security responsibility |
|---|---|
| Stage 4 | Schema, Auth, Storage, RLS, grants, policies, database security tests |
| Stage 5 | Secure client navigation/state handling; no UI-only authorization assumption |
| Stage 6 | Authentication, verification, role/account authorization |
| Stage 7 | Protected report submission, ownership, location/evidence security |
| Stage 8 | FastAPI authorization, input validation, protected algorithm boundary |
| Stage 9 | Admin workflow, status/routing authorization, audit integrity |
| Stage 10 | SOS authorization, Critical override integrity, emergency queue security |
| Stage 11 | Realtime/RLS, FCM privacy/security, announcement authorization |
| Stage 12 | Protected configuration authorization/version integrity |
| Stage 13 | Consolidated security, rate-limit, failure, performance, and abuse testing |
| Stage 14 | Algorithm integrity/reproducibility validation |
| Stage 15 | ISO/IEC 25010 Security evaluation evidence |
| Stage 16 | Deployment configuration, secrets, TLS/certificates, monitoring/backup/operations review |

---

# 22. Stage 3 Security Gate Checklist

The threat review is ready for Stage 3 gate review when:

- [ ] security-sensitive assets are documented;
- [ ] client devices/browsers are treated as untrusted;
- [ ] Resident → FastAPI boundary is documented;
- [ ] Administrator → FastAPI boundary is documented;
- [ ] client → Supabase boundary is documented;
- [ ] FastAPI → Supabase boundary is documented;
- [ ] FCM and map-service boundaries are documented;
- [ ] least privilege is documented;
- [ ] RLS and FastAPI authorization responsibilities remain distinct;
- [ ] client-side role manipulation is addressed;
- [ ] cross-Resident access is addressed;
- [ ] unauthorized direct database writes are addressed;
- [ ] algorithm output manipulation is addressed;
- [ ] workflow/status/routing tampering is addressed;
- [ ] configuration tampering is addressed;
- [ ] audit/history mutation is addressed;
- [ ] report/SOS flooding is addressed;
- [ ] repeated/replayed protected actions are addressed;
- [ ] evidence-upload abuse is addressed;
- [ ] evidence-object authorization gap is documented;
- [ ] notification and Realtime leakage are addressed;
- [ ] secret/service-role exposure is addressed;
- [ ] powerful server credentials are not treated as authorization;
- [ ] error/log leakage is addressed;
- [ ] dependency/failure boundaries are addressed;
- [ ] unapproved emergency-service integration is rejected;
- [ ] continuous Resident location tracking remains prohibited;
- [ ] deployment decisions still pending remain visibly pending;
- [ ] future security verification evidence is assigned to applicable stages;
- [ ] no security control is marked verified solely because its requirement or schema exists.

---

# 23. Required Follow-Up

This Stage 3 review establishes the threat baseline.

It does not replace implementation-stage security work.

For every protected vertical slice:

1. identify applicable threats and requirement IDs;
2. define the client/API/database/Storage authorization path;
3. implement least-privilege controls;
4. reject untrusted protected client values;
5. implement required audit/history behavior;
6. test normal, invalid, unauthorized, duplicate, concurrency, and failure cases;
7. test RLS/direct-client behavior where applicable;
8. review sensitive errors/logs;
9. update the Requirements Traceability Matrix;
10. update this threat review if the architecture or attack surface changes.

A feature must not be declared secure merely because the happy-path feature works.

A database policy must not be treated as verified until its allow and deny behavior has been objectively tested.

A powerful server credential must never be treated as a substitute for application authorization.
