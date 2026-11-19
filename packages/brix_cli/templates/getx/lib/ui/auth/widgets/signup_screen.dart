import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';
import '../view_models/signup_viewmodel.dart';

/// Name, email, password with live rules, confirm password.
class SignupScreen extends GetView<SignupViewModel> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Create account',
      subtitle: 'We send a code to your email to check it.',
      children: [
        Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: controller.nameController,
                  label: 'Name',
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: controller.identifierController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: controller.passwordController,
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                PasswordChecklist(tracker: controller.passwordRules),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: controller.confirmPasswordController,
                  label: 'Confirm password',
                  isRequired: true,
                  isPassword: true,
                  validator: (value) =>
                      value == controller.passwordController.text
                      ? null
                      : 'The passwords do not match.',
                  onSubmitted: (_) => controller.signup(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => BrixButton(
            label: 'Sign up',
            isLoading: controller.isSubmitting.value,
            onPressed: controller.signup,
          ),
        ),
      ],
    );
  }
}
