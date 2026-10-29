import 'package:flutter/widgets.dart';

import '../theme/brix_icon.dart';
import 'brix_alert_button.dart';
import 'brix_alert_style.dart';

/// Builds an app's own alert card. brix keeps the rest: the dimmed screen,
/// the animation, closing, returning the tapped value and replacing an
/// open warning / error.
typedef BrixAlertBuilder = Widget Function(
  BuildContext context,
  BrixAlertData alert,
);

/// Everything a [BrixAlertBuilder] needs to draw an alert.
class BrixAlertData {
  const BrixAlertData({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
    required this.content,
    required this.buttons,
    required this.onPressed,
    required this.style,
  });

  final String title;
  final String? message;
  final BrixIcon? icon;

  /// The icon colour (warning, danger, primary…).
  final Color accent;

  /// The app's own widget under the message, if any.
  final Widget? content;

  final List<BrixAlertButton<Object?>> buttons;

  /// Call with the tapped button's `value` – closes the alert.
  final ValueChanged<Object?> onPressed;

  /// The theme's alert style with the alert's own on top.
  final BrixAlertStyle style;
}
