import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/auth_page.dart';
import '../widgets/busy_button.dart';

class ForgotPasswordScreen extends GetView<BrixForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Forgot password',
      subtitle: 'We send a code to set a new password.',
      children: [
        Form(
          key: controller.formKey,
          child: TextFormField(
            controller: controller.identifierController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => controller.submit(),
            validator: (value) =>
                (value ?? '').trim().contains('@') ? null : 'Enter your email',
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        BusyButton(
          label: 'Send code',
          busy: controller.isSubmitting,
          onPressed: controller.submit,
        ),
      ],
    );
  }
}
