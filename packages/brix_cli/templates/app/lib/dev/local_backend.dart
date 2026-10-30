import 'package:brix/auth.dart';
import 'package:brix_storage/brix_storage.dart';

import '../config/dependencies.dart';
import '../config/dev_tools.dart';
import '../domain/models/user.dart';
import 'account_repository_local.dart';
import 'auth_repository_local.dart';
import 'local_accounts_service.dart';

/// Sets the app up on a backend that lives on this device, so every screen
/// works before your API exists. Each device keeps its own data.
///
/// `main.dart` calls this only in debug builds without an API. To drop it
/// (for example when you bring your own login), delete the `lib/dev`
/// folder and the lines marked `local test backend` in `main.dart`.
void startWithLocalBackend({
  LocalAccountsService? accounts,
  BrixStorage? storage,
}) {
  final backend = accounts ?? LocalAccountsService();
  Dependencies.init(
    apiUrl: '',
    storage: storage,
    backend: (api, session) => (
      auth: AuthRepositoryLocal(backend),
      account: AccountRepositoryLocal(backend, session),
    ),
    devTools: LocalDevTools(backend),
  );
}

/// The local backend's hints, skip and reset.
class LocalDevTools implements DevTools {
  LocalDevTools(this._accounts);

  final LocalAccountsService _accounts;

  @override
  String get loginHint =>
      'Test backend: ${LocalAccountsService.demoEmail} / '
      '${LocalAccountsService.demoPassword}';

  @override
  String get codeHint => 'Test backend code: ${LocalAccountsService.demoCode}';

  @override
  Future<void> skipLogin() async {
    await Dependencies.session.saveSession(
      const AuthSession(
        accessToken: 'local-token',
        user: User(
          id: LocalAccountsService.demoEmail,
          name: 'Demo',
          email: LocalAccountsService.demoEmail,
        ),
      ),
    );
    await Dependencies.navigator.toHome();
  }

  @override
  Future<void> resetLocalBackend() => _accounts.reset();
}
