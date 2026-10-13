// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_editors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create / edit a category.
///
/// Validation mirrors the database CHECK constraints, so a message appears
/// before the round trip and the policy still has the final say.

@ProviderFor(CategoryEditorController)
final categoryEditorControllerProvider = CategoryEditorControllerProvider._();

/// Create / edit a category.
///
/// Validation mirrors the database CHECK constraints, so a message appears
/// before the round trip and the policy still has the final say.
final class CategoryEditorControllerProvider
    extends $NotifierProvider<CategoryEditorController, CategoryEditorState> {
  /// Create / edit a category.
  ///
  /// Validation mirrors the database CHECK constraints, so a message appears
  /// before the round trip and the policy still has the final say.
  CategoryEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryEditorControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryEditorControllerHash();

  @$internal
  @override
  CategoryEditorController create() => CategoryEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryEditorState>(value),
    );
  }
}

String _$categoryEditorControllerHash() =>
    r'bf4ac0973aa1f94181aa4e8eeaf8a8d2c87909ea';

/// Create / edit a category.
///
/// Validation mirrors the database CHECK constraints, so a message appears
/// before the round trip and the policy still has the final say.

abstract class _$CategoryEditorController
    extends $Notifier<CategoryEditorState> {
  CategoryEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CategoryEditorState, CategoryEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryEditorState, CategoryEditorState>,
              CategoryEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Adds or edits a single contact link.

@ProviderFor(ContactsEditorController)
final contactsEditorControllerProvider = ContactsEditorControllerProvider._();

/// Adds or edits a single contact link.
final class ContactsEditorControllerProvider
    extends $NotifierProvider<ContactsEditorController, ContactDraftState> {
  /// Adds or edits a single contact link.
  ContactsEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contactsEditorControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$contactsEditorControllerHash();

  @$internal
  @override
  ContactsEditorController create() => ContactsEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContactDraftState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContactDraftState>(value),
    );
  }
}

String _$contactsEditorControllerHash() =>
    r'543125acf29bd5716bda3e8621e8e1a3f6f09b68';

/// Adds or edits a single contact link.

abstract class _$ContactsEditorController extends $Notifier<ContactDraftState> {
  ContactDraftState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ContactDraftState, ContactDraftState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContactDraftState, ContactDraftState>,
              ContactDraftState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Edits the singleton `site_settings` row: store name, tagline, about,
/// logo, currency and default language.

@ProviderFor(SiteSettingsEditorController)
final siteSettingsEditorControllerProvider =
    SiteSettingsEditorControllerProvider._();

/// Edits the singleton `site_settings` row: store name, tagline, about,
/// logo, currency and default language.
final class SiteSettingsEditorControllerProvider
    extends
        $NotifierProvider<
          SiteSettingsEditorController,
          SiteSettingsEditorState
        > {
  /// Edits the singleton `site_settings` row: store name, tagline, about,
  /// logo, currency and default language.
  SiteSettingsEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'siteSettingsEditorControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$siteSettingsEditorControllerHash();

  @$internal
  @override
  SiteSettingsEditorController create() => SiteSettingsEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SiteSettingsEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SiteSettingsEditorState>(value),
    );
  }
}

String _$siteSettingsEditorControllerHash() =>
    r'bcbd2fb3382f13c1c603b9906d568c175d964be2';

/// Edits the singleton `site_settings` row: store name, tagline, about,
/// logo, currency and default language.

abstract class _$SiteSettingsEditorController
    extends $Notifier<SiteSettingsEditorState> {
  SiteSettingsEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<SiteSettingsEditorState, SiteSettingsEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SiteSettingsEditorState, SiteSettingsEditorState>,
              SiteSettingsEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
