import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// One saved account of the local backend.
class LocalAccount {
  const LocalAccount({
    required this.name,
    required this.password,
    required this.verified,
  });

  factory LocalAccount.fromJson(Map<String, dynamic> json) => LocalAccount(
    name: json['name'] as String? ?? '',
    password: json['password'] as String? ?? '',
    verified: json['verified'] as bool? ?? false,
  );

  final String name;
  final String password;
  final bool verified;

  LocalAccount copyWith({String? name, String? password, bool? verified}) =>
      LocalAccount(
        name: name ?? this.name,
        password: password ?? this.password,
        verified: verified ?? this.verified,
      );

  Map<String, Object?> toJson() => {
    'name': name,
    'password': password,
    'verified': verified,
  };
}

/// The local backend's accounts, kept in a file on this device only: what
/// one tester changes never reaches another device. Starts with the demo
/// account. Only `main_development.dart` uses it.
class LocalAccountsService {
  /// The file is set in tests; on the web the data stays in memory.
  LocalAccountsService([this._file]);

  static const demoEmail = 'demo@brix.dev';
  static const demoPassword = 'Demo@1234';
  static const demoCode = '123456';

  File? _file;
  Map<String, LocalAccount>? _accounts;

  static Map<String, LocalAccount> _seed() => {
    demoEmail: const LocalAccount(
      name: 'Demo',
      password: demoPassword,
      verified: true,
    ),
  };

  Future<Map<String, LocalAccount>> _load() async {
    if (_accounts != null) return _accounts!;
    final file = await _resolveFile();
    if (file != null && file.existsSync()) {
      try {
        final json =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        return _accounts = json.map(
          (email, data) => MapEntry(
            email,
            LocalAccount.fromJson(data as Map<String, dynamic>),
          ),
        );
      } catch (_) {
        // A broken file starts over.
      }
    }
    return _accounts = _seed();
  }

  Future<File?> _resolveFile() async {
    if (_file != null || kIsWeb) return _file;
    final dir = await getApplicationSupportDirectory();
    return _file = File('${dir.path}/brix_local_backend.json');
  }

  Future<void> _save() async {
    final file = await _resolveFile();
    if (file == null) return;
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(
      jsonEncode(_accounts!.map((email, a) => MapEntry(email, a.toJson()))),
    );
  }

  Future<LocalAccount?> find(String email) async => (await _load())[email];

  Future<void> put(String email, LocalAccount account) async {
    (await _load())[email] = account;
    await _save();
  }

  Future<void> remove(String email) async {
    (await _load()).remove(email);
    await _save();
  }

  /// Back to only the demo account, on this device.
  Future<void> reset() async {
    _accounts = _seed();
    await _save();
  }
}
