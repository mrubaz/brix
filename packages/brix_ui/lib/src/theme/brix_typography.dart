import 'package:flutter/painting.dart';

/// The text styles brix widgets use. Styles carry size, weight and font
/// only, the colour comes from [BrixColors], so the same styles work in
/// light and dark.
///
/// Pass your own font with [fontFamily], or whole styles (e.g. from
/// `google_fonts`):
///
/// ```dart
/// BrixTypography(fontFamily: 'Inter')
/// ```
class BrixTypography {
  /// iOS-like sizes: title 20, body and button 16, label 14, caption 12.
  /// [fontFamily] is applied to every style that has no font of its own.
  BrixTypography({
    String? fontFamily,
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? button,
    TextStyle? caption,
  }) : title = _withFont(
         title ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
         fontFamily,
       ),
       body = _withFont(
         body ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
         fontFamily,
       ),
       label = _withFont(
         label ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
         fontFamily,
       ),
       button = _withFont(
         button ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
         fontFamily,
       ),
       caption = _withFont(
         caption ?? const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
         fontFamily,
       );

  const BrixTypography._({
    required this.title,
    required this.body,
    required this.label,
    required this.button,
    required this.caption,
  });

  /// Dialog titles and headings.
  final TextStyle title;

  /// Field input and messages.
  final TextStyle body;

  /// Field labels.
  final TextStyle label;

  /// Button text.
  final TextStyle button;

  /// Hints under fields, small notes.
  final TextStyle caption;

  static TextStyle _withFont(TextStyle style, String? fontFamily) =>
      fontFamily == null || style.fontFamily != null
      ? style
      : style.copyWith(fontFamily: fontFamily);

  BrixTypography copyWith({
    TextStyle? title,
    TextStyle? body,
    TextStyle? label,
    TextStyle? button,
    TextStyle? caption,
  }) {
    return BrixTypography._(
      title: title ?? this.title,
      body: body ?? this.body,
      label: label ?? this.label,
      button: button ?? this.button,
      caption: caption ?? this.caption,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixTypography lerp(BrixTypography other, double t) {
    return BrixTypography._(
      title: TextStyle.lerp(title, other.title, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      label: TextStyle.lerp(label, other.label, t)!,
      button: TextStyle.lerp(button, other.button, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixTypography &&
      other.title == title &&
      other.body == body &&
      other.label == label &&
      other.button == button &&
      other.caption == caption;

  @override
  int get hashCode => Object.hash(title, body, label, button, caption);
}
