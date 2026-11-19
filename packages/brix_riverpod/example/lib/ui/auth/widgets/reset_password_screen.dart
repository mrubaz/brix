import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/password_checklist.dart';
import '../../core/widgets/resend_row.dart';
import '../view_models/reset_password_viewmodel.dart';

/// Code + new password with live rules, for [identifier].
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key, required this.identifier});

  final String identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = resetPasswordProvider(identifier);
    final state = ref.watch(provider);
    final reset = ref.read(provider.notifier);
    return AuthPage(
      title: 'New password',
      subtitle:
          Dependencies.devTools?.codeHint ??
          'Enter the code and your new password.',
      children: [
        Text('Code sent to ${state.code.maskedIdentifier}'),
        TextButton(
          onPressed: reset.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        CodeBoxes(boxes: reset.boxes),
        const SizedBox(height: 16),
        Form(
          key: reset.formKey,
          child: BrixTextField(
            controller: reset.newPasswordController,
            focusNode: reset.newPasswordFocus,
            label: 'New password',
            isRequired: true,
            isPassword: true,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => reset.submit(),
          ),
        ),
        PasswordChecklist(
          policy: reset.flow.passwordPolicy,
          unmet: state.unmetPasswordRules,
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Save password',
          isLoading: state.code.isSubmitting,
          onPressed: reset.submit,
        ),
        ResendRow(
          seconds: state.code.resendIn.inSeconds,
          busy: state.code.isResending,
          onResend: reset.resend,
        ),
      ],
    );
  }
}
