# HelpHub Privacy Impact Review

## Document Control

- Project: HelpHub — A Mobile-Based Barangay Concern Reporting Application Using a Rule-Based Weighted Priority Queue Algorithm with Emergency Response Module
- Roadmap phase: Stage 3 — Requirements, Diagrams, and Privacy Review
- Task: 03.15 — Privacy Impact Review
- GitHub issue: #14
- Status: DRAFT — NOT YET STAKEHOLDER / INSTITUTIONALLY APPROVED
- Scope: One selected barangay and the controlled study/evaluation deployment
- Primary roles: Resident and Barangay Administrator

---

# 1. Purpose

This Privacy Impact Review identifies the personal, location-sensitive, emergency, technical, operational, and evidentiary information processed by HelpHub and documents the privacy controls, unresolved governance decisions, and verification requirements that apply to that information.

The review is intended to prevent privacy-sensitive implementation choices from being silently finalized in application code, database schema, configuration, notifications, exports, or administrative workflows.

This document is a requirements and design review. It does not itself approve retention schedules, verification evidence requirements, routing-detail visibility, emergency escalation recipients, or other stakeholder-controlled policy.

---

# 2. Privacy Principles Applied to HelpHub

HelpHub shall apply the following privacy principles throughout implementation:

1. collect only information required for an approved HelpHub function;
2. request location only when a report or SOS interaction requires it;
3. do not continuously track Residents;
4. restrict sensitive information according to least privilege;
5. enforce protected access at appropriate client, API, database, and storage boundaries;
6. minimize unnecessary sensitive information in notifications and administrative notes;
7. preserve traceability without placing unnecessary personal information into audit records;
8. use private/restricted evidence storage and object-level authorization;
9. keep research/evaluation exports appropriately minimized and protected;
10. retain, archive, anonymize, or lawfully delete data only according to an approved policy.

---

# 3. System and Privacy Boundary

HelpHub serves one selected barangay during the approved study/evaluation scope.

The system has two primary authenticated roles:

- Resident
- Barangay Administrator

External police, fire, medical, disaster-response, or other agencies are not HelpHub authenticated roles in the current scope.

External referral is recorded as an administrative coordination/referral action. It must not be represented as guaranteed external dispatch, response, or direct system integration.

Supporting technical services may include:

- Supabase Auth;
- Supabase PostgreSQL;
- Supabase Storage;
- Supabase Realtime;
- Firebase Cloud Messaging;
- Android location services through `geolocator`;
- map display through `flutter_map` and OpenStreetMap.

Use of a supporting technical service does not remove HelpHub's obligation to minimize data and enforce authorization.

---

# 4. Personal and Sensitive Data Inventory

The following classifications are descriptive privacy considerations for HelpHub. They do not claim to establish a formal government data-classification policy.

| Data category | Examples | Privacy / sensitivity consideration |
|---|---|---|
| Authentication data | Credentials and authentication/session information | Secret authentication information must remain under the approved authentication service and must not be duplicated into ordinary application records. |
| Resident identity | Full name and account/profile identifiers | Personal identifying information. |
| Verification records/evidence | Verification request, review result, possible future residency/identity evidence | Personal and potentially high-sensitivity identity/residency information. Exact evidence fields are not yet approved. |
| Normal concern report | Concern type, description, urgency, affected population, vulnerable-group indicator, timestamps | Description may contain personal, incident, or location-sensitive information entered by the Resident. |
| GPS information | Latitude, longitude, accuracy, capture time | Location-sensitive personal information. |
| Human-readable address | Optional report/location address | Location-sensitive information. |
| Photo evidence | Optional permitted report image | May contain identifiable people, homes, vehicles, documents, or other sensitive context. |
| Report lifecycle information | Current status and status history | Operational information associated with the Resident's concern. |
| Routing/referral information | Destination, assignment/referral history, related notes | Operational information; internal details may require restricted Resident visibility. |
| Algorithm evidence | Factors, normalized ratings, matched rules, score breakdown, versions, priority, route, deadline, queue evidence | Operational decision evidence requiring role-appropriate access. |
| SOS/emergency data | Emergency type, location, timestamp, user details, acknowledgement/tracking information | High-sensitivity emergency and location information. |
| Administrator notes | Internal administrative notes | Must exclude secrets and unnecessary personal information. |
| Audit evidence | Actor/action/entity/minimum required context | Must contain only information necessary for traceability. |
| FCM/device tokens | Push-notification delivery identifiers | Sensitive technical delivery identifiers. |
| Notification content | Report/emergency event notification text | Must minimize lock-screen and payload exposure of identity, GPS, SOS, evidence, and report details. |
| Announcement data | Published barangay communication and authorship metadata | Administrative/publication information; workflow and retention remain governed by approved policy. |
| Research/evaluation data | Test results, UAT/evaluation datasets, exports | Must minimize unnecessary direct identifiers and use appropriate privacy protections. |

---

# 5. Data Collection and Purpose Review

## 5.1 Resident Identity and Account Data

### Purpose

Identity/profile information supports:

- account registration;
- authentication;
- Resident verification;
- ownership of reports and SOS events;
- authorized tracking;
- administrative accountability.

### Privacy requirement

Only information necessary for the approved registration and verification process should be collected.

HelpHub must not store authentication credentials in ordinary application profile tables.

### Unresolved decision

Exact verification-document or verification-evidence requirements are not yet approved.

Reference:

- `DD-C11 — Verification evidence schema`

No verification-evidence fields should be added merely because they might be useful.

---

## 5.2 Normal Concern Data

### Purpose

Normal-report information supports:

- concern submission;
- validation;
- priority processing;
- routing;
- administrative handling;
- Resident tracking;
- research/evaluation of approved system functions.

### Data-minimization rule

The application should not require unrelated identity, health, household, or other personal information that is not part of the approved concern-report model.

Free-text descriptions may nevertheless contain sensitive information entered by the Resident, so access must remain restricted.

---

## 5.3 Location Data

### Purpose

One-time location capture supports locating a submitted concern or confirmed SOS.

### Required captured values

When a GPS capture succeeds, the relevant model preserves:

- latitude;
- longitude;
- accuracy;
- capture time;
- optional human-readable address where available and permitted.

### Privacy boundary

HelpHub shall:

- request location only when the active interaction requires it;
- distinguish successful location capture from permission denial or location failure;
- not continuously track the Resident;
- not use background continuous tracking as part of normal operation.

Continuous Resident location tracking is explicitly outside the approved scope.

---

## 5.4 Photo Evidence

### Purpose

Optional permitted photo evidence may provide supporting context for a normal concern.

### Privacy risks

A photograph may unintentionally reveal:

- people;
- faces;
- homes;
- addresses;
- license plates;
- documents;
- children or vulnerable individuals;
- other private environmental details.

### Required controls

Evidence must use restricted/private storage.

Object-level authorization must determine who may upload/download the evidence.

A private bucket alone is not sufficient proof of access security.

Reference:

- `DD-C09 — Storage object authorization`

Approved file type and size restrictions must also be enforced.

---

## 5.5 SOS / Emergency Data

### Purpose

SOS information supports the Emergency Response Module, including:

- confirmed SOS submission;
- selected approved emergency type;
- one-time location capture;
- timestamp;
- registered-user information required by the workflow;
- automatic Critical override;
- emergency queue;
- acknowledgement;
- status tracking;
- assignment/referral where permitted.

### Sensitivity

SOS location/details are treated as high-sensitivity emergency and location information.

### Safety/privacy boundaries

HelpHub shall:

- use a brief hold or confirmation before SOS activation;
- clearly state that HelpHub does not replace official emergency services;
- avoid continuous location tracking;
- restrict emergency information to appropriately authorized users;
- preserve emergency actions and history for traceability;
- avoid claiming guaranteed dispatch or response by an external agency.

### Unresolved governance

Detailed escalation recipients, timing, retries, acknowledgement-cancellation behavior, and stop conditions remain subject to:

- `D-010 — Emergency escalation`

---

# 6. Access and Ownership Review

## 6.1 Resident

An approved Resident may require authorized access to:

- own profile;
- own verification history;
- active enabled concern taxonomy needed for submission;
- own normal reports;
- own permitted report location/evidence information;
- own report tracking/status history;
- Resident-appropriate routing/referral information;
- own SOS tracking information;
- notifications;
- published announcements.

A Resident must not be able through normal client access to:

- change the Resident's own role;
- approve or restrict accounts;
- alter algorithm configuration;
- alter protected workflow configuration;
- directly rewrite status, routing, or audit history;
- view another Resident's private reports;
- view another Resident's GPS/location data;
- view another Resident's evidence;
- view another Resident's SOS/emergency information.

---

## 6.2 Barangay Administrator

An approved Barangay Administrator may require authorized access to:

- Resident verification records;
- Resident/report information required for administration;
- concern and emergency queues;
- report lifecycle history;
- routing/assignment information;
- configuration history;
- audit evidence according to approved privileges;
- announcement management.

Administrator status does not create unrestricted access.

Administrator access remains subject to:

- least privilege;
- server-side authorization;
- Supabase RLS where applicable;
- protected API operations;
- auditability;
- privacy controls;
- additional authorization where configuration governance requires it.

Protected configuration privilege remains subject to:

- `D-015 — Protected configuration privilege`

---

# 7. Resident Visibility of Internal Routing Information

Current database structures may technically allow Residents to read routing state/history for their own reports.

The privacy and UX policy governing exactly which internal routing details or notes are Resident-visible is not yet finalized.

Reference:

- `DD-C08 — Resident routing-detail visibility`

Until approval is documented:

- internal-only notes must not automatically be exposed;
- UI design must distinguish Resident-facing status/referral information from protected internal operational detail;
- implementation must not assume every routing-history field is safe for Resident display.

---

# 8. Notifications and Lock-Screen Privacy

Push notifications are delivery attempts and must not be treated as guaranteed delivery.

Notification content should contain only enough information to alert the intended user to an event.

Notification payloads and lock-screen text must avoid unnecessary exposure of:

- full report descriptions;
- GPS coordinates;
- precise addresses;
- SOS details;
- verification information;
- sensitive identity information;
- photo-evidence details;
- protected internal notes.

Opening a notification must not bypass authentication or authorization for protected information.

FCM/device tokens must be treated as sensitive technical delivery identifiers.

Exact token schema and retention rules remain implementation-stage concerns subject to the approved privacy policy.

---

# 9. Audit and Traceability Privacy

HelpHub requires audit evidence for security-sensitive and workflow-sensitive actions.

Auditability does not justify unrestricted copying of personal information into audit records.

Audit details must contain the minimum context required to establish:

- who performed the action;
- what action occurred;
- which entity was affected;
- when the action occurred;
- required reason/evidence where applicable.

Audit records must not contain:

- passwords;
- authentication credentials;
- secrets;
- service keys;
- unnecessary complete report descriptions;
- unnecessary GPS data;
- unnecessary SOS details;
- unnecessary photo/evidence content.

Authorized access to audit evidence remains required.

---

# 10. Algorithm Evidence Privacy

Algorithm evidence is necessary for:

- deterministic reproduction;
- explanation;
- validation;
- auditability;
- administrator review;
- research evaluation.

Saved evidence may include:

- algorithm version;
- rule version;
- weight version;
- threshold/routing/deadline versions where applicable;
- raw factor values;
- normalized ratings;
- matched rules;
- score contributions;
- total score;
- override reason;
- classification evidence;
- priority;
- route;
- deadline;
- deterministic queue key.

This evidence must be linked to the appropriate report but exposed according to role and purpose.

Resident-facing explanations should not automatically expose protected administrative/internal routing information.

---

# 11. Research and Evaluation Privacy

Research/evaluation exports must use appropriate privacy controls and minimize unnecessary direct identifiers.

Before exporting production-like or study data for evaluation:

1. identify the minimum fields required for the evaluation question;
2. remove unnecessary direct identifiers;
3. restrict access to authorized study personnel/evaluators;
4. protect location, SOS, evidence, and verification information;
5. document any transformation or anonymization applied;
6. apply the approved retention/deletion policy to exported datasets;
7. avoid using operational personal data where synthetic or appropriately controlled test data can satisfy the evaluation purpose.

Final evaluator access, dataset handling, and retention must remain consistent with approved study and institutional requirements.

---

# 12. Retention, Archival, Anonymization, and Deletion

No final retention duration is approved by the current Stage 3 baseline.

The system therefore must not invent fixed periods such as 30 days, 1 year, 5 years, or permanent retention.

The following categories require an approved retention decision before controlled production deployment:

- profile/account information;
- verification records/evidence;
- active normal reports;
- closed reports;
- archived reports;
- GPS/location records;
- photo evidence;
- status history;
- routing/referral history;
- algorithm evidence;
- SOS/emergency records;
- notifications/device tokens;
- announcements;
- administrator notes;
- audit records;
- research/evaluation exports.

Relevant stakeholder decision:

- `D-013 — Data retention, anonymization, archival, and secure deletion schedule`

Relevant data-dictionary correction:

- `DD-C10 — Retention and anonymization`

Existing history-preserving structures prevent silent deletion but do not constitute a completed retention policy.

The approved policy must specify, where applicable:

- retention duration;
- archival trigger;
- anonymization trigger;
- lawful deletion conditions;
- deletion authority;
- treatment of related history/audit records;
- treatment of backups;
- research/evaluation exports;
- exception/hold requirements;
- evidence that deletion/anonymization occurred.

---

# 13. Data-Subject / User Handling

The Stage 3 source identifies data-subject handling as requiring privacy review but does not yet provide a complete approved operational procedure.

Before deployment, the project must document the approved process for applicable requests concerning:

- access to permitted personal information;
- correction of permitted profile information;
- account/verification concerns;
- questions about location or evidence processing;
- applicable retention/deletion handling;
- disputes or correction requests involving report data;
- escalation to the appropriate barangay/institutional authority.

This document does not invent legal entitlements or response deadlines that have not been approved by the project/institutional governance process.

---

# 14. Privacy Risk and Control Register

No unapproved numerical or qualitative risk-scoring scale is introduced here.

| Privacy risk | Potential impact | Current / required controls | Remaining issue |
|---|---|---|---|
| Cross-Resident data exposure | Disclosure of reports, GPS, evidence, or SOS information | Ownership checks, RLS, server authorization, least privilege | Must be tested for every protected domain |
| Excessive Administrator access | Unnecessary exposure of Resident-sensitive information | Role/permission boundary, server authorization, audit | Final privilege granularity must follow approved policy |
| Continuous location collection | Persistent tracking of Residents | One-time capture requirement; no continuous tracking | Verify implementation does not add background tracking |
| Evidence exposure | Disclosure of identifiable/sensitive photo content | Private bucket, restricted access, upload constraints | `DD-C09` object authorization still requires implementation/testing |
| SOS exposure | Disclosure of emergency identity/location | Restricted emergency access, notification minimization | Detailed escalation policy pending under `D-010` |
| Sensitive lock-screen notification | Third-party viewing of private report/SOS information | Minimal notification payload/content | Must be verified during Stage 11 |
| Audit over-collection | Permanent duplication of unnecessary private information | Minimum audit context rule | Audit payloads require implementation review |
| Internal routing disclosure | Resident sees protected internal destination/note details | Separate Resident/admin presentation | `DD-C08` policy unresolved |
| Verification-document over-collection | Collection of unnecessary identity/residency documents | Do not create evidence schema before approval | `DD-C11` unresolved |
| Indefinite retention | Unnecessary long-term storage of personal/sensitive data | Retention policy required | `D-013` / `DD-C10` unresolved |
| Research export re-identification | Evaluation dataset reveals Resident identity/location | Data minimization, access restriction, anonymization where approved | Final export procedure required |
| Client-side authorization bypass | Protected information exposed through manipulated client | FastAPI authorization, Supabase RLS, least privilege | Security testing required |
| External-referral misunderstanding | Resident assumes automatic external dispatch or data integration | Referral records are coordination only; no dispatch guarantee | External sharing process must be explicitly approved if introduced |

---

# 15. Technical Privacy Controls Required During Implementation

The following controls require implementation and objective verification:

## Authentication and authorization

- Supabase Auth for authentication foundation;
- server-side authorization for protected business operations;
- applicable Supabase RLS;
- least-privilege access;
- no trust in client-provided role/priority/routing authority.

## Location

- request location only during required interaction;
- store latitude, longitude, accuracy, and capture time when captured;
- handle permission denial/failure distinctly;
- no continuous/background Resident tracking.

## Evidence

- private/restricted storage;
- approved file type/size restrictions;
- non-predictable identifiers must not be treated as authorization;
- object-level ownership/access rules.

## Sensitive records

- restrict GPS/SOS data;
- restrict verification information;
- restrict internal notes;
- restrict audit evidence;
- role-appropriate algorithm evidence.

## Notifications

- minimize notification content;
- do not expose unnecessary protected information on lock screens;
- require authentication/authorization after notification open.

## Logging/audit

- no passwords, credentials, service keys, or secrets;
- minimum personal context necessary for traceability.

---

# 16. Privacy Verification Plan

The privacy review is not complete merely because controls are documented.

Implementation stages must produce evidence including, where applicable:

- RLS tests proving cross-Resident isolation;
- unauthorized API tests;
- Administrator privilege tests;
- GPS permission-denied tests;
- GPS unavailable/failure tests;
- verification that background continuous tracking is absent;
- private Storage upload/download authorization tests;
- evidence file-type and size tests;
- notification privacy inspection;
- SOS authorization tests;
- audit minimization review;
- internal-note visibility tests;
- routing-detail visibility tests after policy approval;
- retention/anonymization tests after policy approval;
- research-export privacy review;
- screenshots/UAT evidence for privacy-related UI behavior;
- security review and threat-review findings.

---

# 17. Approval and Decision Dependencies

The following decision-register items materially affect privacy:

| Decision | Privacy relevance | Current status |
|---|---|---|
| `D-007` Normal and emergency status transitions | Determines workflow history and who can perform sensitive transitions | Pending |
| `D-009` External referral workflow | Determines coordination/referral handling and potential disclosure boundary | Pending |
| `D-010` Emergency escalation | Determines SOS recipients, timing, retries, cancellation, and stop behavior | Pending |
| `D-013` Retention/anonymization/archival/secure deletion | Determines lifecycle of personal and sensitive data | Pending |
| `D-014` Deployment audience | Limits deployment to the approved controlled one-barangay study/evaluation release | Pending confirmation |
| `D-015` Protected configuration privilege | Determines who may alter protected policy/configuration | Pending |

Additional unresolved privacy items without a dedicated current `D-###` entry:

- `DD-C08 — Resident routing-detail visibility`
- `DD-C09 — Storage object authorization`
- `DD-C10 — Retention and anonymization`
- `DD-C11 — Verification evidence schema`

These items must not be assigned fabricated decision IDs.

---

# 18. Privacy Decisions Required Before Production Deployment

The following items must be resolved and recorded before the relevant feature reaches controlled production deployment:

- exact verification evidence required from a Resident;
- where verification evidence is stored;
- who may access verification evidence;
- verification-evidence retention/deletion;
- exact Resident-visible routing/referral fields;
- object-level report-evidence upload/download policy;
- retention durations by record type;
- archival policy;
- anonymization policy;
- lawful/authorized deletion procedure;
- data-subject/user handling procedure;
- GPS and SOS access detail beyond the established least-privilege baseline;
- emergency escalation recipients and disclosure behavior;
- notification/device-token retention;
- research/evaluation export handling;
- any external data-sharing/referral procedure introduced later.

---

# 19. Privacy Review Against Out-of-Scope Boundaries

The privacy design must preserve the approved scope.

The system must not introduce:

- continuous Resident location tracking;
- multi-barangay production data sharing;
- automatic SMS fallback containing report/SOS information;
- automatic ordinance penalties;
- replacement of official emergency services;
- claims of guaranteed external-agency response;
- unapproved long-term post-study operation.

If one of these becomes a proposed requirement, the study and privacy assessment must be formally revised before implementation.

---

# 20. Stage 3 Privacy Findings

## PIA-F01 — Location minimization is established

HelpHub uses one-time location capture for required report/SOS interactions and does not continuously track Residents.

## PIA-F02 — GPS and SOS require elevated protection

Location and emergency data are explicitly sensitive and require least privilege and protected access.

## PIA-F03 — Private Storage is necessary but insufficient

The existing private report-evidence bucket must be supplemented by object-level upload/download authorization and tested ownership rules.

Reference: `DD-C09`.

## PIA-F04 — Retention policy is unresolved

No final retention, archival, anonymization, or lawful deletion schedule has been approved.

References:

- `D-013`
- `DD-C10`

## PIA-F05 — Verification evidence must not be invented

The exact verification evidence schema remains intentionally absent pending privacy and stakeholder approval.

Reference: `DD-C11`.

## PIA-F06 — Resident routing-detail visibility remains unresolved

The project must determine which routing/referral fields and notes are appropriate for Resident display.

Reference: `DD-C08`.

## PIA-F07 — Notification privacy requires implementation verification

FCM notification attempts must minimize sensitive content and must not bypass protected access after opening.

## PIA-F08 — Auditability must use data minimization

Audit events must preserve traceability without unnecessarily duplicating private report, GPS, SOS, or evidence content.

## PIA-F09 — Research/evaluation exports require separate handling controls

Study datasets must minimize unnecessary identifiers and follow the approved retention/privacy process.

---

# 21. Stage 3 Privacy Gate Checklist

The Privacy Impact Review is ready for Stage 3 gate review when:

- [ ] personal and sensitive data categories are documented;
- [ ] Resident/Admin access boundaries are documented;
- [ ] one-time GPS/no-continuous-tracking boundary is documented;
- [ ] report evidence privacy requirements are documented;
- [ ] SOS privacy requirements are documented;
- [ ] notification privacy requirements are documented;
- [ ] audit minimization rules are documented;
- [ ] algorithm-evidence access concerns are documented;
- [ ] research/evaluation privacy is documented;
- [ ] `DD-C08` is recorded as unresolved;
- [ ] `DD-C09` is recorded as requiring implementation/testing;
- [ ] `DD-C10` is recorded as unresolved;
- [ ] `DD-C11` is recorded as unresolved;
- [ ] `D-013` retention governance is documented;
- [ ] `D-010` SOS escalation dependency is documented;
- [ ] `D-015` protected configuration privilege dependency is documented;
- [ ] no unapproved retention period has been invented;
- [ ] no unapproved verification-document requirement has been invented;
- [ ] no continuous location tracking has been introduced;
- [ ] no external responder integration/dispatch guarantee has been invented;
- [ ] technical privacy-verification evidence is assigned to future implementation/testing stages.

---

# 22. Required Follow-Up

This Stage 3 review establishes privacy requirements and unresolved decisions.

It does not close stakeholder-dependent items.

Before the applicable implementation or deployment gate, unresolved decisions must be:

1. presented to the correct approving stakeholder/institutional authority;
2. recorded with decision, approver, date, and evidence;
3. reflected in the decision register;
4. reflected in requirements/data/schema/configuration where applicable;
5. implemented through protected operations;
6. objectively tested;
7. reflected in this Privacy Impact Review and the Requirements Traceability Matrix.

No implementation convenience should be treated as stakeholder approval.
