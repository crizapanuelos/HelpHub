# HelpHub Role-Permission Matrix

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — role and permission baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related stakeholder record: `docs/requirements/STAKEHOLDER_VALIDATION_NOTES.md`

## 1. Purpose

This document defines the HelpHub role and permission baseline.

HelpHub has two primary application roles:

1. Resident.
2. Barangay Administrator.

Barangay personnel, committees, offices, responders, utilities, and external agencies may be recorded as assignment or referral destinations where the approved workflow permits, but they are not automatically HelpHub authenticated roles.

Configuration-editing authority is treated as a protected permission granted only to specifically authorized Barangay Administrators. It is not introduced as a third primary application role.

## 2. Permission Terms

| Term | Meaning |
|---|---|
| Allowed | Required by the approved study and permitted when authentication and applicable record ownership/access conditions are satisfied |
| Denied | The role shall not perform the capability through normal authorized application access |
| Conditional | The capability exists, but detailed authorization depends on an approved workflow or governance decision |
| Own only | Access is restricted to records belonging to or otherwise explicitly authorized for the resident |
| Authorized admin only | Access requires an authenticated Barangay Administrator and any additional approved permission check |
| Configuration-authorized admin only | Access requires a Barangay Administrator specifically granted protected configuration authority |

## 3. Authorization Principles

1. The Flutter client shall not be the sole authorization authority.
2. Hiding or disabling an interface control does not replace server-side authorization.
3. Supabase Row Level Security shall protect applicable direct client data access.
4. FastAPI shall verify authorization for protected business operations.
5. Residents shall not gain administrator permissions by modifying local application state, request payloads, route parameters, or stored client values.
6. Record identifiers shall not by themselves grant access to protected records.
7. Protected GPS, SOS, identity, evidence, audit, and configuration information shall follow least-privilege access.
8. Approval-dependent permissions shall not be converted into permanent implementation privileges until the relevant stakeholder decision is recorded.

## 4. Account and Identity Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| Register a resident account | Allowed | Not required as an admin workflow | Authentication/API validation |
| Log in | Allowed | Allowed | Authentication |
| Log out | Allowed | Allowed | Authentication/session handling |
| View own permitted profile | Allowed — own only | Conditional for administrative need | RLS + API authorization where applicable |
| Edit own permitted profile fields | Allowed — own only | Conditional | Protected role/verification fields excluded |
| Change own role to administrator | Denied | Denied through ordinary profile editing | Server/database authority only |
| Submit resident verification information | Conditional | Denied as resident-submission action | Final required verification fields pending approval |
| Review resident verification | Denied | Allowed — authorized admin only | Server-side authorization |
| Approve/manage resident verification | Denied | Conditional | Detailed decisions require approved workflow |
| Restrict resident account | Denied | Conditional | Governance policy required |
| Read unrelated resident identity data | Denied | Conditional and least-privilege only | Administrative purpose must be authorized |

## 5. Normal Concern Reporting Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| Create normal concern report | Allowed when account is authorized | Denied as resident-submission action unless a later approved requirement says otherwise | API authorization |
| Select initial concern type | Allowed from active approved taxonomy | Not a resident-submission action | Taxonomy remains versioned |
| Enter concern description | Allowed | Not a resident-submission action | Input validation |
| Enter resident-declared urgency | Allowed | Not a resident-submission action | Input validation |
| Enter affected-population information | Allowed | Not a resident-submission action | Input validation |
| Enter vulnerable-group indicator | Allowed | Not a resident-submission action | Input validation |
| Capture report location when required | Allowed with permission | Not required for resident submission | No continuous tracking |
| Attach optional permitted photo evidence | Allowed | Not required for resident submission | Private storage restrictions |
| View own submitted reports | Allowed — own only | Allowed for authorized administrative review | RLS/API |
| View another resident's protected reports | Denied | Allowed only when administrative access is authorized | RLS/API |
| Silently delete a report | Denied | Denied | Use approved close/archive workflow |

## 6. Concern Classification and Priority Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| Choose initial concern type | Allowed | Not applicable to normal resident submission | Initial selection is preserved |
| Directly set final priority score | Denied | Denied through normal report editing | FastAPI algorithm authority |
| Directly choose Low/Medium/High/Critical result | Denied | Denied through ordinary report editing | Algorithm/configuration authority |
| Directly set queue position | Denied | Denied | Deterministic server-side ordering |
| Directly set routing result | Denied | Denied through ordinary report editing | Active approved routing configuration |
| Directly set algorithm deadline | Denied | Denied through ordinary report editing | Active deadline configuration |
| View own permitted final report status/priority information | Allowed where exposed by approved resident UI | Allowed | Presentation must respect privacy/access rules |
| Review algorithm explanation evidence | Denied unless a resident-facing subset is explicitly approved | Allowed — authorized admin only | Detailed evidence may contain protected information |
| Review system classification recommendation | Denied unless explicitly part of resident-facing design | Allowed | Admin review supported |
| Perform approved classification override/correction | Denied | Conditional | Procedure, reason requirement, and permissions require approval |
| Modify historical algorithm evidence | Denied | Denied through ordinary workflow | Historical reproducibility required |

## 7. Resident Tracking Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| View current status of own report | Allowed — own only | Allowed | RLS/API |
| View permitted status history of own report | Allowed — own only | Allowed | Internal-only information remains protected |
| View internal administrator notes | Denied by default | Allowed when authorized | Resident exposure requires explicit approved requirement |
| View another resident's status history | Denied | Allowed only for authorized administrative purpose | RLS/API |
| Receive permitted report notifications | Allowed | Not a resident-notification capability | Delivery is not guaranteed |

## 8. Administrator Report-Management Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| Open administrator dashboard | Denied | Allowed | Role authorization |
| View administrator priority queues | Denied | Allowed | Role authorization |
| View authorized report detail | Own resident view only | Allowed | Different resident/admin data projections may apply |
| Assign report internally | Denied | Conditional | Approved handler/workflow required |
| Record external referral | Denied | Conditional | Referral is coordination, not guaranteed dispatch |
| Perform report status transition | Denied | Conditional | Final transition matrix requires stakeholder approval |
| Add internal administrative note | Denied | Allowed | Must remain protected from resident by default |
| Close report | Denied | Conditional | Approved workflow required |
| Archive report | Denied | Conditional | Approved workflow required |
| Permanently/silently delete report through normal workflow | Denied | Denied | Traceability must remain |

## 9. Emergency SOS Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| Open SOS interface | Allowed | Not an administrative action |
| Confirm/hold to activate SOS | Allowed | Not an administrative action |
| Select approved emergency type | Allowed | Not an administrative action |
| Submit one-time SOS GPS location | Allowed with location permission | Not a resident-submission action |
| Cause confirmed SOS Critical override | Allowed only through valid confirmed SOS workflow | Cannot manually fake a confirmed resident SOS through ordinary admin editing | Server-side emergency processing |
| View own permitted SOS tracking information | Allowed — own only | Allowed for authorized emergency handling | Sensitive access |
| View emergency queue | Denied | Allowed — authorized admin only | Role authorization |
| View protected SOS identity/location details | Own submitted information where appropriate | Conditional and least-privilege | Sensitive GPS/SOS data |
| Acknowledge emergency | Denied | Conditional | Approved emergency workflow required |
| Update emergency status | Denied | Conditional | Approved transitions required |
| Assign/refer emergency | Denied | Conditional | Approved workflow required |
| Trigger configured escalation manually where supported | Denied | Conditional | Final escalation design requires approval |
| Mark emergency as false alarm | Denied | Conditional | Authorized admin + mandatory reason |
| Delete false-alarm record/history | Denied | Denied | Record/history/audit must remain |

## 10. Announcements and Notifications Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| View authorized barangay announcements | Allowed | Allowed | Access rules as applicable |
| Publish announcement | Denied | Allowed — authorized admin only | Server-side authorization |
| Modify permitted announcement | Denied | Conditional | Detailed publishing workflow may be refined |
| Receive resident-targeted notification attempts | Allowed | Not applicable as resident recipient | FCM delivery not guaranteed |
| Expose unnecessary SOS/GPS data in notification content | Denied | Denied | Notification privacy requirement |

## 11. Audit Permissions

| Capability | Resident | Barangay Administrator | Enforcement / note |
|---|---|---|---|
| View system-wide audit records | Denied | Conditional — appropriately authorized admin only | Least privilege |
| View protected configuration audit records | Denied | Conditional | Governance authorization |
| Create status audit event directly from client | Denied | Denied | Generated by protected workflow |
| Create assignment/referral audit event directly from client | Denied | Denied | Generated by protected workflow |
| Create false-alarm audit event without false-alarm action | Denied | Denied | Generated by protected workflow |
| Modify/delete audit evidence through ordinary application workflow | Denied | Denied | Audit integrity requirement |

## 12. Protected Configuration Permissions

Protected configuration includes, as applicable:

- concern taxonomy;
- classification/rule sets;
- factor definitions;
- normalized rating anchors;
- factor weights;
- numerical priority thresholds;
- routing configuration;
- deadline configuration;
- non-SOS Critical rules;
- emergency escalation configuration;
- configuration activation/version metadata.

| Capability | Resident | Ordinary Barangay Administrator | Configuration-authorized Barangay Administrator |
|---|---|---|---|
| View public/resident-facing active taxonomy subset | Allowed where required for reporting | Allowed | Allowed |
| View protected configuration detail | Denied | Conditional | Allowed when specifically authorized |
| Propose configuration change | Denied | Conditional | Conditional according to approved governance |
| Approve configuration change | Denied | Denied unless explicitly authorized | Conditional according to approved governance |
| Activate configuration version | Denied | Denied unless explicitly authorized | Conditional according to approved governance |
| Edit an already-used historical configuration version in place | Denied | Denied | Denied |
| Create a new version for an approved material change | Denied | Denied unless explicitly authorized | Allowed according to approved governance |
| Bypass required approval evidence | Denied | Denied | Denied |
| Remove historical version references from processed reports | Denied | Denied | Denied |

The exact configuration-governance permissions remain approval-dependent. The application shall not create a new primary role merely to represent this privilege unless the approved study is formally revised.

## 13. Assignment and Referral Destinations

Assignment or referral destinations are not treated as authenticated HelpHub roles unless a later formally approved integration introduces such a role.

Examples may include:

- internal barangay personnel;
- barangay committees;
- barangay health personnel;
- peace-and-order personnel;
- city offices;
- utilities;
- police, fire, medical, disaster-response, or other external agencies.

The final destination list is approval-dependent.

Recording a destination does not grant that destination:

- a HelpHub account;
- dashboard access;
- report access;
- GPS access;
- evidence access;
- status-update authority; or
- guaranteed dispatch/integration.

## 14. Data-Domain Access Summary

| Data domain | Resident | Barangay Administrator |
|---|---|---|
| Own basic profile | Own only | Conditional administrative access |
| Other resident profiles | Denied | Conditional least-privilege access |
| Own verification submission | Own permitted view | Authorized review |
| Other residents' verification data | Denied | Authorized review only |
| Own reports | Own only | Authorized administrative access |
| Other residents' reports | Denied | Authorized administrative access |
| Own permitted status history | Own only | Authorized administrative access |
| Internal notes | Denied | Authorized administrative access |
| Own permitted evidence | Own-related access where approved | Authorized report access |
| Other residents' evidence | Denied | Authorized report access |
| Own permitted SOS information | Own only | Authorized emergency access |
| Other residents' protected SOS/GPS data | Denied | Authorized emergency access only |
| Announcements | Authorized published announcements | Authorized published/admin functions |
| Audit records | Denied | Appropriately authorized admin only |
| Protected configuration | Denied | Conditional; configuration privilege may be separately required |

## 15. Required Enforcement Layers

### 15.1 Flutter

Flutter shall:

- present only controls appropriate to the authenticated user's permitted workflow;
- handle permission-denied responses safely;
- avoid using hidden controls as the security boundary;
- avoid trusting editable client state for protected authorization.

### 15.2 FastAPI

FastAPI shall enforce protected business authorization for operations such as:

- protected report processing;
- algorithm execution;
- administrator report actions;
- status transitions;
- assignment/referral;
- emergency acknowledgement;
- false-alarm handling;
- protected configuration operations;
- other sensitive writes routed through the API.

### 15.3 Supabase Row Level Security

RLS shall enforce applicable direct client data-isolation rules, especially:

- resident own-data access;
- resident own-report access;
- protected identity access;
- evidence metadata/access domains where applicable;
- other client-accessible relational data.

RLS design shall follow the actual schema and shall be tested explicitly in the applicable later stage.

### 15.4 Supabase Storage

Private storage policies shall prevent public unrestricted access to report evidence.

### 15.5 Audit

Sensitive administrator actions shall generate required audit evidence from trusted protected workflows rather than relying on user-supplied audit entries.

## 16. Approval-Dependent Permission Decisions

The following remain pending stakeholder validation:

1. Exact resident verification decision states.
2. Account restriction authority and procedure.
3. Detailed classification correction/override authority.
4. Final internal handler/assignment permissions.
5. External referral procedure.
6. Final normal-report status-transition permissions.
7. Final emergency status-transition permissions.
8. Emergency acknowledgement authority if further restricted.
9. False-alarm authority.
10. Emergency escalation authority and behavior.
11. Audit-viewing privilege scope.
12. Protected configuration viewing, proposal, approval, and activation privileges.
13. Any reopening, cancellation, rejection, duplicate, or correction workflow not already established by the approved study.

These decisions shall be reconciled with `STAKEHOLDER_VALIDATION_NOTES.md` before dependent implementation is frozen.

## 17. Security Verification Requirements

Later authorization testing shall include at minimum:

1. Resident attempting administrator dashboard access.
2. Resident attempting another resident's report access.
3. Resident attempting another resident's evidence access.
4. Resident attempting protected SOS/GPS access.
5. Resident attempting administrator status updates.
6. Resident attempting assignment/referral actions.
7. Resident attempting protected configuration changes.
8. Ordinary administrator attempting configuration operations without required configuration privilege.
9. Expired or invalid session attempting protected operations.
10. Modified client role value attempting privilege escalation.
11. Direct API request attempting to bypass hidden/disabled UI controls.
12. Database/RLS tests proving resident isolation.
13. Authorized positive-path tests proving legitimate access still works.

## 18. Role Baseline Rule

HelpHub currently has exactly two primary application roles:

- Resident.
- Barangay Administrator.

Do not add a third primary role merely because a handler, responder, committee, external agency, or specialized administrator permission exists.

If stakeholder validation later requires a new authenticated role, that change must be treated as a material scope and architecture decision and reconciled with the approved study before implementation.

Approval-dependent permissions in this document shall not be converted into permanent authorization logic until the required decision evidence is recorded.
