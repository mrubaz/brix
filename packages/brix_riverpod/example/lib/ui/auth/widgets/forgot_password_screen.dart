import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/auth_page.dart';
import '../view_models/forgot_password_viewmodel.dart';

/// Email for the reset code.
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);
    final forgot = ref.read(forgotPasswordProvider.notifier);
    return AuthPage(
      title: 'Forgot password',
      subtitle: 'We send a code to reset it.',
      children: [
        Form(
          key: forgot.formKey,
          child: BrixTextField(
            controller: forgot.identifierController,
            label: 'Email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => forgot.submit(),
          ),
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Send code',
          isLoading: state.isSubmitting,
          onPressed: forgot.submit,
        ),
      ],
    );
  }
}
