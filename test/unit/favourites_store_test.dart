import 'package:amu_sharif_majlis/features/storefront/data/favourites_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late Map<String, String> bytes;
  late FavouritesStore store;

  FavouritesStore build() {
    final _FakeSecureStorage storage = _FakeSecureStorage();
    when(() => storage.read(key: any(named: 'key'))).thenAnswer(
      (Invocation invocation) async =>
          bytes[invocation.namedArguments[#key] as String],
    );
    when(
      () => storage.write(
        key: any(named: 'key'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((Invocation invocation) async {
      bytes[invocation.namedArguments[#key] as String] =
          invocation.namedArguments[#value] as String;
    });
    return FavouritesStore(storage);
  }

  setUp(() {
    bytes = <String, String>{};
    store = build();
  });

  test('starts empty and survives a restart', () async {
    await store.load();
    expect(store.ids, isEmpty);

    expect(await store.toggle('p1'), isTrue, reason: 'p1 was added');
    expect(await store.toggle('p2'), isTrue);

    final FavouritesStore reopened = build();
    await reopened.load();
    expect(reopened.ids, <String>{'p1', 'p2'});
  });

  test('toggling the same piece twice removes it', () async {
    await store.load();

    expect(await store.toggle('p1'), isTrue);
    expect(store.ids, <String>{'p1'});
    expect(await store.toggle('p1'), isFalse);
    expect(store.ids, isEmpty);

    final FavouritesStore reopened = build();
    await reopened.load();
    expect(reopened.ids, isEmpty);
  });

  test('clear() empties the list and is persisted', () async {
    await store.load();
    await store.toggle('p1');
    await store.toggle('p2');

    await store.clear();
    expect(store.ids, isEmpty);

    final FavouritesStore reopened = build();
    await reopened.load();
    expect(reopened.ids, isEmpty);
  });

  test('a corrupt value degrades to an empty list, not a crash', () async {
    bytes['asm.favourites'] = ',,';
    await store.load();
    expect(store.ids, isEmpty);
  });
}
