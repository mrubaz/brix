import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/auth_page.dart';

/// Email for the reset code.
class ForgotPasswordScreen extends GetView<BrixForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Forgot password',
      subtitle: 'We send a code to reset it.',
      children: [
        Form(
          key: controller.formKey,
          child: BrixTextField(
            controller: controller.identifierController,
            label: 'Email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => controller.submit(),
          ),
        ),
        const SizedBox(height: 24),
        Obx(
          () => BrixButton(
            label: 'Send code',
            isLoading: controller.isSubmitting.value,
            onPressed: controller.submit,
          ),
        ),
      ],
    );
  }
}
