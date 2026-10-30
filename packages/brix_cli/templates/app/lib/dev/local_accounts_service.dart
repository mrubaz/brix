import 'dart:convert';

import 'local_box.dart';

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

/// The local backend's accounts, kept on this device only: what one tester
/// changes never reaches another device. Starts with the demo account.
/// Debug builds only (see `main.dart`).
class LocalAccountsService {
  /// [box] is set in tests.
  LocalAccountsService([LocalBox? box]) : _box = box ?? LocalBox();

  static const demoEmail = 'demo@brix.dev';
  static const demoPassword = 'Demo@1234';
  static const demoCode = '123456';

  final LocalBox _box;
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
    final text = await _box.read();
    if (text != null) {
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;
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

  Future<void> _save() => _box.write(
    jsonEncode(_accounts!.map((email, a) => MapEntry(email, a.toJson()))),
  );

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
