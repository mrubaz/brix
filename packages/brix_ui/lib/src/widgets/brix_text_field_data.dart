import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'brix_text_field_style.dart';

/// Builds an app's own text field from what `BrixTextField` knows. brix
/// keeps the logic – required check, password show / hide, Next / Done,
/// closing the keyboard on a tap outside; pass the values below to your
/// `TextFormField` and they work.
typedef BrixTextFieldBuilder = Widget Function(
  BuildContext context,
  BrixTextFieldData field,
);

/// Everything a [BrixTextFieldBuilder] needs to draw a field.
class BrixTextFieldData {
  const BrixTextFieldData({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.isRequired,
    required this.isPassword,
    required this.obscureText,
    required this.toggleObscured,
    required this.validator,
    required this.errorText,
    required this.onChanged,
    required this.onSubmitted,
    required this.onEditingComplete,
    required this.onTap,
    required this.onTapOutside,
    required this.textInputAction,
    required this.keyboardType,
    required this.textCapitalization,
    required this.autofillHints,
    required this.autocorrect,
    required this.inputFormatters,
    required this.maxLines,
    required this.maxLength,
    required this.enabled,
    required this.readOnly,
    required this.prefixIcon,
    required this.suffixIcon,
    required this.style,
  });

  /// Always set – brix makes one when the app gave none.
  final TextEditingController controller;
  final FocusNode focusNode;

  final String? label;
  final String? hint;
  final bool isRequired;
  final bool isPassword;

  /// Hide the text now (a password the user has not chosen to show).
  final bool obscureText;

  /// Shows / hides a password; `null` when it is not a password field.
  final VoidCallback? toggleObscured;

  /// The app's validator, or brix's required check.
  final FormFieldValidator<String> validator;

  /// An error from outside the form (e.g. the backend).
  final String? errorText;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Next moves on, Done closes the keyboard.
  final VoidCallback onEditingComplete;

  final VoidCallback? onTap;

  /// Closes the keyboard.
  final TapRegionCallback onTapOutside;

  final TextInputAction textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;

  /// Off for passwords.
  final bool autocorrect;

  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final Widget? prefixIcon;

  /// The app's suffix icon (a password field gets none – draw your own
  /// show / hide button with [toggleObscured]).
  final Widget? suffixIcon;

  /// The theme's field style with the field's own on top.
  final BrixTextFieldStyle style;
}
