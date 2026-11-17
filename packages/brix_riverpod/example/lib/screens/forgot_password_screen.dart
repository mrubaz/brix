import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/auth_page.dart';

/// Email for the reset code.
class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);
    final notifier = ref.read(forgotPasswordProvider.notifier);
    return AuthPage(
      title: 'Forgot password',
      subtitle: 'We send a code to reset it.',
      children: [
        Form(
          key: notifier.formKey,
          child: BrixTextField(
            controller: notifier.identifierController,
            label: 'Email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => notifier.submit(),
          ),
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Send code',
          isLoading: state.isSubmitting,
          onPressed: notifier.submit,
        ),
      ],
    );
  }
}
