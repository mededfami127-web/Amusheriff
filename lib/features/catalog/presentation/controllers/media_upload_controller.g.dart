// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_upload_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(storageDataSource)
final storageDataSourceProvider = StorageDataSourceProvider._();

final class StorageDataSourceProvider
    extends
        $FunctionalProvider<
          StorageDataSource,
          StorageDataSource,
          StorageDataSource
        >
    with $Provider<StorageDataSource> {
  StorageDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storageDataSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storageDataSourceHash();

  @$internal
  @override
  $ProviderElement<StorageDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StorageDataSource create(Ref ref) {
    return storageDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StorageDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StorageDataSource>(value),
    );
  }
}

String _$storageDataSourceHash() => r'a179e157f45f4a8ef45fd543c227eed4afa86f6f';

/// Upload queue for the media manager: **concurrency 2**, per-file phase,
/// cancel and retry, plus a compensating delete when the catalogue row that
/// should reference an uploaded file never gets written.

@ProviderFor(MediaUploadController)
final mediaUploadControllerProvider = MediaUploadControllerProvider._();

/// Upload queue for the media manager: **concurrency 2**, per-file phase,
/// cancel and retry, plus a compensating delete when the catalogue row that
/// should reference an uploaded file never gets written.
final class MediaUploadControllerProvider
    extends $NotifierProvider<MediaUploadController, List<MediaUploadItem>> {
  /// Upload queue for the media manager: **concurrency 2**, per-file phase,
  /// cancel and retry, plus a compensating delete when the catalogue row that
  /// should reference an uploaded file never gets written.
  MediaUploadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaUploadControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaUploadControllerHash();

  @$internal
  @override
  MediaUploadController create() => MediaUploadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<MediaUploadItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<MediaUploadItem>>(value),
    );
  }
}

String _$mediaUploadControllerHash() =>
    r'134c06e4d635a6a43c95ee61ea3aa5d05aec9e9e';

/// Upload queue for the media manager: **concurrency 2**, per-file phase,
/// cancel and retry, plus a compensating delete when the catalogue row that
/// should reference an uploaded file never gets written.

abstract class _$MediaUploadController
    extends $Notifier<List<MediaUploadItem>> {
  List<MediaUploadItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<MediaUploadItem>, List<MediaUploadItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<MediaUploadItem>, List<MediaUploadItem>>,
              List<MediaUploadItem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
