import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The on-device owner gate.
///
/// Tapping the logo five times opens a small username/password panel. The
/// shipped credentials are `admin` / `admin123`; the owner can change the
/// password from the admin sidebar and the change is kept in the same encrypted
/// store that holds the session material.
///
/// **This is a convenience lock, not the security boundary.** It keeps the
/// gateway out of a customer's way on a shared device. Everything behind it is
/// still protected by Supabase Auth and RLS: the storefront reads published rows
/// through the anon key, and every write requires a signed-in administrator.
/// The password is never stored in the clear — a random per-device salt and its
/// SHA-256 digest are what land on disk.
class AdminGateStore {
  AdminGateStore(this._storage);

  final FlutterSecureStorage _storage;

  /// Shipped credentials, used until the owner changes the password.
  static const String defaultUsername = 'admin';
  static const String defaultPassword = 'admin123';

  static const String _usernameKey = 'asm.admin.username';
  static const String _saltKey = 'asm.admin.salt';
  static const String _hashKey = 'asm.admin.passwordHash';
  static const String _unlockedKey = 'asm.admin.unlocked';
  static const String _ownerEmailKey = 'asm.admin.ownerEmail';

  String _username = defaultUsername;
  String _salt = '';
  String _hash = '';
  bool _unlocked = false;
  String _ownerEmail = '';

  String get username => _username;

  /// Whether the owner has already entered the gateway on this device.
  bool get unlocked => _unlocked;

  /// The shop owner's Supabase e-mail, remembered so the panel does not have to
  /// be retyped on every re-link. The password is never stored here: the
  /// session Supabase keeps is what carries the JWT.
  String get ownerEmail => _ownerEmail;

  /// Called once from `bootstrap()`. Never throws: an unreadable keystore falls
  /// back to the shipped credentials with the gate closed.
  Future<void> load() async {
    try {
      _username = await _storage.read(key: _usernameKey) ?? defaultUsername;
      _salt = await _storage.read(key: _saltKey) ?? '';
      _hash = await _storage.read(key: _hashKey) ?? '';
      _unlocked = (await _storage.read(key: _unlockedKey)) == 'true';
      _ownerEmail = await _storage.read(key: _ownerEmailKey) ?? '';

      if (_salt.isEmpty || _hash.isEmpty) await _seedDefaults();
    } catch (_) {
      _salt = 'asm-unreadable-keystore';
      _hash = digest(defaultPassword, _salt);
      _unlocked = false;
    }
  }

  /// `true` when the pair matches the stored credentials.
  Future<bool> unlock({
    required String username,
    required String password,
  }) async {
    final bool ok =
        username.trim().toLowerCase() == _username.toLowerCase() &&
        matches(password);
    if (!ok) return false;

    _unlocked = true;
    await _write(_unlockedKey, 'true');
    return true;
  }

  /// Closes the gateway again (used by “sign out”).
  Future<void> lock() async {
    _unlocked = false;
    await _write(_unlockedKey, 'false');
  }

  /// Replaces the password after checking the current one.
  Future<bool> changePassword({
    required String current,
    required String next,
  }) async {
    if (!matches(current)) return false;

    _salt = newSalt();
    _hash = digest(next, _salt);
    await _write(_saltKey, _salt);
    await _write(_hashKey, _hash);
    return true;
  }

  /// Whether [candidate] is the current password.
  bool matches(String candidate) => digest(candidate, _salt) == _hash;

  /// Remembers the owner account that was just signed in, so the next re-link
  /// only needs its password.
  Future<void> saveOwnerEmail(String email) async {
    _ownerEmail = email.trim();
    await _write(_ownerEmailKey, _ownerEmail);
  }

  Future<void> _seedDefaults() async {
    _username = defaultUsername;
    _salt = newSalt();
    _hash = digest(defaultPassword, _salt);
    await _write(_usernameKey, _username);
    await _write(_saltKey, _salt);
    await _write(_hashKey, _hash);
  }

  Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      // Persisting is best-effort; the in-memory value still applies.
    }
  }

  /// `sha256(salt:password)` as hex.
  static String digest(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  /// A fresh 16-byte random salt, so the same password never hashes the same
  /// way on two devices.
  static String newSalt() {
    final Random random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }
}
