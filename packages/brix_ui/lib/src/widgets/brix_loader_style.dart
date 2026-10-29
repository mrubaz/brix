import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// How `BrixLoader`s look. Set it in `BrixTheme(loader: …)`; a loader's
/// own `radius` / `color` win.
class BrixLoaderStyle {
  const BrixLoaderStyle({this.radius, this.color});

  /// Size of the spinner. Default: 10 (iOS).
  final double? radius;

  /// Default: `colors.mutedText`.
  final Color? color;

  /// This style with [other]'s set values on top.
  BrixLoaderStyle merge(BrixLoaderStyle? other) {
    if (other == null) return this;
    return BrixLoaderStyle(
      radius: other.radius ?? radius,
      color: other.color ?? color,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixLoaderStyle lerp(BrixLoaderStyle other, double t) {
    return BrixLoaderStyle(
      radius: radius == null || other.radius == null
          ? (t < 0.5 ? radius : other.radius)
          : lerpDouble(radius, other.radius, t),
      color: Color.lerp(color, other.color, t),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixLoaderStyle &&
      other.radius == radius &&
      other.color == color;

  @override
  int get hashCode => Object.hash(radius, color);
}
