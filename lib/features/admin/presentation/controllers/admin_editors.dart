import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../catalog/domain/drafts/catalog_drafts.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_media.dart';
import '../../../catalog/domain/repositories/catalog_repositories.dart';
import '../../../catalog/presentation/providers/catalog_providers.dart';
import '../../../contacts/domain/drafts/contact_link_draft.dart';
import '../../../contacts/domain/entities/contact_kind.dart';
import '../../../contacts/domain/entities/contact_link.dart';
import '../../../contacts/domain/repositories/contact_repository.dart';
import '../../../contacts/presentation/providers/contact_providers.dart';
import '../../../settings/domain/drafts/site_settings_draft.dart';
import '../../../settings/domain/entities/site_settings.dart';
import '../../../settings/presentation/providers/site_settings_providers.dart';
import '../providers/admin_ui_providers.dart';

part 'admin_editors.g.dart';

/// Field-level validation messages, keyed by field name. Every value is an ARB
/// key resolved by the widget, so errors stay localized.
typedef FieldErrors = Map<String, String>;

/// Shared shape of every editor form: save-in-flight, a typed failure, and
/// per-field messages. Widgets read [saving] for spinners and [failure] for an
/// inline banner.
class AdminFormStatus {
  const AdminFormStatus({
    this.saving = false,
    this.failure,
    this.saved = false,
  });

  final bool saving;
  final AppFailure? failure;
  final bool saved;

  bool get isDirty => saving || failure != null || saved;

  AdminFormStatus copyWith({
    bool? saving,
    AppFailure? failure,
    bool? saved,
    bool clearFailure = false,
  }) =>
      AdminFormStatus(
        saving: saving ?? this.saving,
        failure: clearFailure ? null : failure ?? this.failure,
        saved: saved ?? this.saved,
      );
}

/// Create / edit a category.
@riverpod
class CategoryEditorController extends _$CategoryEditorController {
  @override
  CategoryEditorState build() => const CategoryEditorState();

  void load(Category? existing) {
    if (existing == null) {
      state = const CategoryEditorState();
      return;
    }
    state = CategoryEditorState(
      id: existing.id,
      name: existing.name,
      nameAm: existing.nameAm ?? '',
      nameAr: existing.nameAr ?? '',
      slug: existing.slug,
      coverPath: existing.coverPath,
      isVisible: existing.isVisible,
      sortOrder: existing.sortOrder,
      isNew: false,
    );
  }

  void setName(String v) => state = state.copyWith(name: v);
  void setNameAm(String v) => state = state.copyWith(nameAm: v);
  void setNameAr(String v) => state = state.copyWith(nameAr: v);
  void setSlug(String v) => state = state.copyWith(slug: v);
  void setCoverPath(String? v) => state = state.copyWith(coverPath: v);
  void setVisible(bool v) => state = state.copyWith(isVisible: v);
  void setSortOrder(int v) => state = state.copyWith(sortOrder: v);
  void toggleSlugTouched() =>
      state = state.copyWith(slugTouched: true);

  FieldErrors validate() {
    final FieldErrors errors = <String, String>{};
    final String? nameKey = Validators.categoryName(state.name);
    if (nameKey != null) errors['name'] = nameKey;
    final String? slugKey = Validators.slug(state.slug);
    if (slugKey != null) errors['slug'] = slugKey;
    state = state.copyWith(fieldErrors: errors);
    return errors;
  }

  Future<bool> save() async {
    final FieldErrors errors = validate();
    if (errors.isNotEmpty) return false;

    state = state.copyWith(status: const AdminFormStatus(saving: true));

    final CategoryDraft draft = CategoryDraft(
      name: state.name.trim(),
      slug: state.slug.trim(),
      nameAm: state.nameAm.trim(),
      nameAr: state.nameAr.trim(),
      coverPath: state.coverPath,
      sortOrder: state.sortOrder,
      isVisible: state.isVisible,
    );

    try {
      final CategoryRepository repo = ref.read(categoryRepositoryProvider);
      final Category category =
          state.isNew ? await repo.create(draft) : await repo.update(state.id!, draft);
      state = state.copyWith(
        id: category.id,
        isNew: false,
        status: const AdminFormStatus(saved: true),
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(status: AdminFormStatus(failure: failure));
      return false;
    } on Object catch (error, stack) {
      state = state.copyWith(
        status: AdminFormStatus(failure: ErrorMapper.map(error, stackTrace: stack)),
      );
      return false;
    }
  }

  void acknowledge() => state = state.copyWith(status: const AdminFormStatus());
}

/// Validates a link value for its channel.
String? validateContactValue(ContactKind kind, String raw) {
  final String value = raw.trim();
  if (value.isEmpty) return 'validateRequired';

  return switch (kind) {
    ContactKind.whatsapp || ContactKind.phone => Validators.phone(value),
    ContactKind.email => Validators.email(value),
    ContactKind.telegram => _validateTelegram(value),
    ContactKind.website ||
    ContactKind.instagram ||
    ContactKind.facebook ||
    ContactKind.tiktok ||
    ContactKind.youtube ||
    ContactKind.location => Validators.url(value),
    ContactKind.other => Validators.required(value, max: 300),
  };
}

String? _validateTelegram(String value) {
  final String v = value.trim();
  if (v.startsWith('https://t.me/') || v.startsWith('http://t.me/')) {
    final String handle = v.replaceFirst(RegExp(r'^https?://t\.me/'), '');
    return RegExp(r'^[A-Za-z0-9_]{5,32}$').hasMatch(handle)
        ? null
        : 'validateTelegramHandle';
  }
  final String bare = v.startsWith('@') ? v.substring(1) : v;
  return RegExp(r'^[A-Za-z0-9_]{5,32}$').hasMatch(bare)
      ? null
      : 'validateTelegramHandle';
}

/// Adds or edits a single contact link.
@riverpod
class ContactsEditorController extends _$ContactsEditorController {
  @override
  ContactDraftState build() => const ContactDraftState();

  void startNew() => state = const ContactDraftState();

  void startEdit(ContactLink existing) {
    state = ContactDraftState(
      id: existing.id,
      kind: existing.kind,
      label: existing.label,
      value: existing.value,
      isPrimary: existing.isPrimary,
      isVisible: existing.isVisible,
      isNew: false,
    );
  }

  void setKind(ContactKind kind) {
    state = state.copyWith(kind: kind, labelTouched: state.labelTouched);
    if (!state.labelTouched) {
      state = state.copyWith(label: '');
    }
  }

  void setLabel(String v) => state = state.copyWith(label: v, labelTouched: true);
  void setValue(String v) => state = state.copyWith(value: v);
  void setPrimary(bool v) => state = state.copyWith(isPrimary: v);
  void setVisible(bool v) => state = state.copyWith(isVisible: v);

  FieldErrors validate() {
    final FieldErrors errors = <String, String>{};
    final String? labelKey = Validators.required(state.label, max: 80);
    if (labelKey != null) errors['label'] = labelKey;
    final String? valueKey = validateContactValue(state.kind, state.value);
    if (valueKey != null) errors['value'] = valueKey;
    state = state.copyWith(fieldErrors: errors);
    return errors;
  }

  Future<bool> save() async {
    if (validate().isNotEmpty) return false;
    state = state.copyWith(status: const AdminFormStatus(saving: true));

    final ContactLinkDraft draft = ContactLinkDraft(
      kind: state.kind,
      label: state.label.trim(),
      value: state.value.trim(),
      isPrimary: state.isPrimary,
      isVisible: state.isVisible,
      sortOrder: state.sortOrder,
    );

    try {
      final ContactRepository repo = ref.read(contactRepositoryProvider);
      final ContactLink saved =
          state.isNew ? await repo.create(draft) : await repo.update(state.id!, draft);
      state = state.copyWith(
        id: saved.id,
        isNew: false,
        status: const AdminFormStatus(saved: true),
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(status: AdminFormStatus(failure: failure));
      return false;
    } on Object catch (error, stack) {
      state = state.copyWith(
        status: AdminFormStatus(failure: ErrorMapper.map(error, stackTrace: stack)),
      );
      return false;
    }
  }

  void acknowledge() => state = state.copyWith(status: const AdminFormStatus());
}

/// Edits the singleton `site_settings` row.
@riverpod
class SiteSettingsEditorController extends _$SiteSettingsEditorController {
  @override
  SiteSettingsEditorState build() => const SiteSettingsEditorState();

  void load(SiteSettings settings) {
    state = SiteSettingsEditorState(
      storeNameEn: settings.storeNameEn,
      storeNameAm: settings.storeNameAm,
      storeNameAr: settings.storeNameAr,
      tagline: settings.tagline ?? '',
      about: settings.about ?? '',
      logoPath: settings.logoPath,
      currencyCode: settings.currencyCode,
      defaultLanguage: settings.defaultLanguage,
    );
  }

  void setStoreNameEn(String v) => state = state.copyWith(storeNameEn: v);
  void setStoreNameAm(String v) => state = state.copyWith(storeNameAm: v);
  void setStoreNameAr(String v) => state = state.copyWith(storeNameAr: v);
  void setTagline(String v) => state = state.copyWith(tagline: v);
  void setAbout(String v) => state = state.copyWith(about: v);
  void setLogoPath(String? v) => state = state.copyWith(logoPath: v);
  void setCurrency(String v) => state = state.copyWith(currencyCode: v);
  void setDefaultLanguage(String v) => state = state.copyWith(defaultLanguage: v);

  FieldErrors validate() {
    final FieldErrors errors = <String, String>{};
    final String? key = Validators.required(state.storeNameEn, max: 120);
    if (key != null) errors['storeNameEn'] = key;
    state = state.copyWith(fieldErrors: errors);
    return errors;
  }

  Future<bool> save() async {
    if (validate().isNotEmpty) return false;
    state = state.copyWith(status: const AdminFormStatus(saving: true));

    try {
      await ref.read(siteSettingsRepositoryProvider).save(
            SiteSettingsDraft(
              storeNameEn: state.storeNameEn.trim(),
              storeNameAm: state.storeNameAm.trim(),
              storeNameAr: state.storeNameAr.trim(),
              tagline: state.tagline.trim(),
              about: state.about.trim(),
              logoPath: state.logoPath,
              currencyCode: state.currencyCode,
              defaultLanguage: state.defaultLanguage,
            ),
          );
      ref.invalidate(siteSettingsValueProvider);
      state = state.copyWith(status: const AdminFormStatus(saved: true));
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(status: AdminFormStatus(failure: failure));
      return false;
    } on Object catch (error, stack) {
      state = state.copyWith(
        status: AdminFormStatus(failure: ErrorMapper.map(error, stackTrace: stack)),
      );
      return false;
    }
  }

  void acknowledge() => state = state.copyWith(status: const AdminFormStatus());
}

@riverpod
class ProductEditorController extends _$ProductEditorController {
  @override
  ProductEditorState build() => const ProductEditorState();

  void load(Product? existing) {
    if (existing == null) {
      state = const ProductEditorState();
      return;
    }
    state = ProductEditorState(
      id: existing.id,
      categoryId: existing.categoryId,
      title: existing.title,
      titleAm: existing.titleAm ?? '',
      titleAr: existing.titleAr ?? '',
      description: existing.description ?? '',
      descriptionAm: existing.descriptionAm ?? '',
      descriptionAr: existing.descriptionAr ?? '',
      price: existing.price,
      compareAtPrice: existing.compareAtPrice ?? 0,
      currencyCode: existing.currencyCode,
      isAvailable: existing.isAvailable,
      isFeatured: existing.isFeatured,
      isPublished: existing.isPublished,
      sortOrder: existing.sortOrder,
      isNew: false,
    );
  }

  void setCategoryId(String v) => state = state.copyWith(categoryId: v);
  void setTitle(String v) => state = state.copyWith(title: v);
  void setTitleAm(String v) => state = state.copyWith(titleAm: v);
  void setTitleAr(String v) => state = state.copyWith(titleAr: v);
  void setDescription(String v) => state = state.copyWith(description: v);
  void setDescriptionAm(String v) => state = state.copyWith(descriptionAm: v);
  void setDescriptionAr(String v) => state = state.copyWith(descriptionAr: v);
  void setPrice(double v) => state = state.copyWith(price: v);
  void setCompareAtPrice(double v) => state = state.copyWith(compareAtPrice: v);
  void setCurrencyCode(String v) => state = state.copyWith(currencyCode: v);
  void setAvailability(bool v) => state = state.copyWith(isAvailable: v);
  void setFeatured(bool v) => state = state.copyWith(isFeatured: v);
  void setPublished(bool v) => state = state.copyWith(isPublished: v);
  void setSortOrder(int v) => state = state.copyWith(sortOrder: v);
}

/// Controller that owns the media drag-to-reorder, cover toggling and delete
/// rollbacks in the product editor.
@riverpod
class ProductMediaOrderController extends _$ProductMediaOrderController {
  @override
  List<String> build() => const <String>[];

  void reorder(List<String> orderedIds) => state = orderedIds;
}
