import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/auth_page.dart';
import '../widgets/busy_button.dart';
import '../widgets/code_boxes.dart';
import '../widgets/password_checklist.dart';
import '../widgets/password_field.dart';
import '../widgets/resend_row.dart';

/// Code and new password on one screen ([ResetMode.otp]).
class ResetPasswordScreen extends GetView<BrixResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'New password',
      subtitle: 'Demo code: 123456',
      children: [
        Obx(() => Text('Code sent to ${controller.maskedIdentifier.value}')),
        TextButton(
          onPressed: controller.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        const SizedBox(height: 8),
        CodeBoxes(boxes: controller.boxes),
        ResendRow(
          seconds: controller.resendSeconds,
          busy: controller.isResending,
          onResend: controller.resend,
        ),
        const SizedBox(height: 8),
        Form(
          key: controller.formKey,
          child: PasswordField(
            label: 'New password',
            controller: controller.newPasswordController,
            focusNode: controller.newPasswordFocus,
            obscure: controller.obscureNewPassword,
            onToggle: controller.toggleNewPasswordVisibility,
            newPassword: true,
            onSubmitted: (_) => controller.submit(),
          ),
        ),
        PasswordChecklist(tracker: controller.passwordRules),
        const SizedBox(height: 24),
        BusyButton(
          label: 'Save password',
          busy: controller.isSubmitting,
          onPressed: controller.submit,
        ),
      ],
    );
  }
}
