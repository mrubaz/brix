import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/auth_page.dart';
import '../widgets/code_boxes.dart';
import '../widgets/password_checklist.dart';
import '../widgets/resend_row.dart';

/// Code + new password with live rules. [identifier] is the email the code
/// was sent to.
class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key, required this.identifier});

  final String identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = resetPasswordProvider(identifier);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);
    return AuthPage(
      title: 'New password',
      subtitle: 'Demo code: 123456',
      children: [
        Text('Code sent to ${state.code.maskedIdentifier}'),
        TextButton(
          onPressed: notifier.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        CodeBoxes(boxes: notifier.boxes),
        const SizedBox(height: 16),
        Form(
          key: notifier.formKey,
          child: BrixTextField(
            controller: notifier.newPasswordController,
            focusNode: notifier.newPasswordFocus,
            label: 'New password',
            isRequired: true,
            isPassword: true,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => notifier.submit(),
          ),
        ),
        PasswordChecklist(
          policy: notifier.flow.passwordPolicy,
          unmet: state.unmetPasswordRules,
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Save password',
          isLoading: state.code.isSubmitting,
          onPressed: notifier.submit,
        ),
        ResendRow(
          seconds: state.code.resendIn.inSeconds,
          busy: state.code.isResending,
          onResend: notifier.resend,
        ),
      ],
    );
  }
}
