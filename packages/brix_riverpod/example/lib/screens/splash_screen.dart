import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

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
    // Keeps the session notifier alive while the splash is open.
    ref.watch(sessionProvider);
    return const Scaffold(body: BrixLoader(radius: 14));
  }
}
