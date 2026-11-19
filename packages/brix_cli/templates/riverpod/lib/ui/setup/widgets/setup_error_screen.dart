import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/setup_steps.dart';

/// Shown instead of the app when it cannot start safely (no API, or an
/// unsafe one in a release build). Never shows a login without a backend.
/// Lists the setup steps under the problem.
class SetupErrorScreen extends StatelessWidget {
  const SetupErrorScreen({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: BrixTheme.light().toThemeData(),
      home: Builder(
        builder: (context) {
          final brix = context.brix;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brix.icons.warning.build(
                      color: brix.colors.warning,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'The app is not set up',
                      style: brix.typography.title.copyWith(
                        color: brix.colors.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      message,
                      style: brix.typography.body.copyWith(
                        color: brix.colors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SetupSteps(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
