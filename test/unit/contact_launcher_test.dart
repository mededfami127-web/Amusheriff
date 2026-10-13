import 'package:amu_sharif_majlis/core/utils/launcher.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/contact_launcher.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/entities/contact_kind.dart';
import 'package:amu_sharif_majlis/features/contacts/domain/entities/contact_link.dart';
import 'package:flutter_test/flutter_test.dart';

ContactLink _link(ContactKind kind, String value) => ContactLink(
      id: 'id',
      kind: kind,
      label: kind.name,
      value: value,
    );

void main() {
  // previewUrl is pure, so it can be asserted without a platform channel.
  final ContactLauncher launcher = ContactLauncher(LinkLauncher());

  group('WhatsApp', () {
    test('normalises the seeded numbers to digits-only wa.me links', () {
      expect(
        launcher.previewUrl(_link(ContactKind.whatsapp, '+251 917 928 950')),
        'https://wa.me/251917928950',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.whatsapp, '+251918959071')),
        'https://wa.me/251918959071',
      );
    });

    test('pre-fills the inquiry message', () {
      // `Uri.encodeComponent` leaves the unreserved marks `!`, `~`, `*`, `'`,
      // `(`, `)` alone, so `!` survives unescaped.
      expect(
        launcher.previewUrl(
          _link(ContactKind.whatsapp, '+251917928950'),
          message: 'Hello! I am interested in "Royal Majlis" (12,000 ETB).',
        ),
        contains('text=Hello!%20I%20am%20interested'),
      );
    });
  });

  group('Telegram', () {
    test('normalises the logo handle, including the "https;t.me" typo', () {
      // The logo artwork shows "https;t.me/amumejlisamusharif"; the seed data
      // normalises it, but the launcher must also cope with a pasted URL.
      expect(
        launcher.previewUrl(
          _link(ContactKind.telegram, 'https://t.me/amumejlisamusharif'),
        ),
        'https://t.me/amumejlisamusharif',
      );
      expect(
        launcher.previewUrl(
          _link(ContactKind.telegram, 'amumejlisamusharif'),
        ),
        'https://t.me/amumejlisamusharif',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.telegram, '@amumejlisamusharif')),
        'https://t.me/amumejlisamusharif',
      );
    });
  });

  group('other channels', () {
    test('phone uses a tel: intent with formatting stripped', () {
      expect(
        launcher.previewUrl(_link(ContactKind.phone, '+251 918 959 071')),
        'tel:+251918959071',
      );
    });

    test('email uses mailto:', () {
      expect(
        launcher.previewUrl(_link(ContactKind.email, 'sales@asm.et')),
        'mailto:sales@asm.et',
      );
    });

    test('social handles build canonical profile URLs', () {
      expect(
        launcher.previewUrl(_link(ContactKind.instagram, '@amusheriff')),
        'https://instagram.com/amusheriff',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.facebook, 'amusheriff')),
        'https://facebook.com/amusheriff',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.tiktok, '@amusheriff')),
        'https://tiktok.com/@amusheriff',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.youtube, 'amusheriff')),
        'https://youtube.com/@amusheriff',
      );
    });

    test('location opens a maps search', () {
      expect(
        launcher.previewUrl(_link(ContactKind.location, 'Jimma, Ethiopia')),
        'https://www.google.com/maps/search/?q=Jimma%2C%20Ethiopia',
      );
    });

    test('website accepts bare domains and full URLs', () {
      expect(
        launcher.previewUrl(_link(ContactKind.website, 'asm.et')),
        'https://asm.et',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.website, 'https://asm.et/shop')),
        'https://asm.et/shop',
      );
      expect(
        launcher.previewUrl(_link(ContactKind.website, 'not a domain')),
        isNull,
      );
    });
  });

  group('ContactKind', () {
    test('orders direct-message channels first for the product page', () {
      expect(ContactKind.whatsapp.actionPriority, lessThan(ContactKind.phone.actionPriority));
      expect(ContactKind.telegram.actionPriority, lessThan(ContactKind.phone.actionPriority));
      expect(ContactKind.whatsapp.isDirectMessageChannel, isTrue);
      expect(ContactKind.website.isDirectMessageChannel, isFalse);
    });
  });
}
