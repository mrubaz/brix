import 'dart:ui' show lerpDouble;

/// Sizes brix widgets use. Plain logical pixels – an app that scales its
/// layout (e.g. `flutter_screenutil`) passes scaled values here.
class BrixShape {
  /// Defaults follow the iOS touch target (44 pt minimum) with room for
  /// gloves and large text.
  const BrixShape({
    this.radius = 12,
    this.buttonHeight = 50,
    this.fieldHeight = 50,
    this.borderWidth = 1,
  });

  /// Corner radius of buttons, fields, alerts and toasts.
  final double radius;

  /// Height of a button.
  final double buttonHeight;

  /// Height of a one-line text field.
  final double fieldHeight;

  /// Width of field borders and outlined buttons.
  final double borderWidth;

  BrixShape copyWith({
    double? radius,
    double? buttonHeight,
    double? fieldHeight,
    double? borderWidth,
  }) {
    return BrixShape(
      radius: radius ?? this.radius,
      buttonHeight: buttonHeight ?? this.buttonHeight,
      fieldHeight: fieldHeight ?? this.fieldHeight,
      borderWidth: borderWidth ?? this.borderWidth,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixShape lerp(BrixShape other, double t) {
    return BrixShape(
      radius: lerpDouble(radius, other.radius, t)!,
      buttonHeight: lerpDouble(buttonHeight, other.buttonHeight, t)!,
      fieldHeight: lerpDouble(fieldHeight, other.fieldHeight, t)!,
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixShape &&
      other.radius == radius &&
      other.buttonHeight == buttonHeight &&
      other.fieldHeight == fieldHeight &&
      other.borderWidth == borderWidth;

  @override
  int get hashCode =>
      Object.hash(radius, buttonHeight, fieldHeight, borderWidth);
}
