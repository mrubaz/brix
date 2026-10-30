import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/dependencies.dart';
import 'config/dev_tools.dart';
import 'data/repositories/account_repository_local.dart';
import 'data/repositories/auth_repository_local.dart';
import 'data/services/local_accounts_service.dart';
import 'main.dart';

/// The app on a backend that lives on this device: try every screen before
/// your API exists. Each device keeps its own data.
///
/// ```
/// flutter run -t lib/main_development.dart
/// ```
///
/// Never in a release build: it stops at once if one is made from it.
void main() {
  if (kReleaseMode) {
    throw StateError(
      'main_development.dart runs a local test backend and cannot be used '
      'for a release build. Build from lib/main.dart.',
    );
  }
  WidgetsFlutterBinding.ensureInitialized();
  final accounts = LocalAccountsService();
  Dependencies.init(
    apiUrl: '',
    backend: (api, session) => (
      auth: AuthRepositoryLocal(accounts),
      account: AccountRepositoryLocal(accounts, session),
    ),
    devTools: LocalDevTools(accounts),
  );
  runApp(const App());
}

/// The local backend's hints and reset.
class LocalDevTools implements DevTools {
  LocalDevTools(this._accounts);

  final LocalAccountsService _accounts;

  @override
  String get loginHint =>
      'Local backend: ${LocalAccountsService.demoEmail} / '
      '${LocalAccountsService.demoPassword}';

  @override
  String get codeHint => 'Local backend code: ${LocalAccountsService.demoCode}';

  @override
  Future<void> resetLocalBackend() => _accounts.reset();
}
