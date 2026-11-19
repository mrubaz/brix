import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// What to do before the app goes live: on the home screen while
/// developing, and on the setup screen of a release build without an API.
class SetupSteps extends StatelessWidget {
  const SetupSteps({super.key});

  static const steps = [
    (
      title: 'Connect your API',
      text:
          'Put its address in lib/config/app_config.dart or env/*.json. '
          'Until then debug runs use a test backend on this device, and a '
          'release build stops at a setup screen.',
    ),
    (
      title: 'Match your backend',
      text:
          'Change the paths and fields in '
          'lib/data/repositories/*_remote.dart to your API.',
    ),
    (
      title: 'Make it your brand',
      text:
          'Colours, font and shapes live in lib/ui/core/themes/theme.dart. '
          'Every screen follows.',
    ),
    (
      title: 'Remove the test backend',
      text:
          'A release build never holds it or the demo account. To delete it: '
          'lib/dev, test/dev, test/app_test.dart and the lines marked '
          '"local test backend" in lib/main.dart.',
    ),
    (
      title: 'No login in your app?',
      text:
          'Delete lib/ui/auth, lib/ui/account and lib/ui/splash, their '
          'routes in lib/routing, and the account rows in Settings. Then '
          'start lib/routing/app_router.dart at Routes.home.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, step) in steps.indexed) ...[
          if (index > 0) const SizedBox(height: 12),
          BrixCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: brix.colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: brix.typography.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: brix.colors.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.title,
                        style: brix.typography.body.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: brix.colors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SelectableText(
                        step.text,
                        style: brix.typography.body.copyWith(
                          color: brix.colors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
