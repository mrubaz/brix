import 'package:flutter/widgets.dart';

import '../theme/brix_icon.dart';
import 'brix_toast_style.dart';

/// Builds an app's own toast card. brix keeps the rest: placing it,
/// sliding it in and out, the timer, swipe to hide and replacing an open
/// toast.
typedef BrixToastBuilder = Widget Function(
  BuildContext context,
  BrixToastData toast,
);

/// Everything a [BrixToastBuilder] needs to draw a toast.
class BrixToastData {
  const BrixToastData({
    required this.message,
    required this.title,
    required this.icon,
    required this.accent,
    required this.dismiss,
    required this.style,
  });

  final String message;
  final String? title;
  final BrixIcon icon;

  /// The icon colour (`colors.success` for a success toast).
  final Color accent;

  /// Hides the toast now (e.g. a close button).
  final VoidCallback dismiss;

  /// The theme's toast style.
  final BrixToastStyle style;
}
