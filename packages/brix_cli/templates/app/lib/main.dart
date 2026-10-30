import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/dependencies.dart';
import 'data/repositories/account_repository_remote.dart';
import 'data/repositories/auth_repository_remote.dart';
import 'dev/local_backend.dart'; // local test backend
import 'ui/core/themes/theme.dart';
import 'ui/setup/widgets/setup_error_screen.dart';

/// Runs on your API (`lib/config/app_config.dart`).
///
/// Without an API, debug builds run on a local test backend (`lib/dev`) so
/// every screen works on day one. Release builds never contain it: the
/// compiler drops code behind `kDebugMode`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode && AppConfig.apiUrl.isEmpty) {
    startWithLocalBackend(); // local test backend
    runApp(const App());
    return;
  }
  final problem = AppConfig.problem();
  if (problem != null) {
    runApp(SetupErrorScreen(message: problem));
    return;
  }
  Dependencies.init(
    apiUrl: AppConfig.apiUrl,
    backend: (api, session) => (
      auth: AuthRepositoryRemote(api),
      account: AccountRepositoryRemote(api),
    ),
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'brix_app',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: Dependencies.router,
    );
  }
}
