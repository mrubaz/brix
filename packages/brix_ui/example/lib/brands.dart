import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// Three looks from the same widgets, only the theme changes.
enum Brand {
  /// brix's own defaults.
  standard('Default'),

  /// Own colours, round corners, capital buttons with a gradient, fields
  /// with an underline and the label inside, alerts as a bottom sheet,
  /// toasts at the bottom.
  forest('Forest'),

  /// Sharp corners, own button and toast widgets (builders), frosted
  /// glass, Urdu texts.
  sunset('Sunset');

  const Brand(this.label);

  final String label;

  BrixTheme theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    return switch (this) {
      Brand.standard => dark ? BrixTheme.dark() : BrixTheme.light(),
      Brand.forest => _forest(dark),
      Brand.sunset => _sunset(dark),
    };
  }
}

BrixTheme _forest(bool dark) {
  const button = BrixButtonStyle(
    radius: 40,
    height: 54,
    upperCase: true,
    gradient: true,
    textStyle: TextStyle(letterSpacing: 1.2),
  );
  const textField = BrixTextFieldStyle(
    border: BrixFieldBorder.underline,
    labelInside: true,
    contentPadding: EdgeInsets.fromLTRB(0, 10, 0, 10),
  );
  const alert = BrixAlertStyle(
    alignment: Alignment.bottomCenter,
    transition: BrixAlertTransition.slideUp,
    margin: EdgeInsets.all(12),
    maxWidth: double.infinity,
    textAlign: TextAlign.start,
    buttonsVertical: true,
  );
  const toast = BrixToastStyle(position: BrixToastPosition.bottom);
  const shape = BrixShape(radius: 26);
  return dark
      ? BrixTheme.dark(
          colors: const BrixColors.dark(
            primary: Color(0xFF52B788),
            secondary: Color(0xFF95D5B2),
            background: Color(0xFF0B1A12),
            surface: Color(0xFF14281D),
            border: Color(0xFF2D4A3A),
          ),
          shape: shape,
          button: button,
          textField: textField,
          alert: alert,
          toast: toast,
        )
      : BrixTheme.light(
          colors: const BrixColors.light(
            primary: Color(0xFF1E7A4C),
            secondary: Color(0xFF52B788),
            background: Color(0xFFF1F7F2),
            border: Color(0xFFB7D3C0),
          ),
          shape: shape,
          button: button,
          textField: textField,
          alert: alert,
          toast: toast,
        );
}

BrixTheme _sunset(bool dark) {
  const texts = BrixUiTexts(
    ok: 'ٹھیک ہے',
    warningTitle: 'توجہ کریں',
    errorTitle: 'کچھ غلط ہو گیا',
    requiredField: 'یہ خانہ ضروری ہے',
  );
  const shape = BrixShape(radius: 6, borderWidth: 1.5);
  final colors = dark
      ? const BrixColors.dark(
          primary: Color(0xFFFF7A59),
          secondary: Color(0xFFFFB86B),
          background: Color(0xFF1A1325),
          surface: Color(0xFF2A2038),
          border: Color(0xFF4A3A60),
        )
      : const BrixColors.light(
          primary: Color(0xFFE8572F),
          secondary: Color(0xFFFF9F43),
          background: Color(0xFFFFF4EC),
          border: Color(0xFFF2C6AE),
        );
  return (dark ? BrixTheme.dark : BrixTheme.light)(
    colors: colors,
    shape: shape,
    texts: texts,
    glass: true,
    textField: const BrixTextFieldStyle(requiredMarker: ' •'),
    buttonBuilder: _blockButton,
    toastBuilder: _pillToast,
  );
}

/// An app's own button: a bold block with a hard shadow. brix still blocks
/// double taps, plays the haptic and passes the loading state.
Widget _blockButton(BuildContext context, BrixButtonData button) {
  final colors = context.brix.colors;
  final fill = switch (button.variant) {
    BrixButtonVariant.outlined => colors.surface,
    BrixButtonVariant.destructive => colors.danger,
    _ => colors.primary,
  };
  final text = button.variant == BrixButtonVariant.outlined
      ? colors.text
      : colors.onPrimary;
  return Opacity(
    opacity: button.isEnabled ? 1 : 0.4,
    child: GestureDetector(
      onTap: button.onPressed,
      child: Container(
        height: 52,
        width: button.expand ? double.infinity : null,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.text, width: 2),
          boxShadow: [
            BoxShadow(color: colors.text, offset: const Offset(4, 4)),
          ],
        ),
        child: button.isLoading
            ? BrixLoader(color: text)
            : Text(
                button.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
      ),
    ),
  );
}

/// An app's own toast: a dark pill with a close action.
Widget _pillToast(BuildContext context, BrixToastData toast) {
  return Container(
    padding: const EdgeInsets.fromLTRB(18, 6, 6, 6),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1C1E),
      borderRadius: BorderRadius.circular(40),
    ),
    child: Row(
      children: [
        toast.icon.build(color: toast.accent, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            toast.message,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
        TextButton(
          onPressed: toast.dismiss,
          child: const Text(
            'Close',
            style: TextStyle(color: Color(0xFFFFB86B)),
          ),
        ),
      ],
    ),
  );
}
