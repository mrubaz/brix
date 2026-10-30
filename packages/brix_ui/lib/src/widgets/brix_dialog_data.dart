import 'package:flutter/widgets.dart';

import '../theme/brix_icon.dart';
import 'brix_dialog_button.dart';
import 'brix_dialog_style.dart';

/// Builds an app's own dialog card. brix keeps the rest: the dimmed screen,
/// the animation, closing, returning the tapped value and replacing an
/// open warning / error.
typedef BrixDialogBuilder = Widget Function(
  BuildContext context,
  BrixDialogData dialog,
);

/// Everything a [BrixDialogBuilder] needs to draw a dialog.
class BrixDialogData {
  const BrixDialogData({
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

  /// The icon colour (warning, danger, primary...).
  final Color accent;

  /// The app's own widget under the message, if any.
  final Widget? content;

  final List<BrixDialogButton<Object?>> buttons;

  /// Call with the tapped button's `value`, closes the dialog.
  final ValueChanged<Object?> onPressed;

  /// The theme's dialog style with the dialog's own on top.
  final BrixDialogStyle style;
}
