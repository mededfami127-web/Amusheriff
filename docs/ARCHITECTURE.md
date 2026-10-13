# ASM — Architecture

> Amu Sharif Arabiyan Majlis (`አሙ ሸሪፍ አረቢያን መጅሊስ` / `المجلس العربي عمو شريف`)
>
> One Flutter codebase, two wired-together experiences: a public luxury
> storefront and an owner-only admin gateway.

---

## 1. System context

```mermaid
graph TB
    subgraph Device["Flutter app (Android · iOS · Web)"]
        SF["Storefront<br/>public, no login"]
        AG["Admin gateway<br/>session + is_admin"]
    end

    subgraph Supabase["Supabase project"]
        AUTH["Auth<br/>signup disabled<br/>1 owner account"]
        PG[("PostgreSQL 16<br/>RLS on every table")]
        RT["Realtime<br/>postgres_changes"]
        ST["Storage<br/>product-media · brand"]
        EF["Edge Function<br/>/inquiry"]
    end

    SF -- "anon key" --> PG
    SF -- "anon key" --> ST
    SF -- "subscribe" --> RT
    SF -. "lead" .-> EF
    AG -- "owner session" --> PG
    AG -- "owner session" --> ST
    PG -- "realtime stream" --> RT
    EF -- "service role" --> PG
    AUTH -- "JWT" --> PG
```

**Only the public anon (publishable) key ever ships in the app.** The
service-role key lives solely inside the Edge Function's environment. Every
authorisation decision is enforced by PostgreSQL row level security, so a
tampered client gains nothing.

---

## 2. Layer architecture

Feature-first clean architecture. Each feature owns its three layers; nothing
in `domain/` knows that Supabase exists.

```mermaid
graph LR
    subgraph presentation["presentation/"]
        W["Widgets"]
        P["Riverpod providers<br/>@riverpod + code-gen"]
    end

    subgraph domain["domain/"]
        E["Entities<br/>freezed"]
        RI["Repository interfaces<br/>abstract interface class"]
        D["Drafts (write DTOs)"]
    end

    subgraph data["data/"]
        DS["Datasources<br/>raw Supabase access"]
        RI2["Repository implementations"]
    end

    W --> P
    P --> RI
    P --> RI2
    RI -.implemented by.-> RI2
    RI2 --> DS
    RI2 --> E
    DS --> E
    P --> E
```

| Layer | May depend on | Must never depend on |
| --- | --- | --- |
| `presentation` | `domain`, `core` | `data` internals (only via providers) |
| `domain` | `core` | Flutter, Supabase, `data` |
| `data` | `domain`, `core` | `presentation` |

Errors cross every boundary as the sealed `AppFailure` hierarchy
(`lib/core/errors/app_failure.dart`). `ErrorMapper.guard()` wraps every
datasource call, so no `PostgrestException` or `SocketException` ever escapes
the data layer.

---

## 3. Critical wiring — one catalogue, two surfaces

Both experiences resolve the **same** repositories and the **same** providers.
The admin writes through the admin repository; the storefront reads through
RLS-protected public policies. Because reads are Realtime subscriptions, an
admin edit appears on every customer device without a refresh.

```mermaid
sequenceDiagram
    participant Owner as Owner (admin gateway)
    participant Repo as ProductRepository
    participant PG as PostgreSQL
    participant RT as Realtime
    participant Cust as Customer (storefront)

    Cust->>RT: subscribe products + product_media
    RT-->>Cust: initial snapshot (published, visible)

    Owner->>Repo: update(productId, draft)
    Repo->>PG: UPDATE products SET price = …
    PG->>PG: RLS: is_admin() → allow
    PG->>PG: trigger: set_updated_at, audit_row
    PG->>RT: postgres_changes (products)
    RT-->>Cust: new row
    Cust->>Cust: UI re-renders with the new price
```

The storefront joins two independent streams — `products` and
`product_media` — in memory (`combineLatest` in `lib/core/utils/stream_utils.dart`)
so a newly uploaded photo appears without re-querying the product row.

```mermaid
graph LR
    PS["products.stream()<br/>eq is_published"] --> CL["combineLatest"]
    MS["product_media.stream()"] --> CL
    CL --> IDX["groupBy productId"]
    IDX --> PC["ProductCard / ProductDetail"]
```

---

## 4. The single router decides the surface

One `GoRouter` serves both surfaces. Every path runs through one pure function,
so the two experiences can never disagree about who may go where.

```mermaid
flowchart TD
    A["Incoming path"] --> B{"Is it /admin/** ?"}
    B -- No --> C["Public storefront<br/>render"]
    B -- Yes --> D{"Is it /admin/login ?"}
    D -- Yes --> E{"Signed in AND admin ?"}
    E -- Yes --> F["→ /admin"]
    E -- No --> G["Render login form"]
    D -- No --> H{"Session present ?"}
    H -- No --> I["→ /admin/login?returnTo=…"]
    H -- Yes --> J{"admin status"}
    J -- "loading" --> K["Render page's own loader"]
    J -- "true" --> L["Render admin page"]
    J -- "false" --> M["→ /admin/login?error=notAdmin"]
```

The decision lives in `resolveAdminRedirect()` (`lib/core/router/guards.dart`)
and is covered by nine unit tests in `test/unit/router_guards_test.dart`.

---

## 5. Directory map

```
lib/
  main.dart                 entry point
  bootstrap.dart            config validation → Supabase → preferences → Sentry → runApp
  app.dart                  MaterialApp.router (theme, locale, RTL)
  core/
    config/                 flavors, env (--dart-define), AppConfig
    theme/                  brand_colors, gradients, typography, app_theme
    router/                 routes, guards, app_router
    errors/                 AppFailure (sealed), ErrorMapper, localizer
    network/                Supabase client, connectivity, storage URLs
    utils/                  formatters, validators, launcher, stream utils
    widgets/                brand_logo, app_scaffold, gradient_button,
                            gold_divider, shimmer_card, empty_state, error_state
    l10n/generated/         AppLocalizations (en · am · ar)
  features/
    auth/                   domain · data · presentation
    catalog/                entities, drafts, repos, datasource, providers
    storefront/             home, category, product detail, search, 404
    admin/                  login, dashboard, change password, section shells
    contacts/               contact links + launcher rules
    settings/               site settings + local preferences
  l10n/                     app_en.arb · app_am.arb · app_ar.arb
supabase/
  migrations/               schema · views/RPCs · RLS · storage
  seed.sql                  categories, demo products, contact links
  functions/inquiry/        IP-rate-limited lead endpoint
  config.toml
tests/rls/                  local Supabase shim + RLS acceptance suite
scripts/                    run_rls_tests.sh · create_admin.sh
```

---

## 6. State management

Riverpod with code generation (`@riverpod`), `AsyncNotifier` for anything with
a lifecycle. **No business logic uses `setState`.**

| Concern | Provider |
| --- | --- |
| Supabase client | `supabaseClientProvider` (keep-alive, overridden in tests) |
| Auth session | `currentSessionProvider`, `currentUserProvider` |
| Admin verdict | `adminStatusProvider` (`AsyncNotifier<bool>`) |
| Catalogue reads | `storefrontProductsProvider`, `productDetailProvider` |
| Contact channels | `visibleContactLinksProvider`, `orderChannelsProvider` |
| Branding | `siteSettingsProvider` |
| Language / theme | `appPreferencesProvider` (persisted) |

Repositories are exposed as keep-alive providers and overridden with fakes in
tests, so no widget ever reaches the network.

---

## 7. Branding pipeline

```mermaid
graph LR
    S["assets/brand/<br/>logo_badge.svg · logo_transparent.svg · icon_fullbleed.svg"]
    S -- rsvg-convert --> P["logo.png · logo_transparent.png · icon.png · splash.png"]
    P -- flutter_launcher_icons --> I["Android adaptive · iOS · Web icons"]
    P -- flutter_native_splash --> SP["Android 12+ · iOS splash"]
    P -- Image.asset --> A["App bar lockup, hero, About"]
```

Palette and type scale are single-sourced in `lib/core/theme/` so the gradient,
gold hairline and serif wordmark cannot drift between screens.
