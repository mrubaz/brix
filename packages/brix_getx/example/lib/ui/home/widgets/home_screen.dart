import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/tab_page.dart';

/// Your app starts here. Replace it with your first screen.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _steps = [
    (
      title: 'Connect your API',
      text:
          'Put its address in lib/config/app_config.dart. Until then the '
          'app runs on a test backend on this device.',
    ),
    (
      title: 'Make it your brand',
      text:
          'Colours, font and shapes live in lib/ui/core/themes/theme.dart. '
          'Every screen follows.',
    ),
    (
      title: 'Build your first screen',
      text:
          'Start in lib/ui/home/widgets/home_screen.dart. The Library tab '
          'shows every widget you can use.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return FutureBuilder(
      future: Dependencies.session.readSession(),
      builder: (context, snapshot) => TabPage(
        title: 'Welcome, ${snapshot.data?.user.name ?? ''}',
        subtitle: 'Your app runs. Three steps make it yours.',
        children: [
          for (var i = 0; i < _steps.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
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
                      '${i + 1}',
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
                          _steps[i].title,
                          style: brix.typography.body.copyWith(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: brix.colors.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _steps[i].text,
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
      ),
    );
  }
}
