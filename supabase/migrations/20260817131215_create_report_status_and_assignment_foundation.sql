-- =============================================================================
-- HELPHUB TASK 04.6
-- REPORT STATUS AND ASSIGNMENT FOUNDATION
-- =============================================================================
--
-- Purpose:
--   Establish the database structures needed for normal-report lifecycle
--   tracking and assignment history without inventing final Barangay workflow
--   statuses or transition rules.
--
-- Governance boundary:
--   The study contains proposed lifecycle terms, but the final state machine
--   has not yet been documented as an approved production configuration.
--   Therefore this migration first creates a version container only.
--
--   No status names, transition rules, handler names, deadlines, or workflow
--   policy values are seeded by this section.
--
-- Architecture boundary:
--   public.reports remains the raw Resident-submission record.
--   Operational lifecycle state and history are intentionally stored
--   separately rather than adding mutable workflow columns to public.reports.
--
-- =============================================================================


-- =============================================================================
-- 1. REPORT LIFECYCLE CONFIGURATION VERSIONS
-- =============================================================================
--
-- Each row represents one immutable/versioned lifecycle configuration snapshot.
--
-- Future sections may attach:
--   - allowed status definitions;
--   - allowed status transitions;
--   - current report operational state;
--   - append-only report status history.
--
-- Activation and retirement are recorded explicitly so historical reports can
-- later identify which lifecycle configuration governed their transitions.
--
-- Exactly one lifecycle configuration may be active at a time.
--
-- No lifecycle configuration is seeded here because the final HelpHub status
-- state machine remains DEFERRED-CONFIG pending documented approval.
-- =============================================================================

create table public.report_lifecycle_versions (
    id uuid primary key
        default gen_random_uuid(),

    version_number integer not null,

    version_label text,

    notes text,

    created_by uuid
        references public.profiles(id)
        on delete restrict,

    created_at timestamp with time zone not null
        default now(),

    activated_by uuid
        references public.profiles(id)
        on delete restrict,

    activated_at timestamp with time zone,

    retired_by uuid
        references public.profiles(id)
        on delete restrict,

    retired_at timestamp with time zone,

    constraint uq_report_lifecycle_versions_number
        unique (version_number),

    constraint chk_report_lifecycle_versions_number
        check (version_number > 0),

    constraint chk_report_lifecycle_versions_label
        check (
            version_label is null
            or char_length(btrim(version_label)) between 1 and 100
        ),

    constraint chk_report_lifecycle_versions_notes
        check (
            notes is null
            or char_length(btrim(notes)) between 1 and 2000
        ),

    constraint chk_report_lifecycle_versions_activation_pair
        check (
            (activated_at is null and activated_by is null)
            or
            (activated_at is not null and activated_by is not null)
        ),

    constraint chk_report_lifecycle_versions_retirement_pair
        check (
            (retired_at is null and retired_by is null)
            or
            (retired_at is not null and retired_by is not null)
        ),

    constraint chk_report_lifecycle_versions_retired_after_activation
        check (
            retired_at is null
            or (
                activated_at is not null
                and retired_at >= activated_at
            )
        )
);


-- Only one lifecycle configuration can be active at any moment.
create unique index uq_report_lifecycle_versions_one_active
on public.report_lifecycle_versions ((true))
where activated_at is not null
  and retired_at is null;


comment on table public.report_lifecycle_versions is
'Version records for HelpHub report lifecycle configuration. No final status names or transition rules are seeded by Task 04.6 until the approved state machine is documented.';

comment on column public.report_lifecycle_versions.version_number is
'Monotonically increasing engineering version number identifying one report-lifecycle configuration snapshot.';

comment on column public.report_lifecycle_versions.version_label is
'Optional human-readable label for this report-lifecycle configuration version.';

comment on column public.report_lifecycle_versions.notes is
'Optional non-secret administrative notes describing this lifecycle configuration version.';

comment on column public.report_lifecycle_versions.created_by is
'Administrator profile associated with creation of this lifecycle configuration version when available.';

comment on column public.report_lifecycle_versions.activated_at is
'Timestamp when this lifecycle configuration became active for authoritative HelpHub report workflow decisions.';

comment on column public.report_lifecycle_versions.retired_at is
'Timestamp when this previously activated lifecycle configuration stopped being active.';


-- =============================================================================
-- 1.1 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Configuration changes are authoritative administrative operations.
-- No direct client write access is introduced in this section.
--
-- Read policies will be added only after their exact behavior is designed and
-- tested in a later section of this migration.
-- =============================================================================

alter table public.report_lifecycle_versions
    enable row level security;

revoke all privileges
on table public.report_lifecycle_versions
from public, anon, authenticated, service_role;

-- Protected backend code may inspect lifecycle configuration while later
-- authoritative configuration-management operations are implemented.
grant select
on table public.report_lifecycle_versions
to service_role;

-- =============================================================================
-- 2. VERSIONED REPORT STATUS DEFINITIONS
-- =============================================================================
--
-- This table defines the statuses available inside one report-lifecycle
-- configuration version.
--
-- No production status rows are seeded by Task 04.6.
--
-- Status values remain configuration rather than PostgreSQL ENUM values so a
-- later approved state machine can be versioned without rewriting historical
-- report records or replacing database types.
--
-- A status code is unique only within its lifecycle version. Historical
-- lifecycle versions may therefore retain their own status vocabulary.
-- =============================================================================

create table public.report_status_definitions (
    id uuid primary key
        default gen_random_uuid(),

    lifecycle_version_id uuid not null
        references public.report_lifecycle_versions(id)
        on delete restrict,

    code text not null,

    name text not null,

    description text,

    display_order integer not null,

    is_enabled boolean not null
        default true,

    created_at timestamp with time zone not null
        default now(),

    constraint uq_report_status_definitions_version_code
        unique (
            lifecycle_version_id,
            code
        ),

    constraint uq_report_status_definitions_id_version
        unique (
            id,
            lifecycle_version_id
        ),

    constraint uq_report_status_definitions_version_display_order
        unique (
            lifecycle_version_id,
            display_order
        ),

    constraint chk_report_status_definitions_code
        check (
            char_length(btrim(code)) between 2 and 64
        ),

    constraint chk_report_status_definitions_name
        check (
            char_length(btrim(name)) between 1 and 100
        ),

    constraint chk_report_status_definitions_description
        check (
            description is null
            or char_length(btrim(description)) between 1 and 1000
        ),

    constraint chk_report_status_definitions_display_order
        check (
            display_order > 0
        )
);


comment on table public.report_status_definitions is
'Versioned HelpHub report-status definitions. Task 04.6 creates the configuration structure only and does not seed final workflow statuses.';

comment on column public.report_status_definitions.lifecycle_version_id is
'Report lifecycle configuration version that owns this status definition.';

comment on column public.report_status_definitions.code is
'Stable machine-readable status code within one report lifecycle configuration version.';

comment on column public.report_status_definitions.name is
'Human-readable status name defined by the approved lifecycle configuration.';

comment on column public.report_status_definitions.description is
'Optional non-secret explanation of the operational meaning of this configured report status.';

comment on column public.report_status_definitions.display_order is
'Deterministic administrative display position within one lifecycle configuration version.';

comment on column public.report_status_definitions.is_enabled is
'Whether this status definition is available within the associated lifecycle configuration snapshot.';

comment on column public.report_status_definitions.created_at is
'Database-generated timestamp when this versioned status definition was created.';


-- =============================================================================
-- 2.1 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Status definitions are protected workflow configuration.
-- No client-facing mutation privileges are introduced here.
-- =============================================================================

alter table public.report_status_definitions
    enable row level security;

revoke all privileges
on table public.report_status_definitions
from public, anon, authenticated, service_role;

grant select
on table public.report_status_definitions
to service_role;

-- =============================================================================
-- 3. VERSIONED REPORT STATUS TRANSITIONS
-- =============================================================================
--
-- This table describes which configured status-to-status transitions are
-- allowed inside one report lifecycle configuration version.
--
-- Task 04.6 seeds no production transitions.
--
-- Repeating lifecycle_version_id beside both status identifiers is
-- intentional. Composite foreign keys use it to guarantee that the FROM and
-- TO statuses belong to the same lifecycle configuration snapshot.
--
-- This provides the structural foundation for an approved state machine
-- without inventing its actual workflow.
-- =============================================================================

create table public.report_status_transitions (
    id uuid primary key
        default gen_random_uuid(),

    lifecycle_version_id uuid not null
        references public.report_lifecycle_versions(id)
        on delete restrict,

    from_status_id uuid not null,

    to_status_id uuid not null,

    notes text,

    is_enabled boolean not null
        default true,

    created_at timestamp with time zone not null
        default now(),

    constraint fk_report_status_transitions_from_status_version
        foreign key (
            from_status_id,
            lifecycle_version_id
        )
        references public.report_status_definitions (
            id,
            lifecycle_version_id
        )
        on delete restrict,

    constraint fk_report_status_transitions_to_status_version
        foreign key (
            to_status_id,
            lifecycle_version_id
        )
        references public.report_status_definitions (
            id,
            lifecycle_version_id
        )
        on delete restrict,

    constraint uq_report_status_transitions_version_from_to
        unique (
            lifecycle_version_id,
            from_status_id,
            to_status_id
        ),

    constraint uq_report_status_transitions_id_version
        unique (
            id,
            lifecycle_version_id
        ),

    constraint chk_report_status_transitions_distinct_statuses
        check (
            from_status_id <> to_status_id
        ),

    constraint chk_report_status_transitions_notes
        check (
            notes is null
            or char_length(btrim(notes)) between 1 and 1000
        )
);


create index idx_report_status_transitions_from_status
on public.report_status_transitions (
    lifecycle_version_id,
    from_status_id
);


create index idx_report_status_transitions_to_status
on public.report_status_transitions (
    lifecycle_version_id,
    to_status_id
);


comment on table public.report_status_transitions is
'Versioned HelpHub report lifecycle transition configuration. Rows identify permitted status-to-status relationships inside one lifecycle version; Task 04.6 seeds no final workflow transitions.';

comment on column public.report_status_transitions.lifecycle_version_id is
'Report lifecycle configuration version that owns this permitted transition.';

comment on column public.report_status_transitions.from_status_id is
'Configured status from which this transition originates. Composite foreign-key enforcement requires it to belong to lifecycle_version_id.';

comment on column public.report_status_transitions.to_status_id is
'Configured status reached by this transition. Composite foreign-key enforcement requires it to belong to lifecycle_version_id.';

comment on column public.report_status_transitions.notes is
'Optional non-secret administrative explanation of this configured status transition.';

comment on column public.report_status_transitions.is_enabled is
'Whether this transition relationship is available within the associated lifecycle configuration snapshot.';

comment on column public.report_status_transitions.created_at is
'Database-generated timestamp when this versioned transition definition was created.';


-- =============================================================================
-- 3.1 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Transition definitions are protected workflow configuration.
-- No direct client mutation privileges are introduced here.
-- =============================================================================

alter table public.report_status_transitions
    enable row level security;

revoke all privileges
on table public.report_status_transitions
from public, anon, authenticated, service_role;

grant select
on table public.report_status_transitions
to service_role;

-- =============================================================================
-- 4. CURRENT REPORT LIFECYCLE STATE
-- =============================================================================
--
-- This table stores the current operational lifecycle status of a normal
-- HelpHub report without modifying the raw Resident-submission record in
-- public.reports.
--
-- One report may have at most one current lifecycle-state row.
--
-- Task 04.6 does not seed lifecycle versions, statuses, or current-state rows.
-- A report therefore receives a lifecycle state only through a later
-- authoritative server-side workflow operation after an approved lifecycle
-- configuration exists.
--
-- Repeating lifecycle_version_id beside current_status_id is intentional.
-- The composite foreign key guarantees that the current status belongs to the
-- exact lifecycle configuration snapshot recorded for the report.
--
-- Direct client mutation is deliberately not introduced here.
-- =============================================================================

create table public.report_lifecycle_states (
    report_id uuid primary key
        references public.reports(id)
        on delete restrict,

    lifecycle_version_id uuid not null
        references public.report_lifecycle_versions(id)
        on delete restrict,

    current_status_id uuid not null,

    status_changed_by uuid
        references public.profiles(id)
        on delete restrict,

    status_changed_at timestamp with time zone not null
        default now(),

    created_at timestamp with time zone not null
        default now(),

    updated_at timestamp with time zone not null
        default now(),

    constraint fk_report_lifecycle_states_current_status_version
        foreign key (
            current_status_id,
            lifecycle_version_id
        )
        references public.report_status_definitions (
            id,
            lifecycle_version_id
        )
        on delete restrict,

    constraint chk_report_lifecycle_states_updated_after_created
        check (
            updated_at >= created_at
        ),

    constraint chk_report_lifecycle_states_status_changed_after_created
        check (
            status_changed_at >= created_at
        )
);


create index idx_report_lifecycle_states_status
on public.report_lifecycle_states (
    lifecycle_version_id,
    current_status_id,
    status_changed_at,
    report_id
);


comment on table public.report_lifecycle_states is
'Current operational lifecycle snapshot for a HelpHub normal concern report. Raw Resident submission data remains in public.reports, while status history is stored separately.';

comment on column public.report_lifecycle_states.report_id is
'Normal concern report whose current operational lifecycle state is represented by this row. One report has at most one current-state row.';

comment on column public.report_lifecycle_states.lifecycle_version_id is
'Versioned report lifecycle configuration governing the current status of this report.';

comment on column public.report_lifecycle_states.current_status_id is
'Current configured report status. Composite foreign-key enforcement requires this status to belong to lifecycle_version_id.';

comment on column public.report_lifecycle_states.status_changed_by is
'HelpHub profile associated with the most recent authoritative status change; may be NULL for future system-generated operations.';

comment on column public.report_lifecycle_states.status_changed_at is
'Timestamp when the report most recently entered current_status_id.';

comment on column public.report_lifecycle_states.created_at is
'Database timestamp when lifecycle tracking was first established for this report.';

comment on column public.report_lifecycle_states.updated_at is
'Timestamp when this current operational lifecycle snapshot was most recently updated.';


-- =============================================================================
-- 4.1 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Current lifecycle state is authoritative operational data.
--
-- Direct client INSERT, UPDATE, and DELETE access is not introduced.
-- Later protected server-side workflow operations will perform lifecycle
-- changes atomically with status-history and audit-event creation.
-- =============================================================================

alter table public.report_lifecycle_states
    enable row level security;

revoke all privileges
on table public.report_lifecycle_states
from public, anon, authenticated, service_role;

-- The protected backend may inspect the current operational snapshot.
-- Mutation remains reserved for later authoritative database operations.
grant select
on table public.report_lifecycle_states
to service_role;

-- =============================================================================
-- 5. APPEND-ONLY REPORT STATUS HISTORY
-- =============================================================================
--
-- A current operational snapshot is useful for fast reads, but it must never
-- replace the complete lifecycle history required for traceability.
--
-- Each successful authoritative lifecycle operation will later:
--
--   1. validate authorization and lock the report/current-state row;
--   2. validate the configured lifecycle transition;
--   3. append one immutable audit_events row;
--   4. append one report_status_history row linked to that audit event;
--   5. update report_lifecycle_states;
--   6. commit all changes atomically.
--
-- This section establishes the history structure only. It does not implement
-- the authoritative transition operation yet.
--
-- Initial lifecycle establishment:
--
--   from_status_id = NULL
--   transition_id  = NULL
--   to_status_id   = the configured status selected by the later authoritative
--                    initialization operation
--
-- Task 04.6 does not decide which configured status is initial.
--
-- Every later status change must identify a configured transition whose
-- lifecycle version, FROM status, and TO status exactly match the history row.
--
-- Every history row must also reference an audit event. This prevents a
-- lifecycle-history record from existing without corresponding audit evidence.
-- =============================================================================


-- This additional candidate key allows report_status_history to use one
-- composite foreign key proving that transition_id corresponds to the exact
-- lifecycle version, FROM status, and TO status recorded by the history row.
alter table public.report_status_transitions
    add constraint uq_report_status_transitions_id_version_from_to
    unique (
        id,
        lifecycle_version_id,
        from_status_id,
        to_status_id
    );


create table public.report_status_history (
    id uuid primary key
        default gen_random_uuid(),

    report_id uuid not null
        references public.reports(id)
        on delete restrict,

    -- Explicit ordering avoids relying only on timestamps when several
    -- lifecycle operations occur close together.
    sequence_number integer not null,

    lifecycle_version_id uuid not null
        references public.report_lifecycle_versions(id)
        on delete restrict,

    -- NULL only for the first lifecycle-history record for a report.
    from_status_id uuid,

    to_status_id uuid not null,

    -- NULL only for initial lifecycle establishment.
    transition_id uuid,

    changed_by uuid
        references public.profiles(id)
        on delete restrict,

    changed_at timestamp with time zone not null
        default now(),

    change_note text,

    -- Every authoritative status-history record must be linked to an
    -- immutable audit event.
    audit_event_id uuid not null
        references public.audit_events(id)
        on delete restrict,

    constraint uq_report_status_history_report_sequence
        unique (
            report_id,
            sequence_number
        ),

    constraint uq_report_status_history_audit_event
        unique (
            audit_event_id
        ),

    constraint chk_report_status_history_sequence
        check (
            sequence_number > 0
        ),

    constraint fk_report_status_history_from_status_version
        foreign key (
            from_status_id,
            lifecycle_version_id
        )
        references public.report_status_definitions (
            id,
            lifecycle_version_id
        )
        on delete restrict,

    constraint fk_report_status_history_to_status_version
        foreign key (
            to_status_id,
            lifecycle_version_id
        )
        references public.report_status_definitions (
            id,
            lifecycle_version_id
        )
        on delete restrict,

    constraint fk_report_status_history_transition_version_from_to
        foreign key (
            transition_id,
            lifecycle_version_id,
            from_status_id,
            to_status_id
        )
        references public.report_status_transitions (
            id,
            lifecycle_version_id,
            from_status_id,
            to_status_id
        )
        on delete restrict,

    -- Initial lifecycle establishment has neither a previous status nor a
    -- configured transition. Every later history row must have both.
    constraint chk_report_status_history_transition_pair
        check (
            (
                from_status_id is null
                and transition_id is null
            )
            or
            (
                from_status_id is not null
                and transition_id is not null
            )
        ),

    constraint chk_report_status_history_change_note
        check (
            change_note is null
            or char_length(btrim(change_note)) between 1 and 2000
        )
);


create index idx_report_status_history_report_changed
on public.report_status_history (
    report_id,
    changed_at desc,
    id
);


create index idx_report_status_history_to_status_changed
on public.report_status_history (
    lifecycle_version_id,
    to_status_id,
    changed_at desc,
    report_id
);


comment on table public.report_status_history is
'Append-only lifecycle history for HelpHub normal concern reports. Each authoritative history row is linked to immutable audit evidence and preserves the lifecycle configuration version used.';

comment on column public.report_status_history.report_id is
'Normal concern report whose lifecycle history contains this event.';

comment on column public.report_status_history.sequence_number is
'Positive per-report ordering value assigned by the later authoritative lifecycle operation.';

comment on column public.report_status_history.lifecycle_version_id is
'Versioned lifecycle configuration governing this recorded status event.';

comment on column public.report_status_history.from_status_id is
'Previous configured status. NULL only for initial lifecycle establishment.';

comment on column public.report_status_history.to_status_id is
'Configured status entered by this lifecycle-history event.';

comment on column public.report_status_history.transition_id is
'Configured permitted transition used for this status change. NULL only for initial lifecycle establishment.';

comment on column public.report_status_history.changed_by is
'HelpHub profile associated with the authoritative lifecycle operation; may be NULL for future system-generated operations.';

comment on column public.report_status_history.changed_at is
'Database timestamp recording when this lifecycle-history event was created.';

comment on column public.report_status_history.change_note is
'Optional non-secret administrative note associated with this lifecycle event.';

comment on column public.report_status_history.audit_event_id is
'Immutable HelpHub audit event corresponding to this authoritative lifecycle-history event.';


-- =============================================================================
-- 5.1 APPEND-ONLY DATABASE PROTECTION
-- =============================================================================
--
-- Privileges alone are not sufficient protection because future privileged
-- code could accidentally receive UPDATE or DELETE access.
--
-- A database trigger therefore rejects mutation of existing history rows.
-- =============================================================================

create or replace function public.prevent_report_status_history_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
    raise exception
        'HelpHub report status history is append-only and cannot be updated or deleted'
        using errcode = '55000';
end;
$function$;


revoke all
on function public.prevent_report_status_history_mutation()
from public, anon, authenticated, service_role;


create trigger trg_report_status_history_prevent_mutation
before update or delete
on public.report_status_history
for each row
execute function public.prevent_report_status_history_mutation();


comment on function public.prevent_report_status_history_mutation() is
'Rejects UPDATE and DELETE operations on HelpHub append-only report status history.';


-- =============================================================================
-- 5.2 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Residents and administrators will later receive carefully scoped SELECT
-- policies for report tracking and administration.
--
-- Direct lifecycle-history creation from Flutter is not permitted.
-- INSERT will later occur only through the authoritative server-side lifecycle
-- operation so history, current state, transition validation, and audit
-- evidence remain atomic.
-- =============================================================================

alter table public.report_status_history
    enable row level security;

revoke all privileges
on table public.report_status_history
from public, anon, authenticated, service_role;

grant select
on table public.report_status_history
to service_role;

-- =============================================================================
-- 5.3 INITIAL HISTORY STRUCTURAL INVARIANTS
-- =============================================================================
--
-- The first lifecycle-history event for a report has sequence_number = 1 and
-- represents lifecycle establishment rather than a status-to-status
-- transition.
--
-- Every later history event has sequence_number > 1 and must identify both
-- its previous status and configured transition.
--
-- These are structural history-integrity rules only. They do not determine
-- which configured status is the approved initial HelpHub status.
-- =============================================================================

alter table public.report_status_history
    add constraint chk_report_status_history_sequence_role
    check (
        (
            sequence_number = 1
            and from_status_id is null
            and transition_id is null
        )
        or
        (
            sequence_number > 1
            and from_status_id is not null
            and transition_id is not null
        )
    );


-- At most one lifecycle-establishment event may exist for each report.
create unique index uq_report_status_history_one_initial
on public.report_status_history (
    report_id
)
where from_status_id is null
  and transition_id is null;

-- =============================================================================
-- 6. CURRENT REPORT ROUTING / ASSIGNMENT STATE
-- =============================================================================
--
-- This table stores the current operational routing destination for a normal
-- HelpHub report.
--
-- The destination is always a versioned public.routing_destinations row.
-- Its existing destination_kind identifies whether the current handling is:
--
--   internal_handler
--       Internal Barangay handling.
--
--   external_referral
--       Manual referral/coordination with an outside organization or service.
--
-- An external_referral record does NOT mean the outside organization is a
-- HelpHub user, receives automatic dispatch, has accepted the concern, or is
-- integrated with HelpHub.
--
-- No actual handler names, offices, agencies, or routing destinations are
-- seeded by Task 04.6.
--
-- This table represents the current routing snapshot only. Append-only routing
-- history will be stored separately.
-- =============================================================================


-- public.reports.id is already globally unique as the primary key.
--
-- This additional candidate key exists specifically so routing records can use
-- a composite foreign key proving that their taxonomy_version_id is the exact
-- taxonomy version recorded on the report.
alter table public.reports
    add constraint uq_reports_id_taxonomy
    unique (
        id,
        taxonomy_version_id
    );


create table public.report_routing_states (
    report_id uuid primary key,

    taxonomy_version_id uuid not null,

    routing_version_id uuid not null,

    destination_id uuid not null,

    routed_by uuid
        references public.profiles(id)
        on delete restrict,

    routed_at timestamp with time zone not null
        default now(),

    created_at timestamp with time zone not null
        default now(),

    updated_at timestamp with time zone not null
        default now(),

    -- Prove that taxonomy_version_id is the same taxonomy snapshot recorded on
    -- the raw Resident report.
    constraint fk_report_routing_states_report_taxonomy
        foreign key (
            report_id,
            taxonomy_version_id
        )
        references public.reports (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    -- Existing routing_config_versions already exposes the candidate key
    -- (id, taxonomy_version_id). This guarantees that the routing
    -- configuration belongs to the report's taxonomy snapshot.
    constraint fk_report_routing_states_routing_taxonomy
        foreign key (
            routing_version_id,
            taxonomy_version_id
        )
        references public.routing_config_versions (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    -- Existing routing_destinations exposes the candidate key
    -- (id, routing_version_id). This guarantees that the actual destination
    -- belongs to the routing configuration recorded above.
    constraint fk_report_routing_states_destination_version
        foreign key (
            destination_id,
            routing_version_id
        )
        references public.routing_destinations (
            id,
            routing_version_id
        )
        on delete restrict,

    constraint chk_report_routing_states_updated_after_created
        check (
            updated_at >= created_at
        ),

    constraint chk_report_routing_states_routed_after_created
        check (
            routed_at >= created_at
        )
);


create index idx_report_routing_states_destination
on public.report_routing_states (
    routing_version_id,
    destination_id,
    routed_at,
    report_id
);


comment on table public.report_routing_states is
'Current operational routing snapshot for a HelpHub normal concern report. The referenced versioned destination may represent internal Barangay handling or manual external referral; this table does not imply outside-system integration or automatic dispatch.';

comment on column public.report_routing_states.report_id is
'Normal concern report whose current operational routing destination is represented by this row. One report has at most one current routing-state row.';

comment on column public.report_routing_states.taxonomy_version_id is
'Concern taxonomy snapshot copied structurally for composite foreign-key enforcement against both the report and routing configuration.';

comment on column public.report_routing_states.routing_version_id is
'Versioned routing configuration governing the current routing destination.';

comment on column public.report_routing_states.destination_id is
'Versioned routing destination currently recorded for this report. Its destination_kind distinguishes internal_handler from external_referral.';

comment on column public.report_routing_states.routed_by is
'HelpHub profile associated with the most recent authoritative routing action; may be NULL for future system-generated routing operations.';

comment on column public.report_routing_states.routed_at is
'Timestamp when this routing destination became the current operational destination for the report.';

comment on column public.report_routing_states.created_at is
'Database timestamp when operational routing tracking was first established for this report.';

comment on column public.report_routing_states.updated_at is
'Timestamp when the current routing snapshot was most recently updated.';


-- =============================================================================
-- 6.1 ROUTING POLICY BOUNDARY
-- =============================================================================
--
-- This structural table deliberately does not decide whether an administrator
-- may manually override a concern type's configured route.
--
-- The later authoritative routing operation must validate the active routing
-- configuration, concern type, configured concern_type_routes mapping, and any
-- formally approved manual-override policy.
--
-- This prevents Task 04.6 from inventing an administrative override rule.
-- =============================================================================


-- =============================================================================
-- 6.2 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Direct Flutter INSERT, UPDATE, and DELETE operations are not permitted.
--
-- Later protected server-side routing operations will atomically create
-- routing history, update this current snapshot, and append audit evidence.
-- =============================================================================

alter table public.report_routing_states
    enable row level security;

revoke all privileges
on table public.report_routing_states
from public, anon, authenticated, service_role;

grant select
on table public.report_routing_states
to service_role;

-- =============================================================================
-- 7. APPEND-ONLY REPORT ROUTING / ASSIGNMENT HISTORY
-- =============================================================================
--
-- This table preserves every authoritative routing, assignment, reassignment,
-- or referral destination recorded for a normal HelpHub concern report.
--
-- report_routing_states stores only the current operational snapshot.
-- report_routing_history preserves the complete ordered routing record.
--
-- A history destination remains a versioned routing_destinations row. Its
-- existing destination_kind determines whether the recorded action represents:
--
--   internal_handler
--       Internal Barangay handling.
--
--   external_referral
--       Manual referral or coordination with an outside organization/service.
--
-- external_referral does NOT imply:
--   - an external HelpHub account;
--   - automatic dispatch;
--   - electronic integration;
--   - acceptance or acknowledgement by the outside organization.
--
-- Task 04.6 does not seed actual routing destinations or decide whether an
-- administrator may override a configured concern_type_routes mapping.
--
-- Every history row requires immutable audit evidence.
-- =============================================================================

create table public.report_routing_history (
    id uuid primary key
        default gen_random_uuid(),

    report_id uuid not null,

    -- Explicit per-report ordering makes routing history deterministic without
    -- relying only on timestamps.
    sequence_number integer not null,

    taxonomy_version_id uuid not null,

    routing_version_id uuid not null,

    destination_id uuid not null,

    routed_by uuid
        references public.profiles(id)
        on delete restrict,

    routed_at timestamp with time zone not null
        default now(),

    routing_note text,

    audit_event_id uuid not null
        references public.audit_events(id)
        on delete restrict,

    -- The taxonomy version carried by this history record must be the exact
    -- taxonomy version preserved on the raw Resident report.
    constraint fk_report_routing_history_report_taxonomy
        foreign key (
            report_id,
            taxonomy_version_id
        )
        references public.reports (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    -- The routing configuration must belong to that same taxonomy snapshot.
    constraint fk_report_routing_history_routing_taxonomy
        foreign key (
            routing_version_id,
            taxonomy_version_id
        )
        references public.routing_config_versions (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    -- The recorded destination must belong to the recorded routing version.
    constraint fk_report_routing_history_destination_version
        foreign key (
            destination_id,
            routing_version_id
        )
        references public.routing_destinations (
            id,
            routing_version_id
        )
        on delete restrict,

    constraint uq_report_routing_history_report_sequence
        unique (
            report_id,
            sequence_number
        ),

    -- One immutable audit event represents one authoritative routing-history
    -- event.
    constraint uq_report_routing_history_audit_event
        unique (
            audit_event_id
        ),

    constraint chk_report_routing_history_sequence
        check (
            sequence_number > 0
        ),

    constraint chk_report_routing_history_note
        check (
            routing_note is null
            or char_length(btrim(routing_note)) between 1 and 2000
        ),

    -- This candidate key will allow the current routing snapshot to be linked
    -- later to the exact routing-history event that produced it.
    constraint uq_report_routing_history_snapshot_source
        unique (
            id,
            report_id,
            taxonomy_version_id,
            routing_version_id,
            destination_id
        )
);


create index idx_report_routing_history_report_routed
on public.report_routing_history (
    report_id,
    sequence_number,
    routed_at,
    id
);


create index idx_report_routing_history_destination_routed
on public.report_routing_history (
    routing_version_id,
    destination_id,
    routed_at desc,
    report_id
);


comment on table public.report_routing_history is
'Append-only routing, assignment, reassignment, and referral history for HelpHub normal concern reports. Destinations remain versioned configuration references and external_referral does not imply outside-system integration or automatic dispatch.';

comment on column public.report_routing_history.report_id is
'Normal concern report whose routing history contains this event.';

comment on column public.report_routing_history.sequence_number is
'Positive deterministic per-report ordering value assigned by the later authoritative routing operation.';

comment on column public.report_routing_history.taxonomy_version_id is
'Concern taxonomy version preserved for compatibility enforcement against the report and routing configuration.';

comment on column public.report_routing_history.routing_version_id is
'Versioned routing configuration used for this recorded routing action.';

comment on column public.report_routing_history.destination_id is
'Versioned routing destination recorded by this history event. destination_kind distinguishes internal_handler from external_referral.';

comment on column public.report_routing_history.routed_by is
'HelpHub profile associated with this authoritative routing action; may be NULL for future system-generated routing operations.';

comment on column public.report_routing_history.routed_at is
'Database timestamp recording when this routing-history event was created.';

comment on column public.report_routing_history.routing_note is
'Optional non-secret administrative note associated with this routing, assignment, reassignment, or referral event.';

comment on column public.report_routing_history.audit_event_id is
'Immutable HelpHub audit event corresponding to this authoritative routing-history event.';


-- =============================================================================
-- 7.1 APPEND-ONLY DATABASE PROTECTION
-- =============================================================================
--
-- Routing history is evidence of what actually happened to a report.
-- Existing rows must therefore never be silently rewritten or deleted.
-- =============================================================================

create or replace function public.prevent_report_routing_history_mutation()
returns trigger
language plpgsql
security definer
set search_path = ''
as $function$
begin
    raise exception
        'HelpHub report routing history is append-only and cannot be updated or deleted'
        using errcode = '55000';
end;
$function$;


revoke all
on function public.prevent_report_routing_history_mutation()
from public, anon, authenticated, service_role;


create trigger trg_report_routing_history_prevent_mutation
before update or delete
on public.report_routing_history
for each row
execute function public.prevent_report_routing_history_mutation();


comment on function public.prevent_report_routing_history_mutation() is
'Rejects UPDATE and DELETE operations on HelpHub append-only report routing history.';


-- =============================================================================
-- 7.2 DENY-BY-DEFAULT SECURITY BASELINE
-- =============================================================================
--
-- Direct routing-history creation from Flutter is not permitted.
--
-- A later protected server-side routing operation will:
--
--   1. authorize and lock the report/current routing state;
--   2. validate the applicable routing configuration and policy;
--   3. append immutable audit evidence;
--   4. append the linked routing-history event;
--   5. update the current routing snapshot;
--   6. commit atomically.
--
-- Resident/Admin read policies will be designed and tested separately.
-- =============================================================================

alter table public.report_routing_history
    enable row level security;

revoke all privileges
on table public.report_routing_history
from public, anon, authenticated, service_role;

grant select
on table public.report_routing_history
to service_role;

-- =============================================================================
-- 8. CURRENT SNAPSHOT → IMMUTABLE HISTORY LINKAGE
-- =============================================================================
--
-- Current operational snapshots must never exist independently of the
-- permanent history event that produced them.
--
-- This section links:
--
--   report_lifecycle_states
--       → exact report_status_history event
--
--   report_routing_states
--       → exact report_routing_history event
--
-- Composite foreign keys also prove that the history event describes the same
-- report and the same current configured state recorded by the snapshot.
--
-- No workflow status, routing destination, or policy value is introduced by
-- these structural traceability constraints.
-- =============================================================================


-- =============================================================================
-- 8.1 LIFECYCLE SNAPSHOT SOURCE
-- =============================================================================
--
-- This candidate key allows the current lifecycle snapshot to reference the
-- exact immutable status-history event whose TO status became current.
-- =============================================================================

alter table public.report_status_history
    add constraint uq_report_status_history_snapshot_source
    unique (
        id,
        report_id,
        lifecycle_version_id,
        to_status_id
    );


alter table public.report_lifecycle_states
    add column source_history_id uuid not null;


alter table public.report_lifecycle_states
    add constraint fk_report_lifecycle_states_source_history
    foreign key (
        source_history_id,
        report_id,
        lifecycle_version_id,
        current_status_id
    )
    references public.report_status_history (
        id,
        report_id,
        lifecycle_version_id,
        to_status_id
    )
    on delete restrict;


comment on column public.report_lifecycle_states.source_history_id is
'Immutable report status-history event that produced this current lifecycle snapshot. Composite foreign-key enforcement guarantees matching report, lifecycle version, and current status.';


-- =============================================================================
-- 8.2 ROUTING SNAPSHOT SOURCE
-- =============================================================================
--
-- report_routing_history already exposes
-- uq_report_routing_history_snapshot_source:
--
--   (id, report_id, taxonomy_version_id, routing_version_id, destination_id)
--
-- Use that candidate key to prove that the current routing snapshot matches
-- one exact immutable routing-history event.
-- =============================================================================

alter table public.report_routing_states
    add column source_history_id uuid not null;


alter table public.report_routing_states
    add constraint fk_report_routing_states_source_history
    foreign key (
        source_history_id,
        report_id,
        taxonomy_version_id,
        routing_version_id,
        destination_id
    )
    references public.report_routing_history (
        id,
        report_id,
        taxonomy_version_id,
        routing_version_id,
        destination_id
    )
    on delete restrict;


comment on column public.report_routing_states.source_history_id is
'Immutable report routing-history event that produced this current routing snapshot. Composite foreign-key enforcement guarantees matching report, taxonomy version, routing version, and destination.';

-- =============================================================================
-- 9. OPERATIONAL REPORT READ POLICIES
-- =============================================================================
--
-- Residents require report tracking for their own submitted concerns.
-- Barangay Administrators require report visibility for administrative
-- handling.
--
-- These policies expose READ access only.
--
-- Residents:
--   - must have an approved Resident profile;
--   - may read operational records only when the parent public.reports row
--     belongs to auth.uid().
--
-- Approved Barangay Administrators:
--   - may read operational lifecycle and routing records for all reports.
--
-- INSERT, UPDATE, and DELETE remain unavailable to authenticated clients.
-- Authoritative lifecycle/routing mutation will later occur only through
-- protected server-side operations.
-- =============================================================================


-- =============================================================================
-- 9.1 CURRENT LIFECYCLE STATE
-- =============================================================================

create policy report_lifecycle_states_select_own_approved_resident
on public.report_lifecycle_states
for select
to authenticated
using (
    public.is_approved_resident()
    and exists (
        select 1
        from public.reports as r
        where r.id = report_lifecycle_states.report_id
          and r.resident_id = auth.uid()
    )
);


create policy report_lifecycle_states_select_approved_admin
on public.report_lifecycle_states
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


-- =============================================================================
-- 9.2 STATUS HISTORY
-- =============================================================================

create policy report_status_history_select_own_approved_resident
on public.report_status_history
for select
to authenticated
using (
    public.is_approved_resident()
    and exists (
        select 1
        from public.reports as r
        where r.id = report_status_history.report_id
          and r.resident_id = auth.uid()
    )
);


create policy report_status_history_select_approved_admin
on public.report_status_history
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


-- =============================================================================
-- 9.3 CURRENT ROUTING / ASSIGNMENT STATE
-- =============================================================================

create policy report_routing_states_select_own_approved_resident
on public.report_routing_states
for select
to authenticated
using (
    public.is_approved_resident()
    and exists (
        select 1
        from public.reports as r
        where r.id = report_routing_states.report_id
          and r.resident_id = auth.uid()
    )
);


create policy report_routing_states_select_approved_admin
on public.report_routing_states
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


-- =============================================================================
-- 9.4 ROUTING / ASSIGNMENT HISTORY
-- =============================================================================

create policy report_routing_history_select_own_approved_resident
on public.report_routing_history
for select
to authenticated
using (
    public.is_approved_resident()
    and exists (
        select 1
        from public.reports as r
        where r.id = report_routing_history.report_id
          and r.resident_id = auth.uid()
    )
);


create policy report_routing_history_select_approved_admin
on public.report_routing_history
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


-- =============================================================================
-- 9.5 TABLE PRIVILEGES
-- =============================================================================
--
-- RLS determines which rows an authenticated identity may see.
-- Table privileges determine which SQL operations that identity may attempt.
--
-- Grant only SELECT. No direct client INSERT, UPDATE, or DELETE is granted.
-- =============================================================================

grant select
on table
    public.report_lifecycle_states,
    public.report_status_history,
    public.report_routing_states,
    public.report_routing_history
to authenticated;

-- =============================================================================
-- 10. CONFIGURABLE INITIAL LIFECYCLE STATUS
-- =============================================================================
--
-- The approved lifecycle configuration must eventually identify which one of
-- its versioned status definitions is used when lifecycle tracking is first
-- established for a report.
--
-- Task 04.6 does NOT decide the status name or code.
--
-- Draft lifecycle configurations may temporarily contain no initial status.
-- PostgreSQL enforces that a lifecycle version can never contain more than one
-- status marked as initial.
--
-- A later protected lifecycle-configuration activation operation must verify
-- that exactly one enabled initial status exists before activating a version.
-- =============================================================================

alter table public.report_status_definitions
    add column is_initial boolean not null
        default false;


create unique index uq_report_status_definitions_one_initial
on public.report_status_definitions (
    lifecycle_version_id
)
where is_initial = true;


comment on column public.report_status_definitions.is_initial is
'Whether this versioned status is the configured lifecycle-establishment status. At most one status per lifecycle version may be initial; Task 04.6 does not seed or choose that status.';
