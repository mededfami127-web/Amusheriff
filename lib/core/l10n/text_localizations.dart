import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'generated/app_localizations.dart';
import 'overridable_localizations.dart';

/// Registers the override-aware [AppLocalizations] with `MaterialApp`.
///
/// This is the single seam that makes the owner's edits app-wide: every screen
/// already resolves its strings through `AppLocalizations.of(context)`, so
/// handing it a wrapper that prefers the owner's wording changes all of them
/// without touching a single call site.
///
/// [overrides] is the map for the locale the app is currently showing. An empty
/// map returns the generated instance untouched, so a fresh install — and a
/// failed network fetch — costs nothing.
class OverridableLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const OverridableLocalizationsDelegate({this.overrides = const <String, String>{}});

  final Map<String, String> overrides;

  @override
  bool isSupported(Locale locale) => AppLocalizations.delegate.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final AppLocalizations base = await AppLocalizations.delegate.load(locale);
    if (overrides.isEmpty) return base;
    return OverridableAppLocalizations(base, overrides);
  }

  /// Reload only when the wording actually differs, so the app does not rebuild
  /// its whole string table on every provider tick.
  @override
  bool shouldReload(
    covariant LocalizationsDelegate<AppLocalizations> old,
  ) =>
      old is! OverridableLocalizationsDelegate ||
      !mapEquals(old.overrides, overrides);
}

/// Fills the gap for locales the Flutter SDK does not translate.
///
/// Oromo is one: `GlobalMaterialLocalizations`/`GlobalCupertinoLocalizations`
/// ship Amharic and Arabic but no `om`, so running the app in Oromo would make
/// `MaterialApp` warn that a locale is "not supported by all of its localization
/// delegates" and leave Material chrome (tooltips, dialog buttons, pickers)
/// falling through to the widget-layer default.
///
/// Answering those two delegates with the English resource keeps Material
/// widgets working and quiet, while every string the app itself owns is still
/// served in Oromo from `app_om.arb`. It only answers for locales that are
/// missing from the real delegate, so Amharic and Arabic keep their proper
/// translations.
class FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale) &&
      !GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) =>
      false;
}

/// The Cupertino twin of [FallbackMaterialLocalizationsDelegate].
class FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.delegate.isSupported(locale) &&
      !GlobalCupertinoLocalizations.delegate.isSupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(
    covariant LocalizationsDelegate<CupertinoLocalizations> old,
  ) =>
      false;
}

/// Every delegate `MaterialApp` installs, in precedence order.
///
/// One list, so a test that pumps a screen resolves exactly what the app does —
/// including the gap-fill delegates above.
List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates({
  required Map<String, String> overrides,
}) =>
    <LocalizationsDelegate<dynamic>>[
      OverridableLocalizationsDelegate(overrides: overrides),
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      const FallbackMaterialLocalizationsDelegate(),
      const FallbackCupertinoLocalizationsDelegate(),
    ];
