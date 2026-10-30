import 'dart:ui' show lerpDouble;

import 'package:flutter/painting.dart';

import 'brix_dialog_transition.dart';

/// How `BrixDialog`s look. Every value is optional: unset values come from
/// the theme and brix's defaults.
///
/// Set it for the whole app in `BrixTheme(dialog: ...)`, or for one dialog
/// with `BrixDialog.show(style: ...)`, the dialog's own values win.
class BrixDialogStyle {
  const BrixDialogStyle({
    this.alignment,
    this.margin,
    this.transition,
    this.transitionDuration,
    this.scrimColor,
    this.maxWidth,
    this.radius,
    this.padding,
    this.showIcon,
    this.iconSize,
    this.iconCircleSize,
    this.textAlign,
    this.titleStyle,
    this.messageStyle,
    this.buttonsVertical,
    this.buttonGap,
  });

  /// Where the card sits on the screen (inside the safe area). Default:
  /// centre; `Alignment.bottomCenter` with [BrixDialogTransition.slideUp]
  /// gives a sheet, `Alignment.topCenter` with `slideDown` a banner.
  final AlignmentGeometry? alignment;

  /// Space between the card and the screen edges. Default: 24 left and
  /// right.
  final EdgeInsetsGeometry? margin;

  /// How it comes in and goes out. Default: [BrixDialogTransition.scale].
  final BrixDialogTransition? transition;

  /// Default: 220 ms.
  final Duration? transitionDuration;

  /// Dims the screen behind. Default: `colors.scrim`; transparent shows
  /// the screen as it is.
  final Color? scrimColor;

  /// Default: 340.
  final double? maxWidth;

  /// Card corners. Default: `shape.radius + 6`.
  final double? radius;

  /// Space inside the card. Default: 24 on top, 20 elsewhere.
  final EdgeInsetsGeometry? padding;

  /// Shows the icon circle. Default: `true`.
  final bool? showIcon;

  /// Default: 30.
  final double? iconSize;

  /// The tinted circle behind the icon. Default: 56.
  final double? iconCircleSize;

  /// Title and message alignment. Default: centre.
  final TextAlign? textAlign;

  /// Merged over `typography.title`.
  final TextStyle? titleStyle;

  /// Merged over `typography.body`.
  final TextStyle? messageStyle;

  /// Buttons one under another. Default: two buttons side by side, one or
  /// three+ stacked.
  final bool? buttonsVertical;

  /// Space between buttons. Default: 12 side by side, 10 stacked.
  final double? buttonGap;

  /// This style with [other]'s set values on top.
  BrixDialogStyle merge(BrixDialogStyle? other) {
    if (other == null) return this;
    TextStyle? text(TextStyle? a, TextStyle? b) => a == null ? b : a.merge(b);
    return BrixDialogStyle(
      alignment: other.alignment ?? alignment,
      margin: other.margin ?? margin,
      transition: other.transition ?? transition,
      transitionDuration: other.transitionDuration ?? transitionDuration,
      scrimColor: other.scrimColor ?? scrimColor,
      maxWidth: other.maxWidth ?? maxWidth,
      radius: other.radius ?? radius,
      padding: other.padding ?? padding,
      showIcon: other.showIcon ?? showIcon,
      iconSize: other.iconSize ?? iconSize,
      iconCircleSize: other.iconCircleSize ?? iconCircleSize,
      textAlign: other.textAlign ?? textAlign,
      titleStyle: text(titleStyle, other.titleStyle),
      messageStyle: text(messageStyle, other.messageStyle),
      buttonsVertical: other.buttonsVertical ?? buttonsVertical,
      buttonGap: other.buttonGap ?? buttonGap,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixDialogStyle lerp(BrixDialogStyle other, double t) {
    T pick<T>(T a, T b) => t < 0.5 ? a : b;
    double? number(double? a, double? b) =>
        a == null || b == null ? pick(a, b) : lerpDouble(a, b, t);
    return BrixDialogStyle(
      alignment: AlignmentGeometry.lerp(alignment, other.alignment, t),
      margin: EdgeInsetsGeometry.lerp(margin, other.margin, t),
      transition: pick(transition, other.transition),
      transitionDuration: pick(transitionDuration, other.transitionDuration),
      scrimColor: Color.lerp(scrimColor, other.scrimColor, t),
      maxWidth: number(maxWidth, other.maxWidth),
      radius: number(radius, other.radius),
      padding: EdgeInsetsGeometry.lerp(padding, other.padding, t),
      showIcon: pick(showIcon, other.showIcon),
      iconSize: number(iconSize, other.iconSize),
      iconCircleSize: number(iconCircleSize, other.iconCircleSize),
      textAlign: pick(textAlign, other.textAlign),
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t),
      messageStyle: TextStyle.lerp(messageStyle, other.messageStyle, t),
      buttonsVertical: pick(buttonsVertical, other.buttonsVertical),
      buttonGap: number(buttonGap, other.buttonGap),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixDialogStyle &&
      other.alignment == alignment &&
      other.margin == margin &&
      other.transition == transition &&
      other.transitionDuration == transitionDuration &&
      other.scrimColor == scrimColor &&
      other.maxWidth == maxWidth &&
      other.radius == radius &&
      other.padding == padding &&
      other.showIcon == showIcon &&
      other.iconSize == iconSize &&
      other.iconCircleSize == iconCircleSize &&
      other.textAlign == textAlign &&
      other.titleStyle == titleStyle &&
      other.messageStyle == messageStyle &&
      other.buttonsVertical == buttonsVertical &&
      other.buttonGap == buttonGap;

  @override
  int get hashCode => Object.hashAll([
    alignment,
    margin,
    transition,
    transitionDuration,
    scrimColor,
    maxWidth,
    radius,
    padding,
    showIcon,
    iconSize,
    iconCircleSize,
    textAlign,
    titleStyle,
    messageStyle,
    buttonsVertical,
    buttonGap,
  ]);
}
