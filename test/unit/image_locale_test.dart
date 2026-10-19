import 'package:amu_sharif_majlis/core/l10n/generated/app_localizations.dart';
import 'package:amu_sharif_majlis/core/network/storage_urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// An image is addressed by its bucket path, never by the visitor's locale.
///
/// `StorageUrls` takes only the storage path, so the same row must produce the
/// same URL for every supported language while the *text* around it changes.
/// This is the regression the brief names: switching locale must not swap an
/// image for a broken request.
void main() {
  late StorageUrls urls;

  setUpAll(() {
    // URL construction is local; no request leaves the process.
    urls = StorageUrls(
      SupabaseClient('https://example.supabase.co', 'test-anon-key'),
    );
  });

  test('category covers keep one URL across en/am/ar/om', () {
    const String path = 'categories/c1/cover.png';
    final String expected = urls.categoryCover(path);

    expect(expected, contains(path));

    for (final String code in <String>['en', 'am', 'ar', 'om']) {
      final Locale locale = Locale(code);
      final AppLocalizations l10n = lookupAppLocalizations(locale);

      // Prove the locale really resolved, so the URL check below is not a
      // no-op loop over the same object.
      expect(l10n.localeName.split('_').first, code);
      expect(urls.categoryCover(path), expected);
    }
  });

  test('product media keeps one URL across locales, thumb and full', () {
    const String path = 'products/p1/m1.webp';
    final String full = urls.productMedia(path);
    final String thumb = urls.productMediaThumb(path);

    expect(full, contains(path));
    expect(thumb, contains(path));
    expect(thumb, isNot(full));

    for (final String code in <String>['en', 'am', 'ar', 'om']) {
      lookupAppLocalizations(Locale(code));
      expect(urls.productMedia(path), full);
      expect(urls.productMediaThumb(path), thumb);
    }
  });
}
