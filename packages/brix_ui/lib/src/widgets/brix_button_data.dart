import 'package:flutter/widgets.dart';

import 'brix_button_style.dart';
import 'brix_button_variant.dart';

/// Builds an app's own button from what `BrixButton` knows. brix keeps the
/// logic (double-tap guard, haptic, disabled while loading); the builder
/// only draws.
typedef BrixButtonBuilder = Widget Function(
  BuildContext context,
  BrixButtonData button,
);

/// Everything a [BrixButtonBuilder] needs to draw a button.
class BrixButtonData {
  const BrixButtonData({
    required this.label,
    required this.variant,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
    required this.style,
    required this.expand,
    this.icon,
  });

  /// As written; already in capitals when the style says `upperCase`.
  final String label;

  final IconData? icon;
  final BrixButtonVariant variant;
  final bool isLoading;

  /// `false` when the app passed no `onPressed`. A loading button is still
  /// enabled (it should not look faded), but [onPressed] is `null`.
  final bool isEnabled;

  /// Call on tap. `null` while loading or disabled; runs the haptic first.
  final VoidCallback? onPressed;

  /// The theme's button style with the button's own on top.
  final BrixButtonStyle style;

  /// Should take the full width.
  final bool expand;
}
