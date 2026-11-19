import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// A page with a large title, a short line under it and its content, like
/// iOS screens.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: brix.typography.title.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                      color: brix.colors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: brix.typography.body.copyWith(
                      fontSize: 17,
                      color: brix.colors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...children,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
