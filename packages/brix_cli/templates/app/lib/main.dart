import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'config/app_config.dart';
import 'config/dependencies.dart';
import 'data/repositories/account_repository_remote.dart';
import 'data/repositories/auth_repository_remote.dart';
import 'routing/app_pages.dart';
import 'routing/routes.dart';
import 'ui/core/themes/theme.dart';
import 'ui/setup/widgets/setup_error_screen.dart';

/// The real app, on your API. Release builds start here, so nothing for
/// local testing is in them. Try the app without an API with
/// `flutter run -t lib/main_development.dart`.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    // Dialogs and toasts open from view models without a BuildContext.
    BrixUi.navigatorKey = Get.key;
    return GetMaterialApp(
      title: 'brix_app',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
    );
  }
}
