import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/auth_page.dart';
import '../widgets/password_checklist.dart';

/// Name, email, password with live rules, confirm password.
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(signupProvider);
    final notifier = ref.read(signupProvider.notifier);
    return AuthPage(
      title: 'Create account',
      subtitle: 'We send a code to your email to check it.',
      children: [
        Form(
          key: notifier.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: notifier.nameController,
                  label: 'Name',
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: notifier.identifierController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: notifier.passwordController,
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                PasswordChecklist(
                  policy: notifier.flow.passwordPolicy,
                  unmet: state.unmetPasswordRules,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: notifier.confirmPasswordController,
                  label: 'Confirm password',
                  isRequired: true,
                  isPassword: true,
                  validator: (value) =>
                      value == notifier.passwordController.text
                      ? null
                      : 'The passwords do not match.',
                  onSubmitted: (_) => notifier.signup(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Sign up',
          isLoading: state.isSubmitting,
          onPressed: notifier.signup,
        ),
      ],
    );
  }
}
