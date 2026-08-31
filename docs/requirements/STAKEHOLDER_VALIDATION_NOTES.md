# HelpHub Stakeholder Validation Notes

## Document Status

- Roadmap stage: Stage 3 — Requirements Baseline and Diagrams
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — stakeholder validation in progress
- Approval status: NOT YET APPROVED
- Rule: A pending item must not be treated as an approved barangay policy or activated algorithm configuration without recorded approval evidence.

## 1. Purpose

This document records stakeholder validation, source reconciliation, and approval-sensitive decisions for HelpHub.

It separates:

1. requirements already established by the approved revised study;
2. provisional configuration or workflow values that still require approval;
3. contradictions or older decisions that require reconciliation;
4. actual stakeholder decisions and their evidence when obtained.

No blank approval field or proposed value is evidence of approval.

## 2. Sources of Truth

Stage 3 decisions must be checked against the following sources:

1. Approved revised HelpHub study.
2. Updated HelpHub start-to-finish development roadmap.
3. HelpHub Study Analysis and Initial Decision Register.
4. Current merged repository, migrations, tests, and documentation.
5. Recorded barangay stakeholder and adviser/professor decisions.

When sources conflict, the contradiction must be recorded and resolved before dependent database, algorithm, workflow, or security design is frozen.

## 3. Approved Study Baseline

The following are treated as current study-level requirements, not as invented stakeholder configuration values:

| Area | Current study baseline |
|---|---|
| Deployment scope | One selected barangay |
| Primary application roles | Resident and Barangay Administrator |
| Resident reporting | Registered residents submit structured concern reports and track their own reports |
| Normal report inputs | Concern type, description, location when required, resident-declared urgency, affected population, vulnerable-group indicator, optional photo evidence, and timestamps |
| Concern classification responsibility | Resident selects the initial concern type; approved rules validate or recommend a type; administrator review remains available |
| Priority level names | Low, Medium, High, Critical |
| Numerical priority thresholds | Configurable; not final until stakeholder-approved and versioned |
| Normal-report scoring | Deterministic weighted scoring using approved factors, normalized ratings, weights, and thresholds |
| Queue ordering | Override rank descending, priority score descending, response deadline ascending, submission time ascending, report ID ascending |
| SOS behavior | Confirmed SOS receives an automatic Critical override and enters the emergency queue |
| Non-SOS Critical override | Only an approved and testable life-threatening rule may automatically apply the override |
| Location privacy | One-time location capture when required; no continuous resident tracking |
| Emergency limitation | HelpHub does not replace police, fire, medical, disaster-response, or national emergency services |
| External agencies | Recorded as assignment/referral destinations unless formal technical and operational integration exists |
| Status traceability | Every status change creates status-history and audit evidence |
| Report deletion | Reports are closed or archived rather than silently deleted |
| Configuration history | Configuration used by processed reports must remain reproducible and must not be changed in place |
| Out of scope | Assistance requests, multi-barangay deployment, full offline operation, automatic SMS fallback, automatic ordinance penalties/enforcement, guaranteed external dispatch, and long-term post-study operations |

## 4. Source-Reconciliation Notes

### SR-001 — Priority-level decision-register entry

The initial decision register records D-001 as a choice between four and five priority levels.

The approved revised study now consistently defines four priority level names:

- Low
- Medium
- High
- Critical

The numerical score thresholds remain configurable and require stakeholder approval.

**Current Stage 3 treatment:** Preserve the four study-approved names. Do not invent or activate numerical threshold ranges. Update or close the older D-001 record only after the team records the reconciliation evidence.

**Status:** RECONCILIATION REQUIRED

### SR-002 — Classification-responsibility decision-register entry

The initial decision register records D-002 as requiring approval of classification responsibility.

The approved revised study states that the resident selects the initial concern type, the rule-based component validates or recommends another type, and administrator review is available.

**Current Stage 3 treatment:** Use this as the requirements baseline. Barangay validation is still required for any detailed override permission, correction procedure, or workflow-specific implementation rule not established by the study.

**Status:** BASELINE ESTABLISHED; DETAILED WORKFLOW VALIDATION PENDING

## 5. Stakeholder Validation Session Log

No Stage 3 stakeholder validation session is recorded in this repository yet.

When a validation activity occurs, add one row per session.

| Session ID | Date | Stakeholder role | Method | Topics reviewed | Evidence reference | Result |
|---|---|---|---|---|---|---|
| None recorded | None recorded | None recorded | None recorded | None recorded | None recorded | Pending |

Do not store unnecessary personal information in this document. Prefer stakeholder roles or generic identifiers unless an approved evidence process requires otherwise.

## 6. Approval-Sensitive Decision Register

The following items must remain pending until supported by recorded approval evidence.

| ID | Decision / validation topic | Current baseline | Required approver | Approval evidence | Status | Blocks |
|---|---|---|---|---|---|---|
| D-001 | Priority model | Four names are established by the revised study; numerical thresholds remain configurable | Adviser/professor + barangay where policy confirmation is required | Not yet recorded | Source reconciliation required | Final threshold configuration |
| D-002 | Concern classification responsibility | Resident selects; system validates/recommends; administrator review available | Barangay workflow owner for detailed override procedure | Not yet recorded | Partial baseline; detailed validation pending | Override permissions and correction workflow |
| D-003 | Final concern taxonomy and handlers/referrals | Study tables are provisional starting points | Barangay | Not yet recorded | Pending | Seed/configuration data |
| D-004 | Factor definitions, rating anchors, and weights | Must be observable, approved, and versioned | Barangay + adviser/professor | Not yet recorded | Pending | Algorithm v1 |
| D-005 | Numerical priority thresholds | Low/Medium/High/Critical names fixed; ranges not approved | Barangay + adviser/professor | Not yet recorded | Pending | Algorithm v1 |
| D-006 | Acknowledgement and response deadlines | Deadline assignment required; durations not approved | Barangay | Not yet recorded | Pending | Queue deadlines and escalation |
| D-007 | Normal and emergency status transitions | Proposed workflows exist but detailed transitions/permissions require approval | Barangay | Not yet recorded | Pending | Database constraints and UI workflow |
| D-008 | Non-SOS life-threatening Critical rules | Only approved structured/testable rules may auto-override | Barangay + adviser/professor | Not yet recorded | Pending | Algorithm v1 |
| D-009 | External referral workflow | Record coordination/referral; do not claim guaranteed dispatch | Barangay | Not yet recorded | Pending | Administrator referral workflow |
| D-010 | Emergency escalation | Recipients, timing, retries, acknowledgement cancellation, and stop rules require approval | Barangay | Not yet recorded | Pending | SOS escalation |
| D-011 | ISO/IEC 25010:2023 evaluation terminology and selected characteristics | Study currently identifies Functional Suitability, Performance Efficiency, Interaction Capability, Reliability, and Security | Adviser/professor | Not yet recorded | Pending validation | Final evaluation instrument |
| D-012 | Algorithm-validation acceptance criteria | Must be defined before final validation results are collected | Adviser/professor + qualified evaluators as approved | Not yet recorded | Pending | Final algorithm validation |
| D-013 | Data retention, anonymization, archival, and secure deletion schedule | Retention must follow approved institutional/stakeholder policy | Barangay + adviser/professor | Not yet recorded | Pending | Deployment/privacy design |
| D-014 | Deployment audience | Controlled one-barangay study/evaluation release | Adviser/professor + barangay | Not yet recorded | Pending confirmation | Production/evaluation release |
| D-015 | Protected configuration privilege | Configuration editing must be restricted to explicitly authorized administrators | Barangay governance owner + adviser/professor if required | Not yet recorded | Pending | Configuration administration |

## 7. Stakeholder Questions to Validate

### Current Barangay Workflow

1. How are resident concerns currently received?
2. Who reviews a new concern first?
3. Who may acknowledge, assign, refer, update, resolve, close, or archive a concern?
4. Which actions require approval by another official?
5. How are unresolved or overdue concerns currently followed up?
6. How are emergency concerns currently coordinated?

### Concern Taxonomy and Routing

1. Which concern types are actually used by the selected barangay?
2. Which study-proposed types should be renamed, merged, removed, or added?
3. Which internal barangay office or personnel normally handles each type?
4. Which cases require external referral rather than internal assignment?
5. What information should be recorded when an external referral is made?

### Priority Factors and Scoring

1. Which factors are valid for deciding urgency or importance?
2. What observable evidence corresponds to each rating level?
3. What weight should each approved factor receive?
4. What numerical score ranges correspond to Low, Medium, High, and Critical?
5. Are any factors used only for rules rather than weighted scoring?

### Deadlines

1. What acknowledgement target applies to each approved priority or report type?
2. What response target applies?
3. Are resolution targets different from acknowledgement or response targets?
4. What happens when a target is missed?

### Emergency Rules

1. Which non-SOS conditions are safe and specific enough to receive an automatic Critical override?
2. Which conditions should instead create an urgent administrator-review flag?
3. Who must receive an emergency alert?
4. When should an unacknowledged emergency escalate?
5. How many retries are allowed?
6. What stops further escalation?
7. What information may appear in a push notification without exposing unnecessary sensitive data?
8. What procedure applies to a false alarm?

### Status Workflows

1. Which normal-report statuses are approved?
2. Which emergency statuses are approved?
3. Which transitions are allowed?
4. Who may perform each transition?
5. Is reopening allowed?
6. Is resident cancellation allowed?
7. How are rejected, duplicate, incorrect, or referred reports handled?
8. What reason fields are mandatory?

### Privacy and Retention

1. What resident verification data is necessary?
2. Who may access resident identity details?
3. Who may access report photo evidence?
4. Who may access GPS and SOS information?
5. How long should active, closed, archived, evidence, location, notification, and audit records be retained?
6. When should records be anonymized or securely deleted?
7. What information must never appear in lock-screen notifications?

### Configuration Governance

1. Which administrators may view configuration?
2. Which administrators may propose configuration changes?
3. Who approves a new rule, weight, threshold, route, or deadline version?
4. Must an approval reason or attachment be stored?
5. What activation date/time rules are required?
6. Can an activated version ever be edited, or must every change create a new version?

### Algorithm Validation

1. Who qualifies as an evaluator?
2. How many cases are required?
3. What class balance is required?
4. How will evaluator disagreement be resolved?
5. What pass threshold is required for each algorithm metric?
6. What happens if a material configuration change occurs after the validation dataset is frozen?

## 8. Decision Evidence Format

When a decision is approved, record:

- Decision ID.
- Final approved value or rule.
- Approver role.
- Decision date.
- Evidence reference.
- Reason or notes.
- Affected requirements.
- Affected diagrams.
- Affected database/configuration areas.
- Version to be created or activated.
- Required tests.

An approval-sensitive item remains `Pending` until this evidence exists.

## 9. Stage 3 Blocking Rule

Do not freeze dependent database or algorithm design while an unresolved decision can change:

- concern taxonomy;
- rating anchors;
- weights;
- numerical priority thresholds;
- routing or referral behavior;
- deadlines;
- status transitions;
- Critical override conditions;
- emergency escalation;
- configuration authorization;
- retention rules; or
- algorithm-validation acceptance criteria.

Stage 3 may exit only when the requirements baseline is approved and no unresolved contradiction changes the database or algorithm design.

## 10. Academic Development Approval and Stage 3 Exit Determination

### Approval Context

The professor approved proceeding with HelpHub development as an academic Software Engineering project.

- Approval date: 2026-08-05
- Approver role: Professor / Software Engineering academic project approver
- Evidence reference: Oral approval during Software Engineering project consultation
- Approved scope: Development of the HelpHub academic prototype according to the reconciled study, requirements baseline, diagrams, security/privacy constraints, and roadmap

This academic approval authorizes the development team to proceed with implementation.

It must not be represented as official adoption by an actual barangay of any policy, operational response commitment, algorithm value, routing rule, retention rule, or emergency procedure.

### Treatment of Pending Decisions

The individual `D-001` through `D-015` entries remain the authoritative decision register.

Where an exact value or rule is not yet documented, its approval-sensitive value remains provisional.

Academic approval to proceed must not be interpreted as permission to invent or silently activate:

- concern taxonomy values;
- classification override rules;
- factor definitions or rating anchors;
- weights;
- numerical priority thresholds;
- handlers or referral destinations;
- acknowledgement or response deadlines;
- lifecycle transitions;
- non-SOS Critical override conditions;
- emergency escalation rules;
- retention periods;
- algorithm-validation thresholds; or
- protected configuration privileges.

Dependent schema must remain configuration-driven and versioned where these values may change.

An unresolved value must not be hard-coded as an irreversible database constraint or activated algorithm configuration merely because development has been approved.

### Stage 3 Gate Determination

Stage 3 gate result: `PASS WITH CORRECTIONS`

The requirements and design baseline is approved for academic prototype development.

The remaining corrections are:

1. Keep unresolved policy and algorithm values explicitly provisional until their exact prototype values are documented.
2. Use versioned configuration rather than hard-coded policy values wherever the approved architecture requires configuration.
3. Record the exact configuration used for implementation and validation before activating that configuration version.
4. Preserve deterministic algorithm behavior: the same input with the same algorithm, rule, and weight versions must produce the same output.
5. Do not represent academic prototype values as official barangay policy.
6. Resolve privacy-, retention-, evaluation-, validation-, emergency-, and deployment-specific pending decisions before the roadmap gate at which each becomes operationally required.
7. Require separate stakeholder validation before any future real-barangay deployment.

With these corrections recorded, Roadmap Stage 4 may begin.
