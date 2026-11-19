import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/password_checklist.dart';
import '../../core/widgets/resend_row.dart';

/// Code + new password with live rules. A full code moves to the password;
/// a wrong code clears the boxes.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFocus = FocusNode();
  late final BrixResetPasswordCubit _cubit = context
      .read<BrixResetPasswordCubit>();
  late final _boxes = OtpCodeBoxes(
    length: _cubit.otpLength,
    onCompleted: _passwordFocus.requestFocus,
  );

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _cubit.submit(_boxes.code);
  }

  @override
  void dispose() {
    _boxes.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrixResetPasswordCubit, BrixResetPasswordState>(
      listenWhen: (before, now) =>
          now.code.failedAttempts != before.code.failedAttempts,
      listener: (context, state) => _boxes.clear(),
      builder: (context, state) => AuthPage(
        title: 'New password',
        subtitle:
            Dependencies.devTools?.codeHint ??
            'Enter the code and your new password.',
        children: [
          Text('Code sent to ${state.code.maskedIdentifier}'),
          TextButton(
            onPressed: _cubit.changeIdentifier,
            child: const Text('Wrong email? Change it'),
          ),
          CodeBoxes(boxes: _boxes),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: BrixTextField(
              onChanged: _cubit.newPasswordChanged,
              focusNode: _passwordFocus,
              label: 'New password',
              isRequired: true,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
              onSubmitted: (_) => _submit(),
            ),
          ),
          PasswordChecklist(
            policy: _cubit.flow.passwordPolicy,
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
            onResend: _cubit.resend,
          ),
        ],
      ),
    );
  }
}
