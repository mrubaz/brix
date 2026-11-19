import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/app_logo.dart';
import '../../core/widgets/auth_page.dart';

/// About this app. It starts with how the app was made; write your own app's
/// story here.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _packages = [
    (name: 'brix_cli', about: 'made this app with one command'),
    (name: 'brix_ui', about: 'widgets and theme, light and dark'),
    (name: 'brix_getx', about: 'a controller for every account screen'),
    (name: 'brix_network', about: 'API calls that return a result'),
    (name: 'brix_storage', about: 'tokens and settings, kept safe'),
    (name: 'brix', about: 'the core: login, signup, account flows'),
  ];

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final muted = brix.typography.body.copyWith(color: brix.colors.mutedText);
    return AuthPage(
      title: 'About',
      subtitle: 'Made with brix, free Flutter packages (MIT).',
      children: [
        BrixCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(width: 12),
                  Text(
                    'brix',
                    style: brix.typography.title.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: brix.colors.text,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (final package in _packages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: package.name,
                          style: brix.typography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: brix.colors.text,
                          ),
                        ),
                        TextSpan(text: ': ${package.about}', style: muted),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SelectableText('github.com/mrubaz/brix', style: muted),
        const SizedBox(height: 4),
        SelectableText('pub.dev/packages/brix_cli', style: muted),
      ],
    );
  }
}
