import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../domain/drafts/catalog_drafts.dart';
import '../../domain/entities/media_kind.dart';
import '../../domain/entities/product_media.dart';
import '../../domain/repositories/catalog_repositories.dart';
import '../../data/datasources/storage_datasource.dart';
import '../../data/media/media_processor.dart';
import '../providers/catalog_providers.dart';

part 'media_upload_controller.g.dart';

@Riverpod(keepAlive: true)
StorageDataSource storageDataSource(Ref ref) =>
    StorageDataSource(ref.watch(supabaseClientProvider));

/// Where an individual file is in the queue.
///
/// The Supabase storage client exposes no byte-level progress callback, so
/// reporting a percentage would be theatre. Each file reports the real phase it
/// is in instead, and [MediaUploadController.progress] reports genuine
/// completion counts.
enum UploadPhase { queued, processing, uploading, done, failed, cancelled }

@immutable
class MediaUploadItem {
  const MediaUploadItem({
    required this.id,
    required this.file,
    required this.kind,
    this.phase = UploadPhase.queued,
    this.failure,
    this.mediaId,
  });

  final String id;
  final XFile file;
  final MediaKind kind;
  final UploadPhase phase;
  final AppFailure? failure;

  /// Set once the `product_media` row exists, so the grid can take over.
  final String? mediaId;

  bool get isFinished =>
      phase == UploadPhase.done ||
      phase == UploadPhase.failed ||
      phase == UploadPhase.cancelled;

  String get fileName => file.name;

  MediaUploadItem copyWith({
    UploadPhase? phase,
    AppFailure? failure,
    String? mediaId,
    bool clearFailure = false,
  }) => MediaUploadItem(
    id: id,
    file: file,
    kind: kind,
    phase: phase ?? this.phase,
    failure: clearFailure ? null : failure ?? this.failure,
    mediaId: mediaId ?? this.mediaId,
  );
}

/// Upload queue for the media manager: **concurrency 2**, per-file phase,
/// cancel and retry, plus a compensating delete when the catalogue row that
/// should reference an uploaded file never gets written.
@riverpod
class MediaUploadController extends _$MediaUploadController {
  @override
  List<MediaUploadItem> build() {
    ref.onDispose(() => _cancelled.clear());
    return const <MediaUploadItem>[];
  }

  /// Concurrency limit required by the brief.
  static const int maxConcurrent = 2;

  static const MediaProcessor _processor = MediaProcessor();

  final Map<String, bool> _cancelled = <String, bool>{};
  int _seq = 0;

  bool get hasPending => state.any(
    (MediaUploadItem i) =>
        i.phase == UploadPhase.queued ||
        i.phase == UploadPhase.processing ||
        i.phase == UploadPhase.uploading,
  );

  /// Queue completion as a real fraction: finished files over total.
  double get progress {
    if (state.isEmpty) return 0;
    final int done = state.where((MediaUploadItem i) => i.isFinished).length;
    return done / state.length;
  }

  /// Adds [files] to the queue and starts a pool of [maxConcurrent] workers.
  /// Returns once everything queued has settled.
  Future<void> enqueue({
    required String productId,
    required List<XFile> files,
    required MediaKind kind,
  }) async {
    final List<MediaUploadItem> added = files
        .map(
          (XFile f) => MediaUploadItem(id: 'u${_seq++}', file: f, kind: kind),
        )
        .toList(growable: false);

    state = <MediaUploadItem>[...state, ...added];

    final List<MediaUploadItem> pending = added
        .map((MediaUploadItem i) => i)
        .toList(growable: true);
    final List<Future<void>> workers = List<Future<void>>.generate(
      maxConcurrent,
      (int index) async {
        while (pending.isNotEmpty) {
          final MediaUploadItem next = pending.removeAt(0);
          await _runOne(productId, next.id);
        }
      },
    );
    await Future.wait<void>(workers);
  }

  Future<void> _runOne(String productId, String itemId) async {
    final MediaUploadItem? start = _find(itemId);
    if (start == null) return;
    if (_cancelled[itemId] == true) {
      _patch(itemId, phase: UploadPhase.cancelled);
      return;
    }

    final StorageDataSource storage = ref.read(storageDataSourceProvider);
    final ProductMediaRepository mediaRepo = ref.read(
      productMediaRepositoryProvider,
    );

    String? uploadedPath;
    String? uploadedThumb;
    try {
      _patch(itemId, phase: UploadPhase.processing, clearFailure: true);

      final ProcessedMedia processed = await _processor.process(
        file: start.file,
        kind: start.kind,
      );
      if (_cancelled[itemId] == true) {
        _patch(itemId, phase: UploadPhase.cancelled);
        return;
      }

      _patch(itemId, phase: UploadPhase.uploading);

      uploadedPath = await storage.upload(
        bucket: StorageDataSource.productMediaBucket,
        path: StorageDataSource.productMediaPath(
          productId: productId,
          extension: processed.extension,
        ),
        bytes: processed.bytes,
        contentType: processed.contentType,
      );

      final Uint8List? thumb = processed.thumbnailBytes;
      if (thumb != null) {
        try {
          uploadedThumb = await storage.upload(
            bucket: StorageDataSource.productMediaBucket,
            path: StorageDataSource.productMediaPath(
              productId: productId,
              extension: 'jpg',
            ),
            bytes: thumb,
            contentType: 'image/jpeg',
          );
        } on Object {
          // A missing poster frame is cosmetic; the video itself succeeded.
        }
      }

      if (_cancelled[itemId] == true) {
        await storage.removeQuietly(
          StorageDataSource.productMediaBucket,
          uploadedPath,
        );
        if (uploadedThumb != null) {
          await storage.removeQuietly(
            StorageDataSource.productMediaBucket,
            uploadedThumb,
          );
        }
        _patch(itemId, phase: UploadPhase.cancelled);
        return;
      }

      final int sortOrder = await mediaRepo
          .fetchForProduct(productId)
          .then((List<ProductMedia> rows) => rows.length);

      final ProductMedia media = await mediaRepo.add(
        ProductMediaDraft(
          productId: productId,
          kind: start.kind,
          storagePath: uploadedPath,
          thumbnailPath: uploadedThumb,
          durationSeconds: processed.durationSeconds,
          isCover: sortOrder == 0,
          sortOrder: sortOrder,
        ),
      );

      _patch(itemId, phase: UploadPhase.done, mediaId: media.id);
    } on AppFailure catch (failure) {
      await _compensate(storage, uploadedPath, uploadedThumb);
      _patch(itemId, phase: UploadPhase.failed, failure: failure);
    } on Object catch (error, stack) {
      await _compensate(storage, uploadedPath, uploadedThumb);
      _patch(
        itemId,
        phase: UploadPhase.failed,
        failure: ErrorMapper.map(error, stackTrace: stack),
      );
    }
  }

  /// Removes files whose row never landed, so a failed save cannot strand an
  /// orphan object in the bucket.
  Future<void> _compensate(
    StorageDataSource storage,
    String? path,
    String? thumb,
  ) async {
    if (path != null) {
      await storage.removeQuietly(StorageDataSource.productMediaBucket, path);
    }
    if (thumb != null) {
      await storage.removeQuietly(StorageDataSource.productMediaBucket, thumb);
    }
  }

  Future<void> retry(String itemId, {required String productId}) async {
    final MediaUploadItem? item = _find(itemId);
    if (item == null || item.phase == UploadPhase.done) return;
    _cancelled[itemId] = false;
    _patch(itemId, phase: UploadPhase.queued, clearFailure: true);
    await _runOne(productId, itemId);
  }

  /// Cancels a queued or in-flight file. An in-flight upload rolls back the
  /// object it may already have written.
  void cancel(String itemId) {
    final MediaUploadItem? item = _find(itemId);
    if (item == null || item.isFinished) return;
    _cancelled[itemId] = true;
    _patch(itemId, phase: UploadPhase.cancelled);
  }

  void cancelAll() {
    for (final MediaUploadItem item in state) {
      if (item.isFinished) continue;
      _cancelled[item.id] = true;
      _patch(item.id, phase: UploadPhase.cancelled);
    }
  }

  /// Clears finished rows; failed ones stay so the owner can retry them.
  void clearFinished() {
    state = state
        .where(
          (MediaUploadItem i) =>
              i.phase == UploadPhase.queued ||
              i.phase == UploadPhase.processing ||
              i.phase == UploadPhase.uploading ||
              i.phase == UploadPhase.failed,
        )
        .toList(growable: false);
  }

  void dismiss(String itemId) => state = state
      .where((MediaUploadItem i) => i.id != itemId)
      .toList(growable: false);

  void reset() {
    _cancelled.clear();
    state = const <MediaUploadItem>[];
  }

  /// Compensating delete for a product save that fails *after* its media were
  /// uploaded: pass the stored paths to sweep them.
  Future<void> removeUploadedFile(String path) async {
    await ref
        .read(storageDataSourceProvider)
        .removeQuietly(StorageDataSource.productMediaBucket, path);
  }

  MediaUploadItem? _find(String id) {
    for (final MediaUploadItem item in state) {
      if (item.id == id) return item;
    }
    return null;
  }

  void _patch(
    String id, {
    UploadPhase? phase,
    AppFailure? failure,
    String? mediaId,
    bool clearFailure = false,
  }) {
    state = state
        .map(
          (MediaUploadItem item) => item.id == id
              ? item.copyWith(
                  phase: phase,
                  failure: failure,
                  mediaId: mediaId,
                  clearFailure: clearFailure,
                )
              : item,
        )
        .toList(growable: false);
  }
}
