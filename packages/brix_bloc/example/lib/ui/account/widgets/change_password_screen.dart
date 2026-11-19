import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';

/// Current password, new password with live rules, confirm.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  BrixChangePasswordCubit get _cubit => context.read<BrixChangePasswordCubit>();

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrixChangePasswordCubit, BrixChangePasswordState>(
      builder: (context, state) => AuthPage(
        title: 'Change password',
        subtitle: 'Use one you do not use anywhere else.',
        children: [
          Form(
            key: _formKey,
            child: AutofillGroup(
              child: Column(
                children: [
                  BrixTextField(
                    onChanged: _cubit.currentPasswordChanged,
                    label: 'Current password',
                    isRequired: true,
                    isPassword: true,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  BrixTextField(
                    onChanged: _cubit.newPasswordChanged,
                    label: 'New password',
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
                    label: 'Confirm new password',
                    isRequired: true,
                    isPassword: true,
                    validator: (_) => _cubit.state.passwordsMatch
                        ? null
                        : 'The passwords do not match.',
                    onSubmitted: (_) => _submit(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          BrixButton(
            label: 'Change password',
            isLoading: state.isSubmitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
