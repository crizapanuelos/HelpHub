# HelpHub Normal and Emergency Status-Transition Tables

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — proposed workflow baseline
- Approval status: NOT YET STAKEHOLDER APPROVED
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related stakeholder record: `docs/requirements/STAKEHOLDER_VALIDATION_NOTES.md`

## 1. Purpose

This document records the normal-concern and emergency status-transition baseline currently proposed by the approved revised study.

The sequences in this document are not final barangay workflow policy.

Final status labels, transition permissions, reopening behavior, cancellation behavior, rejection/duplicate handling, and emergency escalation behavior require recorded stakeholder approval before dependent database constraints or authorization logic are frozen.

## 2. Workflow Rules Established by the Study

The following rules apply regardless of the final approved status labels:

1. Every successful status change shall create a status-history record.
2. Every successful status change shall create required audit evidence.
3. Reports shall not be silently deleted.
4. Closed or archived records shall preserve required traceability.
5. Emergency false-alarm handling shall require a reason.
6. Emergency referral shall record the coordination/contact action.
7. HelpHub shall not represent an external referral as guaranteed dispatch or response.
8. Unauthorized or invalid status transitions shall be rejected.
9. The Flutter client shall not be the sole authority for protected status changes.
10. Final transition permissions shall be enforced through the appropriate protected backend/database authorization design.

## 3. Status Classification Terms

| Term | Meaning |
|---|---|
| Study-proposed | Appears in the approved revised study as part of the proposed workflow |
| Final approved | Stakeholder approval evidence has been recorded and the workflow version has been approved for implementation |
| Terminal candidate | A state that ends the active handling path in the proposed sequence but may still transition to Closed or Archived |
| Historical state | A state retained for traceability rather than silently deleting the report |
| Undefined | Behavior not established by the approved study and therefore not to be invented during implementation |

## 4. Normal Concern — Study-Proposed Status Sequence

The approved revised study currently proposes:

`Submitted -> Acknowledged/Under Review -> Assigned -> In Progress -> Resolved -> Closed -> Archived`

The wording `Acknowledged/Under Review` is preserved exactly as a study-proposed status expression. Stage 3 shall not silently split it into two independent required states until workflow approval clarifies the intended final labels.

### 4.1 Normal Concern Status Definitions

| Proposed status | Intended meaning at requirements level | Approval status |
|---|---|---|
| Submitted | A normal concern has been successfully accepted into the HelpHub reporting workflow. | Study-proposed |
| Acknowledged/Under Review | The concern has entered administrator acknowledgement/review according to the final approved workflow. | Study-proposed; final label requires approval |
| Assigned | Responsibility has been assigned according to the approved internal assignment workflow. | Study-proposed; assignment rules require approval |
| In Progress | Authorized handling activity is underway. | Study-proposed |
| Resolved | The concern has reached the approved resolution condition but has not necessarily completed final closure/archival. | Study-proposed; resolution criteria require approval |
| Closed | Active workflow handling has been formally closed according to approved procedure. | Study-proposed; closure rules require approval |
| Archived | The record is retained as historical information according to the approved retention/archive policy. | Study-proposed; retention policy requires approval |

### 4.2 Normal Concern Proposed Transition Table

| Transition ID | From | To | Study basis | Permission status | Required traceability |
|---|---|---|---|---|---|
| NTR-001 | New report creation | Submitted | Successful normal-report submission | System-controlled creation | Report creation evidence as applicable |
| NTR-002 | Submitted | Acknowledged/Under Review | Proposed study sequence | Approval-dependent | Status history + audit |
| NTR-003 | Acknowledged/Under Review | Assigned | Proposed study sequence | Approval-dependent | Status history + audit; assignment traceability |
| NTR-004 | Assigned | In Progress | Proposed study sequence | Approval-dependent | Status history + audit |
| NTR-005 | In Progress | Resolved | Proposed study sequence | Approval-dependent | Status history + audit |
| NTR-006 | Resolved | Closed | Proposed study sequence | Approval-dependent | Status history + audit |
| NTR-007 | Closed | Archived | Proposed study sequence | Approval-dependent | Status history + audit; retention/archive rules apply |

These transitions are candidates derived directly from the proposed sequence. They are not yet final database transition constraints.

## 5. Normal Concern — Undefined or Pending Workflow Decisions

The approved study does not currently finalize the following behavior:

| Decision | Current treatment |
|---|---|
| Split `Acknowledged` and `Under Review` into separate states | Undefined — stakeholder decision required |
| Skip directly from Submitted to Assigned | Undefined — do not permit by assumption |
| Move from Assigned back to review | Undefined |
| Move from In Progress back to Assigned | Undefined |
| Reopen a Resolved report | Undefined |
| Reopen a Closed report | Undefined |
| Resident cancellation | Undefined |
| Administrator rejection | Undefined |
| Duplicate-report status/handling | Undefined |
| Incorrect-category correction state | Undefined |
| Report withdrawal | Undefined |
| Automatic transition after deadline expiry | Undefined |
| Automatic closure after resolution | Undefined |
| Time period before archival | Undefined — retention policy required |
| Actor permitted to perform each transition | Approval-dependent |

Until approved, implementation shall not invent these transitions merely because they are common in other systems.

## 6. Emergency — Study-Proposed Status Sequence

The approved revised study currently proposes:

`Submitted-Critical -> Acknowledged -> Responding -> Resolved | Referred | False Alarm -> Closed -> Archived`

A confirmed SOS receives Critical priority and enters the emergency queue. The status workflow remains separate from the priority result: `Critical` is the emergency priority override, while the emergency status records workflow progress.

### 6.1 Emergency Status Definitions

| Proposed status | Intended meaning at requirements level | Approval status |
|---|---|---|
| Submitted-Critical | A confirmed SOS/emergency report has been successfully created and receives the required Critical override. | Study-proposed |
| Acknowledged | An authorized administrator has acknowledged the emergency according to the approved workflow. | Study-proposed; detailed authority requires approval |
| Responding | Barangay-level response/coordination activity is recorded as underway. | Study-proposed |
| Resolved | The emergency reaches the approved resolved condition. | Study-proposed; resolution criteria require approval |
| Referred | An authorized administrator records an approved external or other referral/coordination action. | Study-proposed; referral procedure requires approval |
| False Alarm | An authorized administrator records the case as a false alarm with a mandatory reason. | Study-proposed; authority requires approval |
| Closed | Active emergency handling has been formally closed according to approved procedure. | Study-proposed |
| Archived | The emergency record is retained according to approved retention/archive rules. | Study-proposed; retention policy requires approval |

### 6.2 Emergency Proposed Transition Table

| Transition ID | From | To | Study basis | Permission status | Required traceability |
|---|---|---|---|---|---|
| ETR-001 | Confirmed SOS creation | Submitted-Critical | Confirmed SOS receives Critical override | System-controlled creation | Emergency record + override evidence |
| ETR-002 | Submitted-Critical | Acknowledged | Proposed study sequence | Approval-dependent | Status history + audit + acknowledgement evidence |
| ETR-003 | Acknowledged | Responding | Proposed study sequence | Approval-dependent | Status history + audit |
| ETR-004 | Responding | Resolved | Proposed study branch | Approval-dependent | Status history + audit |
| ETR-005 | Responding | Referred | Proposed study branch | Approval-dependent | Status history + audit + referral/contact record |
| ETR-006 | Responding | False Alarm | Proposed study branch | Approval-dependent | Status history + audit + mandatory false-alarm reason |
| ETR-007 | Resolved | Closed | Proposed study sequence | Approval-dependent | Status history + audit |
| ETR-008 | Referred | Closed | Proposed study sequence | Approval-dependent | Status history + audit |
| ETR-009 | False Alarm | Closed | Proposed study sequence | Approval-dependent | Status history + audit |
| ETR-010 | Closed | Archived | Proposed study sequence | Approval-dependent | Status history + audit; retention/archive rules apply |

These transitions are requirements candidates based on the proposed workflow and shall not be treated as final constraints until approved.

## 7. Emergency — Undefined or Pending Workflow Decisions

| Decision | Current treatment |
|---|---|
| Whether acknowledgement can be undone | Undefined |
| Whether Responding can return to Acknowledged | Undefined |
| Whether Referred may return to Responding | Undefined |
| Whether a referred emergency may later become Resolved before closure | Undefined |
| Whether False Alarm may be corrected/reopened | Undefined |
| Whether Closed emergencies may be reopened | Undefined |
| Who may acknowledge an emergency | Approval-dependent |
| Who may mark Responding | Approval-dependent |
| Who may mark Resolved | Approval-dependent |
| Who may record Referred | Approval-dependent |
| Who may mark False Alarm | Approval-dependent |
| Emergency escalation timing | Approval-dependent |
| Escalation recipients | Approval-dependent |
| Escalation retry count | Approval-dependent |
| Escalation stop condition | Approval-dependent |
| Whether acknowledgement cancels escalation | Approval-dependent |
| Automatic state changes caused by escalation | Undefined — do not invent |
| Archival timing | Retention-policy approval required |

## 8. False-Alarm Control

A false alarm shall not result in silent deletion.

At minimum, the approved study requires:

1. the emergency record remains stored;
2. a false-alarm reason is required;
3. the status change is retained in status history;
4. the action is represented in audit evidence.

The final actor permission and any required reason categories remain approval-dependent.

## 9. Referral Control

A `Referred` state or referral action means HelpHub records barangay coordination/contact activity.

It shall not mean:

- an external agency has a HelpHub account;
- an external agency has accepted the case;
- official dispatch occurred;
- an external response is guaranteed; or
- HelpHub replaces official emergency services.

The final referral destinations and procedure remain approval-dependent.

## 10. Status History Requirements

Each successful transition shall preserve enough information for complete traceability.

The later database/API design shall support, at minimum where applicable:

- report identifier;
- previous status;
- new status;
- transition timestamp;
- trusted actor/user identifier for an administrator action;
- transition reason where required;
- false-alarm reason when applicable;
- referral/coordination reference where applicable;
- relevant workflow/configuration version where required by the approved design.

Exact database columns are deferred to the schema/data-dictionary stage and shall not be invented here.

## 11. Audit Requirements

Status-history records and audit events serve related but distinct purposes.

Status history records the lifecycle of the report.

Audit evidence records the security/workflow action needed to establish who or what performed a protected operation and when.

A protected status change shall not depend on the client manually manufacturing trusted audit evidence.

## 12. Authorization Requirements

1. Residents shall not perform administrator-only normal-report status transitions.
2. Residents shall not acknowledge or administratively change emergency states.
3. Barangay Administrator permissions remain subject to the final workflow-permission decision.
4. Hiding a status-change control in Flutter is not sufficient authorization.
5. FastAPI shall enforce protected workflow rules for operations routed through the API.
6. Applicable Supabase RLS/database controls shall protect direct data access.
7. Invalid transition attempts shall not modify the authoritative report state.
8. Unauthorized transition attempts shall not create false successful history records.

## 13. Concurrency and Failure Requirements

Later implementation and testing shall verify:

1. two administrators attempting the same sensitive transition concurrently;
2. repeated status-update requests;
3. network failure before a protected write reaches the server;
4. network failure after the authoritative write succeeds but before the client receives confirmation;
5. timeout behavior;
6. expired-session attempts;
7. unauthorized transition attempts;
8. invalid from-state/to-state combinations;
9. failure to create required history/audit evidence;
10. emergency acknowledgement races.

A user interface shall not falsely report success when the authoritative status update failed.

## 14. Transition-Test Baseline

For each final approved transition, later tests shall include:

- valid authorized transition;
- invalid source state;
- invalid destination state;
- unauthorized resident attempt;
- unauthorized administrator attempt where permission is restricted;
- expired-session attempt;
- repeated request;
- concurrent request where relevant;
- history creation;
- audit creation;
- mandatory-reason validation where applicable;
- database/RLS/API enforcement where applicable.

## 15. Stakeholder Validation Questions

Before these proposed sequences become final workflow versions, confirm:

1. Are the normal-report status names correct?
2. Is `Acknowledged/Under Review` one state, two states, or alternative wording?
3. Are any normal states missing?
4. Are any proposed normal transitions invalid?
5. Is reopening permitted?
6. Is resident cancellation permitted?
7. How are rejected, duplicate, mistaken, or withdrawn reports handled?
8. Which administrator permission may perform each normal transition?
9. Are the emergency status names correct?
10. May a referred emergency later return to responding or become resolved?
11. May a false alarm be corrected?
12. Who may acknowledge, respond, resolve, refer, or mark a false alarm?
13. What reason fields are mandatory?
14. What transition, if any, occurs when emergency escalation fires?
15. What acknowledgement or closure action stops escalation?
16. When may Closed records become Archived?
17. What retention rules apply after archival?

Answers shall be recorded in `STAKEHOLDER_VALIDATION_NOTES.md`.

## 16. Workflow Versioning Rule

The final approved workflow shall be versioned if workflow definitions are represented as configurable policy.

A material workflow change shall not silently rewrite the historical meaning of earlier report actions.

Where historical reproducibility requires it, processed records shall retain sufficient workflow/version context to explain the status path used at that time.

## 17. Stage 3 Workflow Gate

The sequences in this document remain a study-proposed requirements baseline.

They shall not be treated as final database constraints or permanent authorization rules until the required stakeholder approval evidence is recorded.

If stakeholder validation changes a status name, transition, permission, reason requirement, or escalation behavior, this document, the role-permission matrix, user stories, functional requirements, diagrams, data dictionary, RTM, and dependent implementation design shall be reviewed before Stage 3 can pass.
