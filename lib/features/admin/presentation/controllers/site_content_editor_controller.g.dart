// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_content_editor_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Edits one [site_content] key.
///
/// The sheet is a bottom sheet, so the controller is `keepAlive`: an
/// auto-disposed draft would be thrown away before the sheet is first built.

@ProviderFor(SiteContentEditorController)
final siteContentEditorControllerProvider =
    SiteContentEditorControllerProvider._();

/// Edits one [site_content] key.
///
/// The sheet is a bottom sheet, so the controller is `keepAlive`: an
/// auto-disposed draft would be thrown away before the sheet is first built.
final class SiteContentEditorControllerProvider
    extends
        $NotifierProvider<SiteContentEditorController, SiteContentEditorState> {
  /// Edits one [site_content] key.
  ///
  /// The sheet is a bottom sheet, so the controller is `keepAlive`: an
  /// auto-disposed draft would be thrown away before the sheet is first built.
  SiteContentEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteContentEditorControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteContentEditorControllerHash();

  @$internal
  @override
  SiteContentEditorController create() => SiteContentEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiteContentEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiteContentEditorState>(value),
    );
  }
}

String _$siteContentEditorControllerHash() =>
    r'de12adf4ad5ddc6781858cc176416f4a463781e7';

/// Edits one [site_content] key.
///
/// The sheet is a bottom sheet, so the controller is `keepAlive`: an
/// auto-disposed draft would be thrown away before the sheet is first built.

abstract class _$SiteContentEditorController
    extends $Notifier<SiteContentEditorState> {
  SiteContentEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SiteContentEditorState, SiteContentEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SiteContentEditorState, SiteContentEditorState>,
              SiteContentEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The locales the owner can edit.
/// Locale the site-content page is currently showing.
///
/// `keepAlive` like the draft controller: the page and its sheet share this
/// selection, and a bottom-sheet rebuild must not reset it.

@ProviderFor(SiteContentEditorLocale)
final siteContentEditorLocaleProvider = SiteContentEditorLocaleProvider._();

/// The locales the owner can edit.
/// Locale the site-content page is currently showing.
///
/// `keepAlive` like the draft controller: the page and its sheet share this
/// selection, and a bottom-sheet rebuild must not reset it.
final class SiteContentEditorLocaleProvider
    extends $NotifierProvider<SiteContentEditorLocale, String> {
  /// The locales the owner can edit.
  /// Locale the site-content page is currently showing.
  ///
  /// `keepAlive` like the draft controller: the page and its sheet share this
  /// selection, and a bottom-sheet rebuild must not reset it.
  SiteContentEditorLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteContentEditorLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteContentEditorLocaleHash();

  @$internal
  @override
  SiteContentEditorLocale create() => SiteContentEditorLocale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$siteContentEditorLocaleHash() =>
    r'895d2b85fc8295eb58f33f6570be5c13d94dd2df';

/// The locales the owner can edit.
/// Locale the site-content page is currently showing.
///
/// `keepAlive` like the draft controller: the page and its sheet share this
/// selection, and a bottom-sheet rebuild must not reset it.

abstract class _$SiteContentEditorLocale extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
