# HelpHub Development Setup

Last verified: 2026-08-12

This document records the verified local development environment for HelpHub and the architecture rules that must be followed during implementation.

## 1. Project Repository

Active development repository:

```text
C:\Users\Criza Mae Panuelos\Documents\HelpHub
```

This is the Git-controlled HelpHub repository.

An older non-Git copy also exists elsewhere on the computer. Do not use that copy as the active development repository.

## 2. Canonical Technology Stack

HelpHub uses:

- Flutter/Dart for the Android resident application and responsive web-capable administrator interface.
- Python/FastAPI for protected APIs, business rules, authorization checks, and the priority algorithm.
- Supabase PostgreSQL for application data.
- Supabase Auth for authentication.
- Supabase Storage for private report evidence.
- Supabase Realtime for supported realtime updates.
- Supabase Row Level Security (RLS) for database access control.
- Firebase Cloud Messaging (FCM) for push notifications only.
- geolocator for one-time/on-demand GPS capture.
- flutter_map with OpenStreetMap for map display.
- Docker Desktop for local Supabase services.
- Git/GitHub for source control.

Firebase Authentication, Cloud Firestore, and Firebase Storage are not the primary HelpHub backend.

Google Maps is not the selected map provider for the current architecture.

## 3. Backend Authority

Flutter is a client application.

Flutter must not be the authoritative source for:

- priority scoring;
- priority classification;
- emergency override decisions;
- handler routing;
- response deadlines;
- protected rule configuration;
- protected weight configuration;
- privileged status transitions.

These decisions belong to the protected FastAPI/backend layer.

The previous file:

```text
lib/algorithm/priority_algorithm.dart
```

was removed because it implemented priority computation inside Flutter and contained an obsolete five-level model.

The current priority names are:

- Low
- Medium
- High
- Critical

Do not reintroduce `Minimal`.

## 4. Verified Development Tools

The following environment components were verified during Stage 4 setup:

| Tool | Verified state |
|---|---|
| Git | Working |
| Node.js | v24.18.0 |
| npm | 11.16.0 |
| npx | 11.16.0 |
| Supabase CLI | 2.113.0 |
| WSL | 2.7.11.0 |
| Docker Desktop | 4.86.0 |
| Docker Engine | 29.7.2 |
| VS Code | Available |
| Flutter/Dart | Existing project toolchain; reverify before Flutter implementation |
| Android Studio | Reverify SDK/emulator before Android testing |

## 5. Windows PowerShell npm Note

On this computer, PowerShell execution policy blocks the `npm.ps1` wrapper.

Do not weaken the PowerShell execution policy just for HelpHub.

Use:

```powershell
npm.cmd
npx.cmd
```

instead of:

```powershell
npm
npx
```

when necessary.

## 6. Repository-Local Supabase CLI

The Supabase CLI is installed as a repository development dependency.

Relevant files:

```text
package.json
package-lock.json
supabase/config.toml
supabase/.gitignore
```

Verify the CLI with:

```powershell
npx.cmd supabase --version
```

Expected verified version:

```text
2.113.0
```

## 7. Docker and WSL

Local Supabase runs through Docker Desktop.

Before starting the local stack:

1. Open Docker Desktop.
2. Wait for the Docker engine to report that it is running.
3. Open PowerShell.
4. Go to:

```powershell
Set-Location "$HOME\Documents\HelpHub"
```

Verify Docker with:

```powershell
docker --version
```

and:

```powershell
docker info --format '{{.ServerVersion}}'
```

Do not expose the Docker daemon on unauthenticated TCP port `2375` merely to support optional local Analytics.

## 8. Supabase Initialization

The repository was initialized with:

```powershell
npx.cmd supabase init
```

Local configuration is stored in:

```text
supabase/config.toml
```

No production/cloud Supabase project has been linked yet.

## 9. Supabase Studio Port

The generated Studio port:

```text
54323
```

repeatedly failed to bind on this Windows environment.

The conflict was investigated by checking:

- active Windows listeners;
- remaining Docker containers;
- Windows excluded TCP port ranges.

A verified-free replacement port was selected:

```toml
[studio]
enabled = true
port = 44323
```

Local Supabase Studio therefore uses:

```text
http://127.0.0.1:44323
```

This is a local-development address only.

## 10. Local Supabase Analytics

With local Analytics enabled, the Supabase Vector container repeatedly restarted on this Windows setup.

Supabase also warned that Analytics on Windows required Docker daemon access through TCP port `2375`.

Because local Analytics is not required for HelpHub application functionality, the local configuration uses:

```toml
[analytics]
enabled = false
```

This does not disable HelpHub application audit logging.

HelpHub status history and audit events will be implemented separately in the PostgreSQL application schema.

## 11. Starting Supabase

Keep Docker Desktop running.

From the HelpHub repository:

```powershell
npx.cmd supabase start
```

Successful startup includes:

```text
Started supabase local development setup.
```

The first run may download several Docker images.

The following warning is currently expected:

```text
WARN: no files matched pattern: supabase/seed.sql
```

because application seed data has not been created yet.

## 12. Checking Local Containers

Use:

```powershell
docker ps --filter "name=supabase" --format "table {{.Names}}\t{{.Status}}"
```

Verified required services include:

- PostgreSQL database
- Auth
- Storage
- Realtime
- REST/API
- Kong
- Studio
- pgMeta
- Edge Runtime
- Inbucket/Mailpit support

Required services should report `Up`.

Services with configured health checks should normally report `(healthy)`.

Vector/Analytics is intentionally not required in this Windows local configuration.

## 13. Stopping Supabase

Stop the local stack cleanly with:

```powershell
npx.cmd supabase stop
```

Local database state is preserved in Docker volumes unless it is explicitly reset or deleted.

## 14. Secret Protection

Never commit:

- `.env` files;
- Supabase secret keys;
- Supabase database passwords;
- privileged service credentials;
- Firebase service-account files;
- private keys;
- signing keys;
- certificates.

The repository `.gitignore` includes protections for common secret files and local generated state.

Supabase CLI startup output may display local development credentials.

Do not include credential-containing screenshots in:

- GitHub;
- thesis documents;
- technical manuals;
- presentation slides;
- public posts.

Local development credentials must never be reused as production credentials.

## 15. Verified Git Checkpoints

Verified local commits currently include:

```text
e9e6e40  chore: establish HelpHub project baseline
f9784cf  chore: add Supabase local development tooling
3bb7b15  fix: stabilize local Supabase on Windows
```

A Git remote has not yet been configured.

## 16. Current Database State

At the end of Task 04.1:

- local Supabase is running;
- Supabase PostgreSQL is healthy;
- Supabase Auth is available;
- Supabase Storage is available;
- Supabase Realtime is available;
- Supabase Studio is available on port `44323`;
- no HelpHub production tables have been created yet;
- no HelpHub RLS policies have been created yet;
- no HelpHub Storage buckets have been created yet;
- no cloud Supabase project has been linked yet.

This is intentional.

Environment verification must be completed before creating the application schema.

## 17. HelpHub Scope Reminders

HelpHub serves one selected barangay.

Primary roles:

- Resident
- Barangay Administrator

Location must be captured only when required for report submission or confirmed SOS use.

Do not implement continuous resident tracking.

SOS does not replace official police, fire, medical, or national emergency services.

Do not implement assistance requests unless the study is formally revised.

Reports must not be silently deleted.

Closed or archived reports must preserve traceability.

Every status change must later create:

- a status-history record; and
- an audit event.

## 18. Priority Algorithm Contract

For normal reports, the protected backend will eventually:

1. validate required input;
2. determine or validate concern type using the active versioned rules;
3. match applicable system, city-ordinance, and barangay-specific rules;
4. convert approved factors to normalized ratings;
5. calculate the weighted score;
6. map the result to Low, Medium, High, or Critical;
7. apply an approved Critical override when applicable;
8. assign the approved handler;
9. assign the approved response deadline;
10. generate deterministic queue ordering.

Queue ordering is:

1. override rank descending;
2. priority score descending;
3. nearest deadline ascending;
4. submission time ascending;
5. report ID ascending.

The same input with the same algorithm, rule, and weight versions must produce the same output.

Do not invent final:

- concern categories;
- rules;
- rating anchors;
- thresholds;
- handlers;
- deadlines.

Any development configuration must be versioned.

## 19. Current Development Gate

Current phase:

```text
Stage 4 - Supabase Schema, Auth, Storage, and RLS
```

Task 04.1 establishes the safe local Supabase development environment.

Application schema implementation begins only after this setup task is verified and documented.

## 20. Quick Verification Commands

From:

```text
C:\Users\Criza Mae Panuelos\Documents\HelpHub
```

check Git:

```powershell
git status --short --branch
```

check Node:

```powershell
node --version
```

check npm:

```powershell
npm.cmd --version
```

check Supabase CLI:

```powershell
npx.cmd supabase --version
```

check Docker:

```powershell
docker --version
```

check Docker engine:

```powershell
docker info --format '{{.ServerVersion}}'
```

check Supabase containers:

```powershell
docker ps --filter "name=supabase" --format "table {{.Names}}\t{{.Status}}"
```

Avoid copying or screenshotting credential-heavy Supabase CLI output unless sensitive values have been removed.