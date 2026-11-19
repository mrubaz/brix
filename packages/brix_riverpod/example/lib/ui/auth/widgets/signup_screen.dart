import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';
import '../view_models/signup_viewmodel.dart';

/// Name, email, password with live rules, confirm password.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  SignupViewModel get _viewModel => ref.read(signupProvider.notifier);

  void _signup() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _viewModel.signup();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(signupProvider);
    return AuthPage(
      title: 'Create account',
      subtitle: 'We send a code to your email to check it.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  onChanged: _viewModel.nameChanged,
                  label: 'Name',
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.name],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  onChanged: _viewModel.identifierChanged,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  onChanged: _viewModel.passwordChanged,
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                PasswordChecklist(
                  policy: _viewModel.flow.passwordPolicy,
                  unmet: state.unmetPasswordRules,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  onChanged: _viewModel.confirmPasswordChanged,
                  label: 'Confirm password',
                  isRequired: true,
                  isPassword: true,
                  validator: (_) => ref.read(signupProvider).passwordsMatch
                      ? null
                      : 'The passwords do not match.',
                  onSubmitted: (_) => _signup(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Sign up',
          isLoading: state.isSubmitting,
          onPressed: _signup,
        ),
      ],
    );
  }
}
