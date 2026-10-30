import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/dependencies.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/auth_page.dart';
import '../view_models/login_viewmodel.dart';

/// Email, password, remember me. Only layout, the view model does the rest.
class LoginScreen extends GetView<LoginViewModel> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Welcome back',
      subtitle: 'Log in to continue.',
      children: [
        Form(
          key: controller.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
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
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => controller.login(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => SwitchListTile.adaptive(
            value: controller.rememberMe.value,
            onChanged: (_) => controller.toggleRememberMe(),
            title: const Text('Remember me'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => BrixButton(
            label: 'Log in',
            isLoading: controller.isSubmitting.value,
            onPressed: controller.login,
          ),
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.forgotPassword),
          child: const Text('Forgot password?'),
        ),
        TextButton(
          onPressed: () => Get.toNamed(Routes.signup),
          child: const Text('No account? Sign up'),
        ),
        // Only while developing (main_development.dart); never in a release.
        if (Dependencies.devTools case final dev?) ...[
          const SizedBox(height: 16),
          Text(dev.loginHint, textAlign: TextAlign.center),
          TextButton(
            onPressed: () async {
              await dev.resetLocalBackend();
              BrixToast.success('Local backend reset on this device.');
            },
            child: const Text('Reset local backend'),
          ),
        ],
      ],
    );
  }
}
