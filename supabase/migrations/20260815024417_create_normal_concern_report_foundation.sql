-- HelpHub
-- Task 04.5
-- Normal concern-report foundation
--
-- This migration establishes the raw resident-submitted concern data
-- foundation.
--
-- It does NOT implement:
--   - weighted priority scoring;
--   - priority classification;
--   - handler routing;
--   - response deadlines;
--   - status-history workflow;
--   - SOS/emergency records;
--   - final concern-category seed data.
--
-- Those concerns are intentionally handled by later versioned and
-- protected application/database slices.


-- ============================================================
-- 1. NORMAL CONCERN REPORT
-- ============================================================

create table public.reports (
    id uuid primary key
        default gen_random_uuid(),

    -- The authoritative HelpHub Resident who submitted the report.
    --
    -- Profiles are retained with ON DELETE RESTRICT so report history
    -- cannot silently disappear through account deletion.
    resident_id uuid not null
        references public.profiles(id)
        on delete restrict,

    -- Preserve the taxonomy version used when the Resident selected
    -- the concern type. This supports historical reproducibility.
    taxonomy_version_id uuid not null,

    -- Resident-selected concern type.
    concern_type_id uuid not null,

    -- Raw Resident description of the concern.
    description text not null,

    -- Resident-declared urgency is INPUT DATA only.
    --
    -- It is intentionally not named "priority" because authoritative
    -- HelpHub priority will later be computed server-side by the
    -- versioned rule-based weighted priority algorithm.
    --
    -- No final urgency enum/rating values are invented in this
    -- foundation migration.
    resident_declared_urgency text not null,

    -- Number of people the Resident declares as affected.
    --
    -- Zero is permitted at this database-foundation layer so this
    -- migration does not invent an unsupported minimum population
    -- interpretation. Later validated UI/API rules may be stricter
    -- when an approved factor-rating specification exists.
    affected_population integer not null,

    -- Whether the Resident indicates that a vulnerable group is
    -- affected.
    has_vulnerable_group boolean not null,

    -- Server-side submission timestamp.
    submitted_at timestamp with time zone not null
        default now(),

    -- The report must reference a concern type from the exact taxonomy
    -- version recorded on the report.
    constraint fk_reports_concern_type_taxonomy
        foreign key (
            concern_type_id,
            taxonomy_version_id
        )
        references public.concern_types (
            id,
            taxonomy_version_id
        )
        on delete restrict,

    constraint chk_reports_description
        check (
            char_length(btrim(description)) >= 1
        ),

    constraint chk_reports_resident_declared_urgency
        check (
            char_length(btrim(resident_declared_urgency)) >= 1
        ),

    constraint chk_reports_affected_population
        check (
            affected_population >= 0
        )
);


-- A Resident-report tracking query will normally filter by resident
-- and show newest submissions first.
create index idx_reports_resident_submitted
on public.reports (
    resident_id,
    submitted_at desc,
    id
);


comment on table public.reports is
'Raw normal concern reports submitted by HelpHub Residents. Algorithm outputs, status history, routing, and SOS data are intentionally stored separately.';

comment on column public.reports.resident_id is
'Authoritative profile ID of the Resident who submitted the concern report.';

comment on column public.reports.taxonomy_version_id is
'Concern taxonomy version under which the selected concern type was valid at submission time.';

comment on column public.reports.concern_type_id is
'Resident-selected versioned concern type.';

comment on column public.reports.description is
'Resident-provided description of the reported concern.';

comment on column public.reports.resident_declared_urgency is
'Raw Resident-declared urgency input. This is not the authoritative algorithm-generated priority classification.';

comment on column public.reports.affected_population is
'Resident-declared number of affected people before later algorithm normalization.';

comment on column public.reports.has_vulnerable_group is
'Resident declaration indicating whether a vulnerable group is affected.';

comment on column public.reports.submitted_at is
'Server-side timestamp recording when the normal concern report was submitted.';


-- ============================================================
-- 2. DENY-BY-DEFAULT RLS FOUNDATION
-- ============================================================
--
-- Policies and explicit privileges are added only after their behavior
-- is separately designed and tested.

alter table public.reports
enable row level security;


comment on table public.reports is
'Raw normal concern reports submitted by HelpHub Residents. RLS is enabled; algorithm results, status history, routing, and SOS data remain separate concerns.';


-- ============================================================
-- 3. NORMAL REPORT LOCATION SNAPSHOT
-- ============================================================
--
-- HelpHub stores one location snapshot for a normal concern report.
--
-- This table does NOT implement continuous resident tracking.
-- The coordinates represent the location captured for the report
-- submission only.


create table public.report_locations (
    -- One report has at most one persisted normal-report location.
    --
    -- Using report_id as the primary key provides the one-to-one
    -- relationship without introducing an unnecessary second UUID.
    report_id uuid primary key
        references public.reports(id)
        on delete restrict,

    -- WGS84 latitude in decimal degrees.
    latitude double precision not null,

    -- WGS84 longitude in decimal degrees.
    longitude double precision not null,

    -- Device-reported horizontal location accuracy in meters.
    accuracy_meters double precision not null,

    -- Time at which the device/location provider captured the
    -- coordinates. This is intentionally separate from reports.submitted_at.
    captured_at timestamp with time zone not null,

    -- Optional human-readable location supplied by reverse geocoding
    -- or another approved location-display mechanism.
    address text,

    constraint chk_report_locations_latitude
        check (
            latitude between -90.0 and 90.0
        ),

    constraint chk_report_locations_longitude
        check (
            longitude between -180.0 and 180.0
        ),

    constraint chk_report_locations_accuracy
        check (
            accuracy_meters >= 0.0
        ),

    constraint chk_report_locations_address
        check (
            address is null
            or char_length(btrim(address)) >= 1
        )
);


comment on table public.report_locations is
'One-time GPS/location snapshot associated with a normal HelpHub concern report. This table does not implement continuous resident tracking.';

comment on column public.report_locations.report_id is
'Normal concern report whose one-time location snapshot is stored by this row.';

comment on column public.report_locations.latitude is
'WGS84 latitude in decimal degrees captured for the normal concern report.';

comment on column public.report_locations.longitude is
'WGS84 longitude in decimal degrees captured for the normal concern report.';

comment on column public.report_locations.accuracy_meters is
'Device-reported horizontal location accuracy in meters at capture time.';

comment on column public.report_locations.captured_at is
'Timestamp reported for the one-time location capture associated with the concern report.';

comment on column public.report_locations.address is
'Optional human-readable address associated with the captured report location.';


-- ============================================================
-- 4. REPORT LOCATION DENY-BY-DEFAULT RLS
-- ============================================================
--
-- Policies are added only after report ownership and access behavior
-- are separately designed and tested.

alter table public.report_locations
enable row level security;


-- ============================================================
-- 5. OPTIONAL NORMAL REPORT PHOTO-EVIDENCE METADATA
-- ============================================================
--
-- The actual image object is stored in private Supabase Storage.
--
-- This table stores only the database-side reference and metadata.
-- One normal report may have zero or one photo-evidence record.


create table public.report_evidence (
    -- Using report_id as the primary key enforces zero-or-one photo
    -- evidence record per normal concern report.
    report_id uuid primary key
        references public.reports(id)
        on delete restrict,

    -- Storage bucket identifier containing the private object.
    --
    -- A direct FK to storage.buckets is intentionally deferred until
    -- the local Storage schema and private-bucket foundation are
    -- separately inspected and verified.
    bucket_id text not null,

    -- Object path inside the Storage bucket.
    object_path text not null,

    -- MIME type recorded for the uploaded object.
    content_type text not null,

    -- Size recorded for the uploaded object in bytes.
    size_bytes bigint not null,

    -- Server-side time when this metadata record was created.
    uploaded_at timestamp with time zone not null
        default now(),

    constraint chk_report_evidence_bucket_id
        check (
            char_length(btrim(bucket_id)) >= 1
        ),

    constraint chk_report_evidence_object_path
        check (
            char_length(btrim(object_path)) >= 1
        ),

    constraint chk_report_evidence_content_type
    check (
        content_type in (
            'image/jpeg',
            'image/png',
            'image/webp'
        )
    ),

    constraint chk_report_evidence_size_bytes
    check (
        size_bytes > 0
        and size_bytes <= 5242880
    )
);


comment on table public.report_evidence is
'Metadata for the optional private photo evidence associated with a normal HelpHub concern report. Actual image bytes remain in Supabase Storage.';

comment on column public.report_evidence.report_id is
'Normal concern report associated with this optional photo-evidence object.';

comment on column public.report_evidence.bucket_id is
'Private Supabase Storage bucket identifier containing the evidence object.';

comment on column public.report_evidence.object_path is
'Object path inside the private Supabase Storage bucket.';

comment on column public.report_evidence.content_type is
'MIME type recorded for the uploaded evidence object.';

comment on column public.report_evidence.size_bytes is
'Recorded evidence-object size in bytes.';

comment on column public.report_evidence.uploaded_at is
'Server-side timestamp recording creation of the evidence metadata row.';


-- ============================================================
-- 6. REPORT EVIDENCE DENY-BY-DEFAULT RLS
-- ============================================================
--
-- Storage-object policies and report-evidence access policies are
-- added only after the private bucket and ownership behavior are
-- separately designed and tested.

alter table public.report_evidence
enable row level security;


-- ============================================================
-- 7. PRIVATE NORMAL REPORT EVIDENCE STORAGE BUCKET
-- ============================================================
--
-- Actual photo bytes are stored in Supabase Storage rather than
-- PostgreSQL.
--
-- The bucket is explicitly private.
--
-- -- ENGINEERING-DEFINED SECURITY DEFAULT:
--
-- HelpHub restricts normal-report evidence to common web/mobile image
-- formats and a maximum object size of 5 MiB.
--
-- These are technical upload-security controls rather than barangay
-- policy values. They may be revised through a later documented
-- migration if compatibility or evaluation evidence requires it.

insert into storage.buckets (
    id,
    name,
    public,
    file_size_limit,
    allowed_mime_types
)
values (
    'report-evidence',
    'report-evidence',
    false,
    5242880,
    array[
        'image/jpeg',
        'image/png',
        'image/webp'
    ]::text[]
);


-- ============================================================
-- 8. REPORT EVIDENCE → STORAGE BUCKET INTEGRITY
-- ============================================================
--
-- Normal-report evidence metadata may reference only the dedicated
-- private HelpHub report-evidence bucket.


alter table public.report_evidence
alter column bucket_id
set default 'report-evidence';


alter table public.report_evidence
add constraint chk_report_evidence_bucket_fixed
check (
    bucket_id = 'report-evidence'
);


alter table public.report_evidence
add constraint fk_report_evidence_bucket
foreign key (
    bucket_id
)
references storage.buckets (
    id
)
on delete restrict;


-- ============================================================
-- 9. APPROVED RESIDENT AUTHORIZATION HELPER
-- ============================================================
--
-- Report, report-location, report-evidence, and later Storage
-- authorization repeatedly need to determine whether the current
-- authenticated identity is an approved HelpHub Resident.
--
-- public.profiles is itself protected by RLS, so this helper uses the
-- same hardened SECURITY DEFINER pattern already established for:
--
--     public.is_approved_barangay_admin()
--
-- Security precautions:
--   - every referenced object is schema-qualified;
--   - search_path is empty;
--   - broad PostgreSQL EXECUTE privilege is revoked;
--   - only authenticated users receive EXECUTE;
--   - the function returns only one boolean authorization result;
--   - the function performs no data mutation.


create or replace function public.is_approved_resident()
returns boolean
language sql
stable
security definer
set search_path = ''
as $function$
    select exists (
        select 1
        from public.profiles as p
        where p.id = auth.uid()
          and p.role = 'resident'
          and p.account_status = 'approved'
    );
$function$;


-- PostgreSQL functions normally receive EXECUTE for PUBLIC when
-- created. Remove broad access before granting only what the HelpHub
-- client authorization boundary requires.

revoke all
on function public.is_approved_resident()
from public, anon, authenticated;


-- Only authenticated identities may ask whether their authoritative
-- HelpHub profile satisfies the approved-Resident condition.
--
-- This exposes only a boolean result; it does not expose profile data.

grant execute
on function public.is_approved_resident()
to authenticated;


comment on function public.is_approved_resident() is
'Returns true only when the current authenticated HelpHub identity has an authoritative Resident profile with account_status = approved. Used by RLS authorization and performs no mutation.';


-- ============================================================
-- 10. NORMAL REPORT READ POLICIES
-- ============================================================
--
-- Approved Residents may read only their own normal-report records.
--
-- Approved Barangay Administrators may read report data required for
-- administrative handling.
--
-- No direct client INSERT, UPDATE, or DELETE policy is introduced in
-- this foundation. Raw report creation is reserved for the protected
-- backend boundary.


-- ------------------------------------------------------------
-- Reports
-- ------------------------------------------------------------

create policy reports_select_own_approved_resident
on public.reports
for select
to authenticated
using (
    public.is_approved_resident()
    and resident_id = auth.uid()
);


comment on policy reports_select_own_approved_resident
on public.reports is
'Allows an approved Resident to read only normal concern reports owned by their authenticated HelpHub identity.';


create policy reports_select_approved_admin
on public.reports
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy reports_select_approved_admin
on public.reports is
'Allows an approved Barangay Administrator to read normal concern reports for administrative handling.';


-- ------------------------------------------------------------
-- Report locations
-- ------------------------------------------------------------

create policy report_locations_select_own_approved_resident
on public.report_locations
for select
to authenticated
using (
    public.is_approved_resident()
    and exists (
        select 1
        from public.reports as r
        where r.id = report_id
          and r.resident_id = auth.uid()
    )
);


comment on policy report_locations_select_own_approved_resident
on public.report_locations is
'Allows an approved Resident to read the one-time location snapshot belonging to their own normal concern report.';


create policy report_locations_select_approved_admin
on public.report_locations
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy report_locations_select_approved_admin
on public.report_locations is
'Allows an approved Barangay Administrator to read normal concern report location snapshots for administrative handling.';


-- ------------------------------------------------------------
-- Report evidence metadata
-- ------------------------------------------------------------

create policy report_evidence_select_own_approved_resident
on public.report_evidence
for select
to authenticated
using (
    public.is_approved_resident()
    and exists (
        select 1
        from public.reports as r
        where r.id = report_id
          and r.resident_id = auth.uid()
    )
);


comment on policy report_evidence_select_own_approved_resident
on public.report_evidence is
'Allows an approved Resident to read metadata for the optional private photo evidence belonging to their own normal concern report.';


create policy report_evidence_select_approved_admin
on public.report_evidence
for select
to authenticated
using (
    public.is_approved_barangay_admin()
);


comment on policy report_evidence_select_approved_admin
on public.report_evidence is
'Allows an approved Barangay Administrator to read normal concern report evidence metadata for administrative handling.';


-- ============================================================
-- 11. EXPLICIT NORMAL REPORT TABLE PRIVILEGES
-- ============================================================
--
-- Remove inherited/default assumptions and grant only the operations
-- required by the current architecture.
--
-- anon:
--   no direct access
--
-- authenticated:
--   SELECT only; RLS determines visible rows
--
-- service_role:
--   SELECT + INSERT for protected backend report creation
--
-- UPDATE and DELETE are intentionally absent for all three application
-- roles in this raw-report foundation.


revoke all privileges
on table
    public.reports,
    public.report_locations,
    public.report_evidence
from anon, authenticated, service_role;


grant select
on table
    public.reports,
    public.report_locations,
    public.report_evidence
to authenticated;


grant select, insert
on table
    public.reports,
    public.report_locations,
    public.report_evidence
to service_role;