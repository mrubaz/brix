import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// A tab of the bottom bar: a large title, a short line under it and its
/// content, scrolling like an iOS screen. No back button.
class TabPage extends StatelessWidget {
  const TabPage({
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
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
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
    );
  }
}
