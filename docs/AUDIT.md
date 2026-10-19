# ASM — Audit notes

Living audit, written against the current `main` worktree.

## 1. Missing features

| Area | Status | Notes |
| --- | --- | --- |
| site_content live edit (item 2) | **added upstream** | `supabase/migrations/20260101000800_site_content.sql` creates `public.site_content`, RLS is strict (public read, `is_admin` write), and the RLS suite now asserts it. The app-layer provider + admin editing surface still needs wiring; that is the part not yet finished. |
| Admin contact settings (item 3) | **added upstream** | `supabase/migrations/20260101000900_admin_contact_settings.sql` creates a single-row settings table for phone/email/WhatsApp/Telegram/social fields, with public read and admin-only write. Reusing this from the admin panel and the product page is still pending. |
| Subcategory line on category pages (item 5) | **added upstream** | A new `CategorySubcategoryLine` widget renders horizontal subcategory chips (with the selected slug driven off the URL), and `category_page` now uses it. RTL scroll and “all selected” cue still need their own assertions. |

## 2. Dead / unconnected buttons and screens

| Screen / button | Observed state | Action |
| --- | --- | --- |
| Admin “Live edit” toggle | The gateway already exposes a live-edit mode, and the dashboard renders pencils when it is on. What is not connected yet is the storefront home/dashboard text path the brief names — the app does not currently read `site_content` on the home screen, so turning on “live edit” on the admin side does not yet change the user-facing hero text. | Wire `site_content` into the storefront home via a provider with fallback to ARB, then prove it with a widget test. |
| Admin contact settings | The admin contact-links UI exists and is fully editable, but the new admin-only settings table is not yet surfaced in an admin screen, and the product page does not yet read from it. | Add an admin “Contact settings” screen that edits `admin_contact_settings`, then feed the product page’s contact section from it (or from `contact_links` when the owner prefers that model). |

## 3. Hardcoded text that bypasses l10n

- All storefront text I inspected already flows through `AppLocalizations.of(context)` or `LiveEditableText(textKey: …)`, including category names via `nameFor(language)` and product titles via `titleFor(language)`. No hardcoded user-facing string was found in the edited storefront path.
- The brand logo asset path and the storage URL methods (`StorageUrls.brand`, `productMedia`, `productMediaThumb`) are locale-independent: they are built from `cover_path` / `storage_path`, never from a localized column. The only localized fields are `name`/`title`/`description` and their `_am`/`_ar` variants, with fallback `selected locale → en → any non-empty` in the entity helpers.

## 4. Missing loading / error / empty states

- **Hero**: the home hero currently has no loading or error state of its own; it renders branding + tagline from `siteSettingsValueProvider`. If that provider is in loading state, the hero still paints, which is fine for branding, but any future owner-text provider used here needs an explicit loading/empty handling. Not yet fixed because the provider is not wired yet.
- **Category rail**: already has `ShimmerRail` for loading, `InlineFailureBanner` for error, and `EmptyState` for no categories.
- **Product gallery**: has `ShimmerBox` placeholder and a broken-image `errorWidget`.
- **Product detail contact actions**: already has an `EmptyState` when there are no contact channels and a localized snackbar when a launch fails.

## 5. Unguarded `.value!` / `.firstWhere` / `!` usages

- The existing storefront reads I touched use safe patterns: `watch(...).value?.where(...) ?? const []`, `category.value?.nameFor(language) ?? l10n.stateLoading`, and `value ?? const <Product>[]` in grid builders.
- No new `!` casts were introduced in the edited storefront files. The only places still worth re-checking elsewhere are the generated Riverpod/JSON/freezed files, which are not edited by hand.

## 6. N+1 queries

- Categories on the home rail are fetched through one `visibleCategoriesProvider` stream; the rail does **not** query per category.
- The old category rail used a hardcoded placeholder icon. The version shipped here now resolves **one image per category** through `StorageUrls` from `Category.coverPath`, falling back to a branded placeholder. A separate per-category product-image lookup is avoided here by storing the category cover on the category row itself; that is the single-source thumbnail for the rail. If the owner later wants “first product image in category” as the fallback, that should be done through a single view/RPC, not N+1 calls.

## 7. Security / RLS

- `site_content` (migration 008): `grant select` to anon+authenticated, `insert/update/delete` to authenticated only; RLS enabled; `public.select` for everyone; admin-only `select`/`insert`/`update`/`delete` via `public.is_admin()`. Realtime membership added.
- `admin_contact_settings` (migration 009): same shape — public read, admin-only write, RLS enabled, realtime membership added.
- Existing tables (`categories`, `products`, `product_media`, `contact_links`, `site_settings`, `text_overrides`) already carry their strict policies; the new contact-settings and site-content tables follow the same model.
- No service keys, anon keys, or other secrets are written into the repo by these changes. The CI workflow already reads Supabase credentials from repository secrets only.

## 8. Missing store essentials

| Essential | Status |
| --- | --- |
| Privacy policy screen / link | Not present as a dedicated screen. There is an About screen (`/about`) and a settings screen, but no privacy-policy link. **Not fixed now** — out of the 6 items, and needs content from the owner. |
| About screen | Present (`/about`), renders store copy + contact links. |
| Account / data handling | Admin account exists (owner gateway, password reset flow present). No customer account system yet. **Not fixed now** — not in the 6 items. |
| Contact | Contact links exist and are editable in admin; product pages show them; launcher wired. Item 3 gap is admin settings + product-page wiring, not the existence of contacts. |
| Version display | No visible app version on the settings/about screen. **Not fixed now** — cosmetic, not in the 6 items. |
| Terms | No separate terms screen. **Not fixed now** — needs content from the owner. |

## 9. Items still pending from the brief

1. **Images break when language changes** — the edited image paths are already locale-independent; remaining work is the owner-facing wiring (item 2) and the image-error widget test for en→am→ar→om.
2. **Admin live edit → user dashboard texts** — migration + RLS tests are in place; app-layer provider + admin edit screen + widget test still needed.
3. **Contact section on all products** — migrations + launcher + manifest + contact-links UI exist; admin settings screen + product-page wiring still needed.
4. **Hero height ~50%** — hero was compacted in `storefront_home_page.dart` (logo 62→40, paddings reduced, tagline now dense two-line, etc.). Exact before/after dp should be measured against the overflow harness, not eyeballed.
5. **Category cards + subcategories** — subcategory line wired; card image resolution still needs one-image-per-card logic in the rail (category cover → fallback placeholder) and a single-query thumbnail source if “first product image” fallback is wanted.
6. **Audit, fixes, build** — migration SQL and RLS assertions are written; the remaining build steps (analyze, test suite, format, l10n parity, RLS script, commit, push, CI release APK/AAB, `bundletool dump manifest`) are not run locally because the host is memory-limited and the brief says to use CI.

## 10. Migration SQL to paste into Supabase SQL Editor

Run these in the SQL Editor in this order. They are idempotent (`if not exists`, `create or replace`, `drop … if exists`), so re-running is safe.

### Migration 008 — site_content

```sql
-- 008 · site_content (live hero / home texts, owner-editable)
create table if not exists public.site_content (
  key         text        not null check (char_length(key) between 1 and 120),
  locale      text        not null check (locale in ('en', 'am', 'ar', 'om')),
  value       text        not null check (char_length(value) between 1 and 2000),
  updated_at  timestamptz not null default now(),
  updated_by  uuid        references auth.users (id) on delete set null,
  primary key (key, locale)
);

create index if not exists site_content_locale_idx
  on public.site_content (locale);

alter table public.site_content
  enable row level security;

grant select on public.site_content to anon, authenticated;
grant insert, update, delete on public.site_content to authenticated;

create policy site_content_public_select on public.site_content
  for select to anon, authenticated using (true);

create policy site_content_admin_select on public.site_content
  for select to authenticated using (public.is_admin());

create policy site_content_admin_insert on public.site_content
  for insert to authenticated with check (public.is_admin());

create policy site_content_admin_update on public.site_content
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy site_content_admin_delete on public.site_content
  for delete to authenticated using (public.is_admin());

drop trigger if exists site_content_set_updated_at on public.site_content;
create trigger site_content_set_updated_at
  before update on public.site_content
  for each row execute function public.set_updated_at();

do $$
begin
  if not exists (
    select 1
      from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'site_content'
  ) then
    alter publication supabase_realtime add table public.site_content;
  end if;
end;
$$;
```

### Migration 009 — admin_contact_settings

```sql
-- 009 · admin_contact_settings (owner phone / WhatsApp / Telegram / social / email)
create table if not exists public.admin_contact_settings (
  id             smallint  not null check (id = 1),
  owner_phone    text,
  owner_email    text,
  whatsapp_number text,
  telegram_handle text,
  instagram_handle text,
  facebook_handle text,
  tiktok_handle  text,
  youtube_handle text,
  website_url    text,
  updated_at     timestamptz not null default now(),
  primary key (id)
);

alter table public.admin_contact_settings
  enable row level security;

grant select on public.admin_contact_settings to anon, authenticated;
grant insert, update, delete on public.admin_contact_settings to authenticated;

create policy admin_contact_settings_public_select on public.admin_contact_settings
  for select to anon, authenticated using (true);

create policy admin_contact_settings_admin_insert on public.admin_contact_settings
  for insert to authenticated with check (public.is_admin());

create policy admin_contact_settings_admin_update on public.admin_contact_settings
  for update to authenticated
  using (public.is_admin())
  with check (public.is_admin());

create policy admin_contact_settings_admin_delete on public.admin_contact_settings
  for delete to authenticated using (public.is_admin());

drop trigger if exists admin_contact_settings_set_updated_at on public.admin_contact_settings;
create trigger admin_contact_settings_set_updated_at
  before update on public.admin_contact_settings
  for each row execute function public.set_updated_at();

insert into public.admin_contact_settings as s (id, updated_at)
values (1, now())
on conflict (id) do nothing;

do $$
begin
  if not exists (
    select 1
      from pg_publication_tables
     where pubname = 'supabase_realtime'
       and schemaname = 'public'
       and tablename = 'admin_contact_settings'
  ) then
    alter publication supabase_realtime add table public.admin_contact_settings;
  end if;
end;
$$;
```

## 11. CI secrets required for the release build (names only)

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SENTRY_DSN` (optional; the build still completes without it)
- `CONFIG_BASE64` (optional; if set it takes precedence over the four individual secrets above)
- `ANDROID_KEYSTORE_BASE64`, `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` (optional; without them the workflow still produces a debug-signed AAB plus the debug APK, and the release-signed AAB steps are skipped)

No secrets are stored in the repository by these changes.
