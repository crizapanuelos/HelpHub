-- ============================================================
-- HELP HUB TASK 04.4
-- CONCERN TAXONOMY AND HANDLER FOUNDATION
-- ============================================================
--
-- This migration establishes version-controlled database structures
-- for:
--
--   1. concern-type taxonomy
--   2. internal routing destinations
--   3. external referral destinations
--
-- No final concern types, handlers, referral organizations,
-- deadlines, or routing rules are seeded by this migration.
--
-- Configuration data will be added only through explicit versioned
-- records so historical reports can later preserve the exact
-- configuration that produced their classification and routing.


-- ============================================================
-- 1. CONCERN TAXONOMY VERSIONS
-- ============================================================
--
-- A concern taxonomy version represents one immutable activated
-- snapshot of the concern types available to HelpHub.
--
-- Lifecycle is represented through timestamps rather than a
-- hard-coded status enum:
--
--   Draft:
--       activated_at IS NULL
--       retired_at   IS NULL
--
--   Active:
--       activated_at IS NOT NULL
--       retired_at   IS NULL
--
--   Retired:
--       activated_at IS NOT NULL
--       retired_at   IS NOT NULL
--
-- Only one taxonomy version may be active at a time.
--
-- Later protected configuration operations will be responsible for
-- activation, retirement, authorization, and immutability checks.


create table public.concern_taxonomy_versions (
    id uuid primary key default gen_random_uuid(),

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

    constraint uq_concern_taxonomy_versions_number
        unique (version_number),

    constraint chk_concern_taxonomy_versions_number
        check (version_number > 0),

    constraint chk_concern_taxonomy_versions_label
        check (
            version_label is null
            or char_length(btrim(version_label)) between 1 and 100
        ),

    constraint chk_concern_taxonomy_versions_activation_pair
        check (
            (activated_at is null and activated_by is null)
            or
            (activated_at is not null and activated_by is not null)
        ),

    constraint chk_concern_taxonomy_versions_retirement_pair
        check (
            (retired_at is null and retired_by is null)
            or
            (retired_at is not null and retired_by is not null)
        ),

    constraint chk_concern_taxonomy_versions_retired_after_activation
        check (
            retired_at is null
            or (
                activated_at is not null
                and retired_at >= activated_at
            )
        )
);


-- PostgreSQL partial unique index:
-- at most one row may satisfy "activated and not retired".
create unique index uq_concern_taxonomy_versions_one_active
on public.concern_taxonomy_versions (
    (true)
)
where activated_at is not null
  and retired_at is null;


comment on table public.concern_taxonomy_versions is
'Version records for the HelpHub concern-type taxonomy. Activated versions are preserved for reproducibility rather than edited in place.';

comment on column public.concern_taxonomy_versions.version_number is
'Monotonically increasing engineering version number for a concern taxonomy snapshot.';

comment on column public.concern_taxonomy_versions.version_label is
'Optional human-readable label for this taxonomy version.';

comment on column public.concern_taxonomy_versions.notes is
'Optional non-secret administrative notes describing the taxonomy version.';

comment on column public.concern_taxonomy_versions.created_by is
'Administrator profile associated with creation of the configuration version when available.';

comment on column public.concern_taxonomy_versions.activated_at is
'Timestamp when this taxonomy version became the active HelpHub concern taxonomy.';

comment on column public.concern_taxonomy_versions.retired_at is
'Timestamp when this previously activated taxonomy version stopped being active.';


-- ============================================================
-- 2. CONCERN TYPES
-- ============================================================
--
-- Each concern type belongs to exactly one taxonomy version.
--
-- The same logical concern code may appear in multiple taxonomy
-- versions. Therefore uniqueness is enforced inside a version rather
-- than globally.
--
-- Example structural relationship:
--
--   taxonomy version 1
--       concern code A
--       concern code B
--
--   taxonomy version 2
--       concern code A
--       concern code B
--       concern code C
--
-- No actual HelpHub concern categories are seeded in this migration.
--
-- Historical reports will later reference the versioned concern type
-- selected or validated for that report.


create table public.concern_types (
    id uuid primary key default gen_random_uuid(),

    taxonomy_version_id uuid not null
        references public.concern_taxonomy_versions(id)
        on delete restrict,

    code text not null,

    name text not null,

    description text,

    display_order integer not null,

    is_enabled boolean not null default true,

    created_at timestamp with time zone not null
        default now(),

    constraint uq_concern_types_version_code
        unique (
            taxonomy_version_id,
            code
        ),

    constraint uq_concern_types_id_taxonomy
    unique (
        id,
        taxonomy_version_id
    ),

    constraint uq_concern_types_version_display_order
        unique (
            taxonomy_version_id,
            display_order
        ),

    constraint chk_concern_types_code
        check (
            char_length(btrim(code)) between 2 and 64
        ),

    constraint chk_concern_types_name
        check (
            char_length(btrim(name)) between 2 and 100
        ),

    constraint chk_concern_types_description
        check (
            description is null
            or char_length(btrim(description)) between 1 and 1000
        ),

    constraint chk_concern_types_display_order
        check (
            display_order > 0
        )
);


comment on table public.concern_types is
'Versioned HelpHub concern types available for resident concern reporting and later algorithm classification validation.';

comment on column public.concern_types.taxonomy_version_id is
'Concern taxonomy version that owns this concern-type definition.';

comment on column public.concern_types.code is
'Stable machine-readable concern-type code within one taxonomy version.';

comment on column public.concern_types.name is
'Human-readable concern-type name presented by HelpHub.';

comment on column public.concern_types.description is
'Optional description explaining the scope of this concern type.';

comment on column public.concern_types.display_order is
'Deterministic display position of this concern type within its taxonomy version.';

comment on column public.concern_types.is_enabled is
'Whether this concern type is available within the associated taxonomy snapshot.';

comment on column public.concern_types.created_at is
'Database-generated creation timestamp for this concern-type record.';


-- ============================================================
-- 3. ROUTING CONFIGURATION VERSIONS
-- ============================================================
--
-- Routing configuration is versioned separately from the concern
-- taxonomy because concern categories and routing destinations may
-- evolve independently.
--
-- One routing configuration version will later own:
--
--   - internal Barangay handlers
--   - external referral destinations
--
-- No handler names, outside organizations, deadlines, or routing
-- mappings are seeded by this migration.
--
-- Lifecycle:
--
--   Draft:
--       activated_at IS NULL
--       retired_at   IS NULL
--
--   Active:
--       activated_at IS NOT NULL
--       retired_at   IS NULL
--
--   Retired:
--       activated_at IS NOT NULL
--       retired_at   IS NOT NULL
--
-- Only one routing configuration version may be active at a time.


create table public.routing_config_versions (
    id uuid primary key default gen_random_uuid(),

    taxonomy_version_id uuid not null
        references public.concern_taxonomy_versions(id)
        on delete restrict,

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

    constraint uq_routing_config_versions_id_taxonomy
    unique (
        id,
        taxonomy_version_id
    ),

    constraint chk_routing_config_versions_number
        check (version_number > 0),

    constraint chk_routing_config_versions_label
        check (
            version_label is null
            or char_length(btrim(version_label)) between 1 and 100
        ),

    constraint chk_routing_config_versions_activation_pair
        check (
            (activated_at is null and activated_by is null)
            or
            (activated_at is not null and activated_by is not null)
        ),

    constraint chk_routing_config_versions_retirement_pair
        check (
            (retired_at is null and retired_by is null)
            or
            (retired_at is not null and retired_by is not null)
        ),

    constraint chk_routing_config_versions_retired_after_activation
        check (
            retired_at is null
            or (
                activated_at is not null
                and retired_at >= activated_at
            )
        )
);


create unique index uq_routing_config_versions_one_active
on public.routing_config_versions (
    (true)
)
where activated_at is not null
  and retired_at is null;


comment on table public.routing_config_versions is
'Version records for HelpHub routing configuration containing internal handlers and external referral destinations.';

comment on column public.routing_config_versions.taxonomy_version_id is
'Concern taxonomy version for which this routing configuration and its routing map are defined.';

comment on column public.routing_config_versions.version_number is
'Monotonically increasing engineering version number for a routing configuration snapshot.';

comment on column public.routing_config_versions.version_label is
'Optional human-readable label for this routing configuration version.';

comment on column public.routing_config_versions.notes is
'Optional non-secret administrative notes describing this routing configuration version.';

comment on column public.routing_config_versions.created_by is
'Administrator profile associated with creation of this routing configuration version when available.';

comment on column public.routing_config_versions.activated_at is
'Timestamp when this routing configuration became active for HelpHub routing decisions.';

comment on column public.routing_config_versions.retired_at is
'Timestamp when this previously activated routing configuration stopped being active.';


-- ============================================================
-- 4. ROUTING DESTINATIONS
-- ============================================================
--
-- A routing destination belongs to exactly one routing
-- configuration version.
--
-- Two engineering-defined destination kinds are supported:
--
--   internal_handler
--       A logical internal Barangay handling destination.
--
--   external_referral
--       An outside organization or service to which Barangay staff
--       may manually refer or coordinate a concern.
--
-- Important:
--
--   external_referral does NOT mean that the outside organization
--   is integrated into HelpHub, has a HelpHub account, receives an
--   automatic dispatch, or guarantees a response.
--
-- No actual offices, teams, agencies, organizations, deadlines,
-- or routing mappings are seeded by this migration.


create table public.routing_destinations (
    id uuid primary key default gen_random_uuid(),

    routing_version_id uuid not null
        references public.routing_config_versions(id)
        on delete restrict,

    code text not null,

    name text not null,

    destination_kind text not null,

    description text,

    display_order integer not null,

    is_enabled boolean not null
        default true,

    created_at timestamp with time zone not null
        default now(),

    constraint uq_routing_destinations_version_code
        unique (
            routing_version_id,
            code
        ),

    constraint uq_routing_destinations_id_version
    unique (
        id,
        routing_version_id
    ),

    constraint uq_routing_destinations_version_display_order
        unique (
            routing_version_id,
            display_order
        ),

    constraint chk_routing_destinations_code
        check (
            char_length(btrim(code)) between 2 and 64
        ),

    constraint chk_routing_destinations_name
        check (
            char_length(btrim(name)) between 2 and 150
        ),

    constraint chk_routing_destinations_kind
        check (
            destination_kind in (
                'internal_handler',
                'external_referral'
            )
        ),

    constraint chk_routing_destinations_description
        check (
            description is null
            or char_length(btrim(description)) between 1 and 1000
        ),

    constraint chk_routing_destinations_display_order
        check (
            display_order > 0
        )
);


comment on table public.routing_destinations is
'Versioned HelpHub routing destinations representing either an internal Barangay handler or an external manual referral destination.';


comment on column public.routing_destinations.routing_version_id is
'Routing configuration version that owns this routing-destination definition.';


comment on column public.routing_destinations.code is
'Stable machine-readable routing-destination code within one routing configuration version.';


comment on column public.routing_destinations.name is
'Human-readable routing-destination name shown to authorized HelpHub administrators.';


comment on column public.routing_destinations.destination_kind is
'Engineering-defined destination kind: internal_handler for Barangay handling or external_referral for manual outside coordination.';


comment on column public.routing_destinations.description is
'Optional description of the routing destination and its intended administrative use.';


comment on column public.routing_destinations.display_order is
'Deterministic administrative display position within one routing configuration version.';


comment on column public.routing_destinations.is_enabled is
'Whether this destination is available within the associated routing configuration snapshot.';


comment on column public.routing_destinations.created_at is
'Database-generated creation timestamp for this routing-destination record.';


-- ============================================================
-- 5. CONCERN TYPE ROUTING MAP
-- ============================================================
--
-- This table maps one versioned concern type to its configured
-- routing destination under one routing configuration version.
--
-- The repeated taxonomy_version_id and routing_version_id values
-- are intentional. They allow composite foreign keys to enforce
-- configuration compatibility directly in PostgreSQL.
--
-- Database-enforced requirements:
--
--   1. The routing configuration must belong to taxonomy_version_id.
--
--   2. The concern type must belong to the same taxonomy_version_id.
--
--   3. The routing destination must belong to routing_version_id.
--
-- Therefore a concern type from one taxonomy snapshot cannot be
-- accidentally connected to a routing configuration designed for
-- another taxonomy snapshot.
--
-- One concern type receives at most one configured destination
-- within a routing configuration version.
--
-- No actual concern-to-handler assignments are seeded here.


create table public.concern_type_routes (
    id uuid primary key default gen_random_uuid(),

    routing_version_id uuid not null,

    taxonomy_version_id uuid not null,

    concern_type_id uuid not null,

    destination_id uuid not null,

    is_enabled boolean not null
        default true,

    notes text,

    created_at timestamp with time zone not null
        default now(),

    constraint fk_concern_type_routes_routing_taxonomy
        foreign key (
            routing_version_id,
            taxonomy_version_id
        )
        references public.routing_config_versions (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    constraint fk_concern_type_routes_concern_taxonomy
        foreign key (
            concern_type_id,
            taxonomy_version_id
        )
        references public.concern_types (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    constraint fk_concern_type_routes_destination_version
        foreign key (
            destination_id,
            routing_version_id
        )
        references public.routing_destinations (
            id,
            routing_version_id
        )
        on delete restrict,

    constraint uq_concern_type_routes_version_concern
        unique (
            routing_version_id,
            concern_type_id
        ),

    constraint chk_concern_type_routes_notes
        check (
            notes is null
            or char_length(btrim(notes)) between 1 and 1000
        )
);


create index idx_concern_type_routes_destination
on public.concern_type_routes (
    routing_version_id,
    destination_id
);


comment on table public.concern_type_routes is
'Version-compatible mapping from a HelpHub concern type to its configured internal handler or external referral destination.';


comment on column public.concern_type_routes.routing_version_id is
'Routing configuration version that owns this concern-type routing mapping.';


comment on column public.concern_type_routes.taxonomy_version_id is
'Concern taxonomy version used to enforce compatibility between the routing configuration and concern type.';


comment on column public.concern_type_routes.concern_type_id is
'Versioned concern type being assigned a routing destination.';


comment on column public.concern_type_routes.destination_id is
'Versioned internal handler or external referral destination configured for this concern type.';


comment on column public.concern_type_routes.is_enabled is
'Whether this concern-type routing mapping is available within the routing configuration snapshot.';


comment on column public.concern_type_routes.notes is
'Optional non-secret administrative notes about this routing mapping.';


comment on column public.concern_type_routes.created_at is
'Database-generated creation timestamp for this routing mapping.';


-- ============================================================
-- 6. ROW LEVEL SECURITY BASELINE
-- ============================================================
--
-- Configuration tables are protected by RLS before any client-facing
-- SELECT policy is introduced.
--
-- Resident-facing taxonomy read policies and approved-administrator
-- configuration read policies are defined in the following sections.
--
-- No direct client INSERT, UPDATE, or DELETE access is granted here.


alter table public.concern_taxonomy_versions
    enable row level security;

alter table public.concern_types
    enable row level security;

alter table public.routing_config_versions
    enable row level security;

alter table public.routing_destinations
    enable row level security;

alter table public.concern_type_routes
    enable row level security;


comment on table public.concern_taxonomy_versions is
'RLS-protected version records for the HelpHub concern-type taxonomy. Activated versions are preserved for reproducibility rather than edited in place.';

comment on table public.concern_types is
'RLS-protected versioned HelpHub concern types used for resident concern reporting and later algorithm classification validation.';

comment on table public.routing_config_versions is
'RLS-protected version records for HelpHub routing configuration containing internal handlers and external referral destinations.';

comment on table public.routing_destinations is
'RLS-protected versioned HelpHub routing destinations representing either an internal Barangay handler or an external manual referral destination.';

comment on table public.concern_type_routes is
'RLS-protected version-compatible mapping from a HelpHub concern type to its configured internal handler or external referral destination.';


-- ============================================================
-- 7. APPROVED RESIDENT TAXONOMY READ POLICIES
-- ============================================================
--
-- Approved Residents require only the active concern taxonomy
-- needed to create a concern report.
--
-- They do NOT receive access here to:
--
--   - routing configuration versions
--   - routing destinations
--   - concern-to-routing mappings
--
-- Pending, rejected, or non-Resident authenticated users do not
-- satisfy these Resident policies.


create policy concern_taxonomy_versions_select_approved_resident_active
on public.concern_taxonomy_versions
for select
to authenticated
using (
    activated_at is not null
    and retired_at is null
    and exists (
        select 1
        from public.profiles p
        where p.id = auth.uid()
          and p.role = 'resident'
          and p.account_status = 'approved'
    )
);


comment on policy concern_taxonomy_versions_select_approved_resident_active
on public.concern_taxonomy_versions is
'Allows an approved Resident to read only the currently active concern-taxonomy version.';


create policy concern_types_select_approved_resident_active_enabled
on public.concern_types
for select
to authenticated
using (
    is_enabled = true
    and exists (
        select 1
        from public.profiles p
        where p.id = auth.uid()
          and p.role = 'resident'
          and p.account_status = 'approved'
    )
    and exists (
        select 1
        from public.concern_taxonomy_versions v
        where v.id = taxonomy_version_id
          and v.activated_at is not null
          and v.retired_at is null
    )
);


comment on policy concern_types_select_approved_resident_active_enabled
on public.concern_types is
'Allows an approved Resident to read enabled concern types belonging to the currently active concern taxonomy.';


-- ============================================================
-- 8. APPROVED BARANGAY ADMINISTRATOR CONFIGURATION READ POLICIES
-- ============================================================
--
-- Approved Barangay Administrators may inspect configuration
-- history and routing configuration required for administration.
--
-- Administrator authorization reuses the protected helper created
-- by the identity/verification foundation:
--
--     public.is_approved_barangay_admin()
--
-- These are SELECT-only RLS policies.
--
-- No direct client INSERT, UPDATE, or DELETE policy is introduced.


create policy concern_taxonomy_versions_select_approved_admin
on public.concern_taxonomy_versions
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy concern_taxonomy_versions_select_approved_admin
on public.concern_taxonomy_versions is
'Allows an approved Barangay Administrator to read concern-taxonomy version history.';


create policy concern_types_select_approved_admin
on public.concern_types
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy concern_types_select_approved_admin
on public.concern_types is
'Allows an approved Barangay Administrator to read versioned concern-type configuration.';


create policy routing_config_versions_select_approved_admin
on public.routing_config_versions
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy routing_config_versions_select_approved_admin
on public.routing_config_versions is
'Allows an approved Barangay Administrator to read routing-configuration version history.';


create policy routing_destinations_select_approved_admin
on public.routing_destinations
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy routing_destinations_select_approved_admin
on public.routing_destinations is
'Allows an approved Barangay Administrator to read internal-handler and external-referral destination configuration.';


create policy concern_type_routes_select_approved_admin
on public.concern_type_routes
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy concern_type_routes_select_approved_admin
on public.concern_type_routes is
'Allows an approved Barangay Administrator to read versioned concern-type routing mappings.';


-- ============================================================
-- 9. EXPLICIT CONFIGURATION TABLE PRIVILEGES
-- ============================================================
--
-- Supabase database roles may receive privileges through schema
-- defaults, so this migration explicitly establishes the intended
-- least-privilege boundary instead of relying on inherited defaults.
--
-- anon:
--     no direct access
--
-- authenticated:
--     SELECT only
--     RLS determines whether the authenticated user is an approved
--     Resident or approved Barangay Administrator and which rows are
--     visible.
--
-- service_role:
--     SELECT only for this foundation.
--
-- No INSERT, UPDATE, or DELETE table privilege is granted here.
-- Protected configuration mutation will be introduced separately.


revoke all privileges
on table
    public.concern_taxonomy_versions,
    public.concern_types,
    public.routing_config_versions,
    public.routing_destinations,
    public.concern_type_routes
from anon, authenticated, service_role;


grant select
on table
    public.concern_taxonomy_versions,
    public.concern_types,
    public.routing_config_versions,
    public.routing_destinations,
    public.concern_type_routes
to authenticated, service_role;