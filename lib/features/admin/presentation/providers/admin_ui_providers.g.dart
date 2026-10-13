// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_ui_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the owner asked to see the storefront exactly as a customer would.
///
/// This is a UI affordance, not an authorisation boundary: RLS already stops
/// anon from seeing unpublished rows, and the storefront only ever queries
/// published data. Flipping this on hides the admin chrome so the owner can
/// sanity-check what is live.

@ProviderFor(PreviewAsCustomer)
final previewAsCustomerProvider = PreviewAsCustomerProvider._();

/// Whether the owner asked to see the storefront exactly as a customer would.
///
/// This is a UI affordance, not an authorisation boundary: RLS already stops
/// anon from seeing unpublished rows, and the storefront only ever queries
/// published data. Flipping this on hides the admin chrome so the owner can
/// sanity-check what is live.
final class PreviewAsCustomerProvider
    extends $NotifierProvider<PreviewAsCustomer, bool> {
  /// Whether the owner asked to see the storefront exactly as a customer would.
  ///
  /// This is a UI affordance, not an authorisation boundary: RLS already stops
  /// anon from seeing unpublished rows, and the storefront only ever queries
  /// published data. Flipping this on hides the admin chrome so the owner can
  /// sanity-check what is live.
  PreviewAsCustomerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'previewAsCustomerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$previewAsCustomerHash();

  @$internal
  @override
  PreviewAsCustomer create() => PreviewAsCustomer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$previewAsCustomerHash() => r'81a49049955150753eff96d18edadb026ea725d2';

/// Whether the owner asked to see the storefront exactly as a customer would.
///
/// This is a UI affordance, not an authorisation boundary: RLS already stops
/// anon from seeing unpublished rows, and the storefront only ever queries
/// published data. Flipping this on hides the admin chrome so the owner can
/// sanity-check what is live.

abstract class _$PreviewAsCustomer extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
