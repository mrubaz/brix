import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/password_checklist.dart';
import '../../core/widgets/resend_row.dart';

/// Code + new password with live rules.
class ResetPasswordScreen extends GetView<BrixResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'New password',
      subtitle:
          Dependencies.devTools?.codeHint ??
          'Enter the code and your new password.',
      children: [
        Obx(() => Text('Code sent to ${controller.maskedIdentifier.value}')),
        TextButton(
          onPressed: controller.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        CodeBoxes(boxes: controller.boxes),
        const SizedBox(height: 16),
        Form(
          key: controller.formKey,
          child: BrixTextField(
            controller: controller.newPasswordController,
            focusNode: controller.newPasswordFocus,
            label: 'New password',
            isRequired: true,
            isPassword: true,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => controller.submit(),
          ),
        ),
        PasswordChecklist(tracker: controller.passwordRules),
        const SizedBox(height: 24),
        Obx(
          () => BrixButton(
            label: 'Save password',
            isLoading: controller.isSubmitting.value,
            onPressed: controller.submit,
          ),
        ),
        ResendRow(
          seconds: controller.resendSeconds,
          busy: controller.isResending,
          onResend: controller.resend,
        ),
      ],
    );
  }
}
