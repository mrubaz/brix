import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';

/// Current password, new password with live rules, confirm.
class ChangePasswordScreen extends GetView<BrixChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Change password',
      subtitle: 'Use one you do not use anywhere else.',
      children: [
        Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: controller.currentPasswordController,
                  label: 'Current password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: controller.newPasswordController,
                  label: 'New password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                PasswordChecklist(tracker: controller.passwordRules),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: controller.confirmPasswordController,
                  label: 'Confirm new password',
                  isRequired: true,
                  isPassword: true,
                  validator: (value) =>
                      value == controller.newPasswordController.text
                      ? null
                      : 'The passwords do not match.',
                  onSubmitted: (_) => controller.submit(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => BrixButton(
            label: 'Change password',
            isLoading: controller.isSubmitting.value,
            onPressed: controller.submit,
          ),
        ),
      ],
    );
  }
}
