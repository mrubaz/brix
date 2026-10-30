import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

/// How `BrixButton`s look. Every value is optional: unset values come from
/// the theme's [BrixShape] / [BrixTypography] and brix's defaults.
///
/// Set it for the whole app in `BrixTheme(button: ...)`, or for one button
/// with `BrixButton(style: ...)`, the button's own values win.
///
/// ```dart
/// BrixTheme.light(
///   button: const BrixButtonStyle(radius: 30, upperCase: true, gradient: true),
/// )
/// ```
class BrixButtonStyle {
  const BrixButtonStyle({
    this.height,
    this.radius,
    this.padding,
    this.textStyle,
    this.upperCase,
    this.iconSize,
    this.iconGap,
    this.pressedScale,
    this.pressDuration,
    this.disabledOpacity,
    this.fadeDuration,
    this.borderWidth,
    this.gradient,
    this.haptics,
  });

  /// Default: `shape.buttonHeight`.
  final double? height;

  /// Corner radius. Default: `shape.radius`; a large value gives a pill.
  final double? radius;

  /// Space around the label. Default: 20 left and right.
  final EdgeInsetsGeometry? padding;

  /// Merged over `typography.button` (e.g. only `letterSpacing`). The
  /// colour still comes from the variant.
  final TextStyle? textStyle;

  /// Shows the label in capitals. Default: `false` (as written).
  final bool? upperCase;

  /// Default: 20.
  final double? iconSize;

  /// Space between the icon and the label. Default: 8.
  final double? iconGap;

  /// Size while pressed. Default: 0.97; `1` turns the effect off.
  final double? pressedScale;

  /// How fast it shrinks and grows back. Default: 120 ms.
  final Duration? pressDuration;

  /// Opacity of a disabled button. Default: 0.4.
  final double? disabledOpacity;

  /// How fast it fades when disabled / enabled. Default: 150 ms.
  final Duration? fadeDuration;

  /// Outline width of `BrixButton.outlined`. Default: `shape.borderWidth`.
  final double? borderWidth;

  /// Filled buttons use a primary to secondary gradient. Default: `false`.
  final bool? gradient;

  /// A light tap feel on press. Default: `true`.
  final bool? haptics;

  /// This style with [other]'s set values on top.
  BrixButtonStyle merge(BrixButtonStyle? other) {
    if (other == null) return this;
    return BrixButtonStyle(
      height: other.height ?? height,
      radius: other.radius ?? radius,
      padding: other.padding ?? padding,
      textStyle: textStyle == null
          ? other.textStyle
          : textStyle!.merge(other.textStyle),
      upperCase: other.upperCase ?? upperCase,
      iconSize: other.iconSize ?? iconSize,
      iconGap: other.iconGap ?? iconGap,
      pressedScale: other.pressedScale ?? pressedScale,
      pressDuration: other.pressDuration ?? pressDuration,
      disabledOpacity: other.disabledOpacity ?? disabledOpacity,
      fadeDuration: other.fadeDuration ?? fadeDuration,
      borderWidth: other.borderWidth ?? borderWidth,
      gradient: other.gradient ?? gradient,
      haptics: other.haptics ?? haptics,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixButtonStyle lerp(BrixButtonStyle other, double t) {
    T pick<T>(T a, T b) => t < 0.5 ? a : b;
    double? number(double? a, double? b) =>
        a == null || b == null ? pick(a, b) : lerpDouble(a, b, t);
    return BrixButtonStyle(
      height: number(height, other.height),
      radius: number(radius, other.radius),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      upperCase: pick(upperCase, other.upperCase),
      iconSize: number(iconSize, other.iconSize),
      iconGap: number(iconGap, other.iconGap),
      pressedScale: number(pressedScale, other.pressedScale),
      pressDuration: pick(pressDuration, other.pressDuration),
      disabledOpacity: number(disabledOpacity, other.disabledOpacity),
      fadeDuration: pick(fadeDuration, other.fadeDuration),
      borderWidth: number(borderWidth, other.borderWidth),
      gradient: pick(gradient, other.gradient),
      haptics: pick(haptics, other.haptics),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixButtonStyle &&
      other.height == height &&
      other.radius == radius &&
      other.padding == padding &&
      other.textStyle == textStyle &&
      other.upperCase == upperCase &&
      other.iconSize == iconSize &&
      other.iconGap == iconGap &&
      other.pressedScale == pressedScale &&
      other.pressDuration == pressDuration &&
      other.disabledOpacity == disabledOpacity &&
      other.fadeDuration == fadeDuration &&
      other.borderWidth == borderWidth &&
      other.gradient == gradient &&
      other.haptics == haptics;

  @override
  int get hashCode => Object.hashAll([
    height,
    radius,
    padding,
    textStyle,
    upperCase,
    iconSize,
    iconGap,
    pressedScale,
    pressDuration,
    disabledOpacity,
    fadeDuration,
    borderWidth,
    gradient,
    haptics,
  ]);
}
