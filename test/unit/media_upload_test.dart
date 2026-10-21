import 'dart:typed_data';

import 'package:amu_sharif_majlis/core/errors/app_failure.dart';
import 'package:amu_sharif_majlis/core/errors/error_mapper.dart';
import 'package:amu_sharif_majlis/features/catalog/data/datasources/storage_datasource.dart';
import 'package:amu_sharif_majlis/features/catalog/data/media/media_processor.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/drafts/catalog_drafts.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/media_kind.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/entities/product_media.dart';
import 'package:amu_sharif_majlis/features/catalog/domain/repositories/catalog_repositories.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/controllers/media_upload_controller.dart';
import 'package:amu_sharif_majlis/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The upload path with the network and the native compressor faked out.
///
/// What is asserted is the contract the owner cares about: a picked image is
/// compressed, written to the right bucket and path, its `product_media` row
/// stores that path, and a refused upload keeps the gateway's own code and
/// message so the admin banner can name the fix instead of saying "failed".
void main() {
  late _FakeStorage storage;
  late _FakeMediaRepository media;
  late ProviderContainer container;
  late ProviderSubscription<List<MediaUploadItem>> subscription;

  setUp(() {
    storage = _FakeStorage();
    media = _FakeMediaRepository();
    container = ProviderContainer(
      overrides: [
        storageDataSourceProvider.overrideWithValue(storage),
        productMediaRepositoryProvider.overrideWithValue(media),
      ],
    );
    // `mediaUploadControllerProvider` is auto-disposed: without a listener the
    // controller would be thrown away between `read` calls.
    subscription = container.listen(
      mediaUploadControllerProvider,
      (_, __) {},
      fireImmediately: true,
    );
  });

  tearDown(() {
    subscription.close();
    container.dispose();
    MediaUploadController.processor = const MediaProcessor();
  });

  Future<List<MediaUploadItem>> upload() async {
    MediaUploadController.processor = const _FakeProcessor();
    await container
        .read(mediaUploadControllerProvider.notifier)
        .enqueue(
          productId: 'p1',
          files: <XFile>[XFile('IMG_0042.JPG')],
          kind: MediaKind.image,
        );
    return container.read(mediaUploadControllerProvider);
  }

  test('a picked image is compressed, uploaded and stored on its row', () async {
    final List<MediaUploadItem> items = await upload();

    expect(items, hasLength(1));
    expect(items.single.phase, UploadPhase.done);

    // Compressed bytes, not the raw file, and the bucket the migration creates.
    expect(storage.uploads, hasLength(1));
    final _Upload call = storage.uploads.single;
    expect(call.bucket, StorageDataSource.productMediaBucket);
    expect(call.bucket, 'product-media');
    expect(call.contentType, 'image/jpeg');
    expect(call.bytes, orderedEquals(_FakeProcessor.jpeg));

    // The path is unique, under the folder the storage policy allows, and has
    // no spaces or non-ASCII characters in it.
    expect(call.path, startsWith('products/p1/'));
    expect(call.path, endsWith('.jpg'));
    expect(
      RegExp(r'^products/p1/[0-9a-f-]{36}\.jpg$').hasMatch(call.path),
      isTrue,
    );

    // The row that the storefront reads carries the uploaded path.
    expect(media.added, hasLength(1));
    expect(media.added.single.productId, 'p1');
    expect(media.added.single.storagePath, call.path);
    expect(media.added.single.isCover, isTrue);
  });

  test('a refused upload keeps the gateway code and message', () async {
    storage.refusal = const StorageException(
      'new row violates row-level security policy',
      error: 'Unauthorized',
      statusCode: '403',
    );

    final List<MediaUploadItem> items = await upload();

    expect(items.single.phase, UploadPhase.failed);
    expect(items.single.isFinished, isTrue);

    final AppFailure failure = items.single.failure!;
    expect(failure, isA<PermissionFailure>());
    expect(failure.messageKey, 'errorPermission');

    // What the admin banner prints under the friendly sentence.
    final String? detail = technicalDetailFor(failure);
    expect(detail, contains('HTTP 403'));
    expect(detail, contains('row-level security policy'));

    // No orphan row was written for a file that never landed.
    expect(media.added, isEmpty);
  });

  test(
    'a processor failure is reported as media, never as a dead queue',
    () async {
      MediaUploadController.processor = const _FailingProcessor();

      await container
          .read(mediaUploadControllerProvider.notifier)
          .enqueue(
            productId: 'p1',
            files: <XFile>[XFile('huge.jpg')],
            kind: MediaKind.image,
          );

      final MediaUploadItem item = container
          .read(mediaUploadControllerProvider)
          .single;
      expect(item.phase, UploadPhase.failed);
      expect(item.failure?.messageKey, 'errorMediaImageTooLarge');
      expect(storage.uploads, isEmpty);
      expect(media.added, isEmpty);
    },
  );
}

class _Upload {
  const _Upload({
    required this.bucket,
    required this.path,
    required this.bytes,
    required this.contentType,
  });

  final String bucket;
  final String path;
  final Uint8List bytes;
  final String contentType;
}

class _FakeStorage implements StorageDataSource {
  final List<_Upload> uploads = <_Upload>[];
  StorageException? refusal;

  @override
  Future<String> upload({
    required String bucket,
    required String path,
    required Uint8List bytes,
    required String contentType,
    int retryAttempts = 3,
    StorageRetryController? retryController,
  }) async {
    if (refusal case final StorageException error) throw error;
    uploads.add(
      _Upload(
        bucket: bucket,
        path: path,
        bytes: bytes,
        contentType: contentType,
      ),
    );
    return path;
  }

  @override
  Future<void> remove(String bucket, String path) async {}

  @override
  Future<void> removeQuietly(String bucket, String path) async {}
}

class _FakeProcessor implements MediaProcessor {
  const _FakeProcessor();

  static final Uint8List jpeg = Uint8List.fromList(<int>[
    0xff,
    0xd8,
    0xff,
    0xd9,
  ]);

  @override
  Future<ProcessedMedia> process({
    required XFile file,
    required MediaKind kind,
  }) async =>
      ProcessedMedia(bytes: jpeg, extension: 'jpg', contentType: 'image/jpeg');
}

class _FailingProcessor implements MediaProcessor {
  const _FailingProcessor();

  @override
  Future<ProcessedMedia> process({
    required XFile file,
    required MediaKind kind,
  }) async => throw const MediaFailure(messageKey: 'errorMediaImageTooLarge');
}

class _FakeMediaRepository implements ProductMediaRepository {
  final List<ProductMediaDraft> added = <ProductMediaDraft>[];

  @override
  Stream<List<ProductMedia>> watchAll() =>
      Stream<List<ProductMedia>>.value(const <ProductMedia>[]);

  @override
  Stream<List<ProductMedia>> watchForProduct(String productId) =>
      Stream<List<ProductMedia>>.value(const <ProductMedia>[]);

  @override
  Future<List<ProductMedia>> fetchForProduct(String productId) async =>
      const <ProductMedia>[];

  @override
  Future<ProductMedia> add(ProductMediaDraft draft) async {
    added.add(draft);
    return ProductMedia(
      id: 'm${added.length}',
      productId: draft.productId,
      kind: draft.kind,
      storagePath: draft.storagePath,
      isCover: draft.isCover,
      sortOrder: draft.sortOrder,
    );
  }

  @override
  Future<ProductMedia> update(String id, ProductMediaDraft draft) async =>
      ProductMedia(
        id: id,
        productId: draft.productId,
        kind: draft.kind,
        storagePath: draft.storagePath,
      );

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> setCover(String productId, String mediaId) async {}

  @override
  Future<void> reorder(List<String> orderedIds) async {}
}
