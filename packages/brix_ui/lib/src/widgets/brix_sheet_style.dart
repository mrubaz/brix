import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// How `BrixSheet`s look. Every value is optional: unset values come from
/// the theme and brix's defaults. Set it for the whole app in
/// `BrixTheme(sheet: ...)` or for one sheet with `BrixSheet.show(style:)`.
class BrixSheetStyle {
  const BrixSheetStyle({
    this.radius,
    this.backgroundColor,
    this.showGrabber,
    this.grabberColor,
    this.padding,
    this.maxWidth,
    this.scrimColor,
    this.titleStyle,
  });

  /// Top corners. Default: `shape.radius + 6`.
  final double? radius;

  /// Default: `colors.surface`.
  final Color? backgroundColor;

  /// The small bar at the top that shows the sheet can be dragged. Default:
  /// on.
  final bool? showGrabber;

  /// Default: `colors.border`.
  final Color? grabberColor;

  /// Space around the content. Default: 20 at the sides, 8 on top, 20 below.
  final EdgeInsetsGeometry? padding;

  /// Widest the sheet gets on tablets and desktop. Default: 640.
  final double? maxWidth;

  /// Dims the screen behind. Default: `colors.scrim`.
  final Color? scrimColor;

  /// Merged over `typography.title` for the sheet's title.
  final TextStyle? titleStyle;

  /// This style with [other]'s set values on top.
  BrixSheetStyle merge(BrixSheetStyle? other) {
    if (other == null) return this;
    return BrixSheetStyle(
      radius: other.radius ?? radius,
      backgroundColor: other.backgroundColor ?? backgroundColor,
      showGrabber: other.showGrabber ?? showGrabber,
      grabberColor: other.grabberColor ?? grabberColor,
      padding: other.padding ?? padding,
      maxWidth: other.maxWidth ?? maxWidth,
      scrimColor: other.scrimColor ?? scrimColor,
      titleStyle: titleStyle == null
          ? other.titleStyle
          : titleStyle!.merge(other.titleStyle),
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixSheetStyle lerp(BrixSheetStyle other, double t) {
    T pick<T>(T a, T b) => t < 0.5 ? a : b;
    double? number(double? a, double? b) =>
        a == null || b == null ? pick(a, b) : lerpDouble(a, b, t);
    return BrixSheetStyle(
      radius: number(radius, other.radius),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      showGrabber: pick(showGrabber, other.showGrabber),
      grabberColor: Color.lerp(grabberColor, other.grabberColor, t),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      maxWidth: number(maxWidth, other.maxWidth),
      scrimColor: Color.lerp(scrimColor, other.scrimColor, t),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixSheetStyle &&
      other.radius == radius &&
      other.backgroundColor == backgroundColor &&
      other.showGrabber == showGrabber &&
      other.grabberColor == grabberColor &&
      other.padding == padding &&
      other.maxWidth == maxWidth &&
      other.scrimColor == scrimColor &&
      other.titleStyle == titleStyle;

  @override
  int get hashCode => Object.hash(
    radius,
    backgroundColor,
    showGrabber,
    grabberColor,
    padding,
    maxWidth,
    scrimColor,
    titleStyle,
  );
}
