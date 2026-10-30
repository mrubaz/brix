import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where plain values live (settings, ids, cached JSON). Default:
/// [SharedPrefsStore]. Write your own to use Hive, a file, ...
abstract class ValueStore {
  const ValueStore();

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// Where secrets live (tokens, passwords). Default: [SecureSecretStore].
abstract class SecretStore {
  const SecretStore();

  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> clear();
}

/// [ValueStore] on `shared_preferences`. Values saved as another type
/// (an older app version's `bool` / `int`) are read as text.
class SharedPrefsStore extends ValueStore {
  const SharedPrefsStore();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String?> read(String key) async => (await _prefs).get(key)?.toString();

  @override
  Future<void> write(String key, String value) async =>
      (await _prefs).setString(key, value);

  @override
  Future<void> delete(String key) async => (await _prefs).remove(key);

  @override
  Future<void> clear() async => (await _prefs).clear();
}

/// [SecretStore] on `flutter_secure_storage` (Keychain / Keystore). On iOS
/// secrets are readable after the first unlock and never leave the device.
class SecureSecretStore extends SecretStore {
  const SecureSecretStore([
    this._storage = const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clear() => _storage.deleteAll();
}

/// In-memory stores for tests (and a plain [ValueStore] / [SecretStore]
/// example).
class MemoryStore implements ValueStore, SecretStore {
  MemoryStore([Map<String, String>? values]) : values = {...?values};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> clear() async => values.clear();
}
