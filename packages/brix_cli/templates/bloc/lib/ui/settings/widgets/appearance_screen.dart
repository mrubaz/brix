import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/settings_group.dart';
import '../../core/widgets/settings_row.dart';
import '../view_models/appearance_viewmodel.dart';

/// Light, dark or the same as the phone. The choice is kept.
class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key});

  static const _choices = [
    (mode: ThemeMode.light, icon: Icons.light_mode_rounded, label: 'Light'),
    (mode: ThemeMode.dark, icon: Icons.dark_mode_rounded, label: 'Dark'),
    (
      mode: ThemeMode.system,
      icon: Icons.phone_iphone_rounded,
      label: 'Same as the phone',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final mode = context.watch<AppearanceViewModel>().state;
    return AuthPage(
      title: 'Appearance',
      subtitle: 'Light, dark, or the same as your phone.',
      children: [
        SettingsGroup(
          children: [
            for (final choice in _choices)
              SettingsRow(
                icon: choice.icon,
                label: choice.label,
                iconColor: const Color(0xFF5856D6),
                onTap: () =>
                    context.read<AppearanceViewModel>().select(choice.mode),
                trailing: Icon(
                  Icons.check_rounded,
                  color: mode == choice.mode
                      ? brix.colors.primary
                      : Colors.transparent,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
