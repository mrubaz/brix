import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/password_checklist.dart';
import '../../core/widgets/resend_row.dart';
import '../view_models/reset_password_viewmodel.dart';

/// Code + new password with live rules. A full code moves to the password;
/// a wrong code clears the boxes. [identifier] is the email the code went
/// to.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key, required this.identifier});

  final String identifier;

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFocus = FocusNode();
  late final _provider = resetPasswordProvider(widget.identifier);
  ResetPasswordViewModel get _viewModel => ref.read(_provider.notifier);
  late final _boxes = OtpCodeBoxes(
    length: _viewModel.otpLength,
    onCompleted: _passwordFocus.requestFocus,
  );

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.submit(_boxes.code);
    }
  }

  @override
  void dispose() {
    _boxes.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, (before, now) {
      if (before != null &&
          now.code.failedAttempts != before.code.failedAttempts) {
        _boxes.clear();
      }
    });
    final state = ref.watch(_provider);
    return AuthPage(
      title: 'New password',
      subtitle:
          Dependencies.devTools?.codeHint ??
          'Enter the code and your new password.',
      children: [
        Text('Code sent to ${state.code.maskedIdentifier}'),
        TextButton(
          onPressed: _viewModel.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        CodeBoxes(boxes: _boxes),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: BrixTextField(
            onChanged: _viewModel.newPasswordChanged,
            focusNode: _passwordFocus,
            label: 'New password',
            isRequired: true,
            isPassword: true,
            autofillHints: const [AutofillHints.newPassword],
            onSubmitted: (_) => _submit(),
          ),
        ),
        PasswordChecklist(
          policy: _viewModel.flow.passwordPolicy,
          unmet: state.unmetPasswordRules,
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Save password',
          isLoading: state.code.isSubmitting,
          onPressed: _submit,
        ),
        ResendRow(
          seconds: state.code.resendIn.inSeconds,
          busy: state.code.isResending,
          onResend: _viewModel.resend,
        ),
      ],
    );
  }
}
