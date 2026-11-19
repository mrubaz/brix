import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dependencies.dart';
import '../../../routing/routes.dart';
import '../../core/view_models/session_viewmodel.dart';
import '../../core/widgets/settings_group.dart';
import '../../core/widgets/settings_row.dart';
import '../../core/widgets/tab_page.dart';

/// Account, look and app info, grouped like the iOS Settings app.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return TabPage(
      title: 'Settings',
      subtitle: 'Your account and how the app looks.',
      children: [
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.person_rounded,
              label: 'Profile',
              onTap: () => context.go(Routes.profile),
            ),
            SettingsRow(
              icon: Icons.lock_rounded,
              label: 'Change password',
              iconColor: const Color(0xFF8E8E93),
              onTap: () => context.go(Routes.changePassword),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.dark_mode_rounded,
              label: 'Appearance',
              iconColor: const Color(0xFF5856D6),
              onTap: () => context.go(Routes.appearance),
            ),
            SettingsRow(
              icon: Icons.info_rounded,
              label: 'About',
              iconColor: const Color(0xFF8E8E93),
              onTap: () => context.go(Routes.about),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SettingsGroup(
          children: [
            SettingsRow(
              icon: Icons.delete_rounded,
              label: 'Delete account',
              destructive: true,
              onTap: () async {
                final session = await Dependencies.session.readSession();
                if (context.mounted) {
                  context.go(Routes.deleteAccount, extra: session?.user.email);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        BrixButton.outlined(
          label: 'Log out',
          isLoading: session.isLoggingOut,
          onPressed: ref.read(sessionProvider.notifier).logout,
        ),
      ],
    );
  }
}
