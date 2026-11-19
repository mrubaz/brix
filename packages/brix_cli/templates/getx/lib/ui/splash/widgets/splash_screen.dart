import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/models/user.dart';
import '../../core/widgets/app_logo.dart';

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
    final brix = context.brix;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 88),
            const SizedBox(height: 16),
            Text(
              'brix',
              style: brix.typography.title.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                color: brix.colors.text,
              ),
            ),
            const SizedBox(height: 40),
            const BrixLoader(radius: 11),
          ],
        ),
      ),
    );
  }
}
