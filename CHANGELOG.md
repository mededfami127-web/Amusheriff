# Changelog

All notable changes to this project will be documented in this file.

The format is loosely based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [SemVer](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

No unreleased changes.

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
