import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/view_models/session_viewmodel.dart';
import '../../core/widgets/app_logo.dart';

/// Asks brix where to start: a waiting code, a saved session or login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ref.read(sessionProvider.notifier).start(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Keeps the session view model alive while the splash is open.
    ref.watch(sessionProvider);
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
