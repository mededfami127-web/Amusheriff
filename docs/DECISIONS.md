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

### D-025 — The release AAB is signed from a base64 keystore secret, with a debug fallback

**Brief said:** build the Android artifact in CI. An AAB is only useful if it is
signed with the owner's upload key — Play rejects a debug-signed bundle — and
the key must not be committed.

Day one of the Flutter template signs the release build with the debug keys
(`signingConfig = signingConfigs.getByName("debug")`), which produces an
artifact that looks successful and silently cannot be published. That is now
replaced by: `android/key.properties` supplies the store file, password, alias
and key password when it exists, and CI recreates that file from four GitHub
secrets (`ANDROID_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`,
`KEY_PASSWORD`). Base64 is used because a keystore is binary and a secret can
only hold text.

**Consequence.** Two failure modes are handled explicitly, because both are
otherwise discovered only at upload time: a missing `ANDROID_KEYSTORE_BASE64`
emits `::warning::` and continues, so the pipeline still produces artifacts
(bundles from such a run must not be published); a *present but wrong* secret
fails the job in the decode step — a truncated base64 or a mistyped store
password is caught by `keytool -list` before Gradle runs. `android/key.properties`,
`*.jks` and `*.keystore` stay gitignored.

The same treatment is available for the flavor config via an optional
`CONFIG_BASE64` secret, which decodes to `config/<flavor>.json` and supersedes
the three individual Supabase/Sentry secrets.

---

### D-026 — A docker-free migration runner beside `supabase db push`

**Brief said:** the schema lives in `supabase/migrations/` and reaches the
project through `supabase db push`. That stays the documented path for a real
project (see the README → Setup).

**Deviation.** `scripts/apply_migrations.sh` performs the same push with only
`psql`, which is what this environment and the CI image actually provide:
`--plan` (read-only), `--dry-run` (execute the pending SQL inside a transaction
that is rolled back) and `--apply`. The dry run fingerprints every relation,
column, function, policy and extension before and after the transaction, so
"rolled back" is proved rather than assumed. Versions are recorded in
`supabase_migrations.schema_migrations` in whatever column shape that table
already has — and in the CLI's shape when it does not exist yet — so
`supabase migration list` and the dashboard's migration history stay in
agreement with the script.

Both modes now emit the same version-recording SQL. Previously only `--apply`
did, and it created the `supabase_migrations` *schema* without the
`schema_migrations` *table*, so a first apply failed on the insert and rolled
the whole migration set back; a dry run could not see it because it never
exercised that statement. Verification also surfaced six `create trigger`
statements with no preceding `drop trigger if exists`, which made re-application
fail even though `docs/DATABASE.md` promised otherwise. Both are fixed, and
`.github/workflows/supabase-db-push.yml` now applies *and* re-applies to a
throwaway database so the idempotency claim is enforced rather than asserted.

**Consequence.** CI needs no Docker and no Supabase credentials: the job stands
in the platform with `tests/rls/00_supabase_shim.sql` (D-022), which supplies
the `auth` and `storage` schemas the migrations extend.

---

### D-027 — Android floor raised to API 26

`sentry_flutter` 10 declares `minSdkVersion 26`, and it is the release that
dropped both the `languageVersion = "1.6"` pin and its bundled Kotlin Gradle
plugin — the two things that made every Android build fail under Kotlin 2.4.
The 9.x line still applies KGP 1.8.0, which Gradle 9.3.1 will not run, so the
floor moves from Flutter's default 24 to **26 (Android 8.0)**, dropping Android
7.x support. The change lives in `android/app/build.gradle.kts`.

`tools:overrideLibrary` was rejected: it silences the manifest merger for a
library the app genuinely drives at runtime, which is exactly the kind of
failure this project prefers to surface at build time.

---

### D-028 — Overriding the localization delegate, not the 292 call sites

The owner must be able to rewrite any wording in the app, in any of the four
languages, without a release.

The obvious implementation is a `tr(key)` helper, which means touching every
screen: the app resolves strings through `AppLocalizations.of(context)` in 25
files and 292 keys. Instead, `OverridableLocalizationsDelegate` is registered
with `MaterialApp` in place of the generated delegate and returns an
`AppLocalizations` **subclass** that prefers `override ?? shipped` per key.

Consequences: an edit lands everywhere at once, including screens written before
the feature existed; adding a screen keeps working for free; the one cost is a
generated subclass (`overridable_localizations.dart`, produced by
`tool/gen_text_overlay.dart` from the ARB files and the generated abstract
class), which must be re-generated when an ARB key is added or renamed — the
generator is committed and idempotent, and `flutter analyze` fails loudly if it
drifts.

ICU plurals (`searchResultsCount`) deliberately stay with the generated wording:
a raw string replacement cannot express a plural rule. The editor marks them
read-only rather than pretending otherwise.

### D-029 — Overrides are rows, not files: `public.text_overrides`

Wording lives in one table keyed by `(text_key, locale)`, the ARB key the app
already looks up.

* Deleting a row restores the shipped wording, so "restore default" needs no
  second concept and no stored history.
* Public `SELECT` is required and deliberate: the storefront is anonymous and
  must render the owner's wording to every visitor. Writes are admin-only.
* The pair is the primary key, which is what lets `.stream()` deliver row
  updates to every open device — the same realtime promise the rest of the
  storefront makes, and the reason `text_overrides` is listed in the realtime
  migration's table set and in group 11 of the RLS suite.

### D-030 — The five-tap gateway is convenience, not authorisation

The brief asks for a logo tapped five times opening a username (`admin`) /
password (`admin123`) panel, changeable inside the app. That is a device-local
lock, so it is implemented that way and labelled that way:

* `AdminGateStore` keeps a per-device random salt and a SHA-256 digest in the
  same encrypted store as the session material — never the password itself.
* `resolveAdminRedirect` accepts the unlocked flag, which is what lets an owner
  who has never signed in reach the gateway.
* It grants **no** new database access. RLS still decides every read and write,
  so a customer who somehow unlocked the panel would still be denied by the
  database. The README's security section says exactly this, so nobody mistakes
  the panel for a second factor.
* The password is held to the Supabase password rule when the owner changes it;
  only the shipped default is exempt, because the brief fixes it at `admin123`.

### D-031 — Favourites live on the device, as ids

There is no customer account, so a favourite cannot be a row. `FavouritesStore`
keeps ids in the encrypted keystore, and the favourites screen resolves them
against the live catalogue stream.

Storing ids rather than copies is the point: a piece the owner repriced,
re-photographed or unpublished shows the current truth (or disappears) on the
favourites screen, with no extra query and nothing stale to reconcile.

### D-033 — Oromo is gap-filled for Material and Cupertino

The SDK ships Amharic and Arabic but **no** `om` translations for
`GlobalMaterialLocalizations`/`GlobalCupertinoLocalizations`. Declaring `om` in
`supportedLocales` without addressing that makes `MaterialApp` report "this
application's locale is not supported by all of its localization delegates" and
leaves Material chrome (tooltips, dialog buttons, pickers) on the widget-layer
English default anyway.

`FallbackMaterialLocalizationsDelegate` and its Cupertino twin answer for
precisely those locales the real delegates miss — and only those, so Amharic and
Arabic keep their proper Material translations. The result: the app's own 292
strings are Oromo, Material chrome is English rather than missing, and nothing
warns.

### D-032 — Media deletion removes the files, not just the row

`ProductMediaRepository.delete` removes the catalogue row; on its own that
leaves the full-size image and its thumbnail in the bucket forever — invisible to
the storefront, still billed, and available to resurface if a path is re-used.
The editor therefore deletes the row first, then removes both objects with
`removeQuietly`, and reports a denied write instead of dropping the future on the
floor. The confirmation dialog and the snackbar are part of the same fix.

### D-034 — What each CI gate is for, and the one gate deliberately left out

Auditing `.github/workflows/` against the toolchain it actually runs turned up
one stale command and two holes:

* `dart run build_runner build --delete-conflicting-outputs` was passed in all
  three workflows and in the README. build_runner 2.16 removed that option: every
  run printed "These options have been removed and were ignored". The flag is
  gone and the command is plain `dart run build_runner build` — verification
  that a *missing* generated file is still recreated (delete `launcher.g.dart`,
  build, `git status` clean) is what showed the option is no longer needed
  rather than merely deprecated.
* `flutter gen-l10n` treats `app_en.arb` as the template and answers a missing
  translation with the English wording, so a key added to the template alone
  compiles, passes the generated-drift check (which compares *output*, not ARB
  coverage) and ships English to the Amharic, Arabic and Oromo readers.
  `tool/check_l10n_parity.dart` is now a CI step: it fails with the per-locale
  missing/unknown key list.
* Nothing compiled the app on a pull request — `analyze` and the unit tests do
  not build assets, fonts or a release kernel, and the APK jobs run on `main`.
  `flutter build bundle --release` is the cheap compile gate: no Android SDK, no
  signing, and the same asset bundling a device build performs.

**Deliberately not added here: a `dart format --set-exit-if-changed` step.** The
tree predates the tall-style formatter the current stable SDK ships, so the check
reports 99 of 159 hand-written files as unformatted. A gate would be red on
arrival, and reformatting every feature file is a separate, reviewable change
rather than something to smuggle into a CI fix. It is added in D-035, together
with the two other gates this entry leaves open.

### D-035 — The three gates D-034 left out, and how each one is proved

Closing the remaining holes turned the formatting exclusion above into work:

* **Formatting is gated.** `dart format --set-exit-if-changed` runs in `ci.yml`.
  The one generator whose output was *not* already tall-style —
  `tool/gen_text_overlay.dart`, which writes `lib/core/l10n/text_catalog.dart`
  and `overridable_localizations.dart` — now hands its own output to
  `Platform.resolvedExecutable format` before returning, so the committed
  snapshot stays byte-identical to a fresh regeneration and the format gate
  cannot fight the "generated sources are up to date" check. Verified both ways:
  `dart format --output=none --set-exit-if-changed .` reports 0 changed *after*
  `flutter gen-l10n`, `dart run build_runner build` and the overlay generator
  have all run, and `git status` over `*.g.dart`, `*.freezed.dart` and
  `lib/core/l10n/` is clean. `flutter gen-l10n` and build_runner already emit
  tall-style code, which is why only the overlay files needed the generator
  changed rather than a hand-formatted template. The tree-wide reformat is 100
  files in its own commit (98 hand-written, the two generator outputs and the two
  `tool/` scripts) so that no feature diff hides inside a whitespace change.
* **The Edge Function is checked.** `supabase/functions/inquiry` — the only
  server-side code in the repo, and the only file that runs with the service-role
  key — was compiled by nothing: the SQL suite covers the database and the Flutter
  jobs cover the app, so a TypeScript error there would reach production unseen. A
  Deno job pinned to v2.9.7 (the version this was verified on, and the Edge
  Runtime's own runtime) runs `deno check`, `deno lint` and `deno fmt --check`.
  `deno check` also resolves the pinned `esm.sh` import, so a yanked dependency
  version fails the build here instead of at the first customer request. What this
  still does not do is *execute* the function under the Edge Runtime (D-010): the
  rate-limit behaviour itself remains unverified without a Supabase project.
* **iOS compiles.** `flutter build ios --release --no-codesign` on
  `macos-latest`. Unsigned, so no Apple certificate or provisioning profile is
  needed and the job stays secret-free; the committed `config/prod.json.example`
  supplies the compile-time define. This is what catches a plugin raising the iOS
  deployment target, a stale or missing Podfile, or a broken `Info.plist` — none
  of which `flutter analyze` can see. It is a compile gate, not a device test: App
  Store signing, `chewie`/`video_player` playback and the iOS UI stay unverified
  in this environment.

Android's release path stays where D-034 put it — `build.yml`, on a `v*` tag or a
manual dispatch — because Play signing is the entire point of that job and a
signed AAB on every push to `main` would be waste. It has been exercised for real
once already: the `v1.0.0` tag ran the full `build` workflow to green in 11m42s
and uploaded the signed APK and AAB.

---

## E. Open items handed to Part 2

Closed since this list was written:

* The admin gateway screens are implemented and wired to the router:
  categories, products (list + editor), product media, contact links, site
  settings, inquiries and password. The placeholder pages are gone.
* The media pipeline is implemented. `MediaProcessor.process` compresses images
  with `flutter_image_compress` and videos with `video_compress` (quality tier,
  poster frame, duration), and throws a localized `MediaFailure` when a file
  breaks the bucket caps. `MediaUploadController` runs the queue at concurrency
  2 with per-file phase, cancel, retry and a compensating delete, and the
  product editor drives it.
* `test/unit/admin_gateway_test.dart` covers the gateway widgets end to end
  (list, empty state, list → editor seeding, save-through-repository, and
  validation blocking a bad slug) against fake repositories.
* The owner wording layer (D-028/D-029) and the five-tap gateway (D-030) are
  covered: `test/unit/text_overrides_test.dart` proves the delegate serves the
  owner's text through `of(context)` in a real widget tree and that Oromo
  resolves, `test/unit/admin_gate_store_test.dart` proves the shipped
  credentials, the salted digest and password changes, and
  `test/unit/live_edit_and_layout_test.dart` proves live edit mode puts a pencil
  on the dashboard and that the dashboard, the text editor and the gateway
  password screen lay out at 320x640 with 1.35x text scaling without overflow.

Still open:

* Replace the generated logo with the supplied master asset (D-006).
* Run the Edge Function under the Edge Runtime (D-010). Its TypeScript, lint and
  formatting are now gated in CI (D-035), but its rate-limit behaviour needs a
  Supabase project to observe.
* Native Android product flavors for side-by-side installs (D-019).
* Device verification. Both platforms now *compile* in CI — Android's signed
  release on a `v*` tag (`build.yml`), iOS unsigned on `macos-latest` (D-035) —
  but no build has been run on hardware here, so `chewie`/`video_player`
  playback, App Store signing (the iOS bundle id is still
  `com.amusheriff.amuSharifMajlis`) and iOS UI remain unverified.
* Screen-level integration tests on a device/emulator and CI/CD promotion gates.
