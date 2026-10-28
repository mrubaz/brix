import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../routes.dart';
import '../widgets/auth_page.dart';
import '../widgets/busy_button.dart';
import '../widgets/password_field.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Log in',
      subtitle: 'Demo account: demo@brix.dev / Demo@1234',
      children: [
        Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                TextFormField(
                  controller: controller.identifierController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  validator: _requiredEmail,
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
                  onSubmitted: (_) => controller.login(),
                ),
              ],
            ),
          ),
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (_) => controller.toggleRememberMe(),
                  ),
                ),
                const Text('Remember me'),
              ],
            ),
            TextButton(
              onPressed: () => Get.toNamed(Routes.forgotPassword),
              child: const Text('Forgot password?'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BusyButton(
          label: 'Log in',
          busy: controller.isSubmitting,
          onPressed: controller.login,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Get.toNamed(Routes.signup),
          child: const Text('No account? Sign up'),
        ),
      ],
    );
  }
}

String? _requiredEmail(String? value) =>
    (value ?? '').trim().contains('@') ? null : 'Enter your email';
