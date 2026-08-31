# HelpHub Stage 3 Stakeholder Decision and Approval Packet

## Document Control

- Project: HelpHub — A Mobile-Based Barangay Concern Reporting Application Using a Rule-Based Weighted Priority Queue Algorithm with Emergency Response Module
- Roadmap phase: Stage 3 — Requirements Baseline and Diagrams
- Task: 03.17A — Stakeholder Decision and Approval Packet
- GitHub issue: #14
- Status: DRAFT — FOR STAKEHOLDER / ADVISER DECISION
- Scope: One selected barangay
- Purpose: Record approval evidence required to close Stage 3 without inventing policy or algorithm values

---

## 1. Purpose

This packet consolidates HelpHub approval-sensitive decisions that must be resolved or formally reconciled before dependent database, algorithm, workflow, privacy, security, evaluation, or deployment design is frozen.

This document does not approve any decision by itself.

A decision remains `Pending` until the repository's required approval evidence is recorded.

---

## 2. Required Decision Evidence

For every approved decision, record:

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

Verbal agreement without recorded evidence is not sufficient to change a decision from `Pending`.

---

## 3. Stage 3 Blocking Rule

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

---

## 4. Decision Recording Instructions

For every decision:

1. Review the current HelpHub baseline.
2. Discuss only choices permitted by the approved study and scope.
3. Record the final approved rule or value.
4. Record the required approver role and actual approval evidence.
5. Record the decision date.
6. Identify affected requirements, diagrams, schema/configuration, and tests.
7. Update `STAKEHOLDER_VALIDATION_NOTES.md` only after valid evidence exists.

Fields marked `NOT YET RECORDED` are intentionally unresolved.

Developers must not replace missing stakeholder or adviser decisions with invented values.

---

## 5. D-001 — Priority Model Reconciliation

### Current baseline

The revised study establishes four priority names:

- Low
- Medium
- High
- Critical

Numerical priority thresholds remain governed separately by `D-005`.

### Decision required

Confirm that the HelpHub baseline uses the four revised-study priority names and close any remaining source-reconciliation ambiguity.

### Required approver

Adviser/professor, plus barangay where policy confirmation is required.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Algorithm priority requirements
- Affected diagrams: Updated Conceptual Paradigm and algorithm-related diagrams
- Affected database/configuration areas: Priority/configuration model
- Version to be created or activated: NOT YET RECORDED
- Required tests: Priority-name and configuration compatibility tests

---

## 6. D-002 — Concern Classification Responsibility

### Current baseline

The Resident selects a concern type.

The system validates the selected type or recommends another approved type using the active versioned rules.

Administrator review may be available according to the approved workflow.

### Decision required

Approve:

- when system recommendation occurs;
- whether an Administrator may override classification;
- who has final classification authority;
- what reason or evidence is required for correction;
- how classification changes are recorded and audited.

### Required approver

Barangay workflow owner.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Classification and algorithm validation requirements
- Affected diagrams: Use Case, Conceptual Paradigm, DFDs, Component Diagram
- Affected database/configuration areas: Classification evidence and protected workflow
- Version to be created or activated: NOT YET RECORDED
- Required tests: Classification, recommendation, authorization, correction, history, and audit tests

---

## 7. D-003 — Final Concern Taxonomy and Handlers / Referrals

### Current baseline

Study taxonomy and handler tables are provisional starting points.

They must not be activated as final barangay policy without recorded approval.

### Decision required

Approve:

- final concern categories/types;
- enabled or disabled state;
- intended internal handler or external referral destination;
- special routing treatment where applicable.

### Required approver

Barangay.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Concern reporting, classification, routing, and configuration requirements
- Affected diagrams: Use Case, Conceptual Paradigm, DFDs
- Affected database/configuration areas: Taxonomy versions, concern types, destinations, routes
- Version to be created or activated: NOT YET RECORDED
- Required tests: Active taxonomy, classification compatibility, routing, and authorization tests

---

## 8. D-004 — Factor Definitions, Rating Anchors, and Weights

### Current baseline

Algorithm factors must be observable, approved, normalized through approved rating anchors, weighted, versioned, and reproducible.

No final factor scale, rating anchor, or weight may be invented by implementation.

### Decision required

Approve:

- factor definitions;
- allowed raw values;
- normalized rating scale;
- rating anchors;
- weight for every factor;
- handling of invalid or missing factor data.

### Required approver

Barangay + adviser/professor.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Weighted scoring, normalization, deterministic algorithm, configuration
- Affected diagrams: Conceptual Paradigm, Component Diagram
- Affected database/configuration areas: Factor, rating, weight, and algorithm-evidence configuration
- Version to be created or activated: NOT YET RECORDED
- Required tests: Normalization boundaries, weighted score calculation, invalid values, reproducibility

---

## 9. D-005 — Numerical Priority Thresholds

### Current baseline

Priority names are:

- Low
- Medium
- High
- Critical

Numerical score ranges are not approved.

### Decision required

Approve complete and non-overlapping numerical ranges mapping weighted scores to the four priority names.

### Required approver

Barangay + adviser/professor.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Priority assignment and configuration requirements
- Affected diagrams: Conceptual Paradigm
- Affected database/configuration areas: Threshold configuration
- Version to be created or activated: NOT YET RECORDED
- Required tests: Exact-boundary, below-boundary, above-boundary, gap, and overlap tests

---

## 10. D-006 — Acknowledgement and Response Deadlines

### Current baseline

HelpHub must assign an approved response deadline.

Queue ordering uses nearest deadline ascending after override rank and priority score.

No final durations are approved.

### Decision required

Approve:

- acknowledgement deadlines where applicable;
- response deadlines;
- conditions selecting each deadline;
- normal versus emergency deadline behavior;
- any approved escalation relationship.

### Required approver

Barangay.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Deadline assignment and queue-order requirements
- Affected diagrams: Conceptual Paradigm, DFDs
- Affected database/configuration areas: Deadline configuration and queue key
- Version to be created or activated: NOT YET RECORDED
- Required tests: Deadline assignment, time handling, expiration, and deterministic queue ordering

---

## 11. D-007 — Normal and Emergency Status Transitions

### Current baseline

Proposed normal and emergency workflows exist.

Detailed transitions, permissions, and initial-state rules remain approval-sensitive.

### Decision required

Approve:

- status names;
- initial status;
- allowed transitions;
- actor allowed for each transition;
- required reason or note;
- terminal/closed/archive behavior;
- false-alarm behavior;
- emergency-specific transition rules.

### Required approver

Barangay.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Resident tracking, administrator workflow, SOS tracking, history, audit
- Affected diagrams: Use Case, DFDs, Component Diagram
- Affected database/configuration areas: Lifecycle versions, status definitions, transitions, current state, status history
- Version to be created or activated: NOT YET RECORDED
- Required tests: Valid, invalid, unauthorized, terminal, history, and audit transition tests

---

## 12. D-008 — Non-SOS Life-Threatening Critical Rules

### Current baseline

Confirmed SOS receives an automatic Critical override.

A non-SOS report may receive an automatic Critical override only through an approved, structured, and testable life-threatening rule.

Unstructured or uncertain keyword-only indicators must not silently cause a Critical override.

### Decision required

Approve the exact deterministic conditions, if any, under which a non-SOS concern receives a Critical override.

### Required approver

Barangay + adviser/professor.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Critical override and deterministic algorithm requirements
- Affected diagrams: Conceptual Paradigm, DFDs, Component Diagram
- Affected database/configuration areas: Rule configuration and override evidence
- Version to be created or activated: NOT YET RECORDED
- Required tests: Qualifying cases, non-qualifying cases, false positives, reproducibility, override evidence

---

## 13. D-009 — External Referral Workflow

### Current baseline

HelpHub may record coordination or referral.

HelpHub must not claim guaranteed dispatch or direct integration with police, fire, medical, or other external emergency services.

### Decision required

Approve:

- when external referral is allowed;
- who may create the referral;
- what referral information is recorded;
- whether internal assignment must precede referral;
- what routing information is Resident-visible;
- required audit/history evidence.

### Required approver

Barangay.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Administrator assignment/routing, SOS, audit, tracking
- Affected diagrams: Use Case, Context Diagram, DFDs, Component Diagram
- Affected database/configuration areas: Routing destinations, current routing state, routing history, visibility
- Version to be created or activated: NOT YET RECORDED
- Required tests: Referral authorization, history, audit, privacy, and no-guaranteed-dispatch UI tests

---

## 14. D-010 — Emergency Escalation

### Current baseline

Emergency escalation behavior is not final.

Recipients, timing, retries, acknowledgement cancellation, and stop behavior must come from approved rules/configuration.

### Decision required

Approve:

- whether escalation is enabled;
- eligible recipient or destination types;
- triggering condition;
- timing;
- retry behavior;
- acknowledgement cancellation behavior;
- stop conditions;
- audit requirements.

### Required approver

Barangay.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Emergency response and configuration requirements
- Affected diagrams: Use Case, DFDs, Component Diagram, Deployment Diagram
- Affected database/configuration areas: Emergency escalation configuration/history
- Version to be created or activated: NOT YET RECORDED
- Required tests: Trigger, retry, acknowledgement, cancellation, stop, failure, authorization, and audit tests

---

## 15. D-011 — ISO/IEC 25010:2023 Evaluation Terminology

### Current baseline

The current study identifies:

- Functional Suitability;
- Performance Efficiency;
- Interaction Capability;
- Reliability;
- Security.

Final evaluation-instrument terminology remains adviser/professor controlled.

### Decision required

Confirm the terminology and characteristics to be used in the final evaluation instrument.

### Required approver

Adviser/professor.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: ISO/IEC 25010 evaluation requirements
- Affected diagrams: None unless explanatory documentation changes
- Affected database/configuration areas: None currently expected
- Version to be created or activated: Evaluation instrument version
- Required tests/evidence: Instrument review and Stage 15 evaluation evidence

---

## 16. D-012 — Algorithm-Validation Acceptance Criteria

### Current baseline

Algorithm validation must address:

- concern-type agreement;
- rule-match correctness;
- score-calculation correctness;
- final-priority agreement;
- emergency-override correctness;
- deterministic queue-ordering correctness;
- reproducibility;
- explanation completeness.

Final evaluator qualifications, dataset size, balance, disagreement procedure, and pass thresholds are not approved.

### Decision required

Approve:

- evaluator qualifications;
- number of validation cases;
- required class/case balance;
- disagreement-resolution process;
- pass threshold for each metric;
- action required after a material configuration change following dataset freeze.

### Required approver

Adviser/professor + qualified evaluators as approved.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Algorithm-validation requirements
- Affected diagrams: Conceptual Paradigm where validation is represented
- Affected database/configuration areas: Validation evidence/export design where applicable
- Version to be created or activated: Algorithm-validation protocol version
- Required tests/evidence: Stage 14 validation protocol and validation results

---

## 17. D-013 — Data Retention, Anonymization, Archival, and Secure Deletion

### Current baseline

No final retention duration is approved.

Retention must follow approved institutional and stakeholder policy.

### Decision required

Approve applicable handling for:

- Resident profile/account data;
- verification records and evidence;
- concern reports;
- one-time location information;
- photo evidence;
- lifecycle/routing history;
- algorithm evidence;
- SOS/emergency data;
- notifications/device tokens;
- announcements;
- administrator notes;
- audit records;
- research/evaluation exports;
- backups where applicable.

Where relevant, approve:

- retention duration;
- archival trigger;
- anonymization trigger;
- lawful deletion conditions;
- deletion authority;
- immutable-history treatment;
- backup handling;
- deletion/anonymization evidence.

### Required approver

Barangay + adviser/professor.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Privacy, traceability, audit, and deployment requirements
- Affected diagrams: DFDs and Deployment Diagram where affected
- Affected database/configuration areas: Retention, archival, anonymization, deletion, audit, backup/export handling
- Version to be created or activated: Retention/privacy policy version
- Required tests: Retention, archive, anonymization, authorized deletion, immutable-history, and export/backup tests

---

## 18. D-014 — Deployment Audience

### Current baseline

HelpHub serves one selected barangay and is currently scoped as a controlled study/evaluation release.

### Decision required

Confirm:

- intended deployment audience;
- approved access window;
- whether use is evaluation-only or controlled operational use;
- who owns deployment access decisions;
- post-study handling expectations.

This decision does not expand HelpHub into multi-barangay or indefinite post-study operation.

### Required approver

Adviser/professor + barangay.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Deployment, privacy, and architecture constraints
- Affected diagrams: Deployment Diagram
- Affected database/configuration areas: Environment/access configuration where applicable
- Version to be created or activated: Deployment release version
- Required tests/evidence: Deployment checklist and access verification

---

## 19. D-015 — Protected Configuration Privilege

### Current baseline

Configuration editing must be restricted to explicitly authorized Barangay Administrators.

Ordinary Administrator status must not automatically imply configuration-editing privilege if approved governance requires additional authorization.

### Decision required

Approve:

- which Administrator(s) may edit configuration;
- who may create draft versions;
- who may approve versions;
- who may activate versions;
- whether one person may perform multiple governance steps;
- reason/evidence requirements for changes;
- whether activated versions are immutable;
- whether every material change creates a new version.

### Required approver

Barangay governance owner + adviser/professor if required.

### Decision evidence

- Final approved value or rule: NOT YET RECORDED
- Approver role: NOT YET RECORDED
- Decision date: NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Reason or notes: NOT YET RECORDED
- Affected requirements: Protected configuration requirements
- Affected diagrams: Role-Permission Matrix, DFDs, Component Diagram
- Affected database/configuration areas: Configuration authorization, version lifecycle, activation, audit
- Version to be created or activated: Configuration-governance version
- Required tests: Unauthorized access, privilege separation, activation, immutability, and audit tests

---

## 20. Additional Data-Dictionary Corrections Requiring Explicit Treatment

These items currently do not have separate `D-###` identifiers. Do not invent new IDs without formally updating the decision register.

### DD-C08 — Resident Routing-Detail Visibility

Approve which internal routing/referral destination and note information may be visible to a Resident.

### DD-C09 — Storage Object Authorization

Confirm the intended evidence-object ownership and authorization model before implementing Supabase Storage object policies.

A private bucket by itself is not sufficient authorization.

### DD-C10 — Retention and Anonymization

Resolve through the policy approved under `D-013`.

### DD-C11 — Verification Evidence Schema

Approve the exact verification evidence requirements, storage location, authorized access, and privacy treatment before introducing evidence fields or storage objects.

---

## 21. Decision Session Summary

Complete only after an actual decision/approval session.

- Session date: NOT YET RECORDED
- Session type: NOT YET RECORDED
- Barangay participants/roles: NOT YET RECORDED
- Adviser/professor participants/roles: NOT YET RECORDED
- Other approved participants/evaluators: NOT YET RECORDED
- Evidence location/reference: NOT YET RECORDED

### Decision Status Summary

| Decision | Status |
|---|---|
| D-001 | Pending |
| D-002 | Pending |
| D-003 | Pending |
| D-004 | Pending |
| D-005 | Pending |
| D-006 | Pending |
| D-007 | Pending |
| D-008 | Pending |
| D-009 | Pending |
| D-010 | Pending |
| D-011 | Pending |
| D-012 | Pending |
| D-013 | Pending |
| D-014 | Pending |
| D-015 | Pending |
| DD-C08 | Pending |
| DD-C09 | Pending implementation/policy confirmation |
| DD-C10 | Pending through D-013 |
| DD-C11 | Pending |

---

## 22. Stage 3 Gate Decision

This section must not be completed as `PASS` until the requirements approval and Stage 3 blocking conditions are satisfied.

- Gate result: NOT YET RECORDED
- Gate decision date: NOT YET RECORDED
- Gate approver(s): NOT YET RECORDED
- Evidence reference: NOT YET RECORDED
- Corrections required: NOT YET RECORDED

Allowed gate outcomes:

- `PASS`
- `PASS WITH CORRECTIONS`
- `BLOCKED`

A later roadmap stage must not begin until the Stage 3 gate is formally recorded as `PASS` or `PASS WITH CORRECTIONS` and required corrections are recorded.

---

## 23. Repository Update Procedure After Approval

After genuine approval evidence is obtained:

1. Update the applicable `D-###` entries in `STAKEHOLDER_VALIDATION_NOTES.md`.
2. Record the approved rule/value, approver, date, and evidence reference.
3. Update affected functional/non-functional requirements.
4. Update affected user stories and acceptance criteria.
5. Update the Role-Permission Matrix or Status Transition Tables where affected.
6. Update affected diagrams.
7. Update `DATA_DICTIONARY.md`.
8. Update the Privacy Impact Review where affected.
9. Update the Security Threat Review where affected.
10. Update the Requirements Traceability Matrix.
11. Create or revise required versioned configuration artifacts only from approved values.
12. Add or revise applicable tests.
13. Run repository/document consistency checks.
14. Record the final Stage 3 gate decision.
15. Update GitHub Issue #14.
16. Prepare the Stage 3 pull request.

No developer-generated value may substitute for missing stakeholder approval.
