import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';
import '../view_models/delete_account_viewmodel.dart';

/// Sends a code to [identifier], then deletes the account with it.
class DeleteAccountScreen extends ConsumerWidget {
  const DeleteAccountScreen({super.key, required this.identifier});

  final String identifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = deleteAccountProvider(identifier);
    final state = ref.watch(provider);
    final delete = ref.read(provider.notifier);
    return AuthPage(
      title: 'Delete account',
      subtitle: 'This removes your account and its data for good.',
      children: [
        if (!state.isCodeSent)
          BrixButton.destructive(
            label: 'Send me a code',
            isLoading: state.isRequesting,
            onPressed: delete.requestDeletion,
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Code sent to ${state.maskedIdentifier}'),
              if (Dependencies.devTools case final dev?) Text(dev.codeHint),
              const SizedBox(height: 12),
              CodeBoxes(boxes: delete.boxes),
              const SizedBox(height: 24),
              BrixButton.destructive(
                label: 'Delete my account',
                isLoading: state.isSubmitting,
                onPressed: delete.confirm,
              ),
              ResendRow(
                seconds: state.resendIn.inSeconds,
                busy: state.isResending,
                onResend: delete.resend,
              ),
            ],
          ),
      ],
    );
  }
}
