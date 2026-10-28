import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Password input with a show / hide eye.
class PasswordField extends StatelessWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.label = 'Password',
    this.newPassword = false,
    this.focusNode,
    this.validator,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final RxBool obscure;
  final VoidCallback onToggle;
  final String label;

  /// Autofill as a new password (signup, reset) instead of a saved one.
  final bool newPassword;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => TextFormField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscure.value,
        autofillHints: [
          newPassword ? AutofillHints.newPassword : AutofillHints.password,
        ],
        textInputAction: onSubmitted == null
            ? TextInputAction.next
            : TextInputAction.done,
        onFieldSubmitted: onSubmitted,
        validator:
            validator ??
            (value) => (value ?? '').isEmpty ? 'Enter a password' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            onPressed: onToggle,
            icon: Icon(obscure.value ? Icons.visibility_off : Icons.visibility),
          ),
        ),
      ),
    );
  }
}
