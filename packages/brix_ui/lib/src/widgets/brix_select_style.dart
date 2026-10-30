import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// How the options of `BrixSelect`s look. The field itself follows
/// `BrixTheme.textField`, so selects and text fields always match. Set it
/// in `BrixTheme(select: ...)` or for one select with `style:`.
class BrixSelectStyle {
  const BrixSelectStyle({
    this.menuRadius,
    this.menuMaxHeight,
    this.menuColor,
    this.optionPadding,
    this.optionStyle,
    this.selectedColor,
  });

  /// Default: `shape.radius`.
  final double? menuRadius;

  /// Longer menus scroll. Default: 320.
  final double? menuMaxHeight;

  /// Default: `colors.surface`.
  final Color? menuColor;

  /// Space around each option. Default: 16 by 12.
  final EdgeInsetsGeometry? optionPadding;

  /// Merged over `typography.body` for the options.
  final TextStyle? optionStyle;

  /// The tick next to the chosen option. Default: `colors.primary`.
  final Color? selectedColor;

  /// This style with [other]'s set values on top.
  BrixSelectStyle merge(BrixSelectStyle? other) {
    if (other == null) return this;
    return BrixSelectStyle(
      menuRadius: other.menuRadius ?? menuRadius,
      menuMaxHeight: other.menuMaxHeight ?? menuMaxHeight,
      menuColor: other.menuColor ?? menuColor,
      optionPadding: other.optionPadding ?? optionPadding,
      optionStyle: optionStyle == null
          ? other.optionStyle
          : optionStyle!.merge(other.optionStyle),
      selectedColor: other.selectedColor ?? selectedColor,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixSelectStyle lerp(BrixSelectStyle other, double t) {
    double? number(double? a, double? b) =>
        a == null || b == null ? (t < 0.5 ? a : b) : lerpDouble(a, b, t);
    return BrixSelectStyle(
      menuRadius: number(menuRadius, other.menuRadius),
      menuMaxHeight: number(menuMaxHeight, other.menuMaxHeight),
      menuColor: Color.lerp(menuColor, other.menuColor, t),
      optionPadding: EdgeInsetsGeometry.lerp(
        optionPadding,
        other.optionPadding,
        t,
      ),
      optionStyle: TextStyle.lerp(optionStyle, other.optionStyle, t),
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixSelectStyle &&
      other.menuRadius == menuRadius &&
      other.menuMaxHeight == menuMaxHeight &&
      other.menuColor == menuColor &&
      other.optionPadding == optionPadding &&
      other.optionStyle == optionStyle &&
      other.selectedColor == selectedColor;

  @override
  int get hashCode => Object.hash(
    menuRadius,
    menuMaxHeight,
    menuColor,
    optionPadding,
    optionStyle,
    selectedColor,
  );
}
