# HelpHub Updated Conceptual Paradigm Narrative

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — conceptual-paradigm requirements baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Study reference: Figure 1.0 — Conceptual Paradigm of HelpHub
- Related stakeholder record: `docs/requirements/STAKEHOLDER_VALIDATION_NOTES.md`
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related workflows: `docs/requirements/STATUS_TRANSITION_TABLES.md`
- Related use-case model: `docs/diagrams/USE_CASE_DIAGRAM.md`

## 1. Purpose

This document is the Stage 3 narrative companion to the approved study's updated conceptual paradigm.

It does not replace Figure 1.0 in the study. Its purpose is to preserve the meaning of the study's Input-Process-Output model with feedback loop as the project moves into requirements, architecture, implementation, testing, evaluation, and deployment.

The conceptual paradigm must remain consistent with the approved HelpHub scope and must not be interpreted using superseded project concepts from older study drafts.

## 2. Conceptual Model

HelpHub uses an Input-Process-Output (IPO) conceptual model with a feedback loop.

The model connects:

1. the foundations, requirements, report data, emergency data, and approved configuration that enter the study and system;
2. the governance, development, algorithmic, workflow, and evaluation processes that transform those inputs;
3. the functional HelpHub modules and measurable evaluation evidence produced as outputs; and
4. stakeholder and evaluation feedback that may revise future requirements or configuration without altering the historical configuration used by already-processed reports.

The feedback loop therefore supports controlled improvement rather than uncontrolled mutation of system behavior.

## 3. Input

The Input side of the conceptual paradigm contains four major groups.

### 3.1 Theoretical Foundations

The approved study identifies the following theoretical foundations:

- Open Systems Perspective;
- Technology Acceptance in Digital Governance; and
- Digital Governance / E-Government Theory.

These foundations support HelpHub as an integrated, user-centered, traceable barangay-level digital governance application.

They guide system integration, usability, transparency, accountability, decision support, and the preservation of appropriate human review.

### 3.2 User and Barangay Requirements

Requirements include the validated needs, constraints, permissions, workflows, usability expectations, privacy obligations, security controls, and evaluation criteria for the selected barangay.

The primary HelpHub application roles are:

- Resident; and
- Barangay Administrator.

External barangay personnel, committees, utilities, police, fire, medical, disaster-response organizations, or other agencies may become assignment or referral destinations where an approved workflow permits.

They are not automatically HelpHub application actors, authenticated users, or technically integrated responders.

### 3.3 Normal Report and Emergency Data

Normal concern-report inputs include the approved concern type and required reporting information defined by the requirements baseline, including:

- description;
- location data;
- resident-declared urgency;
- affected population;
- vulnerable-group indicator;
- optional permitted photo evidence; and
- required timestamps and associated report metadata.

Location capture must follow the approved privacy model and is not continuous resident tracking.

Emergency input follows a distinct SOS interaction and includes:

- brief SOS hold or confirmation;
- selected emergency type;
- one-time GPS location;
- timestamp; and
- registered-user details required for the emergency record.

HelpHub must clearly communicate that its Emergency Response Module does not replace official emergency services.

### 3.4 Approved Versioned Configuration

Algorithm and workflow policy is treated separately from ordinary report data.

Configuration may include:

- concern-type rules;
- rule sets;
- normalized factor-rating definitions;
- factor weights;
- priority thresholds;
- handler or routing definitions;
- response deadlines;
- Critical-override rules; and
- workflow permissions.

These values must not be treated as permanently fixed constants merely because a provisional value appears in a design document or study table.

A configuration becomes operational only through the approved configuration process.

Activated configuration must be versioned so that the system can identify the exact policy used for a processed report.

## 4. Process

The Process portion of the paradigm transforms the approved inputs through requirements approval, design, implementation, operation, testing, and evaluation.

For Stage 3 traceability, this process is separated into governance/development processing and application-runtime processing.

### 4.1 Requirements and Development Process

Before implementation decisions become authoritative, the team must:

1. reconcile the approved study, roadmap, stakeholder decisions, repository evidence, and decision register;
2. identify approval-dependent policy decisions;
3. define testable requirements and acceptance criteria;
4. design system, data, security, privacy, workflow, and user-interface structures;
5. implement the system in small testable vertical slices;
6. verify each slice through normal, boundary, invalid, unauthorized, and failure testing; and
7. collect implementation and evaluation evidence.

Stage gates prevent unresolved requirements contradictions from silently becoming database schema or algorithm behavior.

### 4.2 Normal Concern Processing

For a normal concern report, the resident provides the initial concern type and report details.

The protected Rule-Based Weighted Priority Queue processing path must:

1. validate required input;
2. determine or validate the concern type using the active approved rule version;
3. match applicable approved system, city-ordinance, and barangay-specific rules;
4. convert each approved factor to its normalized rating;
5. calculate the weighted score using the active weight version;
6. map the score to the approved Low, Medium, High, or Critical priority according to the active threshold version;
7. apply an approved Critical emergency override when applicable;
8. assign the approved route or handler and response deadline; and
9. generate the deterministic queue position.

Deterministic queue ordering follows:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending; and
5. report ID ascending.

The same report input evaluated using the same algorithm, rule, weight, and other applicable configuration versions must produce the same result.

### 4.3 Emergency Processing

Confirmed SOS reports follow a separate emergency path rather than the normal weighted-priority path.

The emergency process:

1. requires the approved hold or confirmation interaction;
2. records the selected emergency type;
3. captures one-time GPS location information;
4. records the event timestamp and required registered-user details;
5. applies the automatic Critical override;
6. places the emergency in the emergency queue; and
7. supports acknowledgement and approved tracking, assignment, referral, resolution, false-alarm, closure, and archival behavior as permitted by the final approved emergency workflow.

The Emergency Response Module supports barangay-level handling and coordination but does not guarantee dispatch or replace police, fire, medical, disaster-response, or other official emergency services.

### 4.4 Workflow and Traceability Processing

Administrator actions may include:

- report review;
- assignment;
- referral recording;
- approved status transitions;
- internal notes;
- emergency acknowledgement;
- announcement publication;
- authorized audit review; and
- protected configuration management.

Every report status change must create the corresponding status-history record and required audit evidence.

Assignment, referral, emergency, and protected configuration actions must remain traceable according to the approved authorization and audit rules.

Reports must not be silently deleted. Closure and archival must preserve the required historical evidence.

### 4.5 Evaluation Process

HelpHub is evaluated through the approved ISO/IEC 25010:2023 quality characteristics used by the study together with algorithm-specific validation.

The study evaluation includes:

- Functional Suitability;
- Performance Efficiency;
- Interaction Capability;
- Reliability; and
- Security.

Algorithm-specific evidence includes validation of:

- concern-type agreement;
- rule matching;
- score calculation;
- priority agreement;
- emergency override behavior;
- deterministic queue ordering;
- reproducibility; and
- explanation completeness.

Final evaluation datasets, acceptance thresholds, evaluator qualifications, and other approval-sensitive evaluation parameters remain governed by the approved study and stakeholder-decision process.

## 5. Output

The Output side of the conceptual paradigm consists of both functional system capabilities and measurable evidence.

### 5.1 Functional HelpHub Outputs

The system output includes the implemented HelpHub capabilities required by the study:

- user registration, authentication, profile management, verification, and role-based access;
- normal concern reporting;
- one-time location capture and optional protected photo evidence;
- resident report tracking and complete status history;
- Rule-Based Weighted Priority Queue processing;
- administrator dashboards and ordered queue views;
- assignment, referral recording, approved status updates, and internal notes;
- Emergency Response Module and emergency queue;
- notifications and barangay announcements;
- audit evidence; and
- protected versioned rule and weight configuration.

These modules collectively provide the structured and traceable digital concern-management workflow described by the study.

### 5.2 Evaluation and Research Evidence

The project must also produce evidence showing whether HelpHub meets its requirements and research objectives.

Evidence may include:

- automated test results;
- API and authorization test results;
- database and Row Level Security test results;
- integration and user-acceptance test evidence;
- performance measurements;
- security and privacy checks;
- algorithm-validation results;
- ISO/IEC 25010:2023 evaluation results;
- screenshots and demonstration evidence;
- traceability records; and
- configuration and audit records needed to reproduce evaluated behavior.

An implemented feature without the required verification evidence is not treated as complete.

## 6. Feedback Loop

The conceptual paradigm includes an explicit feedback loop.

Evaluation results, stakeholder validation, usability findings, defects, security findings, algorithm-validation results, and controlled deployment feedback may lead to:

- clarified requirements;
- revised acceptance criteria;
- interface improvements;
- workflow changes;
- corrected implementation;
- revised rules;
- revised factor definitions;
- revised weights;
- revised thresholds;
- revised routing or deadlines; or
- other approved configuration changes.

Feedback does not authorize silent modification of previously activated configuration.

When configuration changes are approved, a new version must be created and activated according to the protected configuration process.

Previously processed reports retain references to the versions that produced their results so earlier decisions remain reproducible and auditable.

## 7. Reproducibility and Version Preservation

Reproducibility is a core connection between the Input, Process, Output, and Feedback portions of the paradigm.

For each processed normal report, implementation must preserve enough algorithm evidence to identify and reproduce the decision, including the applicable:

- algorithm version;
- rule version;
- weight version;
- factor values;
- normalized ratings;
- matched rules;
- score breakdown;
- override reason where applicable;
- classification;
- priority;
- route;
- deadline; and
- deterministic queue key.

An activated historical configuration must not be edited in place if doing so would change the interpretation of reports already processed using that version.

## 8. Conceptual Boundaries

The conceptual paradigm must not be interpreted as expanding HelpHub beyond the approved scope.

In particular:

- HelpHub serves one selected barangay for the study;
- there are two primary application roles;
- assistance-request functionality is outside the approved scope;
- full offline operation is not required;
- SMS fallback is not part of the approved scope;
- HelpHub does not automatically enforce ordinances or penalties;
- external referral does not prove technical integration or guaranteed response;
- SOS does not replace official emergency services;
- HelpHub does not continuously track residents; and
- long-term post-study operation is outside the current study commitment.

Any change to these boundaries requires formal study and stakeholder reconciliation before implementation.

## 9. Relationship to Stage 3 Requirements

This narrative provides conceptual traceability for the Stage 3 requirements artifacts.

| Conceptual element | Stage 3 artifact |
| --- | --- |
| User and barangay requirements | `FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md` |
| User interactions | `USER_STORIES_AND_ACCEPTANCE_CRITERIA.md` |
| Actor authority | `ROLE_PERMISSION_MATRIX.md` |
| Normal and emergency workflows | `STATUS_TRANSITION_TABLES.md` |
| Stakeholder-controlled policy | `STAKEHOLDER_VALIDATION_NOTES.md` |
| System actors and capabilities | `USE_CASE_DIAGRAM.md` |
| System/data boundaries | System context and DFD artifacts to follow |
| Technical realization | Component and deployment artifacts to follow |
| Data definitions | Stage 3 data dictionary to follow |
| Objective-to-evidence mapping | Stage 3 Requirements Traceability Matrix to follow |
| Privacy and security implications | Stage 3 privacy impact and threat review to follow |

## 10. Approval-Sensitive Areas

This narrative intentionally does not declare final values for:

- complete concern taxonomy;
- detailed rule set;
- factor-rating anchors;
- factor weights;
- numerical priority thresholds;
- final handlers or referral destinations;
- response deadlines;
- non-SOS Critical override rules;
- final normal status-transition permissions;
- final emergency status-transition permissions;
- escalation rules;
- retention periods;
- protected configuration privilege; or
- final algorithm-validation acceptance thresholds.

Those decisions remain subject to documented stakeholder approval and version control.

## 11. Stage 3 Verification Checklist

Before Stage 3 approval, verify that:

- the IPO model matches the approved revised study;
- the feedback loop is explicitly represented;
- configurable algorithm policy is separated from ordinary report inputs;
- configuration approval and version preservation are explicit;
- normal concern processing follows the approved algorithm contract;
- confirmed SOS follows the separate Critical-override path;
- the deterministic queue ordering is unchanged;
- status history and audit traceability are preserved;
- the model contains only Resident and Barangay Administrator as primary application roles;
- no assistance-request module has been reintroduced;
- no external agency is represented as an automatically integrated responder;
- privacy-sensitive location handling remains one-time rather than continuous tracking;
- no provisional rule, weight, threshold, handler, deadline, or workflow value is presented as approved; and
- feedback cannot mutate the configuration history of reports already processed.

## 12. Stage 3 Conceptual-Paradigm Rule

The conceptual paradigm is a controlled bridge between the approved study and the technical implementation.

Later architecture, database, algorithm, UI, testing, evaluation, and deployment artifacts must remain traceable to this model.

If a stakeholder decision changes the Input, Process, Output, feedback behavior, actor boundary, algorithm contract, or approved system scope, this narrative and all affected downstream artifacts must be reviewed before the relevant stage gate can pass.
