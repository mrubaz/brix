import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';

/// Sends a code, then deletes the account with it. Nothing deletes on its
/// own: the button does.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  late final BrixDeleteAccountCubit _cubit = context
      .read<BrixDeleteAccountCubit>();
  late final _boxes = OtpCodeBoxes(length: _cubit.otpLength);

  @override
  void dispose() {
    _boxes.dispose();
    super.dispose();
  }

  void _confirm() {
    FocusManager.instance.primaryFocus?.unfocus();
    _cubit.confirm(_boxes.code);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrixDeleteAccountCubit, CodeEntryState>(
      // The boxes appear once the code is sent, and a wrong code empties
      // them: either way start typing in the first box. After the frame,
      // so the boxes are on screen.
      listener: (context, state) =>
          WidgetsBinding.instance.addPostFrameCallback((_) => _boxes.clear()),
      listenWhen: (before, now) =>
          (!before.isCodeSent && now.isCodeSent) ||
          now.failedAttempts != before.failedAttempts,
      builder: (context, state) => AuthPage(
        title: 'Delete account',
        subtitle: 'This removes your account and its data for good.',
        children: [
          if (!state.isCodeSent)
            BrixButton.destructive(
              label: 'Send me a code',
              isLoading: state.isRequesting,
              onPressed: _cubit.requestDeletion,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Code sent to ${state.maskedIdentifier}'),
                if (Dependencies.devTools case final dev?) Text(dev.codeHint),
                const SizedBox(height: 12),
                CodeBoxes(boxes: _boxes),
                const SizedBox(height: 24),
                BrixButton.destructive(
                  label: 'Delete my account',
                  isLoading: state.isSubmitting,
                  onPressed: _confirm,
                ),
                ResendRow(
                  seconds: state.resendIn.inSeconds,
                  busy: state.isResending,
                  onResend: _cubit.resend,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
