import 'package:flutter/painting.dart';

/// The colours every brix widget reads. Widgets never use a colour of their
/// own, so switching between light and dark needs no widget change.
///
/// Start from [BrixColors.light] or [BrixColors.dark] and pass only the
/// colours your app changes:
///
/// ```dart
/// BrixColors.light(primary: const Color(0xFF1D629D))
/// ```
class BrixColors {
  /// Light defaults, close to the iOS system colours.
  const BrixColors.light({
    this.primary = const Color(0xFF007AFF),
    this.onPrimary = const Color(0xFFFFFFFF),
    this.secondary = const Color(0xFF5856D6),
    this.background = const Color(0xFFF2F2F7),
    this.surface = const Color(0xFFFFFFFF),
    this.text = const Color(0xFF1C1C1E),
    this.mutedText = const Color(0xFF6C6C70),
    this.border = const Color(0xFFC6C6C8),
    this.success = const Color(0xFF34C759),
    this.warning = const Color(0xFFFF9500),
    this.danger = const Color(0xFFFF3B30),
    this.scrim = const Color(0x66000000),
  });

  /// Dark defaults, close to the iOS system colours.
  const BrixColors.dark({
    this.primary = const Color(0xFF0A84FF),
    this.onPrimary = const Color(0xFFFFFFFF),
    this.secondary = const Color(0xFF5E5CE6),
    this.background = const Color(0xFF000000),
    this.surface = const Color(0xFF1C1C1E),
    this.text = const Color(0xFFFFFFFF),
    this.mutedText = const Color(0xFF98989F),
    this.border = const Color(0xFF38383A),
    this.success = const Color(0xFF30D158),
    this.warning = const Color(0xFFFF9F0A),
    this.danger = const Color(0xFFFF453A),
    this.scrim = const Color(0x99000000),
  });

  /// Main action colour: filled buttons, focused fields, links.
  final Color primary;

  /// Text and icons on [primary] (and on [danger]).
  final Color onPrimary;

  /// Second accent, e.g. the end of a gradient button.
  final Color secondary;

  /// Screen background.
  final Color background;

  /// Cards, fields, dialogs and toasts, anything that sits on [background].
  final Color surface;

  /// Main text.
  final Color text;

  /// Hints, captions and other quiet text.
  final Color mutedText;

  /// Field borders, outlines and dividers.
  final Color border;

  /// Success toasts and done states.
  final Color success;

  /// Warnings.
  final Color warning;

  /// Errors and destructive actions.
  final Color danger;

  /// Dims the screen behind a dialog, so it reads on any background.
  final Color scrim;

  BrixColors copyWith({
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? text,
    Color? mutedText,
    Color? border,
    Color? success,
    Color? warning,
    Color? danger,
    Color? scrim,
  }) {
    return BrixColors.light(
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      scrim: scrim ?? this.scrim,
    );
  }

  /// Blends from this to [other] while the theme animates.
  BrixColors lerp(BrixColors other, double t) {
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return BrixColors.light(
      primary: mix(primary, other.primary),
      onPrimary: mix(onPrimary, other.onPrimary),
      secondary: mix(secondary, other.secondary),
      background: mix(background, other.background),
      surface: mix(surface, other.surface),
      text: mix(text, other.text),
      mutedText: mix(mutedText, other.mutedText),
      border: mix(border, other.border),
      success: mix(success, other.success),
      warning: mix(warning, other.warning),
      danger: mix(danger, other.danger),
      scrim: mix(scrim, other.scrim),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixColors &&
      other.primary == primary &&
      other.onPrimary == onPrimary &&
      other.secondary == secondary &&
      other.background == background &&
      other.surface == surface &&
      other.text == text &&
      other.mutedText == mutedText &&
      other.border == border &&
      other.success == success &&
      other.warning == warning &&
      other.danger == danger &&
      other.scrim == scrim;

  @override
  int get hashCode => Object.hash(
    primary,
    onPrimary,
    secondary,
    background,
    surface,
    text,
    mutedText,
    border,
    success,
    warning,
    danger,
    scrim,
  );
}
