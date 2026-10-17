// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_editor_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(textOverridesRepository)
final textOverridesRepositoryProvider = TextOverridesRepositoryProvider._();

final class TextOverridesRepositoryProvider
    extends
        $FunctionalProvider<
          TextOverridesRepository,
          TextOverridesRepository,
          TextOverridesRepository
        >
    with $Provider<TextOverridesRepository> {
  TextOverridesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textOverridesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textOverridesRepositoryHash();

  @$internal
  @override
  $ProviderElement<TextOverridesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TextOverridesRepository create(Ref ref) {
    return textOverridesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextOverridesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextOverridesRepository>(value),
    );
  }
}

String _$textOverridesRepositoryHash() =>
    r'046cd8fc987aa22265a13883ed832b8f7efc658d';

/// Every owner rewrite for one locale, live.

@ProviderFor(textOverrides)
final textOverridesProvider = TextOverridesFamily._();

/// Every owner rewrite for one locale, live.

final class TextOverridesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, String>>,
          Map<String, String>,
          Stream<Map<String, String>>
        >
    with
        $FutureModifier<Map<String, String>>,
        $StreamProvider<Map<String, String>> {
  /// Every owner rewrite for one locale, live.
  TextOverridesProvider._({
    required TextOverridesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'textOverridesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$textOverridesHash();

  @override
  String toString() {
    return r'textOverridesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<Map<String, String>> create(Ref ref) {
    final argument = this.argument as String;
    return textOverrides(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TextOverridesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$textOverridesHash() => r'753426eef2df18246bd26f824cfa94eb92f81023';

/// Every owner rewrite for one locale, live.

final class TextOverridesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Map<String, String>>, String> {
  TextOverridesFamily._()
    : super(
        retry: null,
        name: r'textOverridesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every owner rewrite for one locale, live.

  TextOverridesProvider call(String locale) =>
      TextOverridesProvider._(argument: locale, from: this);

  @override
  String toString() => r'textOverridesProvider';
}

/// Synchronous view of [textOverrides], for the localizations delegate.
///
/// An empty map until the first event (and whenever the fetch fails), which is
/// exactly the shipped wording — never an error screen.

@ProviderFor(textOverridesValue)
final textOverridesValueProvider = TextOverridesValueFamily._();

/// Synchronous view of [textOverrides], for the localizations delegate.
///
/// An empty map until the first event (and whenever the fetch fails), which is
/// exactly the shipped wording — never an error screen.

final class TextOverridesValueProvider
    extends
        $FunctionalProvider<
          Map<String, String>,
          Map<String, String>,
          Map<String, String>
        >
    with $Provider<Map<String, String>> {
  /// Synchronous view of [textOverrides], for the localizations delegate.
  ///
  /// An empty map until the first event (and whenever the fetch fails), which is
  /// exactly the shipped wording — never an error screen.
  TextOverridesValueProvider._({
    required TextOverridesValueFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'textOverridesValueProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$textOverridesValueHash();

  @override
  String toString() {
    return r'textOverridesValueProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<String, String>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<String, String> create(Ref ref) {
    final argument = this.argument as String;
    return textOverridesValue(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TextOverridesValueProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$textOverridesValueHash() =>
    r'dd70e99711e3bcb085a0adc7a00071fb8638430c';

/// Synchronous view of [textOverrides], for the localizations delegate.
///
/// An empty map until the first event (and whenever the fetch fails), which is
/// exactly the shipped wording — never an error screen.

final class TextOverridesValueFamily extends $Family
    with $FunctionalFamilyOverride<Map<String, String>, String> {
  TextOverridesValueFamily._()
    : super(
        retry: null,
        name: r'textOverridesValueProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Synchronous view of [textOverrides], for the localizations delegate.
  ///
  /// An empty map until the first event (and whenever the fetch fails), which is
  /// exactly the shipped wording — never an error screen.

  TextOverridesValueProvider call(String locale) =>
      TextOverridesValueProvider._(argument: locale, from: this);

  @override
  String toString() => r'textOverridesValueProvider';
}

/// The locale the owner is editing.
///
/// Deliberately separate from [AppLanguage]: the owner can rewrite the Arabic
/// wording while browsing the app in Oromo.

@ProviderFor(TextEditorLocale)
final textEditorLocaleProvider = TextEditorLocaleProvider._();

/// The locale the owner is editing.
///
/// Deliberately separate from [AppLanguage]: the owner can rewrite the Arabic
/// wording while browsing the app in Oromo.
final class TextEditorLocaleProvider
    extends $NotifierProvider<TextEditorLocale, String> {
  /// The locale the owner is editing.
  ///
  /// Deliberately separate from [AppLanguage]: the owner can rewrite the Arabic
  /// wording while browsing the app in Oromo.
  TextEditorLocaleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorLocaleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorLocaleHash();

  @$internal
  @override
  TextEditorLocale create() => TextEditorLocale();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$textEditorLocaleHash() => r'9c62d2c1f03f7647c8cdae12fa0d4e4ddb91b475';

/// The locale the owner is editing.
///
/// Deliberately separate from [AppLanguage]: the owner can rewrite the Arabic
/// wording while browsing the app in Oromo.

abstract class _$TextEditorLocale extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Free-text search over keys, wording and defaults.

@ProviderFor(TextEditorQuery)
final textEditorQueryProvider = TextEditorQueryProvider._();

/// Free-text search over keys, wording and defaults.
final class TextEditorQueryProvider
    extends $NotifierProvider<TextEditorQuery, String> {
  /// Free-text search over keys, wording and defaults.
  TextEditorQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorQueryHash();

  @$internal
  @override
  TextEditorQuery create() => TextEditorQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$textEditorQueryHash() => r'464b1dad54e5d779a37265a3f1904f459e9dca5a';

/// Free-text search over keys, wording and defaults.

abstract class _$TextEditorQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The screen group being shown, or `null` for "every screen".

@ProviderFor(TextEditorSection)
final textEditorSectionProvider = TextEditorSectionProvider._();

/// The screen group being shown, or `null` for "every screen".
final class TextEditorSectionProvider
    extends $NotifierProvider<TextEditorSection, String?> {
  /// The screen group being shown, or `null` for "every screen".
  TextEditorSectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorSectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorSectionHash();

  @$internal
  @override
  TextEditorSection create() => TextEditorSection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$textEditorSectionHash() => r'3c1db54a8fa885509bb402742a814137e771b5af';

/// The screen group being shown, or `null` for "every screen".

abstract class _$TextEditorSection extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Every key whose current wording in the edited locale came from the owner.

@ProviderFor(overriddenKeys)
final overriddenKeysProvider = OverriddenKeysFamily._();

/// Every key whose current wording in the edited locale came from the owner.

final class OverriddenKeysProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// Every key whose current wording in the edited locale came from the owner.
  OverriddenKeysProvider._({
    required OverriddenKeysFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'overriddenKeysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$overriddenKeysHash();

  @override
  String toString() {
    return r'overriddenKeysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    final argument = this.argument as String;
    return overriddenKeys(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OverriddenKeysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$overriddenKeysHash() => r'36f07e6001ccd407d4a72ffba656f10e5333d20f';

/// Every key whose current wording in the edited locale came from the owner.

final class OverriddenKeysFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, String> {
  OverriddenKeysFamily._()
    : super(
        retry: null,
        name: r'overriddenKeysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every key whose current wording in the edited locale came from the owner.

  OverriddenKeysProvider call(String locale) =>
      OverriddenKeysProvider._(argument: locale, from: this);

  @override
  String toString() => r'overriddenKeysProvider';
}

/// The screen groups that actually contain texts, in editor order.
///
/// Derived from the catalogue so a newly added ARB key shows up under its
/// screen the moment the generator is re-run.

@ProviderFor(textEditorSections)
final textEditorSectionsProvider = TextEditorSectionsProvider._();

/// The screen groups that actually contain texts, in editor order.
///
/// Derived from the catalogue so a newly added ARB key shows up under its
/// screen the moment the generator is re-run.

final class TextEditorSectionsProvider
    extends $FunctionalProvider<List<String>, List<String>, List<String>>
    with $Provider<List<String>> {
  /// The screen groups that actually contain texts, in editor order.
  ///
  /// Derived from the catalogue so a newly added ARB key shows up under its
  /// screen the moment the generator is re-run.
  TextEditorSectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorSectionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorSectionsHash();

  @$internal
  @override
  $ProviderElement<List<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  List<String> create(Ref ref) {
    return textEditorSections(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$textEditorSectionsHash() =>
    r'be085ab725bbcfeead67f37b4f5c3e4d4e68bbc8';

/// Every key still needing owner wording in [locale].

@ProviderFor(textGapKeys)
final textGapKeysProvider = TextGapKeysFamily._();

/// Every key still needing owner wording in [locale].

final class TextGapKeysProvider
    extends $FunctionalProvider<Set<String>, Set<String>, Set<String>>
    with $Provider<Set<String>> {
  /// Every key still needing owner wording in [locale].
  TextGapKeysProvider._({
    required TextGapKeysFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'textGapKeysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$textGapKeysHash();

  @override
  String toString() {
    return r'textGapKeysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Set<String>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Set<String> create(Ref ref) {
    final argument = this.argument as String;
    return textGapKeys(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TextGapKeysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$textGapKeysHash() => r'50116833ce5d4bee27c6a71e4c4ed9cd2e477170';

/// Every key still needing owner wording in [locale].

final class TextGapKeysFamily extends $Family
    with $FunctionalFamilyOverride<Set<String>, String> {
  TextGapKeysFamily._()
    : super(
        retry: null,
        name: r'textGapKeysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Every key still needing owner wording in [locale].

  TextGapKeysProvider call(String locale) =>
      TextGapKeysProvider._(argument: locale, from: this);

  @override
  String toString() => r'textGapKeysProvider';
}

/// How many words are still missing in [locale], for the language chips.

@ProviderFor(textGapCount)
final textGapCountProvider = TextGapCountFamily._();

/// How many words are still missing in [locale], for the language chips.

final class TextGapCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many words are still missing in [locale], for the language chips.
  TextGapCountProvider._({
    required TextGapCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'textGapCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$textGapCountHash();

  @override
  String toString() {
    return r'textGapCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return textGapCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TextGapCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$textGapCountHash() => r'dc25aacb7f432eab6cf457ab89201c6f71d05ed1';

/// How many words are still missing in [locale], for the language chips.

final class TextGapCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  TextGapCountFamily._()
    : super(
        retry: null,
        name: r'textGapCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many words are still missing in [locale], for the language chips.

  TextGapCountProvider call(String locale) =>
      TextGapCountProvider._(argument: locale, from: this);

  @override
  String toString() => r'textGapCountProvider';
}

/// Missing words per screen, for the section chips.

@ProviderFor(textGapCountsBySection)
final textGapCountsBySectionProvider = TextGapCountsBySectionProvider._();

/// Missing words per screen, for the section chips.

final class TextGapCountsBySectionProvider
    extends
        $FunctionalProvider<
          Map<String, int>,
          Map<String, int>,
          Map<String, int>
        >
    with $Provider<Map<String, int>> {
  /// Missing words per screen, for the section chips.
  TextGapCountsBySectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textGapCountsBySectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textGapCountsBySectionHash();

  @$internal
  @override
  $ProviderElement<Map<String, int>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Map<String, int> create(Ref ref) {
    return textGapCountsBySection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, int> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, int>>(value),
    );
  }
}

String _$textGapCountsBySectionHash() =>
    r'cc0b849565e89cc6e360a0840620655fede723dd';

/// "Fill the gap" mode: show only the strings that still need wording.
///
/// Kept in its own provider so switching language or screen never loses the
/// mode, which is what makes filling a whole language a single pass.

@ProviderFor(TextEditorGapsOnly)
final textEditorGapsOnlyProvider = TextEditorGapsOnlyProvider._();

/// "Fill the gap" mode: show only the strings that still need wording.
///
/// Kept in its own provider so switching language or screen never loses the
/// mode, which is what makes filling a whole language a single pass.
final class TextEditorGapsOnlyProvider
    extends $NotifierProvider<TextEditorGapsOnly, bool> {
  /// "Fill the gap" mode: show only the strings that still need wording.
  ///
  /// Kept in its own provider so switching language or screen never loses the
  /// mode, which is what makes filling a whole language a single pass.
  TextEditorGapsOnlyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorGapsOnlyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorGapsOnlyHash();

  @$internal
  @override
  TextEditorGapsOnly create() => TextEditorGapsOnly();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$textEditorGapsOnlyHash() =>
    r'd4674655d2060ff71d879fc556a094a9af9058bf';

/// "Fill the gap" mode: show only the strings that still need wording.
///
/// Kept in its own provider so switching language or screen never loses the
/// mode, which is what makes filling a whole language a single pass.

abstract class _$TextEditorGapsOnly extends $Notifier<bool> {
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

/// The catalogue entries matching the current search, section and gap filter.

@ProviderFor(filteredTextEntries)
final filteredTextEntriesProvider = FilteredTextEntriesProvider._();

/// The catalogue entries matching the current search, section and gap filter.

final class FilteredTextEntriesProvider
    extends
        $FunctionalProvider<
          List<AppTextEntry>,
          List<AppTextEntry>,
          List<AppTextEntry>
        >
    with $Provider<List<AppTextEntry>> {
  /// The catalogue entries matching the current search, section and gap filter.
  FilteredTextEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredTextEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredTextEntriesHash();

  @$internal
  @override
  $ProviderElement<List<AppTextEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<AppTextEntry> create(Ref ref) {
    return filteredTextEntries(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AppTextEntry> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AppTextEntry>>(value),
    );
  }
}

String _$filteredTextEntriesHash() =>
    r'49dcac6043dee6336f9f506d8e63552adeae4c42';

/// Live edit mode: pencil icons over every editable string.
///
/// Session-scoped on purpose — it is a working mode for the owner, not a
/// setting a customer should ever land in.

@ProviderFor(LiveEditMode)
final liveEditModeProvider = LiveEditModeProvider._();

/// Live edit mode: pencil icons over every editable string.
///
/// Session-scoped on purpose — it is a working mode for the owner, not a
/// setting a customer should ever land in.
final class LiveEditModeProvider extends $NotifierProvider<LiveEditMode, bool> {
  /// Live edit mode: pencil icons over every editable string.
  ///
  /// Session-scoped on purpose — it is a working mode for the owner, not a
  /// setting a customer should ever land in.
  LiveEditModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'liveEditModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$liveEditModeHash();

  @$internal
  @override
  LiveEditMode create() => LiveEditMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$liveEditModeHash() => r'd910df62c66876de6dc7531df64709110ba8d11c';

/// Live edit mode: pencil icons over every editable string.
///
/// Session-scoped on purpose — it is a working mode for the owner, not a
/// setting a customer should ever land in.

abstract class _$LiveEditMode extends $Notifier<bool> {
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

/// Saves and restores the owner's wording.
///
/// The state change is optimistic in the only way that matters here: the write
/// goes to Supabase and the live stream (realtime) re-renders every screen,
/// including this one.

@ProviderFor(TextEditorController)
final textEditorControllerProvider = TextEditorControllerProvider._();

/// Saves and restores the owner's wording.
///
/// The state change is optimistic in the only way that matters here: the write
/// goes to Supabase and the live stream (realtime) re-renders every screen,
/// including this one.
final class TextEditorControllerProvider
    extends $NotifierProvider<TextEditorController, TextEditorStatus> {
  /// Saves and restores the owner's wording.
  ///
  /// The state change is optimistic in the only way that matters here: the write
  /// goes to Supabase and the live stream (realtime) re-renders every screen,
  /// including this one.
  TextEditorControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textEditorControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textEditorControllerHash();

  @$internal
  @override
  TextEditorController create() => TextEditorController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextEditorStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextEditorStatus>(value),
    );
  }
}

String _$textEditorControllerHash() =>
    r'37f9fa2000e8d00792db43e2e08efc1f3d9e192c';

/// Saves and restores the owner's wording.
///
/// The state change is optimistic in the only way that matters here: the write
/// goes to Supabase and the live stream (realtime) re-renders every screen,
/// including this one.

abstract class _$TextEditorController extends $Notifier<TextEditorStatus> {
  TextEditorStatus build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TextEditorStatus, TextEditorStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TextEditorStatus, TextEditorStatus>,
              TextEditorStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
