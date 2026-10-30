import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/models/user.dart';

/// Asks brix where to start: a waiting code, a saved session or login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => Get.find<BrixSessionController<User>>().start(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: BrixLoader(radius: 14));
  }
}
