import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

import 'brix_field_border.dart';

/// How `BrixTextField`s look. Every value is optional: unset values come
/// from the theme's [BrixColors] / [BrixShape] / [BrixTypography] and brix's
/// defaults.
///
/// Set it for the whole app in `BrixTheme(textField: …)`, or for one field
/// with `BrixTextField(style: …)` – the field's own values win.
///
/// ```dart
/// BrixTheme.light(
///   textField: const BrixTextFieldStyle(
///     border: BrixFieldBorder.underline,
///     labelInside: true,
///   ),
/// )
/// ```
class BrixTextFieldStyle {
  const BrixTextFieldStyle({
    this.border,
    this.filled,
    this.fillColor,
    this.radius,
    this.height,
    this.contentPadding,
    this.borderWidth,
    this.focusedBorderWidth,
    this.labelInside,
    this.labelGap,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.errorStyle,
    this.errorMaxLines,
    this.requiredMarker,
    this.requiredMarkerStyle,
  });

  /// Default: [BrixFieldBorder.outline].
  final BrixFieldBorder? border;

  /// Paints a background. Default: on, except for an underline.
  final bool? filled;

  /// Default: `colors.surface` (`colors.background` when read-only).
  final Color? fillColor;

  /// Default: `shape.radius`. Not used by an underline.
  final double? radius;

  /// Minimum height of a one-line field. Default: `shape.fieldHeight`.
  final double? height;

  /// Space around the text. Default: 14 all round.
  final EdgeInsetsGeometry? contentPadding;

  /// Default: `shape.borderWidth`.
  final double? borderWidth;

  /// Edge width while typing. Default: 1.5 × [borderWidth].
  final double? focusedBorderWidth;

  /// Label inside the field, moving up while typing (Material). Default:
  /// `false` – the label sits above the field.
  final bool? labelInside;

  /// Space between an outside label and the field. Default: 8.
  final double? labelGap;

  /// Merged over `typography.body` for the typed text.
  final TextStyle? textStyle;

  /// Merged over `typography.label`.
  final TextStyle? labelStyle;

  /// Merged over `typography.body` for the hint.
  final TextStyle? hintStyle;

  /// Merged over `typography.caption` in `colors.danger`.
  final TextStyle? errorStyle;

  /// Default: 3.
  final int? errorMaxLines;

  /// Added to the label of a required field. Default: ` *`; `''` hides it.
  final String? requiredMarker;

  /// Merged over the marker's default `colors.danger`.
  final TextStyle? requiredMarkerStyle;

  /// This style with [other]'s set values on top.
  BrixTextFieldStyle merge(BrixTextFieldStyle? other) {
    if (other == null) return this;
    TextStyle? text(TextStyle? a, TextStyle? b) => a == null ? b : a.merge(b);
    return BrixTextFieldStyle(
      border: other.border ?? border,
      filled: other.filled ?? filled,
      fillColor: other.fillColor ?? fillColor,
      radius: other.radius ?? radius,
      height: other.height ?? height,
      contentPadding: other.contentPadding ?? contentPadding,
      borderWidth: other.borderWidth ?? borderWidth,
      focusedBorderWidth: other.focusedBorderWidth ?? focusedBorderWidth,
      labelInside: other.labelInside ?? labelInside,
      labelGap: other.labelGap ?? labelGap,
      textStyle: text(textStyle, other.textStyle),
      labelStyle: text(labelStyle, other.labelStyle),
      hintStyle: text(hintStyle, other.hintStyle),
      errorStyle: text(errorStyle, other.errorStyle),
      errorMaxLines: other.errorMaxLines ?? errorMaxLines,
      requiredMarker: other.requiredMarker ?? requiredMarker,
      requiredMarkerStyle: text(requiredMarkerStyle, other.requiredMarkerStyle),
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixTextFieldStyle lerp(BrixTextFieldStyle other, double t) {
    T pick<T>(T a, T b) => t < 0.5 ? a : b;
    double? number(double? a, double? b) =>
        a == null || b == null ? pick(a, b) : lerpDouble(a, b, t);
    return BrixTextFieldStyle(
      border: pick(border, other.border),
      filled: pick(filled, other.filled),
      fillColor: Color.lerp(fillColor, other.fillColor, t),
      radius: number(radius, other.radius),
      height: number(height, other.height),
      contentPadding: EdgeInsetsGeometry.lerp(
        contentPadding,
        other.contentPadding,
        t,
      ),
      borderWidth: number(borderWidth, other.borderWidth),
      focusedBorderWidth: number(focusedBorderWidth, other.focusedBorderWidth),
      labelInside: pick(labelInside, other.labelInside),
      labelGap: number(labelGap, other.labelGap),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      labelStyle: TextStyle.lerp(labelStyle, other.labelStyle, t),
      hintStyle: TextStyle.lerp(hintStyle, other.hintStyle, t),
      errorStyle: TextStyle.lerp(errorStyle, other.errorStyle, t),
      errorMaxLines: pick(errorMaxLines, other.errorMaxLines),
      requiredMarker: pick(requiredMarker, other.requiredMarker),
      requiredMarkerStyle: TextStyle.lerp(
        requiredMarkerStyle,
        other.requiredMarkerStyle,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixTextFieldStyle &&
      other.border == border &&
      other.filled == filled &&
      other.fillColor == fillColor &&
      other.radius == radius &&
      other.height == height &&
      other.contentPadding == contentPadding &&
      other.borderWidth == borderWidth &&
      other.focusedBorderWidth == focusedBorderWidth &&
      other.labelInside == labelInside &&
      other.labelGap == labelGap &&
      other.textStyle == textStyle &&
      other.labelStyle == labelStyle &&
      other.hintStyle == hintStyle &&
      other.errorStyle == errorStyle &&
      other.errorMaxLines == errorMaxLines &&
      other.requiredMarker == requiredMarker &&
      other.requiredMarkerStyle == requiredMarkerStyle;

  @override
  int get hashCode => Object.hashAll([
    border,
    filled,
    fillColor,
    radius,
    height,
    contentPadding,
    borderWidth,
    focusedBorderWidth,
    labelInside,
    labelGap,
    textStyle,
    labelStyle,
    hintStyle,
    errorStyle,
    errorMaxLines,
    requiredMarker,
    requiredMarkerStyle,
  ]);
}
