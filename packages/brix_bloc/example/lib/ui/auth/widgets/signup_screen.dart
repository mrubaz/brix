import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';
import '../view_models/signup_viewmodel.dart';

/// Name, email, password with live rules, confirm password.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  SignupViewModel get _cubit => context.read<SignupViewModel>();

  void _signup() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _cubit.signup();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignupViewModel, BrixSignupState>(
      builder: (context, state) => AuthPage(
        title: 'Create account',
        subtitle: 'We send a code to your email to check it.',
        children: [
          Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                children: [
                  BrixTextField(
                    onChanged: _cubit.nameChanged,
                    label: 'Name',
                    isRequired: true,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  BrixTextField(
                    onChanged: _cubit.identifierChanged,
                    label: 'Email',
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  BrixTextField(
                    onChanged: _cubit.passwordChanged,
                    label: 'Password',
                    isRequired: true,
                    isPassword: true,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                  ),
                  PasswordChecklist(
                    policy: _cubit.flow.passwordPolicy,
                    unmet: state.unmetPasswordRules,
                  ),
                  const SizedBox(height: 16),
                  BrixTextField(
                    onChanged: _cubit.confirmPasswordChanged,
                    label: 'Confirm password',
                    isRequired: true,
                    isPassword: true,
                    validator: (_) => _cubit.state.passwordsMatch
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
      ),
    );
  }
}
