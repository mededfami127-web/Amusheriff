import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/errors/error_localizer.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/generated/app_localizations.dart';
import '../../../../core/network/storage_urls.dart';
import '../../../../core/router/routes.dart';
import '../../../../core/theme/brand_colors.dart';
import '../../../../core/theme/typography.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_failure_banner.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/media_kind.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_media.dart';
import '../../../catalog/presentation/controllers/media_upload_controller.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../controllers/admin_editors.dart';
import '../widgets/admin_scaffold.dart';
import '../widgets/admin_text_field.dart';

/// Create/edit a product, including its media.
///
/// The form is controller-driven: [ProductEditorController] holds the draft.
/// The list page seeds it before navigating, and a direct deep link seeds it
/// here from the live row once that row arrives.
class AdminProductEditorPage extends ConsumerStatefulWidget {
  const AdminProductEditorPage({super.key, this.productId});

  /// `null` when the owner is adding a new product.
  final String? productId;

  @override
  ConsumerState<AdminProductEditorPage> createState() =>
      _AdminProductEditorPageState();
}

class _AdminProductEditorPageState
    extends ConsumerState<AdminProductEditorPage> {
  bool _seeded = false;

  /// Set when a deep link points at a row that no longer exists, so the page
  /// does not spin forever waiting for it.
  bool _missing = false;

  bool get _isNew => widget.productId == null;

  @override
  void initState() {
    super.initState();
    if (_isNew) {
      // Seeding after the first frame keeps provider writes out of build().
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(productEditorControllerProvider.notifier).load(null);
        setState(() => _seeded = true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? productId = widget.productId;

    if (productId != null) {
      // A deep link may arrive before the list page seeded the draft.
      ref.listen(productDetailProvider(productId), (_, AsyncValue<Product?> next) {
        final Product? product = next.value;
        if (product == null) {
          if (next.isLoading) return;
          if (mounted && !_missing) {
            setState(() {
              _missing = true;
              _seeded = true;
            });
          }
          return;
        }
        if (ref.read(productEditorControllerProvider).id == product.id) return;
        ref.read(productEditorControllerProvider.notifier).load(product);
        if (!_seeded && mounted) setState(() => _seeded = true);
      });

      if (!_seeded &&
          ref.read(productEditorControllerProvider).id == productId) {
        _seeded = true;
      }
    }

    final ProductEditorState state =
        ref.watch(productEditorControllerProvider);
    final ProductEditorController controller =
        ref.read(productEditorControllerProvider.notifier);
    final List<Category> categories =
        ref.watch(allCategoriesProvider).value ?? const <Category>[];

    if (_missing) {
      return AdminScaffold(
        title: l10n.adminEditProduct,
        selectedRoute: Routes.adminProducts,
        child: EmptyState(
          title: l10n.stateNotFoundTitle,
          message: l10n.errorNotFound,
          icon: Icons.search_off_rounded,
          action: FilledButton.icon(
            onPressed: () => context.go(Routes.adminProducts),
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(l10n.adminBackToGateway),
          ),
        ),
      );
    }

    if (!_seeded) {
      return AdminScaffold(
        title: _isNew ? l10n.adminAddProduct : l10n.adminEditProduct,
        selectedRoute: Routes.adminProducts,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    final bool saving = state.status.saving;

    return AdminScaffold(
      title: _isNew ? l10n.adminAddProduct : l10n.adminEditProduct,
      selectedRoute: Routes.adminProducts,
      actions: <Widget>[
        IconButton(
          tooltip: l10n.actionClose,
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go(Routes.adminProducts),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: <Widget>[
          if (state.status.failure != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InlineFailureBanner(
                failure: state.status.failure!,
                onDismiss: controller.acknowledge,
              ),
            ),
          DropdownButtonFormField<String>(
            initialValue: state.categoryId.isEmpty ? null : state.categoryId,
            decoration: InputDecoration(
              labelText: l10n.adminCategories,
              errorText: localizeFieldKey(l10n, state.fieldErrors['categoryId']),
            ),
            items: categories
                .map(
                  (Category category) => DropdownMenuItem<String>(
                    value: category.id,
                    child: Text(
                      category.nameFor(
                        Localizations.localeOf(context).languageCode,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: (String? value) {
              if (value != null) controller.setCategoryId(value);
            },
          ),
          const SizedBox(height: 16),
          AdminTextField(
            label: l10n.adminProductTitle,
            value: state.title,
            textInputAction: TextInputAction.next,
            onChanged: controller.setTitle,
            error: localizeFieldKey(l10n, state.fieldErrors['title']),
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminProductTitleAm,
            value: state.titleAm,
            textInputAction: TextInputAction.next,
            onChanged: controller.setTitleAm,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminProductTitleAr,
            value: state.titleAr,
            textInputAction: TextInputAction.next,
            onChanged: controller.setTitleAr,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminProductDescription,
            value: state.description,
            maxLines: 4,
            onChanged: controller.setDescription,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminProductDescriptionAm,
            value: state.descriptionAm,
            maxLines: 3,
            onChanged: controller.setDescriptionAm,
          ),
          const SizedBox(height: 14),
          AdminTextField(
            label: l10n.adminProductDescriptionAr,
            value: state.descriptionAr,
            maxLines: 3,
            onChanged: controller.setDescriptionAr,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AdminTextField(
                  label: l10n.adminPrice,
                  value: state.price.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (String value) =>
                      controller.setPrice(double.tryParse(value) ?? 0),
                  error: localizeFieldKey(l10n, state.fieldErrors['price']),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AdminTextField(
                  label: l10n.adminCompareAtPrice,
                  value: state.compareAtPrice.toString(),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (String value) =>
                      controller.setCompareAtPrice(double.tryParse(value) ?? 0),
                  error: localizeFieldKey(
                    l10n,
                    state.fieldErrors['compareAtPrice'],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.isPublished,
            title: Text(l10n.adminPublish),
            onChanged: controller.setPublished,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.isFeatured,
            title: Text(l10n.adminFeatured),
            onChanged: controller.setFeatured,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: state.isAvailable,
            title: Text(l10n.labelAvailable),
            onChanged: controller.setAvailability,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: BrandColors.royalViolet,
              foregroundColor: BrandColors.ivory,
              minimumSize: const Size.fromHeight(52),
            ),
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(l10n.actionSave),
            onPressed: saving ? null : () => _save(controller, l10n),
          ),
          if (state.id != null) ...<Widget>[
            const SizedBox(height: 28),
            _MediaSection(productId: state.id!),
          ],
        ],
      ),
    );
  }

  Future<void> _save(
    ProductEditorController controller,
    AppLocalizations l10n,
  ) async {
    final bool ok = await controller.save();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? l10n.adminProductSaved : l10n.errorServer)),
    );
  }
}

/// Existing media plus the upload queue for the product being edited.
class _MediaSection extends ConsumerWidget {
  const _MediaSection({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<Product?> async = ref.watch(productDetailProvider(productId));
    final List<MediaUploadItem> queue = ref.watch(mediaUploadControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(l10n.adminMedia, style: BrandTypography.displaySmall.copyWith(fontSize: 18)),
        const SizedBox(height: 10),
        if (queue.isNotEmpty) ...<Widget>[
          Text(l10n.adminUploadQueue, style: BrandTypography.labelLarge),
          const SizedBox(height: 8),
          for (final MediaUploadItem item in queue)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(_iconFor(item.phase)),
              title: Text(item.fileName, style: BrandTypography.bodySmall),
              subtitle: Text(
                item.failure == null
                    ? item.phase.name
                    : localizeFailure(l10n, item.failure!),
                style: BrandTypography.bodySmall,
              ),
              trailing: item.isFinished && item.phase != UploadPhase.done
                  ? IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: l10n.actionRetry,
                      onPressed: () => ref
                          .read(mediaUploadControllerProvider.notifier)
                          .retry(item.id, productId: productId),
                    )
                  : item.isFinished
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          tooltip: l10n.actionCancel,
                          onPressed: () => ref
                              .read(mediaUploadControllerProvider.notifier)
                              .cancel(item.id),
                        ),
            ),
          const SizedBox(height: 8),
        ],
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LinearProgressIndicator(minHeight: 3),
          ),
          error: (Object error, StackTrace _) => Text(
            localizeFailure(l10n, ErrorMapper.map(error)),
            style: BrandTypography.bodySmall,
          ),
          data: (Product? product) {
            final List<ProductMedia> media =
                product?.media ?? const <ProductMedia>[];
            if (media.isEmpty) {
              return Text(l10n.adminNoMedia, style: BrandTypography.bodySmall);
            }
            return SizedBox(
              height: 128,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: media.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (BuildContext context, int index) =>
                    _MediaCard(productId: productId, media: media[index], l10n: l10n),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 8,
          children: <Widget>[
            OutlinedButton.icon(
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(l10n.adminAddImages),
              onPressed: () => _pick(ref, MediaKind.image),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.videocam_outlined),
              label: Text(l10n.adminAddVideo),
              onPressed: () => _pick(ref, MediaKind.video),
            ),
          ],
        ),
      ],
    );
  }

  static IconData _iconFor(UploadPhase phase) => switch (phase) {
        UploadPhase.queued => Icons.schedule_rounded,
        UploadPhase.processing => Icons.tune_rounded,
        UploadPhase.uploading => Icons.cloud_upload_outlined,
        UploadPhase.done => Icons.check_circle_outline_rounded,
        UploadPhase.failed => Icons.error_outline_rounded,
        UploadPhase.cancelled => Icons.cancel_outlined,
      };

  Future<void> _pick(WidgetRef ref, MediaKind kind) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = kind.isVideo
        ? <XFile>[
            if (await picker.pickVideo(source: ImageSource.gallery)
                case final XFile file) file,
          ]
        : await picker.pickMultiImage(imageQuality: 92);

    if (files.isEmpty) return;
    await ref
        .read(mediaUploadControllerProvider.notifier)
        .enqueue(productId: productId, files: files, kind: kind);
  }
}

class _MediaCard extends ConsumerWidget {
  const _MediaCard({
    required this.productId,
    required this.media,
    required this.l10n,
  });

  final String productId;
  final ProductMedia media;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String thumbPath = media.thumbnailPath ?? media.storagePath;
    final StorageUrls urls = ref.read(storageUrlsProvider);

    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    urls.productMediaThumb(thumbPath, width: 220),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: BrandColors.deepPlum,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: BrandColors.gold,
                      ),
                    ),
                  ),
                ),
                if (media.isVideo)
                  const Positioned(
                    right: 6,
                    bottom: 6,
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: BrandColors.ivory,
                    ),
                  ),
                if (media.isCover)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: BrandColors.gold,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        l10n.adminCover,
                        style: BrandTypography.labelSmall.copyWith(
                          color: BrandColors.deepPlum,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.star_outline_rounded, size: 18),
                tooltip: l10n.adminSetCover,
                onPressed: media.isCover
                    ? null
                    : () => ref
                        .read(productMediaRepositoryProvider)
                        .setCover(productId, media.id),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                tooltip: l10n.adminRemoveMedia,
                onPressed: () => ref
                    .read(productMediaRepositoryProvider)
                    .delete(media.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
