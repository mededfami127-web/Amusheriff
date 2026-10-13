import '../../../core/utils/launcher.dart';
import 'entities/contact_kind.dart';
import 'entities/contact_link.dart';

/// Business rule: which platform intent each [ContactKind] should open.
///
/// Kept out of the widgets so "Buy on WhatsApp" and the contact sheet share one
/// implementation, and so Part 2's integration tests can assert the built URL
/// without touching a platform channel.
class ContactLauncher {
  const ContactLauncher(this._launcher);

  final LinkLauncher _launcher;

  /// Opens [link], pre-filling [message] on the chat channels.
  Future<bool> launch(ContactLink link, {String? message}) {
    final String value = link.value.trim();
    return switch (link.kind) {
      ContactKind.whatsapp =>
        _launcher.openWhatsApp(value, message: message),
      ContactKind.telegram =>
        _launcher.openTelegram(value, message: message),
      ContactKind.phone => _launcher.openPhone(value),
      ContactKind.email => _launcher.openEmail(
          value,
          subject: message == null ? null : '',
          body: message,
        ),
      ContactKind.instagram => _launcher.openInstagram(value),
      ContactKind.facebook => _launcher.openFacebook(value),
      ContactKind.tiktok => _launcher.openTikTok(value),
      ContactKind.youtube => _launcher.openYouTube(value),
      ContactKind.website => _launcher.openRaw(value),
      ContactKind.location => _launcher.openMaps(value),
      ContactKind.other => _launcher.openRaw(value),
    };
  }

  /// The URL that [launch] will resolve to, for tests and "copy link".
  String? previewUrl(ContactLink link, {String? message}) {
    final String value = link.value.trim();
    return switch (link.kind) {
      ContactKind.whatsapp => _buildWhatsApp(value, message),
      ContactKind.telegram => _buildTelegram(value, message),
      ContactKind.phone => 'tel:${value.replaceAll(RegExp(r'[^0-9+]'), '')}',
      ContactKind.email => 'mailto:$value',
      ContactKind.instagram =>
        'https://instagram.com/${value.replaceAll('@', '')}',
      ContactKind.facebook => 'https://facebook.com/${value.replaceAll('@', '')}',
      ContactKind.tiktok => 'https://tiktok.com/@${value.replaceAll('@', '')}',
      ContactKind.youtube =>
        value.startsWith('http') ? value : 'https://youtube.com/@${value.replaceAll('@', '')}',
      ContactKind.location =>
        'https://www.google.com/maps/search/?q=${Uri.encodeComponent(value)}',
      ContactKind.website => _normaliseUrl(value),
      ContactKind.other => _normaliseUrl(value),
    };
  }

  static String _buildWhatsApp(String number, String? message) {
    final String digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    final String query = (message == null || message.isEmpty)
        ? ''
        : '?text=${Uri.encodeComponent(message)}';
    return 'https://wa.me/$digits$query';
  }

  static String _buildTelegram(String value, String? message) {
    final String handle = value
        .trim()
        .replaceAll(RegExp(r'^(https?://)?(www\.)?(t\.me|telegram\.me)/'), '')
        .replaceAll('@', '');
    final String query = (message == null || message.isEmpty)
        ? ''
        : '?text=${Uri.encodeComponent(message)}';
    return 'https://t.me/$handle$query';
  }

  static String? _normaliseUrl(String value) {
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (RegExp(r'^[\w.-]+\.[a-z]{2,}(/.*)?$').hasMatch(value)) {
      return 'https://$value';
    }
    return null;
  }
}
