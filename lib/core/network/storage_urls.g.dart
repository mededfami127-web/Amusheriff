// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_urls.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storageUrls)
final storageUrlsProvider = StorageUrlsProvider._();

final class StorageUrlsProvider
    extends $FunctionalProvider<StorageUrls, StorageUrls, StorageUrls>
    with $Provider<StorageUrls> {
  StorageUrlsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageUrlsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageUrlsHash();

  @$internal
  @override
  $ProviderElement<StorageUrls> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StorageUrls create(Ref ref) {
    return storageUrls(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageUrls value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageUrls>(value),
    );
  }
}

String _$storageUrlsHash() => r'c169d3de182b356764066300eb42854c2fc19e13';
