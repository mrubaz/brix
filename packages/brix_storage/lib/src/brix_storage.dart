import 'dart:convert';

import 'stores.dart';

/// One place for an app's local data: plain values and secrets.
///
/// Secrets are handled the safe way:
/// - **Reinstall (iOS):** the Keychain keeps secrets after the app is
///   deleted, plain values do not. Without the install marker the old
///   secrets are wiped, so a new install never logs in as the old user.
/// - **Broken Keystore (Android, after a backup restore):** a failed read
///   gives `null` instead of a crash; the error goes to [onError].
/// - **Older versions** that kept a secret as a plain value: it moves to
///   secret storage on the first read.
/// - Read secrets are cached in memory (a token is read on every call).
///
/// ```dart
/// final storage = BrixStorage();
/// await storage.writeSecret('token', token);
/// final token = await storage.readSecret('token');
/// await storage.writeJson('user', user.toJson());
/// ```
class BrixStorage {
  BrixStorage({
    ValueStore? values,
    SecretStore? secrets,
    this.installMarkerKey = 'brix.installed',
    this.onError,
  }) : values = values ?? const SharedPrefsStore(),
       secrets = secrets ?? const SecureSecretStore();

  final ValueStore values;
  final SecretStore secrets;

  /// Plain value that says secrets were written by this install.
  final String installMarkerKey;

  /// Storage problems that were handled (logged, not thrown).
  final void Function(Object error, StackTrace stackTrace)? onError;

  final _cache = <String, String?>{};

  // ------------------------------------------------------------- values

  Future<String?> read(String key) => values.read(key);

  Future<void> write(String key, String value) => values.write(key, value);

  Future<void> delete(String key) => values.delete(key);

  /// A JSON object saved with [writeJson]; `null` when missing or broken.
  Future<Map<String, dynamic>?> readJson(String key) async {
    final text = await values.read(key);
    if (text == null) return null;
    try {
      final decoded = jsonDecode(text);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> json) =>
      values.write(key, jsonEncode(json));

  // ------------------------------------------------------------ secrets

  Future<String?> readSecret(String key) async {
    if (_cache.containsKey(key)) return _cache[key];
    final value = await _readSecret(key);
    _cache[key] = value;
    return value;
  }

  Future<void> writeSecret(String key, String value) async {
    await secrets.write(key, value);
    await values.write(installMarkerKey, 'true');
    _cache[key] = value;
  }

  Future<void> deleteSecret(String key) async {
    _cache.remove(key);
    try {
      await secrets.delete(key);
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
    }
  }

  /// Deletes every value and secret (e.g. account deleted).
  Future<void> clear() async {
    _cache.clear();
    await values.clear();
    try {
      await secrets.clear();
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
    }
  }

  Future<String?> _readSecret(String key) async {
    final legacy = await values.read(key);
    if (legacy != null) {
      try {
        await writeSecret(key, legacy);
        await values.delete(key);
      } catch (error, stackTrace) {
        // Keep the plain copy so the move is tried again next time.
        onError?.call(error, stackTrace);
      }
      return legacy;
    }
    try {
      if (await values.read(installMarkerKey) == null) {
        await secrets.clear();
        return null;
      }
      return await secrets.read(key);
    } catch (error, stackTrace) {
      onError?.call(error, stackTrace);
      return null;
    }
  }
}
