# HelpHub Use-Case Diagram

## Document Status

- Roadmap stage: Stage 3 — Requirements, Diagrams, and Privacy Review
- Tracking issue: GitHub Issue #14
- Working status: DRAFT — use-case baseline
- Approval status: NOT YET STAGE-GATE APPROVED
- Related requirements: `docs/requirements/FUNCTIONAL_AND_NON_FUNCTIONAL_REQUIREMENTS.md`
- Related user stories: `docs/requirements/USER_STORIES_AND_ACCEPTANCE_CRITERIA.md`
- Related permissions: `docs/requirements/ROLE_PERMISSION_MATRIX.md`
- Related workflows: `docs/requirements/STATUS_TRANSITION_TABLES.md`
- Related stakeholder record: `docs/requirements/STAKEHOLDER_VALIDATION_NOTES.md`

## 1. Purpose

This diagram shows the major requirements-level interactions between the two primary HelpHub application actors and the HelpHub system boundary.

The primary application actors are:

1. Resident.
2. Barangay Administrator.

Barangay personnel, committees, utilities, police, fire, medical, disaster-response, and other external agencies may be assignment or referral destinations where the approved workflow permits, but they are not represented as authenticated HelpHub actors unless a formal technical and operational integration is approved.

## 2. Use-Case Diagram

~~~mermaid
flowchart LR

    RES["Resident"]
    ADM["Barangay Administrator"]

    subgraph HH["HelpHub System Boundary"]

        subgraph ACCESS["Account and Access"]
            UC01(["UC-01 Register Resident Account"])
            UC02(["UC-02 Log In / Log Out"])
            UC03(["UC-03 Manage Own Profile"])
            UC04(["UC-04 Submit Resident Verification"])
            UC05(["UC-05 Review / Manage Resident Verification"])
            UC06(["UC-06 Manage / Restrict Resident Account"])
        end

        subgraph CONCERN["Normal Concern Reporting and Tracking"]
            UC07(["UC-07 Submit Normal Concern"])
            UC08(["UC-08 Capture One-Time Report Location"])
            UC09(["UC-09 Attach Optional Photo Evidence"])
            UC10(["UC-10 Track Own Reports"])
            UC11(["UC-11 View Own Status History"])
        end

        subgraph ALGORITHM["Rule-Based Weighted Priority Queue Processing"]
            UC12(["UC-12 Validate / Recommend Concern Type"])
            UC13(["UC-13 Match Approved Rules"])
            UC14(["UC-14 Normalize Factors and Compute Score"])
            UC15(["UC-15 Assign Priority, Route, and Deadline"])
            UC16(["UC-16 Generate Deterministic Queue Order"])
            UC17(["UC-17 Review Algorithm Explanation"])
        end

        subgraph ADMIN["Administrator Concern Management"]
            UC18(["UC-18 View Dashboard / Priority Queues"])
            UC19(["UC-19 Review Report Detail"])
            UC20(["UC-20 Assign Report / Record Referral"])
            UC21(["UC-21 Update Approved Report Status"])
            UC22(["UC-22 Add Internal Note"])
        end

        subgraph SOS["Emergency Response Module"]
            UC23(["UC-23 Send Confirmed SOS"])
            UC24(["UC-24 Capture One-Time SOS Location"])
            UC25(["UC-25 Apply Critical Override / Emergency Queue"])
            UC26(["UC-26 View Emergency Queue"])
            UC27(["UC-27 Acknowledge / Track Emergency"])
            UC28(["UC-28 Assign / Refer Emergency"])
            UC29(["UC-29 Mark False Alarm with Reason"])
        end

        subgraph COMM["Communication"]
            UC30(["UC-30 View Barangay Announcements"])
            UC31(["UC-31 Publish Barangay Announcement"])
            UC32(["UC-32 Receive Permitted Notification"])
        end

        subgraph GOVERNANCE["Audit and Protected Configuration"]
            UC33(["UC-33 View Authorized Audit Evidence"])
            UC34(["UC-34 Manage Versioned Configuration"])
        end

        subgraph TRACE["Required Trusted System Behavior"]
            UC35(["UC-35 Create Status-History Record"])
            UC36(["UC-36 Create Required Audit Event"])
        end
    end

    RES --> UC01
    RES --> UC02
    RES --> UC03
    RES --> UC04
    RES --> UC07
    RES --> UC10
    RES --> UC11
    RES --> UC23
    RES --> UC30
    RES --> UC32

    ADM --> UC02
    ADM --> UC05
    ADM --> UC06
    ADM --> UC17
    ADM --> UC18
    ADM --> UC19
    ADM --> UC20
    ADM --> UC21
    ADM --> UC22
    ADM --> UC26
    ADM --> UC27
    ADM --> UC28
    ADM --> UC29
    ADM --> UC31
    ADM --> UC33
    ADM --> UC34

    UC07 -. "includes when required" .-> UC08
    UC07 -. "includes when provided" .-> UC09
    UC07 -. "includes protected processing" .-> UC12

    UC12 -. "continues to" .-> UC13
    UC13 -. "continues to" .-> UC14
    UC14 -. "continues to" .-> UC15
    UC15 -. "continues to" .-> UC16

    UC23 -. "includes" .-> UC24
    UC23 -. "includes" .-> UC25

    UC21 -. "requires" .-> UC35
    UC21 -. "requires" .-> UC36
    UC27 -. "requires traceability" .-> UC35
    UC27 -. "requires audit" .-> UC36
    UC28 -. "requires audit" .-> UC36
    UC29 -. "requires" .-> UC35
    UC29 -. "requires audit" .-> UC36
~~~

## 3. Actor Definitions

### Resident

The Resident represents a registered barangay resident using authorized resident functions.

Major resident interactions include:

- registration and authentication;
- profile management;
- resident-verification submission;
- normal concern submission;
- optional permitted evidence;
- one-time location capture when needed;
- personal report tracking;
- permitted status history;
- Emergency SOS;
- announcements; and
- notifications.

### Barangay Administrator

The Barangay Administrator represents an authenticated administrative user acting within approved permissions.

Major administrator interactions include:

- resident verification and account management;
- dashboard and queue review;
- report-detail and algorithm-explanation review;
- assignment and referral recording;
- approved status transitions;
- internal notes;
- emergency acknowledgement and tracking;
- emergency assignment/referral;
- false-alarm handling;
- announcements;
- audit review; and
- protected configuration when specifically authorized.

## 4. Important System Boundaries

### 4.1 External Agencies Are Not HelpHub Actors

External organizations are intentionally omitted as authenticated HelpHub actors.

Recording a referral does not prove:

- a technical HelpHub integration exists;
- the destination has a HelpHub account;
- the destination accepted the case;
- official dispatch occurred; or
- an external response is guaranteed.

### 4.2 Configuration Authorization Is Not a Third Primary Role

`UC-34 Manage Versioned Configuration` is available only to a Barangay Administrator who has the additional approved configuration-management permission.

This does not create a third primary application role.

### 4.3 Priority Processing Is Internal System Behavior

The Rule-Based Weighted Priority Queue Algorithm is internal trusted system behavior rather than a human actor.

For a normal concern, protected processing includes:

1. input validation;
2. concern-type validation or recommendation;
3. approved rule matching;
4. normalized factor ratings;
5. weighted scoring;
6. Low, Medium, High, or Critical priority mapping;
7. approved Critical override where applicable;
8. routing and deadline assignment; and
9. deterministic queue ordering.

Final rules, rating anchors, weights, numerical thresholds, routes, and deadlines remain governed by approved versioned configuration.

### 4.4 SOS Does Not Replace Official Emergency Services

The Emergency Response Module supports barangay-level alerting, coordination, acknowledgement, referral, and tracking.

HelpHub does not replace official police, fire, medical, disaster-response, or national emergency services.

## 5. Use-Case Traceability

| Use case | Primary requirement/story source |
|---|---|
| UC-01 to UC-06 | FR-UM series / US-UM and US-ADM-001 |
| UC-07 to UC-11 | FR-CR, FR-LE, FR-RT / US-CR and US-RT |
| UC-12 to UC-17 | FR-ALG / US-ALG |
| UC-18 to UC-22 | FR-AD / US-AD |
| UC-23 to UC-29 | FR-SOS / US-SOS |
| UC-30 to UC-32 | FR-CM / US-CM |
| UC-33 | FR-AU / US-AU-001 |
| UC-34 | FR-CFG / US-CFG-001 |
| UC-35 to UC-36 | Status-history, audit, and workflow requirements |

## 6. Approval-Dependent Areas

This diagram establishes required capabilities but does not approve:

1. final concern taxonomy;
2. final verification decision states;
3. classification override procedure;
4. final assignment handlers or referral destinations;
5. numerical priority thresholds;
6. response deadlines;
7. final status-transition permissions;
8. non-SOS Critical override rules;
9. emergency escalation behavior;
10. false-alarm authority;
11. audit-view privilege scope; or
12. protected configuration privilege.

These remain governed by `STAKEHOLDER_VALIDATION_NOTES.md`.

## 7. Diagram Verification Checklist

Before Stage 3 approval, verify that:

- only Resident and Barangay Administrator are primary application actors;
- assistance requests are absent;
- external agencies are not shown as directly integrated responders;
- normal concern submission includes protected priority processing;
- SOS uses one-time location and Critical override;
- resident tracking includes status history;
- administrator workflow includes assignment/referral and status updates;
- status changes preserve required history and audit evidence;
- notifications and announcements are represented;
- protected configuration is represented without adding a third primary role;
- no provisional weight, threshold, handler, deadline, or escalation value is presented as approved.

## 8. Stage 3 Diagram Rule

This use-case diagram is a requirements-level system-boundary model.

It shall be revised if approved stakeholder decisions materially change a user capability, actor permission, workflow, or system boundary.

Internal technology components such as Flutter, FastAPI, Supabase, Firebase Cloud Messaging, and location/map libraries belong in later component and deployment diagrams rather than being represented as human actors here.
