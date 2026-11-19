import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/auth_page.dart';
import '../../core/widgets/password_checklist.dart';
import '../view_models/change_password_viewmodel.dart';

/// Current password, new password with live rules, confirm.
class ChangePasswordScreen extends ConsumerWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(changePasswordProvider);
    final change = ref.read(changePasswordProvider.notifier);
    return AuthPage(
      title: 'Change password',
      subtitle: 'Use one you do not use anywhere else.',
      children: [
        Form(
          key: change.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: change.currentPasswordController,
                  label: 'Current password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: change.newPasswordController,
                  label: 'New password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.newPassword],
                  textInputAction: TextInputAction.next,
                ),
                PasswordChecklist(
                  policy: change.flow.passwordPolicy,
                  unmet: state.unmetPasswordRules,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: change.confirmPasswordController,
                  label: 'Confirm new password',
                  isRequired: true,
                  isPassword: true,
                  validator: (value) =>
                      value == change.newPasswordController.text
                      ? null
                      : 'The passwords do not match.',
                  onSubmitted: (_) => change.submit(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Change password',
          isLoading: state.isSubmitting,
          onPressed: change.submit,
        ),
      ],
    );
  }
}
