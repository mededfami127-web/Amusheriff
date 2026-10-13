# Amu Sharif Arabiyan Majlis — ASM

> **አሙ ሸሪፍ አረቢያን መጅሊስ** · **المجلس العربي عمو شريف** · Amu Sharif Arabiyan Majlis

A luxury Arabic-majlis and sofa catalogue in a single Flutter codebase, with two
wired-together experiences:

| Surface | Route | Access |
| --- | --- | --- |
| **Storefront** — browse the catalogue, open a product, contact the owner on WhatsApp / Telegram / phone | `/` | public, no login |
| **Admin gateway** — categories, products, media, prices, contact links, branding and password | `/admin/**` | valid session **and** `profiles.is_admin = true` |

Both surfaces share one catalogue and one contact-link repository, and the store
front subscribes to Supabase Realtime — so anything the owner changes is live on
every customer device without a restart.

**Status: both phases implemented.** Scaffold, branding, architecture, the full
database schema (RLS + storage policies), seed data and the RLS acceptance
suite are done and green, and so are the screens: the storefront catalogue and
the admin gateway (categories, products with media, contact links, branding,
inquiries, password). What is still open — screen-level integration tests,
CI/CD promotion gates and release Android/iOS builds — is tracked in
`docs/DECISIONS.md` → "Open items handed to Part 2".

---

## Verified results

| Check | Command | Result |
| --- | --- | --- |
| Code generation | `dart run build_runner build --delete-conflicting-outputs` | 0 errors |
| Static analysis | `flutter analyze` | **No issues found** |
| Unit + widget tests | `flutter test` | **64 passed** |
| RLS acceptance suite | `bash scripts/run_rls_tests.sh` | **19/19 groups passed** on PostgreSQL 16.15 |

Not yet exercised in this environment: release Android/iOS builds (no Android
SDK or Xcode available) and the Edge Function under the Edge Runtime. See
`docs/DECISIONS.md` → "Open items handed to Part 2".

---

## Setup

### 1. Toolchain

```bash
flutter --version      # 3.47.x stable, Dart 3.13+
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n       # also runs automatically via `generate: true`
```

### 2. Supabase project

```bash
supabase link --project-ref <your-project-ref>
supabase db push                       # applies supabase/migrations/*
psql "$SUPABASE_DB_URL" -f supabase/seed.sql
```

Public e-mail sign-up is disabled (`supabase/config.toml`). Create the single
owner account, then promote it:

```bash
SUPABASE_URL='https://<ref>.supabase.co' \
SUPABASE_SERVICE_ROLE_KEY='<service-role-key>' \
SUPABASE_DB_URL='postgres://…' \
  ./scripts/create_admin.sh owner@example.com 'Strong-Passphrase-1'
```

The service-role key is used on your machine only (`POST /auth/v1/admin/users`)
and must never be put in `config/*.json` — the app ships the anon key only.
To promote an account that already exists:

```bash
SUPABASE_DB_URL='postgres://…' ./scripts/create_admin.sh --promote-only owner@example.com
```

The equivalent SQL, if you prefer to do it by hand:

```sql
update public.profiles set is_admin = true where id = '<uid>';
```

### 3. Flavor configuration

Copy a template and fill in the project values. These files are gitignored;
only the `.example` versions are committed.

```bash
cp config/dev.json.example config/dev.json
flutter run --dart-define-from-file=config/dev.json
```

| Key | Meaning |
| --- | --- |
| `FLAVOR` | `dev` · `staging` · `prod` |
| `SUPABASE_URL` | project URL |
| `SUPABASE_ANON_KEY` | **public** anon key — never the service-role key |
| `SENTRY_DSN` | optional; error reporting is skipped when empty |
| `LOG_LEVEL` | `debug` · `info` · `warning` |

`bootstrap()` validates this configuration and fails loudly with an actionable
message rather than surfacing an opaque network error later.

### 4. Branding assets

```bash
# Rasterise the master SVGs (needs librsvg)
rsvg-convert -w 1024 -h 1024 assets/brand/logo_badge.svg       -o assets/brand/logo.png
rsvg-convert -w 1024 -h 1024 assets/brand/logo_transparent.svg -o assets/brand/splash.png
rsvg-convert -w 1024 -h 1024 assets/brand/icon_fullbleed.svg   -o assets/brand/icon.png

dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

---

## Development

```bash
flutter analyze                # must stay clean; CI runs --fatal-infos
flutter test                   # unit tests
flutter run --dart-define-from-file=config/dev.json
```

After changing any `@riverpod` provider, freezed entity or JSON model:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Database changes

Add a new timestamped file to `supabase/migrations/`, then run the suite:

```bash
PGHOST=127.0.0.1 PGPORT=5432 PGUSER=postgres bash scripts/run_rls_tests.sh
```

The suite rebuilds a throwaway database, installs a local Supabase shim, applies
the real migrations and seed, and runs every RLS assertion. It exits non-zero on
the first failure, so it works unchanged as a CI gate (see
`.github/workflows/ci.yml`).

---

## Project layout

```
lib/core/          config · theme · router · errors · network · utils · widgets · l10n
lib/features/      auth · catalog · storefront · admin · contacts · settings
                   (each: domain/ · data/ · presentation/)
lib/l10n/          app_en.arb · app_am.arb · app_ar.arb
supabase/          migrations · seed.sql · functions · config.toml
tests/rls/         local Supabase shim + RLS acceptance suite
scripts/           run_rls_tests.sh · create_admin.sh
docs/              ARCHITECTURE.md · DATABASE.md · DECISIONS.md
```

Architecture, diagrams and the authorization model:
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) ·
[`docs/DATABASE.md`](docs/DATABASE.md).
Every deviation from the brief, with its rationale:
[`docs/DECISIONS.md`](docs/DECISIONS.md).

---

## Security posture

* The app ships **only** the public anon key. The service-role key exists solely
  inside the `inquiry` Edge Function's environment.
* RLS is enabled on every table and is deny-by-default.
* `profiles.is_admin` is guarded by three independent layers (grant, policy,
  trigger) and can only be changed by SQL run as the project owner.
* Public e-mail sign-up is disabled; there is exactly one account.
* Storage buckets are public-read and admin-write, with per-type size caps and a
  path-prefix check enforced by policy.
