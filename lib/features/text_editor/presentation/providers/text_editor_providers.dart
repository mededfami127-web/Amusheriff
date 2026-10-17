import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/l10n/text_catalog.dart';
import '../../../../core/network/supabase_client_provider.dart';
import '../../data/repositories/text_overrides_repository_impl.dart';
import '../../domain/repositories/text_overrides_repository.dart';

part 'text_editor_providers.g.dart';

// ── Data ────────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
TextOverridesRepository textOverridesRepository(Ref ref) =>
    TextOverridesRepositoryImpl(ref.watch(supabaseClientProvider));

/// Every owner rewrite for one locale, live.
@riverpod
Stream<Map<String, String>> textOverrides(Ref ref, String locale) =>
    ref.watch(textOverridesRepositoryProvider).watch(locale);

/// Synchronous view of [textOverrides], for the localizations delegate.
///
/// An empty map until the first event (and whenever the fetch fails), which is
/// exactly the shipped wording — never an error screen.
@riverpod
Map<String, String> textOverridesValue(Ref ref, String locale) =>
    ref.watch(textOverridesProvider(locale)).value ?? const <String, String>{};

// ── Editor state ────────────────────────────────────────────────────────────

/// The locale the owner is editing.
///
/// Deliberately separate from [AppLanguage]: the owner can rewrite the Arabic
/// wording while browsing the app in Oromo.
@Riverpod(keepAlive: true)
class TextEditorLocale extends _$TextEditorLocale {
  @override
  String build() => 'en';

  void select(String code) {
    if (kAppTextLocales.contains(code)) state = code;
  }
}

/// Free-text search over keys, wording and defaults.
@Riverpod(keepAlive: true)
class TextEditorQuery extends _$TextEditorQuery {
  @override
  String build() => '';

  void update(String value) => state = value;
  void clear() => state = '';
}

/// The screen group being shown, or `null` for "every screen".
@Riverpod(keepAlive: true)
class TextEditorSection extends _$TextEditorSection {
  @override
  String? build() => null;

  void select(String? sectionKey) => state = sectionKey;
}

/// Every key whose current wording in the edited locale came from the owner.
@riverpod
Set<String> overriddenKeys(Ref ref, String locale) =>
    ref.watch(textOverridesProvider(locale)).value?.keys.toSet() ??
    const <String>{};

/// The screen groups that actually contain texts, in editor order.
///
/// Derived from the catalogue so a newly added ARB key shows up under its
/// screen the moment the generator is re-run.
@Riverpod(keepAlive: true)
List<String> textEditorSections(Ref ref) => <String>[
  for (final String section in kAppTextSections)
    if (kAppTextEntries.any((AppTextEntry e) => e.sectionKey == section))
      section,
];

/// A string whose wording is still the English one, or missing entirely, is a
/// *gap* in [locale].
///
/// This is the distinction the owner asked for: a machine-drafted Amharic or
/// Oromo table is not wrong everywhere, only where the row still reads as
/// English. A key the owner has already rewritten is never a gap again, so
/// filling one removes it from the list on the spot.
bool isTextGap(
  AppTextEntry entry,
  String locale,
  Map<String, String> overrides,
) {
  // English is the source language; there is nothing to fill in.
  if (locale == 'en') return false;
  if (!entry.isEditable) return false;
  if (overrides.containsKey(entry.key)) return false;

  final String? translated = entry.defaults[locale];
  if (translated == null) return true;

  final String english = entry.defaults['en'] ?? entry.anyDefault;
  return translated.trim().toLowerCase() == english.trim().toLowerCase();
}

/// Every key still needing owner wording in [locale].
@riverpod
Set<String> textGapKeys(Ref ref, String locale) {
  final Map<String, String> overrides =
      ref.watch(textOverridesProvider(locale)).value ??
      const <String, String>{};

  return <String>{
    for (final AppTextEntry entry in kAppTextEntries)
      if (isTextGap(entry, locale, overrides)) entry.key,
  };
}

/// How many words are still missing in [locale], for the language chips.
@riverpod
int textGapCount(Ref ref, String locale) =>
    ref.watch(textGapKeysProvider(locale)).length;

/// Missing words per screen, for the section chips.
@riverpod
Map<String, int> textGapCountsBySection(Ref ref) {
  final String locale = ref.watch(textEditorLocaleProvider);
  final Set<String> gaps = ref.watch(textGapKeysProvider(locale));

  final Map<String, int> counts = <String, int>{};
  for (final AppTextEntry entry in kAppTextEntries) {
    if (!gaps.contains(entry.key)) continue;
    counts[entry.sectionKey] = (counts[entry.sectionKey] ?? 0) + 1;
  }
  return counts;
}

/// "Fill the gap" mode: show only the strings that still need wording.
///
/// Kept in its own provider so switching language or screen never loses the
/// mode, which is what makes filling a whole language a single pass.
@Riverpod(keepAlive: true)
class TextEditorGapsOnly extends _$TextEditorGapsOnly {
  @override
  bool build() => false;

  void set(bool value) => state = value;
  void toggle() => state = !state;
}

/// The catalogue entries matching the current search, section and gap filter.
@riverpod
List<AppTextEntry> filteredTextEntries(Ref ref) {
  final String query = ref.watch(textEditorQueryProvider).trim().toLowerCase();
  final String? section = ref.watch(textEditorSectionProvider);
  final String locale = ref.watch(textEditorLocaleProvider);
  final bool gapsOnly = ref.watch(textEditorGapsOnlyProvider);
  final Set<String> gaps = gapsOnly
      ? ref.watch(textGapKeysProvider(locale))
      : const <String>{};
  final Map<String, String> overrides =
      ref.watch(textOverridesProvider(locale)).value ??
      const <String, String>{};

  return <AppTextEntry>[
    for (final AppTextEntry entry in kAppTextEntries)
      if ((section == null || entry.sectionKey == section) &&
          (!gapsOnly || gaps.contains(entry.key)) &&
          (query.isEmpty ||
              entry.key.toLowerCase().contains(query) ||
              overrides[entry.key]?.toLowerCase().contains(query) == true ||
              entry.defaultFor(locale).toLowerCase().contains(query) ||
              entry.defaults.values.any(
                (String text) => text.toLowerCase().contains(query),
              )))
        entry,
  ];
}

/// Live edit mode: pencil icons over every editable string.
///
/// Session-scoped on purpose — it is a working mode for the owner, not a
/// setting a customer should ever land in.
@Riverpod(keepAlive: true)
class LiveEditMode extends _$LiveEditMode {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void enable() => state = true;
  void disable() => state = false;
}

// ── Writes ──────────────────────────────────────────────────────────────────

/// Outcome of the last save/restore, so the editor can report it once.
@immutable
class TextEditorStatus {
  const TextEditorStatus({
    this.saving = false,
    this.saved = false,
    this.failure,
  });

  final bool saving;
  final bool saved;
  final AppFailure? failure;

  TextEditorStatus copyWith({
    bool? saving,
    bool? saved,
    AppFailure? failure,
    bool clearFailure = false,
  }) => TextEditorStatus(
    saving: saving ?? this.saving,
    saved: saved ?? this.saved,
    failure: clearFailure ? null : (failure ?? this.failure),
  );
}

/// Saves and restores the owner's wording.
///
/// The state change is optimistic in the only way that matters here: the write
/// goes to Supabase and the live stream (realtime) re-renders every screen,
/// including this one.
@riverpod
class TextEditorController extends _$TextEditorController {
  @override
  TextEditorStatus build() => const TextEditorStatus();

  TextOverridesRepository get _repo =>
      ref.read(textOverridesRepositoryProvider);

  Future<bool> save({
    required String textKey,
    required String locale,
    required String value,
  }) async {
    if (value.trim().isEmpty) {
      state = state.copyWith(
        failure: const ValidationFailure(
          messageKey: 'errorValidation',
          fieldErrors: <String, String>{'value': 'validateRequired'},
        ),
        saved: false,
      );
      return false;
    }

    state = const TextEditorStatus(saving: true);
    try {
      await _repo.save(textKey: textKey, locale: locale, value: value);
      // A realtime subscription usually pushes the new row back, but a project
      // without the `text_overrides` publication never would: refetching here
      // means the new wording appears on every screen even then.
      ref.invalidate(textOverridesProvider(locale));
      state = const TextEditorStatus(saved: true);
      return true;
    } on AppFailure catch (failure) {
      state = TextEditorStatus(failure: failure);
      return false;
    } on Object catch (error, stack) {
      state = TextEditorStatus(
        failure: ErrorMapper.map(error, stackTrace: stack),
      );
      return false;
    }
  }

  Future<bool> restore({
    required String textKey,
    required String locale,
  }) async {
    state = const TextEditorStatus(saving: true);
    try {
      await _repo.remove(textKey: textKey, locale: locale);
      ref.invalidate(textOverridesProvider(locale));
      state = const TextEditorStatus(saved: true);
      return true;
    } on AppFailure catch (failure) {
      state = TextEditorStatus(failure: failure);
      return false;
    } on Object catch (error, stack) {
      state = TextEditorStatus(
        failure: ErrorMapper.map(error, stackTrace: stack),
      );
      return false;
    }
  }

  void acknowledge() => state = const TextEditorStatus();
}
