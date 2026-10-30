import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/brix_theme_context.dart';

/// The card behind dialogs and toasts: solid `colors.surface` with a soft
/// shadow, or frosted when the theme has `glass` on. Internal to brix_ui.
class BrixPanel extends StatelessWidget {
  const BrixPanel({
    super.key,
    required this.child,
    required this.padding,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Default: `shape.radius + 6`.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final radius = BorderRadius.circular(this.radius ?? brix.shape.radius + 6);
    final shadow = BoxShadow(
      color: const Color(0x29000000),
      blurRadius: 30,
      offset: const Offset(0, 12),
    );

    if (!brix.glass) {
      return Container(
        padding: padding,
        decoration: BoxDecoration(
          color: brix.colors.surface,
          borderRadius: radius,
          boxShadow: [shadow],
        ),
        child: child,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: [shadow]),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: brix.colors.surface.withValues(alpha: 0.8),
              borderRadius: radius,
              border: Border.all(
                color: brix.colors.border.withValues(alpha: 0.4),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
