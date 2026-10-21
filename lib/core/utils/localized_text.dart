/// Picks the text to show for one catalogue row in one language.
///
/// The order is deliberate and identical for every entity: the selected
/// language first, then English, then any other language that actually has
/// text. A blank string is treated as "not written yet" — the admin form saves
/// an empty field as `NULL`, but a row edited before that rule existed can
/// still hold `''`, and rendering it would leave an empty card.
///
/// English is the second step rather than the last so a product that has only
/// an Amharic title still shows *something* in Arabic instead of a blank line.
String localizedText({
  required String languageCode,
  required String english,
  String? amharic,
  String? arabic,
  String? oromo,
}) {
  final String? selected = switch (languageCode) {
    'am' => amharic,
    'ar' => arabic,
    'om' => oromo,
    _ => english,
  };
  for (final String? value in <String?>[
    selected,
    english,
    amharic,
    arabic,
    oromo,
  ]) {
    final String text = (value ?? '').trim();
    if (text.isNotEmpty) return text;
  }
  return '';
}
