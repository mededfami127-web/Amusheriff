# Changelog

All notable changes to this project will be documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

No unreleased changes.

## [1.0.9] - 2026-10-22

### Fixed

- The app bar, hero and About page show “Amusheriff Arabiyan Mejlis and Furniture” even when
  `site_settings.store_name_en` still holds a pre-rename spelling: a blank or legacy stored
  name now resolves to the localised brand, while a name the owner typed is kept.
- The app bar grows with the text scale and clamps the wordmark, so the two-line name fits a
  320 dp screen at a 2.0 text scale without clipping or ellipsis.
- `supabase/APPLY_ALL.sql` ends with an unguarded update of the stored shop name, so running
  the file once fixes the live row.

## [1.0.8] - 2026-10-21

### Added

- Category chips beside “All products” on the storefront home, so a shopper can narrow the
  grid to one subcategory.
- A subcategory dropdown in the product editor; it appears once a mother category that has
  children is chosen.

### Changed

- The shop is now “Amusheriff Arabiyan Mejlis and Furniture”: the hero wraps the full name and
  the app bar shows it on two lines instead of truncating it.
- Category covers are compressed and resized before upload, the same way product images are.

### Fixed

- Uploaded category covers render on the dashboard; they were read as packaged assets and
  could never load.
- A successful upload refreshes the product tile and product page immediately instead of
  waiting for the next realtime event.
- Upload failures show the storage gateway's status code and message under the friendly line.
- A double tap on Save in the product or category form no longer writes the row twice.
- Deleting a category that still holds products or subcategories explains why it is refused
  instead of surfacing a database error.
- `supabase/APPLY_ALL.sql` now creates the catalogue tables, `profiles`, `is_admin()` and
  `site_settings` when they are missing, so a fresh project can be brought up from that one file.

## [1.0.0] - 2026-10-20

### Added

- First public release of the Amusheriff storefront and admin app.
- Storefront home, category, product detail, search, favorites, and privacy-linked settings screens.
- Admin gate with password entry, dashboard, products, categories, contacts, inquiries,
  site content and site settings editing, and system check diagnostics.
- Catalog data layer backed by Supabase with storage URLs, catalog remote data source, and
  repository implementations for products, categories, and product media.
- Contact repository and launcher used by the product page’s “Buy” and “Contact the owner”
  flows, with primary link and order channel helpers.
- Language support for English, Amharic, Arabic, and Oromo, with overridable localizations for
  live-edited site content and text overrides.
- Site content live-edit flow with an admin editor page and sheet, and home-storefront texts that
  read site content before falling back to localized defaults.
- Compact hero on the storefront home page and full-bleed category card imagery with fallback and
  placeholder treatment.
- Privacy Policy row in settings that opens the configured Google Sites URL.
- Supabase migrations for the initial schema, RLS policies, views/RPC helpers, storage buckets,
  subcategories, site content, text overrides, and admin contact settings.
- CI workflow for building the release AAB without the unused prod product flavor, plus Android SDK
  provisioning helper scripts and Android/Gradle signing configuration for release builds.
- App icon assets regenerated in the chosen gold treatment for launcher and adaptive icon entries.
- Unit tests covering router guards, text overrides, system checks, admin gateway behavior,
  storefront subcategory rendering, overflow safety, and live-edit + layout behavior.

### Changed

- Consolidated release tooling so CI can ship an AAB without depending on a non-existent prod
  flavor.
- Normalized CI script permissions and made the Android SDK install paths explicit.

### Fixed

- Home screen storefront texts now honor site content overrides before using localized fallbacks.
- Category card imagery now falls back cleanly when a cover is missing.
- Admin contact settings are exposed alongside contacts management.

### Known limitations

- The release AAB signing keystore is intentionally not committed; it must be supplied via
  `android/key.properties` locally or through the CI `ANDROID_KEYSTORE_BASE64` secret for a
  publishable build.

[Unreleased]: https://github.com/mededfami127-web/Amusheriff/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/mededfami127-web/Amusheriff/releases/tag/v1.0.0
