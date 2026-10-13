# integration_test/

Reserved for on-device integration tests, which are **Part 2** scope.

Phase 1 covers the pure layers, where tests are fast and deterministic:

| Suite | Covers |
| --- | --- |
| `test/unit/router_guards_test.dart` | the admin route guard decision table |
| `test/unit/validators_test.dart` | every rule that mirrors a DB constraint |
| `test/unit/contact_launcher_test.dart` | the URL each contact channel resolves to |
| `test/unit/entities_and_formatters_test.dart` | entity localization, pricing, formatters |
| `test/unit/stream_utils_test.dart` | the realtime `combineLatest` / `debounce` combinators |
| `tests/rls/rls_tests.sql` | the RLS, audit, RPC and storage policies on real PostgreSQL |

Part 2 adds here:

* `app_boot_test.dart` — `bootstrap()` with a stubbed Supabase client, asserting
  the branded storefront shell renders signed-out.
* `admin_flow_test.dart` — sign in, create a category, confirm it appears on the
  storefront without a restart (the realtime wiring end to end).
* `contact_launch_test.dart` — tapping a product's WhatsApp action builds the
  expected `wa.me` intent.

Run them with:

```bash
flutter test integration_test --dart-define-from-file=config/dev.json
```
