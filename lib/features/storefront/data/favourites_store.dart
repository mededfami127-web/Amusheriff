import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The customer's favourites, kept on the device.
///
/// A favourite is a personal bookmark, not shop content: there is no account to
/// attach it to on the storefront, so it lives in the same encrypted store as
/// the language choice and survives a restart. Storing ids rather than products
/// means a favourite always renders the *current* price, photo and availability
/// from the live catalogue stream.
class FavouritesStore {
  FavouritesStore(this._storage, {this.initial = const <String>{}});

  final FlutterSecureStorage _storage;

  /// Ids restored during `bootstrap()`.
  Set<String> initial;

  static const String _key = 'asm.favourites';

  Set<String> _ids = <String>{};

  Set<String> get ids => _ids;

  /// Called once from `bootstrap()`. Never throws: an unreadable store simply
  /// starts empty.
  Future<void> load() async {
    try {
      final String? raw = await _storage.read(key: _key);
      _ids = _parse(raw);
    } catch (_) {
      _ids = <String>{...initial};
    }
    initial = _ids;
  }

  /// Adds or removes [productId]. Returns the new state for that id.
  Future<bool> toggle(String productId) async {
    final Set<String> next = <String>{..._ids};
    final bool added = next.add(productId);
    if (!added) next.remove(productId);
    _ids = next;
    await _persist();
    return added;
  }

  Future<void> clear() async {
    _ids = <String>{};
    await _persist();
  }

  Future<void> _persist() async {
    try {
      await _storage.write(key: _key, value: _ids.join(','));
    } catch (_) {
      // Persisting is best-effort; the in-memory value still applies.
    }
  }

  static Set<String> _parse(String? raw) {
    final String value = raw ?? '';
    if (value.isEmpty) return <String>{};
    return value
        .split(',')
        .map((String id) => id.trim())
        .where((String id) => id.isNotEmpty)
        .toSet();
  }
}
