import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// Where a `BrixToast` shows. An app only picks one, so it is an enum.
enum BrixToastPosition {
  /// Slides down under the status bar (default).
  top,

  /// Fades in with a small grow in the middle of the screen.
  center,

  /// Slides up above the home indicator.
  bottom,
}

/// How `BrixToast`s look and behave. Every value is optional: unset values
/// come from the theme and brix's defaults. Set it in
/// `BrixTheme(toast: …)`.
class BrixToastStyle {
  const BrixToastStyle({
    this.position,
    this.duration,
    this.animationDuration,
    this.reverseDuration,
    this.maxWidth,
    this.margin,
    this.radius,
    this.padding,
    this.iconSize,
    this.titleStyle,
    this.messageStyle,
  });

  /// Default: [BrixToastPosition.top]. Swipe towards the edge to hide it.
  final BrixToastPosition? position;

  /// How long it stays. Default: 3 seconds.
  final Duration? duration;

  /// How fast it comes in. Default: 280 ms.
  final Duration? animationDuration;

  /// How fast it goes out. Default: 200 ms.
  final Duration? reverseDuration;

  /// Default: 500.
  final double? maxWidth;

  /// Space to the screen edges (inside the safe area). Default: 16 at the
  /// sides, 8 from the top / bottom.
  final EdgeInsets? margin;

  /// Card corners. Default: `shape.radius + 6`.
  final double? radius;

  /// Space inside the card. Default: 14 × 12.
  final EdgeInsetsGeometry? padding;

  /// Default: 26.
  final double? iconSize;

  /// Merged over `typography.label`.
  final TextStyle? titleStyle;

  /// Merged over `typography.body`.
  final TextStyle? messageStyle;

  /// This style with [other]'s set values on top.
  BrixToastStyle merge(BrixToastStyle? other) {
    if (other == null) return this;
    TextStyle? text(TextStyle? a, TextStyle? b) => a == null ? b : a.merge(b);
    return BrixToastStyle(
      position: other.position ?? position,
      duration: other.duration ?? duration,
      animationDuration: other.animationDuration ?? animationDuration,
      reverseDuration: other.reverseDuration ?? reverseDuration,
      maxWidth: other.maxWidth ?? maxWidth,
      margin: other.margin ?? margin,
      radius: other.radius ?? radius,
      padding: other.padding ?? padding,
      iconSize: other.iconSize ?? iconSize,
      titleStyle: text(titleStyle, other.titleStyle),
      messageStyle: text(messageStyle, other.messageStyle),
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixToastStyle lerp(BrixToastStyle other, double t) {
    T pick<T>(T a, T b) => t < 0.5 ? a : b;
    double? number(double? a, double? b) =>
        a == null || b == null ? pick(a, b) : lerpDouble(a, b, t);
    return BrixToastStyle(
      position: pick(position, other.position),
      duration: pick(duration, other.duration),
      animationDuration: pick(animationDuration, other.animationDuration),
      reverseDuration: pick(reverseDuration, other.reverseDuration),
      maxWidth: number(maxWidth, other.maxWidth),
      margin: EdgeInsets.lerp(margin, other.margin, t),
      radius: number(radius, other.radius),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      iconSize: number(iconSize, other.iconSize),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixToastStyle &&
      other.position == position &&
      other.duration == duration &&
      other.animationDuration == animationDuration &&
      other.reverseDuration == reverseDuration &&
      other.maxWidth == maxWidth &&
      other.margin == margin &&
      other.radius == radius &&
      other.padding == padding &&
      other.iconSize == iconSize &&
      other.titleStyle == titleStyle &&
      other.messageStyle == messageStyle;

  @override
  int get hashCode => Object.hash(
    position,
    duration,
    animationDuration,
    reverseDuration,
    maxWidth,
    margin,
    radius,
    padding,
    iconSize,
    titleStyle,
    messageStyle,
  );
}
