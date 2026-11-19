import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';
import '../view_models/delete_account_viewmodel.dart';

/// Sends a code to [identifier], then deletes the account with it. Nothing deletes on its
/// own: the button does.
class DeleteAccountScreen extends ConsumerStatefulWidget {
  const DeleteAccountScreen({super.key, required this.identifier});

  final String identifier;

  @override
  ConsumerState<DeleteAccountScreen> createState() =>
      _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends ConsumerState<DeleteAccountScreen> {
  late final _provider = deleteAccountProvider(widget.identifier);
  DeleteAccountViewModel get _viewModel => ref.read(_provider.notifier);
  late final _boxes = OtpCodeBoxes(length: _viewModel.otpLength);

  @override
  void dispose() {
    _boxes.dispose();
    super.dispose();
  }

  void _confirm() {
    FocusManager.instance.primaryFocus?.unfocus();
    _viewModel.confirm(_boxes.code);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, (before, now) {
      if (before == null) return;
      // The boxes appear once the code is sent: start typing there.
      if (!before.isCodeSent && now.isCodeSent) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _boxes.focusNodes.first.requestFocus(),
        );
      }
      // A wrong code clears them.
      if (now.failedAttempts != before.failedAttempts) _boxes.clear();
    });
    final state = ref.watch(_provider);
    return AuthPage(
      title: 'Delete account',
      subtitle: 'This removes your account and its data for good.',
      children: [
        if (!state.isCodeSent)
          BrixButton.destructive(
            label: 'Send me a code',
            isLoading: state.isRequesting,
            onPressed: _viewModel.requestDeletion,
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
                onResend: _viewModel.resend,
              ),
            ],
          ),
      ],
    );
  }
}
