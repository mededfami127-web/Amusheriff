import 'dart:convert';

import 'package:amu_sharif_majlis/core/config/env.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a syntactically valid (unsigned) JWT carrying [role] in its payload,
/// the way Supabase's legacy anon / service-role keys are shaped.
String _jwtWithRole(String role) {
  String seg(Map<String, Object?> m) =>
      base64Url.encode(utf8.encode(jsonEncode(m))).replaceAll('=', '');
  return '${seg({'alg': 'HS256', 'typ': 'JWT'})}.'
      '${seg({'iss': 'supabase', 'ref': 'abcdefghijklmnop', 'role': role})}.'
      'c2lnbmF0dXJl';
}

void main() {
  group('Env.looksLikeServiceRoleKey', () {
    test('rejects a legacy service-role JWT', () {
      expect(Env.looksLikeServiceRoleKey(_jwtWithRole('service_role')), isTrue);
    });

    test('accepts a legacy anon JWT', () {
      expect(Env.looksLikeServiceRoleKey(_jwtWithRole('anon')), isFalse);
    });

    test('accepts a legacy authenticated JWT', () {
      expect(Env.looksLikeServiceRoleKey(_jwtWithRole('authenticated')), isFalse);
    });

    test('rejects a new-style sb_secret_ key', () {
      // The modern secret key is not a JWT, so it is caught by prefix.
      expect(Env.looksLikeServiceRoleKey('sb_secret_abc123'), isTrue);
    });

    test('accepts a new-style publishable key', () {
      expect(Env.looksLikeServiceRoleKey('sb_publishable_abc123'), isFalse);
    });

    test('does not throw on malformed input', () {
      for (final String bad in <String>['', 'not-a-jwt', 'a.b', 'a.b.c.d', '..']) {
        expect(
          () => Env.looksLikeServiceRoleKey(bad),
          returnsNormally,
          reason: 'input: "$bad"',
        );
        expect(Env.looksLikeServiceRoleKey(bad), isFalse, reason: 'input: "$bad"');
      }
    });

    test('a malformed payload segment is treated as unclassified', () {
      // Three segments, but the middle one is not base64url-encoded JSON.
      expect(Env.looksLikeServiceRoleKey('aaa.!!!not-base64!!!.ccc'), isFalse);
    });

    test('a JWT whose payload is not a JSON object is unclassified', () {
      final String seg = base64Url.encode(utf8.encode('[1,2,3]')).replaceAll('=', '');
      expect(Env.looksLikeServiceRoleKey('aaa.$seg.ccc'), isFalse);
    });

    test('role must match exactly — no substring or case folding', () {
      expect(Env.looksLikeServiceRoleKey(_jwtWithRole('service_role_v2')), isFalse);
      expect(Env.looksLikeServiceRoleKey(_jwtWithRole('SERVICE_ROLE')), isFalse);
    });
  });
}
