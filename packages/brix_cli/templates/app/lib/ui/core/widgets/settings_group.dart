import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// Rows in one white rounded card with thin lines between them, like the
/// iOS Settings app.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: brix.colors.surface,
        borderRadius: BorderRadius.circular(brix.shape.radius),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: 56,
                color: brix.colors.border,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}
