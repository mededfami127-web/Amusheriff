import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../catalog/domain/drafts/catalog_drafts.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
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

/// Draft of the category form: every field the sheet can edit, plus the
/// validation and save state the widgets render.
class CategoryEditorState {
  const CategoryEditorState({
    this.id,
    this.name = '',
    this.nameAm = '',
    this.nameAr = '',
    this.slug = '',
    this.coverPath,
    this.isVisible = true,
    this.sortOrder = 0,
    this.isNew = true,
    this.slugTouched = false,
    this.fieldErrors = const <String, String>{},
    this.status = const AdminFormStatus(),
  });

  final String? id;
  final String name;
  final String nameAm;
  final String nameAr;
  final String slug;
  final String? coverPath;
  final bool isVisible;
  final int sortOrder;
  final bool isNew;
  final bool slugTouched;
  final FieldErrors fieldErrors;
  final AdminFormStatus status;

  CategoryEditorState copyWith({
    String? id,
    String? name,
    String? nameAm,
    String? nameAr,
    String? slug,
    String? coverPath,
    bool? isVisible,
    int? sortOrder,
    bool? isNew,
    bool? slugTouched,
    FieldErrors? fieldErrors,
    AdminFormStatus? status,
  }) =>
      CategoryEditorState(
        id: id ?? this.id,
        name: name ?? this.name,
        nameAm: nameAm ?? this.nameAm,
        nameAr: nameAr ?? this.nameAr,
        slug: slug ?? this.slug,
        coverPath: coverPath ?? this.coverPath,
        isVisible: isVisible ?? this.isVisible,
        sortOrder: sortOrder ?? this.sortOrder,
        isNew: isNew ?? this.isNew,
        slugTouched: slugTouched ?? this.slugTouched,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        status: status ?? this.status,
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

/// Draft of the contact-link form.
class ContactDraftState {
  const ContactDraftState({
    this.id,
    this.kind = ContactKind.whatsapp,
    this.label = '',
    this.value = '',
    this.isPrimary = false,
    this.isVisible = true,
    this.sortOrder = 0,
    this.isNew = true,
    this.labelTouched = false,
    this.fieldErrors = const <String, String>{},
    this.status = const AdminFormStatus(),
  });

  final String? id;
  final ContactKind kind;
  final String label;
  final String value;
  final bool isPrimary;
  final bool isVisible;
  final int sortOrder;
  final bool isNew;

  /// True once the owner typed a label, so switching the channel no longer
  /// overwrites their text with the channel default.
  final bool labelTouched;
  final FieldErrors fieldErrors;
  final AdminFormStatus status;

  ContactDraftState copyWith({
    String? id,
    ContactKind? kind,
    String? label,
    String? value,
    bool? isPrimary,
    bool? isVisible,
    int? sortOrder,
    bool? isNew,
    bool? labelTouched,
    FieldErrors? fieldErrors,
    AdminFormStatus? status,
  }) =>
      ContactDraftState(
        id: id ?? this.id,
        kind: kind ?? this.kind,
        label: label ?? this.label,
        value: value ?? this.value,
        isPrimary: isPrimary ?? this.isPrimary,
        isVisible: isVisible ?? this.isVisible,
        sortOrder: sortOrder ?? this.sortOrder,
        isNew: isNew ?? this.isNew,
        labelTouched: labelTouched ?? this.labelTouched,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        status: status ?? this.status,
      );
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

/// Draft of the singleton `site_settings` form.
class SiteSettingsEditorState {
  const SiteSettingsEditorState({
    this.storeNameEn = '',
    this.storeNameAm = '',
    this.storeNameAr = '',
    this.tagline = '',
    this.about = '',
    this.logoPath,
    this.currencyCode = 'ETB',
    this.defaultLanguage = 'en',
    this.fieldErrors = const <String, String>{},
    this.status = const AdminFormStatus(),
  });

  final String storeNameEn;
  final String storeNameAm;
  final String storeNameAr;
  final String tagline;
  final String about;
  final String? logoPath;
  final String currencyCode;
  final String defaultLanguage;
  final FieldErrors fieldErrors;
  final AdminFormStatus status;

  SiteSettingsEditorState copyWith({
    String? storeNameEn,
    String? storeNameAm,
    String? storeNameAr,
    String? tagline,
    String? about,
    String? logoPath,
    String? currencyCode,
    String? defaultLanguage,
    FieldErrors? fieldErrors,
    AdminFormStatus? status,
  }) =>
      SiteSettingsEditorState(
        storeNameEn: storeNameEn ?? this.storeNameEn,
        storeNameAm: storeNameAm ?? this.storeNameAm,
        storeNameAr: storeNameAr ?? this.storeNameAr,
        tagline: tagline ?? this.tagline,
        about: about ?? this.about,
        logoPath: logoPath ?? this.logoPath,
        currencyCode: currencyCode ?? this.currencyCode,
        defaultLanguage: defaultLanguage ?? this.defaultLanguage,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        status: status ?? this.status,
      );
}

/// Edits the singleton `site_settings` row.
///
/// The draft is seeded from the live row, so opening the screen always shows
/// what the storefront is currently serving and a remote edit lands here too.
@riverpod
class SiteSettingsEditorController extends _$SiteSettingsEditorController {
  @override
  SiteSettingsEditorState build() {
    final SiteSettings settings = ref.watch(siteSettingsValueProvider);
    return SiteSettingsEditorState(
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

/// Draft of the product form, including its media ordering.
class ProductEditorState {
  const ProductEditorState({
    this.id,
    this.categoryId = '',
    this.title = '',
    this.titleAm = '',
    this.titleAr = '',
    this.description = '',
    this.descriptionAm = '',
    this.descriptionAr = '',
    this.price = 0,
    this.compareAtPrice = 0,
    this.currencyCode = 'ETB',
    this.isAvailable = true,
    this.isFeatured = false,
    this.isPublished = true,
    this.sortOrder = 0,
    this.isNew = true,
    this.fieldErrors = const <String, String>{},
    this.status = const AdminFormStatus(),
  });

  final String? id;
  final String categoryId;
  final String title;
  final String titleAm;
  final String titleAr;
  final String description;
  final String descriptionAm;
  final String descriptionAr;
  final double price;
  final double compareAtPrice;
  final String currencyCode;
  final bool isAvailable;
  final bool isFeatured;
  final bool isPublished;
  final int sortOrder;
  final bool isNew;
  final FieldErrors fieldErrors;
  final AdminFormStatus status;

  ProductEditorState copyWith({
    String? id,
    String? categoryId,
    String? title,
    String? titleAm,
    String? titleAr,
    String? description,
    String? descriptionAm,
    String? descriptionAr,
    double? price,
    double? compareAtPrice,
    String? currencyCode,
    bool? isAvailable,
    bool? isFeatured,
    bool? isPublished,
    int? sortOrder,
    bool? isNew,
    FieldErrors? fieldErrors,
    AdminFormStatus? status,
  }) =>
      ProductEditorState(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        title: title ?? this.title,
        titleAm: titleAm ?? this.titleAm,
        titleAr: titleAr ?? this.titleAr,
        description: description ?? this.description,
        descriptionAm: descriptionAm ?? this.descriptionAm,
        descriptionAr: descriptionAr ?? this.descriptionAr,
        price: price ?? this.price,
        compareAtPrice: compareAtPrice ?? this.compareAtPrice,
        currencyCode: currencyCode ?? this.currencyCode,
        isAvailable: isAvailable ?? this.isAvailable,
        isFeatured: isFeatured ?? this.isFeatured,
        isPublished: isPublished ?? this.isPublished,
        sortOrder: sortOrder ?? this.sortOrder,
        isNew: isNew ?? this.isNew,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        status: status ?? this.status,
      );
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

  FieldErrors validate() {
    final FieldErrors errors = <String, String>{};
    if (state.categoryId.isEmpty) errors['categoryId'] = 'validateRequired';
    final String? titleKey = Validators.productTitle(state.title);
    if (titleKey != null) errors['title'] = titleKey;
    final String? priceKey = Validators.price(state.price.toString());
    if (priceKey != null) errors['price'] = priceKey;
    // Zero means "no compare-at price", matching the nullable column, so the
    // greater-than-price rule only applies once a value is set.
    if (state.compareAtPrice > 0) {
      final String? compareKey = Validators.compareAtPrice(
        state.compareAtPrice.toString(),
        state.price,
      );
      if (compareKey != null) errors['compareAtPrice'] = compareKey;
    }
    state = state.copyWith(fieldErrors: errors);
    return errors;
  }

  Future<bool> save() async {
    if (validate().isNotEmpty) return false;
    state = state.copyWith(status: const AdminFormStatus(saving: true));

    final ProductDraft draft = ProductDraft(
      categoryId: state.categoryId,
      title: state.title.trim(),
      titleAm: state.titleAm.trim(),
      titleAr: state.titleAr.trim(),
      description: state.description.trim(),
      descriptionAm: state.descriptionAm.trim(),
      descriptionAr: state.descriptionAr.trim(),
      price: state.price,
      compareAtPrice: state.compareAtPrice > 0 ? state.compareAtPrice : null,
      currencyCode: state.currencyCode,
      isAvailable: state.isAvailable,
      isFeatured: state.isFeatured,
      isPublished: state.isPublished,
      sortOrder: state.sortOrder,
    );

    try {
      final ProductRepository repo = ref.read(productRepositoryProvider);
      final Product product = state.isNew
          ? await repo.create(draft)
          : await repo.update(state.id!, draft);
      state = state.copyWith(
        id: product.id,
        isNew: false,
        status: const AdminFormStatus(saved: true),
      );
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(status: AdminFormStatus(failure: failure));
      return false;
    } on Object catch (error, stack) {
      state = state.copyWith(
        status:
            AdminFormStatus(failure: ErrorMapper.map(error, stackTrace: stack)),
      );
      return false;
    }
  }

  void acknowledge() => state = state.copyWith(status: const AdminFormStatus());

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
