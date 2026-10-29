import 'package:flutter/widgets.dart';

/// An icon brix_ui can tint and size: a Flutter [IconData], or any widget
/// (an SVG, an image) with [BrixIcon.custom].
///
/// A custom widget gets the colour and size through [IconTheme], so an
/// `Icon` inside it follows them; an SVG can read them with
/// `IconTheme.of(context)`.
class BrixIcon {
  const BrixIcon(IconData this.icon) : child = null;

  const BrixIcon.custom(Widget this.child) : icon = null;

  final IconData? icon;
  final Widget? child;

  /// The icon in [color] at [size].
  Widget build({required Color color, required double size}) {
    if (icon != null) return Icon(icon, color: color, size: size);
    return IconTheme.merge(
      data: IconThemeData(color: color, size: size),
      child: SizedBox.square(
        dimension: size,
        child: Center(child: child),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixIcon && other.icon == icon && other.child == child;

  @override
  int get hashCode => Object.hash(icon, child);
}
