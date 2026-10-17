// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_editors.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Create / edit a category, including its optional place under a mother
/// category.
///
/// `keepAlive` on purpose: the category sheet is a bottom sheet, which Riverpod
/// builds one frame after `load()` seeds this draft — an auto-disposed state is
/// already gone by then, so an edit form would open empty and a subcategory
/// would be created as a top-level category. Every open calls [load], so the
/// state can never go stale between openings.

@ProviderFor(CategoryEditorController)
final categoryEditorControllerProvider = CategoryEditorControllerProvider._();

/// Create / edit a category, including its optional place under a mother
/// category.
///
/// `keepAlive` on purpose: the category sheet is a bottom sheet, which Riverpod
/// builds one frame after `load()` seeds this draft — an auto-disposed state is
/// already gone by then, so an edit form would open empty and a subcategory
/// would be created as a top-level category. Every open calls [load], so the
/// state can never go stale between openings.
final class CategoryEditorControllerProvider
    extends $NotifierProvider<CategoryEditorController, CategoryEditorState> {
  /// Create / edit a category, including its optional place under a mother
  /// category.
  ///
  /// `keepAlive` on purpose: the category sheet is a bottom sheet, which Riverpod
  /// builds one frame after `load()` seeds this draft — an auto-disposed state is
  /// already gone by then, so an edit form would open empty and a subcategory
  /// would be created as a top-level category. Every open calls [load], so the
  /// state can never go stale between openings.
  CategoryEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryEditorControllerProvider',
        isAutoDispose: false,
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
    r'4e2dbe81514aace5ac6b195b8dae09fc4cb6085f';

/// Create / edit a category, including its optional place under a mother
/// category.
///
/// `keepAlive` on purpose: the category sheet is a bottom sheet, which Riverpod
/// builds one frame after `load()` seeds this draft — an auto-disposed state is
/// already gone by then, so an edit form would open empty and a subcategory
/// would be created as a top-level category. Every open calls [load], so the
/// state can never go stale between openings.

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
    r'1dcb685ca25a3f7f9b63b6c9a58421f45b81653d';

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

/// Edits the singleton `site_settings` row.
///
/// The draft is seeded from the live row, so opening the screen always shows
/// what the storefront is currently serving and a remote edit lands here too.

@ProviderFor(SiteSettingsEditorController)
final siteSettingsEditorControllerProvider =
    SiteSettingsEditorControllerProvider._();

/// Edits the singleton `site_settings` row.
///
/// The draft is seeded from the live row, so opening the screen always shows
/// what the storefront is currently serving and a remote edit lands here too.
final class SiteSettingsEditorControllerProvider
    extends
        $NotifierProvider<
          SiteSettingsEditorController,
          SiteSettingsEditorState
        > {
  /// Edits the singleton `site_settings` row.
  ///
  /// The draft is seeded from the live row, so opening the screen always shows
  /// what the storefront is currently serving and a remote edit lands here too.
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
    r'd82dc06abc0a33cedca82d7fed5c441760e92839';

/// Edits the singleton `site_settings` row.
///
/// The draft is seeded from the live row, so opening the screen always shows
/// what the storefront is currently serving and a remote edit lands here too.

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

@ProviderFor(ProductEditorController)
final productEditorControllerProvider = ProductEditorControllerProvider._();

final class ProductEditorControllerProvider
    extends $NotifierProvider<ProductEditorController, ProductEditorState> {
  ProductEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productEditorControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productEditorControllerHash();

  @$internal
  @override
  ProductEditorController create() => ProductEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductEditorState>(value),
    );
  }
}

String _$productEditorControllerHash() =>
    r'f228a6753ad5c2d9e50f108070f8e050b57a41e9';

abstract class _$ProductEditorController extends $Notifier<ProductEditorState> {
  ProductEditorState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ProductEditorState, ProductEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductEditorState, ProductEditorState>,
              ProductEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Controller that owns the media drag-to-reorder, cover toggling and delete
/// rollbacks in the product editor.

@ProviderFor(ProductMediaOrderController)
final productMediaOrderControllerProvider =
    ProductMediaOrderControllerProvider._();

/// Controller that owns the media drag-to-reorder, cover toggling and delete
/// rollbacks in the product editor.
final class ProductMediaOrderControllerProvider
    extends $NotifierProvider<ProductMediaOrderController, List<String>> {
  /// Controller that owns the media drag-to-reorder, cover toggling and delete
  /// rollbacks in the product editor.
  ProductMediaOrderControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productMediaOrderControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productMediaOrderControllerHash();

  @$internal
  @override
  ProductMediaOrderController create() => ProductMediaOrderController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$productMediaOrderControllerHash() =>
    r'c32a1e09b7f9ea11977aa6c7ac8bea05f2492456';

/// Controller that owns the media drag-to-reorder, cover toggling and delete
/// rollbacks in the product editor.

abstract class _$ProductMediaOrderController extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<String>, List<String>>,
              List<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
