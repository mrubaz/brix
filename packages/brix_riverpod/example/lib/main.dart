import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_keys.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

/// brix + Riverpod demo with brix_ui screens: login, signup with a code,
/// forgot / reset password, logout. No server needed, see
/// `demo/demo_auth_provider.dart`.
///
/// Demo account: demo@brix.dev / Demo@1234. Every code: 123456.
void main() => runApp(const ProviderScope(child: BrixExampleApp()));

class BrixExampleApp extends StatelessWidget {
  const BrixExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    BrixUi.navigatorKey = AppKeys.navigator;
    return MaterialApp(
      title: 'brix example',
      debugShowCheckedModeBanner: false,
      navigatorKey: AppKeys.navigator,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      initialRoute: Routes.splash,
      onGenerateRoute: Routes.build,
    );
  }
}
