// Fails when the ARB files have drifted apart.
//
//   dart run tool/check_l10n_parity.dart
//
// `flutter gen-l10n` takes lib/l10n/app_en.arb as the template and answers any
// key a translation is missing with the English wording. Nothing in the build
// says so: a key added to the template alone still compiles, still passes the
// generated-drift check (which compares generated output, not ARB coverage) and
// silently ships English text to the Amharic, Arabic and Oromo readers. This
// check closes that gap, and it is what lets
// `dart run tool/gen_text_overlay.dart` announce the same key count for all
// four locales.
//
// Keys starting with `@` are gen-l10n metadata (`@key`, `@@locale`), not
// messages, and are ignored here. Placeholders are deliberately not compared:
// ICU plural bodies (`{count, plural, =2{نتيجتان} …}`) would need a real
// parser, and gen-l10n itself already rejects a translation that uses a
// placeholder the template does not declare.
import 'dart:convert';
import 'dart:io';

const String _arbDir = 'lib/l10n';
const String _templateName = 'app_en.arb';

void main() {
  final Directory dir = Directory(_arbDir);
  if (!dir.existsSync()) {
    stderr.writeln('error: $_arbDir does not exist — run this from the repository root.');
    exit(2);
  }

  final List<File> arbs = dir
      .listSync()
      .whereType<File>()
      .where((File file) => file.path.endsWith('.arb'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));

  File? template;
  for (final File file in arbs) {
    if (_name(file) == _templateName) template = file;
  }
  if (template == null) {
    stderr.writeln('error: $_arbDir/$_templateName not found.');
    exit(2);
  }
  if (arbs.length < 2) {
    stderr.writeln('error: $_arbDir holds no translations besides $_templateName.');
    exit(2);
  }

  final Set<String> templateKeys = _messageKeys(template);
  bool failed = false;

  for (final File file in arbs) {
    final String name = _name(file);
    if (name == _templateName) continue;

    final Set<String> keys = _messageKeys(file);
    final List<String> missing = templateKeys.difference(keys).toList()..sort();
    final List<String> unknown = keys.difference(templateKeys).toList()..sort();
    if (missing.isEmpty && unknown.isEmpty) continue;

    failed = true;
    stderr.writeln('✗ $name is out of step with $_templateName:');
    if (missing.isNotEmpty) {
      stderr.writeln('    missing (${missing.length}): ${missing.join(', ')}');
    }
    if (unknown.isNotEmpty) {
      stderr.writeln('    not in the template (${unknown.length}): ${unknown.join(', ')}');
    }
  }

  if (failed) {
    stderr.writeln('');
    stderr.writeln('Add the key to every lib/l10n/app_*.arb, then regenerate the');
    stderr.writeln('committed output:');
    stderr.writeln('  flutter gen-l10n && dart run tool/gen_text_overlay.dart');
    exit(1);
  }

  final String locales =
      arbs.map((File file) => _name(file).replaceAll('app_', '').replaceAll('.arb', '')).join(', ');
  stdout.writeln('l10n parity OK: ${templateKeys.length} message keys in each of $locales.');
}

/// `lib/l10n/app_am.arb` → `app_am.arb`.
String _name(File file) => file.uri.pathSegments.last;

/// Every message key in one ARB file, with the `@`-prefixed metadata removed.
Set<String> _messageKeys(File file) {
  final Object? decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('error: ${file.path} is not a JSON object.');
    exit(2);
  }
  return decoded.keys.where((String key) => !key.startsWith('@')).toSet();
}
