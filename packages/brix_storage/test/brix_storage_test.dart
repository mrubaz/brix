import 'package:brix/auth.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _BrokenSecrets extends MemoryStore {
  int reads = 0;

  @override
  Future<String?> read(String key) async {
    reads++;
    throw StateError('Failed to unwrap key');
  }
}

class _User {
  _User(this.id);
  factory _User.fromJson(Map<String, dynamic> json) =>
      _User(json['id'] as String);
  final String id;
  Map<String, dynamic> toJson() => {'id': id};
}

void main() {
  late MemoryStore values;
  late MemoryStore secrets;
  late List<Object> errors;
  late BrixStorage storage;

  setUp(() {
    values = MemoryStore();
    secrets = MemoryStore();
    errors = [];
    storage = BrixStorage(
      values: values,
      secrets: secrets,
      onError: (error, _) => errors.add(error),
    );
  });

  group('secrets', () {
    test(
      'written secrets are read back, from memory after the first read',
      () async {
        await storage.writeSecret('token', 't1');
        secrets.values['token'] = 'changed underneath';

        expect(await storage.readSecret('token'), 't1');
        expect(values.values['brix.installed'], 'true');
      },
    );

    test('reinstall: secrets without the install marker are wiped', () async {
      secrets.values['token'] = 'old user token'; // Keychain survived

      expect(await storage.readSecret('token'), isNull);
      expect(secrets.values, isEmpty);
    });

    test('a broken keystore gives null, never a crash', () async {
      final broken = _BrokenSecrets();
      values.values['brix.installed'] = 'true';
      storage = BrixStorage(
        values: values,
        secrets: broken,
        onError: (error, _) => errors.add(error),
      );

      expect(await storage.readSecret('token'), isNull);
      expect(errors.single, isA<StateError>());
    });

    test(
      'a secret an older version kept as a plain value moves once',
      () async {
        values.values['apiToken'] = 'legacy';

        expect(await storage.readSecret('apiToken'), 'legacy');
        expect(values.values.containsKey('apiToken'), isFalse);
        expect(secrets.values['apiToken'], 'legacy');
      },
    );

    test('delete and clear also empty the memory cache', () async {
      await storage.writeSecret('token', 't1');
      await storage.write('name', 'Ada');
      await storage.deleteSecret('token');
      expect(await storage.readSecret('token'), isNull);

      await storage.writeSecret('token', 't2');
      await storage.clear();
      expect(values.values, isEmpty);
      expect(secrets.values, isEmpty);
      expect(await storage.readSecret('token'), isNull);
    });
  });

  test('JSON values; a broken one reads as null', () async {
    await storage.writeJson('user', {'id': 'u1'});
    expect(await storage.readJson('user'), {'id': 'u1'});

    values.values['user'] = '{not json';
    expect(await storage.readJson('user'), isNull);
    expect(errors, hasLength(1));
  });

  group('BrixSessionStore', () {
    BrixSessionStore<_User> store([SessionKeys keys = const SessionKeys()]) =>
        BrixSessionStore(
          storage: storage,
          userToJson: (user) => user.toJson(),
          userFromJson: _User.fromJson,
          keys: keys,
        );

    test('session saved and read back; logout keeps remember me', () async {
      await store().saveSession(
        AuthSession(accessToken: 't1', user: _User('u1'), refreshToken: 'r1'),
      );
      await store().saveRememberedCredentials(
        const RememberedCredentials(identifier: 'a@b.com', password: 'pw'),
      );
      await store().savePendingIdentifier('a@b.com');

      final session = await store().readSession();
      expect(session?.accessToken, 't1');
      expect(session?.refreshToken, 'r1');
      expect(session?.user.id, 'u1');
      expect(secrets.values['brix.rememberedPassword'], 'pw');
      expect(values.values.values, isNot(contains('pw')));

      await store().clearSession();
      expect(await store().readSession(), isNull);
      expect(await store().readPendingIdentifier(), isNull);
      expect((await store().readRememberedCredentials())?.password, 'pw');

      await store().clearAll();
      expect(await store().readRememberedCredentials(), isNull);
    });

    test("an older version's keys keep its users logged in", () async {
      values.values.addAll({
        'hasSecureData': 'true',
        'user_data': '{"id":"u7"}',
        'apiToken': 'legacy-token', // plain, before secure storage
      });
      final legacy = BrixSessionStore<_User>(
        storage: BrixStorage(
          values: values,
          secrets: secrets,
          installMarkerKey: 'hasSecureData',
        ),
        userToJson: (user) => user.toJson(),
        userFromJson: _User.fromJson,
        keys: const SessionKeys(token: 'apiToken', user: 'user_data'),
      );

      final session = await legacy.readSession();

      expect(session?.accessToken, 'legacy-token');
      expect(session?.user.id, 'u7');
    });

    test('an unreadable user means no session', () async {
      await storage.writeSecret('brix.token', 't1');
      values.values['brix.user'] = '{"name":"no id"}';

      expect(await store().readSession(), isNull);
      expect(errors, isNotEmpty);
    });
  });
}
