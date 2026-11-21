import 'dart:ui' show Rect;

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;

part 'launcher.g.dart';

/// Signature of the underlying launcher, injectable so tests never touch the
/// platform channel.
typedef LaunchUriFn = Future<bool> Function(
  Uri uri,
  url_launcher.LaunchMode mode,
);

/// Wraps `url_launcher` and `share_plus` with the app's URL-building rules.
class LinkLauncher {
  LinkLauncher({LaunchUriFn? launch})
    : _launch =
          launch ??
          ((Uri uri, url_launcher.LaunchMode mode) =>
              url_launcher.launchUrl(uri, mode: mode));

  final LaunchUriFn _launch;

  Future<bool> _open(
    Uri uri, {
    url_launcher.LaunchMode mode = url_launcher.LaunchMode.externalApplication,
  }) async {
    if (!await url_launcher.canLaunchUrl(uri)) return false;
    return _launch(uri, mode);
  }

  Future<bool> openWeb(
    String url, {
    url_launcher.LaunchMode mode = url_launcher.LaunchMode.externalApplication,
  }) => _open(Uri.parse(url), mode: mode);

  /// `tel:` links strip formatting characters, which break dialers on Android.
  Future<bool> openPhone(String number) => _open(
    Uri(scheme: 'tel', path: number.replaceAll(RegExp(r'[^0-9+]'), '')),
  );

  /// Opens a `tel:` URI that is already normalised (see `PhoneNumbers.telUri`).
  ///
  /// Separate from [openPhone] so the Call button can hand over the exact
  /// international number — `tel:+251917928950` — instead of letting a second
  /// sanitiser strip the `+` the dialer needs for a country code.
  Future<bool> openTel(Uri uri) => _open(uri);

  Future<bool> openEmail(String address, {String? subject, String? body}) =>
      _open(
        Uri(
          scheme: 'mailto',
          path: address,
          queryParameters: <String, String>{
            if (subject != null) 'subject': subject,
            if (body != null) 'body': body,
          },
        ),
      );

  Future<bool> openSms(String number) => _open(
    Uri(scheme: 'sms', path: number.replaceAll(RegExp(r'[^0-9+]'), '')),
  );

  /// `wa.me` requires a digits-only number with country code (no `+`).
  Future<bool> openWhatsApp(String number, {String? message}) {
    final String digits = number.replaceAll(RegExp(r'[^0-9]'), '');
    return _open(
      Uri.https('wa.me', '/$digits', <String, String>{
        if (message != null && message.isNotEmpty) 'text': message,
      }),
    );
  }

  /// Accepts `@handle`, `handle` or a full `t.me/...` URL.
  Future<bool> openTelegram(String value, {String? message}) {
    final String handle = value
        .trim()
        .replaceAll(RegExp(r'^(https?://)?(www\.)?(t\.me|telegram\.me)/'), '')
        .replaceAll('@', '');
    return _open(
      Uri.https('t.me', '/$handle', <String, String>{
        if (message != null && message.isNotEmpty) 'text': message,
      }),
    );
  }

  Future<bool> openMaps(String query) => _open(
    Uri.https('www.google.com', '/maps/search/', <String, String>{'q': query}),
  );

  Future<bool> openInstagram(String handle) => _open(
    Uri.https('instagram.com', '/${handle.trim().replaceAll('@', '')}'),
  );

  Future<bool> openFacebook(String handle) =>
      _open(Uri.https('facebook.com', '/${handle.trim().replaceAll('@', '')}'));

  Future<bool> openTikTok(String handle) =>
      _open(Uri.https('tiktok.com', '/@${handle.trim().replaceAll('@', '')}'));

  Future<bool> openYouTube(String handleOrUrl) {
    final String v = handleOrUrl.trim();
    if (v.startsWith('http')) return _open(Uri.parse(v));
    final String handle = v.replaceAll('@', '');
    return _open(
      handle.startsWith('UC')
          ? Uri.https('youtube.com', '/channel/$handle')
          : Uri.https('youtube.com', '/@$handle'),
    );
  }

  /// Opens whatever a free-form `other` contact link contains.
  Future<bool> openRaw(String value) {
    final String v = value.trim();
    if (v.startsWith('http://') || v.startsWith('https://')) {
      return _open(Uri.parse(v));
    }
    // The admin link validator also accepts these two intent schemes; without
    // this branch a saved tel:/mailto: link would be a dead button.
    if (v.startsWith('tel:') || v.startsWith('mailto:')) {
      return _open(Uri.parse(v));
    }
    // Bare domains and handles: try once as https, then give up gracefully.
    if (RegExp(r'^[\w.-]+\.[a-z]{2,}(/.*)?$').hasMatch(v)) {
      return _open(Uri.parse('https://$v'));
    }
    return Future<bool>.value(false);
  }

  /// Native share sheet. On iPad `sharePositionOrigin` is required, which the
  /// caller supplies from the tapped widget's render box.
  Future<ShareResult> share({
    required String text,
    String? subject,
    Rect? sharePositionOrigin,
  }) => Share.share(
    text,
    subject: subject,
    sharePositionOrigin: sharePositionOrigin,
  );

  /// Shares a product deep link together with a short message.
  Future<ShareResult> shareProduct({
    required String title,
    required String url,
    String? price,
    Rect? sharePositionOrigin,
  }) => Share.share(
    <String>[title, if (price != null) price, '', url].join('\n'),
    sharePositionOrigin: sharePositionOrigin,
  );
}

/// Overridden in tests with a fake [LinkLauncher].
@Riverpod(keepAlive: true)
LinkLauncher linkLauncher(Ref ref) => LinkLauncher();
