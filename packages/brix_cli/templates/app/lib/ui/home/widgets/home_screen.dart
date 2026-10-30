import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/settings_group.dart';
import '../../core/widgets/settings_row.dart';

/// Your app starts here. Replace it with your first screen.
class HomeScreen extends GetView<BrixSessionController<User>> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            FutureBuilder(
              future: Dependencies.session.readSession(),
              builder: (context, snapshot) => Text(
                'Hello ${snapshot.data?.user.name ?? ''}',
                style: brix.typography.title.copyWith(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: brix.colors.text,
                ),
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
            SettingsGroup(
              children: [
                SettingsRow(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  onTap: () => Get.toNamed(Routes.profile),
                ),
                SettingsRow(
                  icon: Icons.lock_rounded,
                  label: 'Change password',
                  iconColor: const Color(0xFF8E8E93),
                  onTap: () => Get.toNamed(Routes.changePassword),
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
                    Get.toNamed(
                      Routes.deleteAccount,
                      arguments: session?.user.email,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            Obx(
              () => BrixButton.outlined(
                label: 'Log out',
                isLoading: controller.isLoggingOut.value,
                onPressed: controller.logout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
