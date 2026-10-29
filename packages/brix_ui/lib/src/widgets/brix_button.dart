import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brix_colors.dart';
import '../theme/brix_theme_context.dart';
import 'brix_button_data.dart';
import 'brix_button_style.dart';
import 'brix_button_variant.dart';
import 'brix_loader.dart';

/// The app's main button, styled from the theme.
///
/// - `BrixButton` – filled with `colors.primary` (or a primary → secondary
///   gradient with [gradient]).
/// - `BrixButton.outlined` – the quieter second action (Back, Cancel).
/// - `BrixButton.destructive` – filled with `colors.danger` (Delete, Log out).
///
/// While [isLoading] it shows a spinner, keeps its size and ignores taps,
/// so a request cannot be sent twice. `onPressed: null` disables it.
///
/// Its look comes from `BrixTheme.button` with [style] on top. To draw a
/// completely own button and keep this logic, give a [builder] (or
/// `BrixTheme.buttonBuilder` for every button).
///
/// ```dart
/// BrixButton(label: 'Log in', isLoading: loading, onPressed: login)
/// ```
class BrixButton extends StatefulWidget {
  const BrixButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.expand = true,
    this.haptics,
    this.style,
    this.builder,
  }) : variant = BrixButtonVariant.filled;

  const BrixButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.haptics,
    this.style,
    this.builder,
  }) : gradient = false,
       variant = BrixButtonVariant.outlined;

  const BrixButton.destructive({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.haptics,
    this.style,
    this.builder,
  }) : gradient = false,
       variant = BrixButtonVariant.destructive;

  /// Shown as written, unless the style says `upperCase`.
  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;

  /// Shows a spinner instead of the label and ignores taps.
  final bool isLoading;

  /// Optional icon before the label.
  final IconData? icon;

  /// Filled button only: primary → secondary gradient instead of a flat
  /// colour. `null` follows the style (default: flat).
  final bool? gradient;

  /// Takes the full width (forms); `false` fits the label.
  final bool expand;

  /// A light tap feel on press. `null` follows the style (default: on).
  final bool? haptics;

  /// This button's look, on top of `BrixTheme.button`.
  final BrixButtonStyle? style;

  /// Draws this button instead of brix (wins over
  /// `BrixTheme.buttonBuilder`).
  final BrixButtonBuilder? builder;

  /// Filled, outlined or destructive.
  final BrixButtonVariant variant;

  @override
  State<BrixButton> createState() => _BrixButtonState();
}

class _BrixButtonState extends State<BrixButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  void didUpdateWidget(BrixButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Loading starts on tap, before the finger lifts – drop the press.
    if (!_enabled) _pressed = false;
  }

  void _handleTap(bool haptics) {
    if (!_enabled) return;
    if (haptics) HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  void _setPressed(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  /// Background, border and content colours for the variant.
  ({Color? fill, Gradient? gradient, Color? border, Color content}) _look(
    BrixColors colors,
    bool gradient,
  ) {
    return switch (widget.variant) {
      BrixButtonVariant.outlined => (
        fill: null,
        gradient: null,
        border: colors.primary,
        content: colors.primary,
      ),
      BrixButtonVariant.destructive => (
        fill: colors.danger,
        gradient: null,
        border: null,
        content: colors.onPrimary,
      ),
      _ => (
        fill: gradient ? null : colors.primary,
        gradient: gradient
            ? LinearGradient(colors: [colors.primary, colors.secondary])
            : null,
        border: null,
        content: colors.onPrimary,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final style = brix.button.merge(widget.style);
    final haptics = widget.haptics ?? style.haptics ?? true;
    final gradient =
        widget.variant == BrixButtonVariant.filled &&
        (widget.gradient ?? style.gradient ?? false);
    final label = (style.upperCase ?? false)
        ? widget.label.toUpperCase()
        : widget.label;

    final builder = widget.builder ?? brix.buttonBuilder;
    if (builder != null) {
      return builder(
        context,
        BrixButtonData(
          label: label,
          icon: widget.icon,
          variant: widget.variant,
          isLoading: widget.isLoading,
          isEnabled: widget.onPressed != null,
          onPressed: _enabled ? () => _handleTap(haptics) : null,
          style: style.merge(BrixButtonStyle(gradient: gradient)),
          expand: widget.expand,
        ),
      );
    }

    final look = _look(brix.colors, gradient);
    final radius = BorderRadius.circular(style.radius ?? brix.shape.radius);
    final textStyle = brix.typography.button
        .merge(style.textStyle)
        .copyWith(color: look.content);
    final iconSize = style.iconSize ?? 20;

    final Widget content = widget.isLoading
        ? BrixLoader(radius: 9, color: look.content)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: look.content, size: iconSize),
                SizedBox(width: style.iconGap ?? 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.isLoading ? widget.label : null,
      excludeSemantics: widget.isLoading,
      child: AnimatedOpacity(
        // A loading button stays fully visible; only disabled fades.
        opacity: widget.onPressed == null ? style.disabledOpacity ?? 0.4 : 1,
        duration: style.fadeDuration ?? const Duration(milliseconds: 150),
        child: AnimatedScale(
          scale: _pressed ? style.pressedScale ?? 0.97 : 1,
          duration: style.pressDuration ?? const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: SizedBox(
            height: style.height ?? brix.shape.buttonHeight,
            width: widget.expand ? double.infinity : null,
            child: Material(
              type: MaterialType.transparency,
              child: Ink(
                decoration: BoxDecoration(
                  color: look.fill,
                  gradient: look.gradient,
                  borderRadius: radius,
                  border: look.border == null
                      ? null
                      : Border.all(
                          color: look.border!,
                          width: style.borderWidth ?? brix.shape.borderWidth,
                        ),
                ),
                child: InkWell(
                  borderRadius: radius,
                  splashFactory: NoSplash.splashFactory,
                  highlightColor: Colors.transparent,
                  onTap: _enabled ? () => _handleTap(haptics) : null,
                  onHighlightChanged: _enabled ? _setPressed : null,
                  child: Padding(
                    padding:
                        style.padding ??
                        const EdgeInsets.symmetric(horizontal: 20),
                    child: Center(widthFactor: 1, child: content),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
