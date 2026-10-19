import 'package:amu_sharif_majlis/features/admin/data/admin_gate_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

/// In-memory stand-in for the platform keystore: the store's contract is what
/// matters here, not the encryption underneath it.
class _FakeSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late Map<String, String> bytes;
  late AdminGateStore store;

  setUp(() {
    bytes = <String, String>{};
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

    store = AdminGateStore(storage);
  });

  group('shipped credentials', () {
    test('the first load seeds admin / admin123', () async {
      await store.load();

      expect(store.username, AdminGateStore.defaultUsername);
      expect(store.unlocked, isFalse, reason: 'a fresh install starts locked');
      expect(
        await store.unlock(
          username: AdminGateStore.defaultUsername,
          password: AdminGateStore.defaultPassword,
        ),
        isTrue,
      );
      expect(store.unlocked, isTrue);
    });

    test('the password is never written in the clear', () async {
      await store.load();

      expect(
        bytes.values.any(
          (String value) => value.contains(AdminGateStore.defaultPassword),
        ),
        isFalse,
        reason: 'only a salted digest may reach the keystore',
      );
      expect(bytes, contains('asm.admin.passwordHash'));
      expect(bytes, contains('asm.admin.salt'));
    });

    test(
      'the username is matched case-insensitively, the password is not',
      () async {
        await store.load();

        expect(
          await store.unlock(
            username: 'ADMIN',
            password: AdminGateStore.defaultPassword,
          ),
          isTrue,
        );
        expect(
          await store.unlock(
            username: 'admin',
            password: AdminGateStore.defaultPassword.toUpperCase(),
          ),
          isFalse,
        );
      },
    );

    test('a wrong password or username leaves the gate closed', () async {
      await store.load();

      expect(await store.unlock(username: 'admin', password: 'nope'), isFalse);
      expect(
        await store.unlock(username: 'owner', password: 'admin123'),
        isFalse,
      );
      expect(store.unlocked, isFalse);
      expect(bytes['asm.admin.unlocked'], isNot('true'));
    });
  });

  group('persistence', () {
    test('unlocking survives a reload, locking closes it again', () async {
      await store.load();
      await store.unlock(username: 'admin', password: 'admin123');

      final AdminGateStore reopened = AdminGateStore(_storageOf(bytes));
      await reopened.load();
      expect(reopened.unlocked, isTrue);

      await reopened.lock();
      final AdminGateStore again = AdminGateStore(_storageOf(bytes));
      await again.load();
      expect(again.unlocked, isFalse);
    });
  });

  group('owner account', () {
    test('only the linked e-mail is remembered, never a password', () async {
      await store.load();
      expect(store.ownerEmail, isEmpty);

      await store.saveOwnerEmail(' owner@example.com ');

      expect(store.ownerEmail, 'owner@example.com');
      final AdminGateStore reopened = AdminGateStore(_storageOf(bytes));
      await reopened.load();
      expect(reopened.ownerEmail, 'owner@example.com');
      expect(bytes.keys.where((String key) => key.contains('owner')), <String>[
        'asm.admin.ownerEmail',
      ], reason: 'the owner password must never reach the keystore');
    });
  });

  group('changing the password', () {
    test('requires the current password and then replaces it', () async {
      await store.load();

      expect(
        await store.changePassword(current: 'wrong', next: 'Str0ngPassw0rd'),
        isFalse,
      );
      expect(
        await store.changePassword(current: 'admin123', next: 'Str0ngPassw0rd'),
        isTrue,
      );

      expect(store.matches('admin123'), isFalse);
      expect(store.matches('Str0ngPassw0rd'), isTrue);
      expect(
        await store.unlock(username: 'admin', password: 'Str0ngPassw0rd'),
        isTrue,
      );
    });

    test('a changed password survives a reload', () async {
      await store.load();
      await store.changePassword(current: 'admin123', next: 'Str0ngPassw0rd');

      final AdminGateStore reopened = AdminGateStore(_storageOf(bytes));
      await reopened.load();
      expect(
        await reopened.unlock(username: 'admin', password: 'Str0ngPassw0rd'),
        isTrue,
      );
    });
  });

  group('digest', () {
    test('is salted, so one password hashes differently per device', () {
      final String a = AdminGateStore.digest('admin123', 'salt-a');
      final String b = AdminGateStore.digest('admin123', 'salt-b');

      expect(a, isNot(b));
      expect(a, AdminGateStore.digest('admin123', 'salt-a'));
      expect(AdminGateStore.newSalt(), isNot(AdminGateStore.newSalt()));
    });
  });
}

/// A second store over the same bytes, to prove values were persisted.
_FakeSecureStorage _storageOf(Map<String, String> bytes) {
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
  return storage;
}
