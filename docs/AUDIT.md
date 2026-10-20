# ASM — Audit notes

Only what is still open. Everything that was fixed has a test or a CI job that
fails if it regresses; those are not repeated here.

## 1. Still open

| # | Item | Why it is still open | Who can close it |
| --- | --- | --- | --- |
| 1 | No version number on Settings/About | `l10n.settingsVersion` exists but nothing renders it. Reading the installed version needs `package_info_plus` (a new dependency) or a build-time constant; deliberately not added in the last three changes. | Any follow-up change |
| 2 | No Terms screen | The privacy policy is published and linked; terms are owner-authored copy we do not have. | Owner supplies the text |
| 3 | Play listing assets | Screenshots, feature graphic, short/full description, and the Data Safety form (content below) are filled in the Play Console, not in this repo. | Owner, in Play Console |
| 4 | Crash reports are only active when `SENTRY_DSN` is set | `bootstrap()` reports to Sentry only when a DSN is compiled in; without the secret the app just logs locally. Nothing crashes when it is missing. | Set the `SENTRY_DSN` repository secret |
| 5 | RLS suite needs a PostgreSQL 15+ instance | `scripts/run_rls_tests.sh` boots a shim schema and runs `tests/rls/*.sql`; CI's `rls` job provides the service, a laptop needs one too. | Nobody — by design |

## 2. Data Safety (Play Console) — what to declare

Audited against the current `main`: `pubspec.yaml`, `lib/bootstrap.dart`,
`lib/core/errors/error_reporter.dart`, `lib/core/errors/error_mapper.dart`,
`android/app/src/main/AndroidManifest.xml`, and the Android manifests of every
plugin in the graph.

**What leaves the device**

| Path | Data | Destination |
| --- | --- | --- |
| Supabase REST/Realtime (`supabase_flutter`) | Catalogue reads only — no account, no identifier for shoppers | The project's Supabase host |
| Supabase Storage / image transforms | Product photos the owner uploads | Supabase storage + CDN |
| Supabase Auth | The owner's e-mail and session token, shop staff only | Supabase Auth |
| Sentry (`sentry_flutter` 10.1.0, only with a DSN) | Uncaught errors and `AppFailure`s: stack trace, error text, app version, OS version, device model. `sendDefaultPii = false`, no screenshots, no session replay, no user id. Performance traces sampled | sentry.io |
| OS intents (`url_launcher`) | tel:, `wa.me`, `t.me`, mailto, SMS, the privacy URL | The chosen app, not us |

**What does not leave the device**

- Favourites, language, theme, and the owner's gate state live in
  `flutter_secure_storage` only.
- No analytics SDK, no ads SDK, no attribution SDK, no advertising ID, no
  Firebase, no Crashlytics, no push service. `connectivity_plus` reports network
  state to the app, nothing more.

**Permissions in the release manifest**

- `INTERNET` — Supabase and Sentry.
- `ACCESS_NETWORK_STATE` — declared by us and by `connectivity_plus`.
- `WRITE_EXTERNAL_STORAGE` — declared by `video_compress`, which is only reached
  when the owner uploads a video. No runtime request is made and the app writes
  only to app-scoped directories, so it is inert on Android 10+.

**One-line answer for the form**

Declare **App info and performance → Crash logs and Diagnostics**, collected
automatically (not user-provided), encrypted in transit, not shared for
advertising, used only for app functionality/analytics-of-failures; everything
else is "not collected". If `SENTRY_DSN` is left unset in CI, the honest answer
becomes **nothing needs to be declared**.
