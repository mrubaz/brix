import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/signup_controller.dart';
import '../widgets/auth_page.dart';
import '../widgets/busy_button.dart';
import '../widgets/password_checklist.dart';
import '../widgets/password_field.dart';

class SignupScreen extends GetView<SignupController> {
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
                TextFormField(
                  controller: controller.nameController,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter your name' : null,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.identifierController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: (value) => (value ?? '').trim().contains('@')
                      ? null
                      : 'Enter your email',
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: controller.passwordController,
                  obscure: controller.obscurePassword,
                  onToggle: controller.togglePasswordVisibility,
                  newPassword: true,
                ),
                PasswordChecklist(tracker: controller.passwordRules),
                const SizedBox(height: 16),
                PasswordField(
                  label: 'Confirm password',
                  controller: controller.confirmPasswordController,
                  obscure: controller.obscureConfirmPassword,
                  onToggle: controller.toggleConfirmPasswordVisibility,
                  newPassword: true,
                  validator: (value) =>
                      value == controller.passwordController.text
                      ? null
                      : 'Passwords do not match',
                  onSubmitted: (_) => controller.signup(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        BusyButton(
          label: 'Sign up',
          busy: controller.isSubmitting,
          onPressed: controller.signup,
        ),
      ],
    );
  }
}
