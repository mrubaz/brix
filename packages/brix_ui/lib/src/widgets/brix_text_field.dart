import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/brix_theme_context.dart';
import 'brix_field_look.dart';
import 'brix_text_field_data.dart';
import 'brix_text_field_style.dart';

/// A form field styled from the theme: label above, `*` when required,
/// primary border on focus, danger border and text on error.
///
/// - [isPassword] hides the text and adds a show / hide button; it turns
///   off autocorrect and suggestions. The value is never trimmed.
/// - Keyboard: [TextInputAction.next] moves to the next field, `done`
///   closes the keyboard; a tap outside closes it too.
/// - Errors: [validator] inside a `Form`, or [errorText] from outside
///   (e.g. a backend field error). A required field with no [validator]
///   checks it is not empty.
///
/// Its look comes from `BrixTheme.textField` with [style] on top. To draw
/// a completely own field and keep this logic, give a [builder] (or
/// `BrixTheme.textFieldBuilder` for every field).
///
/// ```dart
/// BrixTextField(
///   controller: email,
///   label: 'Email',
///   isRequired: true,
///   keyboardType: TextInputType.emailAddress,
///   autofillHints: const [AutofillHints.email],
///   textInputAction: TextInputAction.next,
/// )
/// ```
class BrixTextField extends StatefulWidget {
  const BrixTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.isRequired = false,
    this.requiredMessage,
    this.isPassword = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.style,
    this.builder,
  });

  final TextEditingController? controller;

  /// Starting text when there is no [controller].
  final String? initialValue;

  /// Shown above the field.
  final String? label;

  /// Grey text inside the empty field.
  final String? hint;

  /// Adds a `*` to the label and, without a [validator], an empty check.
  final bool isRequired;

  /// Error shown by the built-in empty check; defaults to the theme's
  /// `texts.requiredField`.
  final String? requiredMessage;

  /// Hidden text with a show / hide button.
  final bool isPassword;

  final Widget? prefixIcon;

  /// Ignored when [isPassword], the show / hide button takes its place.
  final Widget? suffixIcon;

  final TextInputType? keyboardType;

  /// Defaults to `done` (or a new line for a multi-line field).
  final TextInputAction? textInputAction;

  final TextCapitalization textCapitalization;

  /// What the field holds, so password managers and the keyboard can fill
  /// it (`AutofillHints.email`, `.password`, `.newPassword`...). Put the
  /// form's fields in an `AutofillGroup` to save new passwords.
  final Iterable<String>? autofillHints;

  final FormFieldValidator<String>? validator;

  /// An error from outside the form (e.g. the backend); shown until it is
  /// set back to `null`.
  final String? errorText;

  final ValueChanged<String>? onChanged;

  /// Runs when the keyboard's action key is pressed (e.g. Done submits).
  final ValueChanged<String>? onSubmitted;

  final VoidCallback? onTap;

  /// Shows the text but cannot be typed in (e.g. opens a picker on tap).
  final bool readOnly;

  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  /// This field's look, on top of `BrixTheme.textField`.
  final BrixTextFieldStyle? style;

  /// Draws this field instead of brix (wins over
  /// `BrixTheme.textFieldBuilder`).
  final BrixTextFieldBuilder? builder;

  @override
  State<BrixTextField> createState() => _BrixTextFieldState();
}

class _BrixTextFieldState extends State<BrixTextField> {
  FocusNode? _ownFocusNode;
  TextEditingController? _ownController;
  bool _obscured = true;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _ownFocusNode?.dispose();
    _ownController?.dispose();
    super.dispose();
  }

  TextInputAction get _action =>
      widget.textInputAction ??
      (widget.maxLines > 1 ? TextInputAction.newline : TextInputAction.done);

  String? _validate(String? value) {
    if (widget.validator != null) return widget.validator!(value);
    // A password of spaces is still typed text; other fields need more.
    final empty = widget.isPassword
        ? value?.isEmpty ?? true
        : value?.trim().isEmpty ?? true;
    if (widget.isRequired && empty) {
      return widget.requiredMessage ?? context.brix.texts.requiredField;
    }
    return null;
  }

  void _onEditingComplete() {
    switch (_action) {
      case TextInputAction.next:
        _focusNode.nextFocus();
      case TextInputAction.newline:
        break;
      default:
        _focusNode.unfocus();
    }
  }

  void _toggleObscured() => setState(() => _obscured = !_obscured);

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final style = brix.textField.merge(widget.style);
    final builder = widget.builder ?? brix.textFieldBuilder;
    if (builder != null) {
      return builder(
        context,
        BrixTextFieldData(
          controller: _controller,
          focusNode: _focusNode,
          label: widget.label,
          hint: widget.hint,
          isRequired: widget.isRequired,
          isPassword: widget.isPassword,
          obscureText: widget.isPassword && _obscured,
          toggleObscured: widget.isPassword ? _toggleObscured : null,
          validator: _validate,
          errorText: widget.errorText,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          onEditingComplete: _onEditingComplete,
          onTap: widget.onTap,
          onTapOutside: (_) => _focusNode.unfocus(),
          textInputAction: _action,
          keyboardType: widget.isPassword
              ? TextInputType.visiblePassword
              : widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          autofillHints: widget.enabled ? widget.autofillHints : null,
          autocorrect: !widget.isPassword,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.isPassword ? null : widget.suffixIcon,
          style: style,
        ),
      );
    }

    final colors = brix.colors;
    final canType = widget.enabled && !widget.readOnly;
    final look = BrixFieldLook(brix, style);
    final labelText = look.label(widget.label, isRequired: widget.isRequired);

    final passwordToggle = IconButton(
      tooltip: _obscured ? brix.texts.showPassword : brix.texts.hidePassword,
      icon: (_obscured ? brix.icons.showPassword : brix.icons.hidePassword)
          .build(color: colors.mutedText, size: 24),
      onPressed: _toggleObscured,
    );

    final field = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.isPassword && _obscured,
      autocorrect: !widget.isPassword,
      enableSuggestions: !widget.isPassword,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      textInputAction: _action,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.enabled ? widget.autofillHints : null,
      validator: _validate,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      onEditingComplete: _onEditingComplete,
      onTap: widget.onTap,
      onTapOutside: (_) => _focusNode.unfocus(),
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      cursorColor: colors.primary,
      style: look.textStyle(enabled: widget.enabled),
      decoration: look.decoration(
        canType: canType,
        label: labelText,
        hint: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.isPassword ? passwordToggle : widget.suffixIcon,
      ),
    );

    // The label is read with the field, not as separate text, so the
    // password button stays its own accessible button.
    return look.withLabel(field, labelText, widget.label);
  }
}
