# ASM — Decision log

Every place the brief was silent, or where the live toolchain disagreed with
it, is recorded here with the reasoning and the consequence. Decisions are
grouped by area and numbered `D-0xx`; the numbers are referenced from code
comments where they matter.

---

## A. Toolchain

### D-001 — Riverpod 3 (`flutter_riverpod` 3.x, `riverpod_annotation` 4.x, `riverpod_generator` 4.x), not Riverpod 2

**Brief said:** "Riverpod 2 (flutter_riverpod, riverpod_annotation, code-gen)".

**Finding.** Riverpod 2's code-gen chain is
`riverpod_generator 2.6.4 → riverpod_analyzer_utils 0.5.9 → custom_lint_core 0.7.x → analyzer_plugin → analyzer 7.x`.
`analyzer 7.6.0` supports language version **3.9.0**, but Flutter 3.47.7 ships
**Dart 3.13.5**. build_runner crashes with
`Missing implementation of visitDotShorthandPropertyAccess` — the analyzer
cannot parse the SDK's own syntax. Pinning the toolchain with
`dependency_overrides` did not help; `analyzer_plugin` is simply too old.

**Decision.** Keep the explicitly required **latest stable Flutter**, and move
to the Riverpod release that supports it. The brief's *intent* — Riverpod with
`flutter_riverpod`, `riverpod_annotation`, code generation and `AsyncNotifier`,
never `setState` for business logic — is fully honoured; only the major version
number differs.

**Consequence.** `pubspec.yaml` carries a comment explaining the floor. If
Riverpod 2 specifically is required, the workaround is to downgrade Flutter to
the last release bundling Dart ≤ 3.9, which contradicts "latest stable".

---

### D-002 — `freezed` 4 and `json_serializable` 6.14

Required by `analyzer 14.x`, which D-001 forces. Freezed 4 requires entities to
be declared `abstract class … with _$X` rather than `class … with _$X`; all
entities follow that form.

---

### D-003 — SDK floor raised to `>=3.13.0 <4.0.0`

A package's *language version* is derived from its SDK constraint's lower bound.
With `>=3.5.0`, generator output using dot-shorthands and null-aware-elements
failed to format (`FormatterException`) because the package's language version
was lower than the syntax it contained. The floor now matches the SDK.

---

### D-004 — `custom_lint` and `riverpod_lint` removed

Neither is required by the brief, and both drag in `analyzer_plugin 0.12.0`,
which is incompatible with any `analyzer` that supports Dart 3.13 (see D-001).
`flutter_lints` plus the project's own stricter `analysis_options.yaml` remain,
and `flutter analyze --fatal-infos` is clean.

---

### D-005 — `dependency_overrides` deliberately absent

An earlier attempt pinned `custom_lint_core`/`analyzer_plugin` to work around
D-001. Once the toolchain moved to the current releases the overrides were
removed, so the lockfile resolves from published constraints alone.

---

## B. Branding

### D-006 — The logo was generated from the written brief, not sampled from a supplied file

**Brief said:** "use the supplied image as master asset (`assets/brand/logo.png`)"
and "sample exact hex values from the logo file".

**Finding.** No image file was present in the repository, and no font/sample
was supplied.

**Decision.** Author the master artwork from the description and the hex values
given in the brief (royal violet `#6A11CB` → magenta `#D41F8F`, gold
`#C9A24D`, gold gradient `#E6C97A`→`#B8893A`, warm orange `#F28C28`, soft
yellow `#F5F77A`, ivory `#FBF8F2`, charcoal `#16121C`, deep plum `#1E1428`).

Three SVGs are the source of truth, rasterised with `rsvg-convert`:

| Source | Rasterised output | Use |
| --- | --- | --- |
| `logo_badge.svg` | `logo.png`, `logo_512.png` | master asset, About page |
| `logo_transparent.svg` | `logo_transparent.png`, `splash.png` | app bar, hero, splash |
| `icon_fullbleed.svg` | `icon.png`, `icon_adaptive_fg.png` | launcher icons |

**Consequence.** Palette and artwork are internally consistent and fully
versioned. **When the real logo file is supplied it should replace
`assets/brand/logo.png` and, if the hex values differ, `brand_colors.dart`.**

---

### D-007 — Bundled fonts

| Role | Family | Source |
| --- | --- | --- |
| Brand display | Playfair Display | variable (`wght` axis), applied via `FontVariation` |
| Body / UI | Poppins | static 400/500/600/700 |
| Arabic | Cairo | variable |
| Arabic display | Noto Naskh Arabic | variable |
| Amharic | Noto Sans Ethiopic | variable |

The brief asked for "Playfair Display **or** Cinzel"; Cinzel has no static
build in the Google Fonts repository and Playfair pairs better with the gold
serif wordmark. Google Fonts no longer publishes static Playfair, so the
variable face is used with explicit `fontVariations` for weights — that is why
`BrandTypography` sets them rather than relying on `FontWeight` alone.

`BrandTypography.globalFallback` chains Poppins → Ethiopic → Arabic so a
product title containing Amharic or Arabic renders correctly even when the
active locale is English.

---

### D-008 — `flutter_secure_storage` also stores non-secret preferences

The brief lists `flutter_secure_storage` but not `shared_preferences`. Rather
than add a dependency outside the specified package list, the language and
theme choice are persisted through the same encrypted store. The value is
cached in memory so `AppPreferences.build()` can be synchronous, which means
the **first frame already has the correct theme and, for Arabic, the correct
RTL direction** — no flash.

---

## C. Database

### D-009 — `reorder_rows(table, ids[])` RPC instead of N updates

Dragging an item in the admin reorder list is a single round trip and a single
transaction. The function is `SECURITY DEFINER` (dynamic SQL), so it carries an
explicit `is_admin()` check and a table whitelist; both are asserted in the RLS
suite (group 6).

---

### D-010 — Inquiries are rate-limited in the database, with the Edge Function as a second layer

**Brief said:** "public insert only (rate-limited through an Edge Function)".

**Decision.** Both layers, because they protect different things:

* `guard_inquiry_rate()` — a `BEFORE INSERT` trigger capping one `device_id` at
  10 submissions per 10 minutes. It works even if the Edge Function is not
  deployed, and it is covered by the SQL suite (group 3b).
* `supabase/functions/inquiry/index.ts` — adds the one signal the database
  cannot see, the caller's IP, stored only as a SHA-256 hash in
  `inquiries.ip_hash`.

**Consequence.** The Edge Function is written but **not executed by the Phase 1
test suite** (it needs the Edge Runtime and Deno). It is verified in Part 2.

---

### D-011 — `product_media` public visibility is derived from the *whole* chain

**Brief said:** "public select where parent product is published".

**Decision.** Also require the parent product's **category to be visible**. A
product in a hidden category is already unreachable, so exposing its media
would be an inconsistency, not a convenience. The RLS suite asserts this
(group 1).

---

### D-012 — `security_invoker` views require PostgreSQL 15+

`v_products_public` and `v_categories_with_counts` are declared
`with (security_invoker = true)`. Without it a view owned by the migration role
would bypass RLS and leak unpublished rows to anonymous visitors.

**Consequence.** PostgreSQL **16** is the minimum. `supabase/config.toml` pins
`major_version = 16`, CI uses `postgres:16`, and the local suite was run on
PostgreSQL 16.15 — not on the PostgreSQL 14 that happens to be preinstalled in
some sandboxes.

---

### D-013 — The app queries tables directly, not the public views

The views exist because the brief requires them, and they are RLS-safe and
tested. The Dart data layer, however, subscribes to the `products` and
`product_media` tables so that **Realtime works**: a view cannot be subscribed
to, and the join is done in memory instead (`combineLatest` + `groupBy`). The
views remain available for reporting and for any future read-only aggregation.

---

### D-014 — `contact_links.is_primary` is not unique

The brief marks a link `is_primary` but does not constrain it. A unique partial
index would make the admin's "set as primary" toggle fail whenever the owner
forgot to clear the old one first. Instead, ordering puts primary first
(`order by is_primary desc, sort_order asc`) and
`primaryContactLinkProvider` falls back to the first visible link. Adding the
unique index later is a one-line migration.

---

### D-015 — `search_products` is the storefront search, for every caller

It filters to published products in visible categories in its own `WHERE`
clause. An admin therefore receives the same result set — which is correct, and
is why the admin catalogue reads the `products` table directly (broad RLS admin
SELECT policy). The function is `SECURITY INVOKER`; the suite asserts this
structurally via `pg_proc.prosecdef` so a future edit cannot quietly turn it
into a `DEFINER` and bypass RLS.

---

### D-016 — Plain SQL assertions instead of pgTAP

**Brief said:** "pgTAP or SQL tests". The suite uses a tiny `test.assert` /
`test.assert_eq` helper with `\set ON_ERROR_STOP on`, so the first failure
aborts with a non-zero exit code — directly usable as a CI gate, with no
extension to install. `assert_eq` is declared `anycompatible` so `count(*)`
(bigint) can be compared against integer literals without casts at every call
site.

**Consequence.** No `pgTAP` install step in CI, and the assertions read as
plain SQL, which makes them easy to extend as the schema grows.

---

### D-017 — The database has zero `updated_at` on `product_media`, `inquiries`, `audit_log`

The brief specifies an `updated_at` trigger "on every table with `updated_at`".
Those three tables intentionally have no such column: media rows are replaced
rather than edited in practice, inquiries and audit rows are append-only.

---

### D-018 — Inquiries have no anon `SELECT` grant at all

RLS would return zero rows, but withholding the grant is strictly stronger:
`anon` cannot even ask. The suite asserts the `42501` and separately confirms
the admin can read the log.

---

## D. Platform and delivery

### D-019 — Flutter flavors are `--dart-define-from-file`, not native product flavors

**Brief said:** "Build flavors dev, staging, prod, each with its own Supabase URL
and anon key via `--dart-define-from-file`."

That is implemented exactly: `FLAVOR` selects an `AppFlavor`, and
`config/{dev,staging,prod}.json.example` documents the shape. Native Gradle
product flavors (which enable side-by-side installs) are **not** configured,
because they cannot be verified in this environment and an incorrect
`build.gradle` would break the primary Android target. The helper
`AppFlavor.applicationIdSuffix` is already present for when they are added.

---

### D-020 — Two Android fixes that the Flutter template does not include

Both are in `android/app/src/main/AndroidManifest.xml`:

1. **`android.permission.INTERNET`** — the template only adds it to the debug
   and profile manifests. A release APK without it cannot reach Supabase, and
   the failure mode is a silent network error rather than a build failure.
2. **`<queries>` entries for `https`, `http`, `tel`, `mailto`, `smsto`** —
   on Android 11+ `url_launcher.canLaunchUrl` returns `false` for a scheme that
   is not declared, so `LinkLauncher` would refuse to open WhatsApp, the dialer
   or the mail client. `iOS` gets the matching `LSApplicationQueriesSchemes`.

---

### D-021 — A real bug found by the unit tests: `NumberFormat` cache key

`Formatters.money` cached a `NumberFormat` per `locale|currency` but chose the
decimal count from the amount. A whole-number price cached a 0-decimal
formatter, which then silently rounded a later fractional price
(`1250.50` → `ETB1,251`). The digit count is now part of the cache key. This was
caught by `test/unit/entities_and_formatters_test.dart` — a reminder worth
keeping in the log.

---

### D-022 — Test-only Supabase shim

`tests/rls/00_supabase_shim.sql` recreates the roles and the `auth`/`storage`
schemas so the **real** migrations and the **real** policies can be exercised
locally. It is never applied to a project; it exists so the suite tests the
deployed objects rather than a hand-written approximation. It also defines a
`test` schema with the two assertion helpers.

---

### D-023 — The owner account is created through the Auth Admin API, not by SQL

The brief fixes one thing about account creation: there is exactly **one**
account, e-mail sign-up stays disabled, and `profiles.is_admin` is flipped by
SQL run as the project owner.

An earlier version of `scripts/create_admin.sh` inserted straight into
`auth.users` with a `crypt()` hash. That is unreliable: GoTrue needs a matching
row in **`auth.identities`** as well as `auth.users`, plus the right
`raw_app_meta_data`, for password sign-in to succeed. The columns also drift
between GoTrue releases, and the failure mode is silent — the user exists but
login returns a generic error.

**Decision.** The script creates the user with
`POST {SUPABASE_URL}/auth/v1/admin/users` (`email_confirm: true`) using the
service-role key, then performs the promotion with direct SQL through
`SUPABASE_DB_URL`. Supabase owns the Auth schema; we only own `public.profiles`.
The `--promote-only <email>` mode skips the API call for an account that
already exists (e.g. one created in the dashboard).

**Consequence.** The create path now needs `SUPABASE_URL` and
`SUPABASE_SERVICE_ROLE_KEY` in addition to `SUPABASE_DB_URL`. That key is used
on the operator's machine only and is still never bundled into the app; the
promotion remains a plain owner-run SQL statement, so `is_admin` stays out of
reach of any client call.

---

### D-024 — The "never ship the service-role key" guard reads the JWT `role` claim

`Env.assertConfigured()` refuses to start when `SUPABASE_ANON_KEY` is actually a
service-role key, because that key bypasses every RLS policy in the database.

A first attempt tested `key.startsWith('eyJ') && key.length > 900`. That check
is useless: legacy anon and service-role keys are JWTs of essentially the same
length and differ *only* in their `role` claim, so the guard could never fire.
It is replaced by decoding the token payload and comparing `role` to
`service_role`, with new-style `sb_secret_` keys caught by prefix (they are not
JWTs at all). Malformed input returns `false` rather than throwing, so a
misconfigured build still reports the missing-config error instead of a decode
error. `test/unit/env_test.dart` covers service-role, anon and authenticated
JWTs, both new-style prefixes, and four malformed shapes.

**Consequence.** This is a safety net against operator error, not a security
boundary — the real boundary is RLS plus keeping the key out of `config/*.json`.

---

## E. Open items handed to Part 2

* Replace the generated logo with the supplied master asset (D-006).
* Verify the Edge Function under the Edge Runtime (D-010).
* Native Android product flavors for side-by-side installs (D-019).
* Verify release Android/iOS builds (no Android SDK or Xcode in this
  environment) — `flutter build` was not exercised.
* Screen-level integration tests and CI/CD promotion gates.
* `chewie`, `video_player`, `image_picker`, `file_picker`,
  `flutter_image_compress` and `video_compress` are declared and their domain
  models exist, but the upload/playback pipeline itself is Part 2 work.
