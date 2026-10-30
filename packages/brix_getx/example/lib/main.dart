import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'routes.dart';

/// brix + GetX demo: login, signup with a code, forgot / reset password,
/// logout. No server needed, see `demo/demo_auth_provider.dart`.
///
/// Demo account: demo@brix.dev / Demo@1234. Every code: 123456.
void main() => runApp(const BrixExampleApp());

class BrixExampleApp extends StatelessWidget {
  const BrixExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'brix example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      initialRoute: Routes.splash,
      getPages: Routes.pages,
    );
  }
}
