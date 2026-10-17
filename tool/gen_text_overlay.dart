// Generates the two files that make every string in the app editable.
//
//   dart run tool/gen_text_overlay.dart
//
//   1. lib/core/l10n/text_catalog.dart
//      Every ARB key with its default wording in every locale, the placeholders
//      it carries, and the screen it belongs to. The owner-facing editor reads
//      this to list "every word of the app" without touching the ARBs.
//
//   2. lib/core/l10n/overridable_localizations.dart
//      An `AppLocalizations` subclass that returns the owner's wording when one
//      exists and the shipped ARB wording otherwise. Because the whole app
//      resolves strings through `AppLocalizations.of(context)`, registering
//      this through the delegate in `text_localizations.dart` makes an edit
//      land everywhere without touching a single call site.
//
// The ARB files stay the source of truth for the shipped wording; this script
// only restates them as Dart so the runtime can look a key up by name.
import 'dart:convert';
import 'dart:io';

const String _arbDir = 'lib/l10n';
const String _generatedLocalizations =
    'lib/core/l10n/generated/app_localizations.dart';
const String _catalogPath = 'lib/core/l10n/text_catalog.dart';
const String _overridesPath = 'lib/core/l10n/overridable_localizations.dart';

/// Locale code → the name the owner sees in the language picker.
const Map<String, String> _localeNames = <String, String>{
  'en': 'English',
  'am': 'አማርኛ',
  'ar': 'العربي',
  'om': 'Oromoo',
};

/// Key → the ARB key whose value titles that screen group in the editor.
///
/// Ordered: the first rule that matches wins, so the narrower admin screens
/// must come before the broad shared-word fallbacks at the end.
const Map<String, List<String>> _sections = <String, List<String>>{
  'groupStorefront': <String>[
    'section',
    'search',
    'a11y',
    'favourites',
    'navFavourites',
    'inquiryMessageTemplate',
    'labelPrice',
    'labelFrom',
    'labelDiscount',
    'labelAvailable',
    'labelUnavailable',
    'labelDuration',
    'actionOrderNow',
    'actionCallNow',
    'actionViewDetails',
    'actionContactOwner',
    'actionShare',
    'actionCopyLink',
    'actionCopySuccess',
  ],
  'settingsTitle': <String>[
    'settings',
    'nav',
    'appTitle',
    'brand',
    'tagline',
    'aboutFallback',
    'stateOffline',
  ],
  'adminDashboard': <String>[
    'adminDashboard',
    'adminStats',
    'adminInquiriesWeek',
    'adminMostContacted',
    'adminQuickActions',
    'adminNoInquiriesYet',
    'adminSortOrderHint',
    'adminViewStore',
    'adminViewAll',
    'adminPreview',
    'adminExitPreview',
    'adminJustNow',
    'adminProductColumn',
    'adminWhen',
  ],
  'adminProducts': <String>[
    'adminProduct',
    'adminAdd',
    'adminMedia',
    'adminCover',
    'adminRemoveMedia',
    'adminUpload',
    'adminPrice',
    'adminCompareAtPrice',
    'adminFeatured',
    'adminSlug',
    'adminPublish',
    'adminUnpublish',
    'adminVisibleInStore',
    'adminSetCover',
    'adminSave',
    'adminDuplicate',
    'adminDragToReorder',
    'adminDiscard',
    'adminUnsaved',
    'adminSearchProducts',
    'adminFilter',
  ],
  'adminCategories': <String>[
    'adminCategor',
    'adminCreateCategory',
    'adminMoveProductsTo',
    'adminNoCategories',
    'adminSectionSoon',
  ],
  'adminContacts': <String>[
    'adminContact',
    'adminMarkPrimary',
    'adminPrimaryBadge',
    'adminNoContacts',
    'adminChannel',
  ],
  'adminInquiries': <String>['adminInquir', 'adminClearInquiries'],
  'adminSiteSettings': <String>[
    'adminSiteSettings',
    'adminStoreName',
    'adminTagline',
    'adminAbout',
    'adminCurrency',
    'adminDefaultLanguage',
    'adminUploadLogo',
    'adminLogoPreview',
    'adminLivePreview',
  ],
  'adminTextEditor': <String>['adminTextEditor', 'adminLiveEdit'],
  'adminAccount': <String>[
    'adminLogin',
    'adminEmailLabel',
    'adminPassword',
    'adminSignIn',
    'adminSignOut',
    'adminForgotPassword',
    'adminResetSent',
    'adminNotAuthorised',
    'adminChangePassword',
    'adminCurrentPassword',
    'adminNewPassword',
    'adminConfirmPassword',
    'adminStrength',
    'adminReauthPrompt',
    'adminOtherSessionsSignedOut',
    'adminPasswordChanged',
    'adminAccount',
    'adminBackToGateway',
    'adminGatewayTitle',
  ],
  'gateTitle': <String>['gate'],
  'groupErrors': <String>['error'],
  'groupValidation': <String>['validate'],
};

const String _fallbackSection = 'groupCommon';

void main() {
  final Map<String, Map<String, String>> locales = _readArbs();
  // English first (it is the template and the picker's default), then the rest
  // in a stable order so regenerating never shuffles the language list.
  final List<String> localeCodes = <String>[
    'en',
    ...locales.keys.where((String code) => code != 'en').toList()..sort(),
  ];
  final Map<String, String> english = locales['en']!;

  // Placeholder names per key, straight from the template's `@key` metadata.
  final Map<String, List<String>> placeholders = _readPlaceholders();
  final Set<String> pluralKeys = english.entries
      .where((MapEntry<String, String> e) => e.value.contains('plural,'))
      .map((MapEntry<String, String> e) => e.key)
      .toSet();

  final List<String> keys = english.keys.toList()..sort();
  final Map<String, String> sections = <String, String>{
    for (final String key in keys) key: _sectionFor(key),
  };

  _write(
    _catalogPath,
    _buildCatalog(
      localeCodes: localeCodes,
      locales: locales,
      keys: keys,
      placeholders: placeholders,
      pluralKeys: pluralKeys,
      sections: sections,
    ),
  );
  _write(
    _overridesPath,
    _buildOverrides(declarations: _readDeclarations(), pluralKeys: pluralKeys),
  );

  // Both files are committed and gated by the `dart format
  // --set-exit-if-changed` CI step, so the generator hands its own output to
  // the same formatter instead of trying to match the style by hand: a
  // regenerated file is then byte-identical to the committed one and the
  // "generated sources are up to date" check stays green.
  _format(<String>[_catalogPath, _overridesPath]);

  stdout.writeln(
    'text overlay: ${keys.length} keys × ${localeCodes.length} locales '
    '(${localeCodes.join(', ')})',
  );
  stdout.writeln('  wrote $_catalogPath');
  stdout.writeln('  wrote $_overridesPath');
}

/// Formats [paths] with the SDK that is running this script.
///
/// `Platform.resolvedExecutable` is the `dart` VM itself, so the result matches
/// whatever toolchain invoked the generator — no `PATH` lookup that could find
/// a different SDK than the one CI's format gate uses.
void _format(List<String> paths) {
  final List<String> args = <String>['format', ...paths];
  final ProcessResult result = Process.runSync(
    Platform.resolvedExecutable,
    args,
  );
  if (result.exitCode != 0) {
    stderr
      ..write(result.stdout)
      ..write(result.stderr);
    throw ProcessException(
      Platform.resolvedExecutable,
      args,
      'dart format failed',
      result.exitCode,
    );
  }
}

// ── Sources ─────────────────────────────────────────────────────────────────

/// Reads every `lib/l10n/app_<locale>.arb` into `locale → (key → text)`.
Map<String, Map<String, String>> _readArbs() {
  final Directory dir = Directory(_arbDir);
  if (!dir.existsSync()) {
    stderr.writeln('error: $_arbDir not found — run from the project root');
    exit(1);
  }

  final Map<String, Map<String, String>> result =
      <String, Map<String, String>>{};
  for (final FileSystemEntity entity in dir.listSync()) {
    final String name = entity.path.split(Platform.pathSeparator).last;
    if (!name.startsWith('app_') || !name.endsWith('.arb')) continue;

    final Map<String, dynamic> json = jsonDecode(
      File(entity.path).readAsStringSync(),
    ) as Map<String, dynamic>;
    final String locale =
        json['@@locale'] as String? ?? name.substring(4, name.length - 4);
    result[locale] = <String, String>{
      for (final MapEntry<String, dynamic> entry in json.entries)
        if (!entry.key.startsWith('@') && entry.value is String)
          entry.key: entry.value as String,
    };
  }

  if (!result.containsKey('en')) {
    stderr.writeln('error: $_arbDir/app_en.arb (the template) is missing');
    exit(1);
  }
  return result;
}

/// Placeholder names declared by the template's `@key` metadata blocks.
Map<String, List<String>> _readPlaceholders() {
  final String raw = File('$_arbDir/app_en.arb').readAsStringSync();
  final Map<String, dynamic> json = jsonDecode(raw) as Map<String, dynamic>;
  final Map<String, List<String>> result = <String, List<String>>{};

  for (final MapEntry<String, dynamic> entry in json.entries) {
    if (!entry.key.startsWith('@') || entry.key.startsWith('@@')) continue;
    final Object? meta = entry.value;
    if (meta is! Map<String, dynamic>) continue;
    final Object? declared = meta['placeholders'];
    if (declared is! Map<String, dynamic>) continue;
    result[entry.key.substring(1)] = declared.keys.toList();
  }
  return result;
}

/// The `String get x;` / `String x(params);` declarations the generator emitted,
/// so the override subclass matches the abstract class exactly.
List<_Declaration> _readDeclarations() {
  final File file = File(_generatedLocalizations);
  if (!file.existsSync()) {
    stderr.writeln(
      'error: $_generatedLocalizations not found — run `flutter gen-l10n` first',
    );
    exit(1);
  }

  final RegExp pattern = RegExp(
    r'^  String (get )?([A-Za-z0-9_]+)(\((.*)\))?;',
    multiLine: true,
  );
  final List<_Declaration> declarations = <_Declaration>[];
  for (final RegExpMatch match in pattern.allMatches(file.readAsStringSync())) {
    final String params = match.group(4) ?? '';
    declarations.add(
      _Declaration(
        name: match.group(2)!,
        isGetter: match.group(1) != null,
        params: params.isEmpty
            ? const <_Param>[]
            : params.split(',').map(_Param.parse).toList(growable: false),
      ),
    );
  }
  if (declarations.isEmpty) {
    stderr.writeln(
      'error: no declarations parsed from $_generatedLocalizations',
    );
    exit(1);
  }
  return declarations;
}

String _sectionFor(String key) {
  for (final MapEntry<String, List<String>> entry in _sections.entries) {
    for (final String prefix in entry.value) {
      if (key == prefix || key.startsWith(prefix)) return entry.key;
    }
  }
  return _fallbackSection;
}

// ── Emitters ────────────────────────────────────────────────────────────────

String _buildCatalog({
  required List<String> localeCodes,
  required Map<String, Map<String, String>> locales,
  required List<String> keys,
  required Map<String, List<String>> placeholders,
  required Set<String> pluralKeys,
  required Map<String, String> sections,
}) {
  final StringBuffer out = StringBuffer()
    ..writeln('// GENERATED FILE — DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln('// Run `dart run tool/gen_text_overlay.dart` after changing any')
    ..writeln('// lib/l10n/app_*.arb file. It restates the ARBs as Dart so the')
    ..writeln(
      '// owner-facing text editor can list and resolve every string by key.',
    )
    ..writeln('// ignore_for_file: type=lint')
    ..writeln()
    ..writeln('/// One editable string: its key, its shipped wording in every')
    ..writeln('/// locale, and the screen group it belongs to.')
    ..writeln('class AppTextEntry {')
    ..writeln('  const AppTextEntry({')
    ..writeln('    required this.key,')
    ..writeln('    required this.sectionKey,')
    ..writeln('    required this.defaults,')
    ..writeln('    this.placeholders = const <String>[],')
    ..writeln('    this.isPlural = false,')
    ..writeln('  });')
    ..writeln()
    ..writeln('  final String key;')
    ..writeln()
    ..writeln('  /// ARB key of the screen this text belongs to.')
    ..writeln('  final String sectionKey;')
    ..writeln()
    ..writeln('  /// Locale code → shipped wording.')
    ..writeln('  final Map<String, String> defaults;')
    ..writeln()
    ..writeln('  /// `{name}`-style variables the text must keep.')
    ..writeln('  final List<String> placeholders;')
    ..writeln()
    ..writeln(
      '  /// ICU plurals cannot be replaced by plain text, so the editor',
    )
    ..writeln('  /// shows these read-only.')
    ..writeln('  final bool isPlural;')
    ..writeln()
    ..writeln('  bool get hasPlaceholders => placeholders.isNotEmpty;')
    ..writeln()
    ..writeln('  bool get isEditable => !isPlural;')
    ..writeln()
    ..writeln(
      '  /// The shipped wording for [locale], falling back to English.',
    )
    ..writeln('  String defaultFor(String locale) =>')
    ..writeln('      defaults[locale] ?? defaults[\'en\'] ?? key;')
    ..writeln()
    ..writeln('  /// Same, for the first locale that has any wording at all.')
    ..writeln('  String get anyDefault =>')
    ..writeln('      defaults.values.isEmpty ? key : defaults.values.first;')
    ..writeln('}')
    ..writeln()
    ..writeln('/// Locales the owner can edit, in picker order.')
    ..writeln('const List<String> kAppTextLocales = <String>[');
  for (final String code in localeCodes) {
    out.writeln("  '$code',");
  }
  out
    ..writeln('];')
    ..writeln()
    ..writeln('/// Locale code → the name shown in the language picker.')
    ..writeln(
      'const Map<String, String> kAppTextLocaleNames = '
      '<String, String>{',
    );
  for (final String code in localeCodes) {
    out.writeln("  '$code': '${_dart(_localeNames[code] ?? code)}',");
  }
  out
    ..writeln('};')
    ..writeln()
    ..writeln('/// Screen groups, in the order the editor shows them.')
    ..writeln('const List<String> kAppTextSections = <String>[');
  for (final String section in _orderedSections(sections)) {
    out.writeln("  '$section',");
  }
  out
    ..writeln('];')
    ..writeln()
    ..writeln('/// Every string in the app.')
    ..writeln('const List<AppTextEntry> kAppTextEntries = <AppTextEntry>[');

  for (final String key in keys) {
    final Map<String, String> defaults = <String, String>{
      for (final String code in localeCodes)
        if (locales[code]!.containsKey(key)) code: locales[code]![key]!,
    };
    out
      ..writeln('  AppTextEntry(')
      ..writeln("    key: '${_dart(key)}',")
      ..writeln("    sectionKey: '${sections[key]}',")
      ..writeln('    defaults: <String, String>{');
    for (final MapEntry<String, String> entry in defaults.entries) {
      out.writeln("      '${entry.key}': '${_dart(entry.value)}',");
    }
    out.writeln('    },');
    final List<String> declared = placeholders[key] ?? const <String>[];
    if (declared.isNotEmpty) {
      out.writeln('    placeholders: <String>[');
      for (final String name in declared) {
        out.writeln("      '$name',");
      }
      out.writeln('    ],');
    }
    if (pluralKeys.contains(key)) out.writeln('    isPlural: true,');
    out.writeln('  ),');
  }

  out
    ..writeln('];')
    ..writeln()
    ..writeln('/// Lookup by key, for the in-place pencils and the editor.')
    ..writeln(
      'final Map<String, AppTextEntry> kAppTextByKey = '
      '<String, AppTextEntry>{',
    )
    ..writeln('  for (final AppTextEntry entry in kAppTextEntries)')
    ..writeln('    entry.key: entry,')
    ..writeln('};');
  return out.toString();
}

String _buildOverrides({
  required List<_Declaration> declarations,
  required Set<String> pluralKeys,
}) {
  final StringBuffer out = StringBuffer()
    ..writeln('// GENERATED FILE — DO NOT EDIT BY HAND.')
    ..writeln('//')
    ..writeln('// Run `dart run tool/gen_text_overlay.dart` after changing any')
    ..writeln('// lib/l10n/app_*.arb file or regenerating the localizations.')
    ..writeln('// ignore_for_file: type=lint')
    ..writeln()
    ..writeln("import 'generated/app_localizations.dart';")
    ..writeln()
    ..writeln(
      '/// [AppLocalizations] that renders the owner\'s own wording where',
    )
    ..writeln('/// one exists and the shipped ARB wording everywhere else.')
    ..writeln('///')
    ..writeln('/// Every screen already reads its strings through')
    ..writeln(
      '/// `AppLocalizations.of(context)`, so wrapping that instance is what',
    )
    ..writeln('/// makes an edit appear on all of them at once.')
    ..writeln('class OverridableAppLocalizations extends AppLocalizations {')
    ..writeln('  OverridableAppLocalizations(this._base, this._overrides)')
    ..writeln('      : super(_base.localeName);')
    ..writeln()
    ..writeln('  final AppLocalizations _base;')
    ..writeln()
    ..writeln('  /// The owner\'s wording for THIS locale, keyed by ARB key.')
    ..writeln('  final Map<String, String> _overrides;')
    ..writeln()
    ..writeln('  /// Whether the owner has rewritten [key] for this locale.')
    ..writeln('  bool owns(String key) => _overrides.containsKey(key);')
    ..writeln()
    ..writeln('  String _text(String key, String fallback) =>')
    ..writeln('      _overrides[key] ?? fallback;')
    ..writeln()
    ..writeln(
      '  /// Applies an override that carries `{variable}` placeholders, so',
    )
    ..writeln('  /// a rewritten message still names the product it is about.')
    ..writeln('  String _filled(')
    ..writeln('    String key,')
    ..writeln('    String fallback,')
    ..writeln('    Map<String, String> params,')
    ..writeln('  ) {')
    ..writeln('    final String? override = _overrides[key];')
    ..writeln('    if (override == null) return fallback;')
    ..writeln('    String result = override;')
    ..writeln('    params.forEach((String name, String value) {')
    ..writeln("      result = result.replaceAll('{\$name}', value);")
    ..writeln('    });')
    ..writeln('    return result;')
    ..writeln('  }');

  for (final _Declaration declaration in declarations) {
    out.writeln();
    if (declaration.isGetter) {
      out.writeln('  @override');
      out.writeln(
        '  String get ${declaration.name} =>'
        " _text('${declaration.name}', _base.${declaration.name});",
      );
      continue;
    }

    out.writeln('  @override');
    if (pluralKeys.contains(declaration.name)) {
      // ICU plural syntax cannot survive a plain-text replacement.
      out.writeln(
        '  String ${declaration.name}(${declaration.paramsSource}) =>',
      );
      out.writeln('      _base.${declaration.name}(${declaration.argNames});');
      continue;
    }

    out.writeln('  String ${declaration.name}(${declaration.paramsSource}) =>');
    if (declaration.params.isEmpty) {
      out.writeln(
        '      _text(\'${declaration.name}\', _base.${declaration.name}());',
      );
      continue;
    }
    out.writeln('      _filled(');
    out.writeln("        '${declaration.name}',");
    out.writeln('        _base.${declaration.name}(${declaration.argNames}),');
    out.writeln('        <String, String>{');
    for (final _Param param in declaration.params) {
      out.writeln("          '${param.name}': '\${${param.name}}',");
    }
    out.writeln('        },');
    out.writeln('      );');
  }

  out.writeln('}');
  return out.toString();
}

List<String> _orderedSections(Map<String, String> sections) {
  final List<String> declared = _sections.keys.toList()..add(_fallbackSection);
  return <String>[
    for (final String section in declared)
      if (sections.containsValue(section)) section,
  ];
}

/// Escapes a string for a single-quoted Dart literal.
String _dart(String value) => value
    .replaceAll(r'\', r'\\')
    .replaceAll("'", r"\'")
    .replaceAll(r'$', r'\$')
    .replaceAll('\n', r'\n');

void _write(String path, String contents) {
  final File file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsStringSync(contents);
}

// ── Parsed declarations ─────────────────────────────────────────────────────

class _Declaration {
  const _Declaration({
    required this.name,
    required this.isGetter,
    required this.params,
  });

  final String name;
  final bool isGetter;
  final List<_Param> params;

  /// `String name, int count`, for the override signature.
  String get paramsSource =>
      params.map((_Param p) => '${p.type} ${p.name}').join(', ');

  /// `name, count`, for the delegated call.
  String get argNames => params.map((_Param p) => p.name).join(', ');
}

class _Param {
  const _Param(this.type, this.name);

  final String type;
  final String name;

  static _Param parse(String raw) {
    final List<String> parts = raw.trim().split(RegExp(r'\s+'));
    return _Param(parts.first, parts.last);
  }
}
