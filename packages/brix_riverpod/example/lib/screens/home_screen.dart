import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';

/// Your app starts here. Replace it with your first screen.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brix = context.brix;
    final session = ref.watch(sessionProvider);
    final notifier = ref.read(sessionProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            Text(
              'Home',
              style: brix.typography.title.copyWith(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: brix.colors.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'You are logged in.',
              style: brix.typography.body.copyWith(
                fontSize: 17,
                color: brix.colors.mutedText,
              ),
            ),
            const SizedBox(height: 28),
            BrixButton.outlined(
              label: 'Log out',
              isLoading: session.isLoggingOut,
              onPressed: notifier.logout,
            ),
          ],
        ),
      ),
    );
  }
}
