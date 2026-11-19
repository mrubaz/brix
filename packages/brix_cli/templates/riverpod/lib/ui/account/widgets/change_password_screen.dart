import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';
import '../view_models/change_password_viewmodel.dart';

/// Current password, new password with live rules, confirm.
class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  ChangePasswordViewModel get _viewModel =>
      ref.read(changePasswordProvider.notifier);

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _viewModel.submit();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    return AuthPage(
      title: 'Change password',
      subtitle: 'Use one you do not use anywhere else.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  onChanged: _viewModel.currentPasswordChanged,
                  label: 'Current password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  onChanged: _viewModel.newPasswordChanged,
                  label: 'New password',
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
                  label: 'Confirm new password',
                  isRequired: true,
                  isPassword: true,
                  validator: (_) =>
                      ref.read(changePasswordProvider).passwordsMatch
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
    );
  }
}
