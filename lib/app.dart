import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/l10n/generated/app_localizations.dart';
import 'core/l10n/text_localizations.dart';
import 'core/network/connectivity_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_boundary.dart';
import 'features/settings/presentation/providers/site_settings_providers.dart';
import 'features/text_editor/presentation/providers/text_editor_providers.dart';

/// Root widget.
///
/// One `MaterialApp.router` serves both surfaces: the public storefront and the
/// guarded admin gateway. Locale and theme come from the persisted preferences
/// loaded during `bootstrap()`, so the very first frame is already correct —
/// including right-to-left layout for Arabic.
class AmuApp extends ConsumerWidget {
  const AmuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GoRouter router = ref.watch(appRouterProvider);
    final AppPreferencesState prefs = ref.watch(appPreferencesProvider);

    // The owner's own wording for the language on screen. Empty until the first
    // event (and whenever the fetch fails), which renders the shipped ARB text.
    final Map<String, String> overrides = ref.watch(
      textOverridesValueProvider(prefs.language.code),
    );

    return MaterialApp.router(
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: prefs.themeMode,
      locale: prefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      // A device locale the catalogue does not ship (or `om_ET`) resolves to a
      // language this app has text and number data for, not to no locale.
      localeResolutionCallback: resolveAppLocale,
      // `appLocalizationsDelegates` puts the override-aware delegate in the
      // generated one's place, so every `AppLocalizations.of(context)` lookup in
      // the app honours the owner's edits without a call site changing, and
      // gap-fills Material/Cupertino for a locale the SDK does not translate
      // (Oromo).
      localizationsDelegates: appLocalizationsDelegates(overrides: overrides),
      routerConfig: router,
      builder: (BuildContext context, Widget? child) {
        // Clamp text scaling so the luxury layouts never break, while still
        // honouring a user's accessibility setting up to a sane maximum.
        final MediaQueryData media = MediaQuery.of(context);
        return AppErrorBoundary(
          child: OfflineBannerHost(
            child: MediaQuery(
              data: media.copyWith(
                textScaler: media.textScaler.clamp(
                  minScaleFactor: 0.9,
                  maxScaleFactor: 1.35,
                ),
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
