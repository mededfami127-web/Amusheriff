/// Write-side DTO for `public.site_content`.
@immutable
class SiteContentDraft {
  const SiteContentDraft({
    required this.key,
    required this.locale,
    required this.value,
  });

  final String key;
  final String locale;
  final String value;

  Map<String, dynamic> toRow(String? userId) => <String, dynamic>{
        'key': key.trim(),
        'locale': locale.trim(),
        'value': value.trim(),
        if (userId != null) 'updated_by': userId,
      };
}
