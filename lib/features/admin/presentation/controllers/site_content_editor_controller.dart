import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/utils/validators.dart';
import '../../../settings/domain/repositories/site_content_repository.dart';

part 'site_content_editor_controller.g.dart';

/// Draft of the site-content editing sheet: one key, one locale, the save state.
class SiteContentEditorState {
  const SiteContentEditorState({
    this.key = '',
    this.locale = 'en',
    this.value = '',
    this.fieldErrors = const <String, String>{},
    this.status = const AdminFormStatus(),
  });

  final String key;
  final String locale;
  final String value;
  final FieldErrors fieldErrors;
  final AdminFormStatus status;

  SiteContentEditorState copyWith({
    String? key,
    String? locale,
    String? value,
    FieldErrors? fieldErrors,
    AdminFormStatus? status,
  }) =>
      SiteContentEditorState(
        key: key ?? this.key,
        locale: locale ?? this.locale,
        value: value ?? this.value,
        fieldErrors: fieldErrors ?? this.fieldErrors,
        status: status ?? this.status,
      );
}

typedef FieldErrors = Map<String, String>;

/// Status shared with the other admin editors: saving, saved, typed failure.
class AdminFormStatus {
  const AdminFormStatus({this.saving = false, this.saved = false, this.failure});

  final bool saving;
  final bool saved;
  final AppFailure? failure;

  AdminFormStatus copyWith({
    bool? saving,
    bool? saved,
    AppFailure? failure,
    bool clearFailure = false,
  }) =>
      AdminFormStatus(
        saving: saving ?? this.saving,
        saved: saved ?? this.saved,
        failure: clearFailure ? null : (failure ?? this.failure),
      );
}

/// Edits one [site_content] key.
///
/// The sheet is a bottom sheet, so the controller is `keepAlive`: an
/// auto-disposed draft would be thrown away before the sheet is first built.
@Riverpod(keepAlive: true)
class SiteContentEditorController extends _$SiteContentEditorController {
  @override
  SiteContentEditorState build() => const SiteContentEditorState();

  void load(String key, String locale, String? current) {
    state = SiteContentEditorState(
      key: key,
      locale: locale,
      value: current ?? '',
    );
  }

  void setLocale(String code) {
    if (!kAppTextLocales.contains(code)) return;
    state = state.copyWith(locale: code);
  }

  void setValue(String v) => state = state.copyWith(value: v);

  FieldErrors validate() {
    final FieldErrors errors = <String, String>{};
    final String? keyKey = Validators.required(state.key, max: 120);
    if (keyKey != null) errors['key'] = keyKey;
    final String? valueKey = Validators.required(state.value, max: 2000);
    if (valueKey != null) errors['value'] = valueKey;
    state = state.copyWith(fieldErrors: errors);
    return errors;
  }

  Future<bool> save() async {
    if (validate().isNotEmpty) return false;
    state = state.copyWith(status: const AdminFormStatus(saving: true));

    try {
      final SiteContentRepository repo =
          ref.read(siteContentRepositoryProvider);
      await repo.save(
        key: state.key.trim(),
        locale: state.locale.trim(),
        value: state.value.trim(),
      );
      ref.invalidate(siteContentProvider(state.locale));
      state = state.copyWith(status: const AdminFormStatus(saved: true));
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(status: AdminFormStatus(failure: failure));
      return false;
    } on Object catch (error, stack) {
      state = state.copyWith(
        status: AdminFormStatus(
          failure: ErrorMapper.map(error, stackTrace: stack),
        ),
      );
      return false;
    }
  }

  Future<bool> restore() async {
    state = state.copyWith(status: const AdminFormStatus(saving: true));
    try {
      final SiteContentRepository repo =
          ref.read(siteContentRepositoryProvider);
      await repo.remove(key: state.key.trim(), locale: state.locale.trim());
      ref.invalidate(siteContentProvider(state.locale));
      state = state.copyWith(status: const AdminFormStatus(saved: true));
      return true;
    } on AppFailure catch (failure) {
      state = state.copyWith(status: AdminFormStatus(failure: failure));
      return false;
    } on Object catch (error, stack) {
      state = state.copyWith(
        status: AdminFormStatus(
          failure: ErrorMapper.map(error, stackTrace: stack),
        ),
      );
      return false;
    }
  }

  void acknowledge() => state = state.copyWith(status: const AdminFormStatus());
}

/// The locales the owner can edit.
const List<String> kAppTextLocales = <String>['en', 'am', 'ar', 'om'];
