import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../widgets/auth_page.dart';
import '../widgets/code_boxes.dart';
import '../widgets/resend_row.dart';

/// The code sent after signup. Typing the last digit verifies it. The
/// email comes from the session store, so it also works after a restart.
class OtpScreen extends ConsumerWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(otpProvider);
    final notifier = ref.read(otpProvider.notifier);
    return AuthPage(
      title: 'Check your email',
      subtitle: 'Demo code: 123456',
      children: [
        Text('Code sent to ${state.maskedIdentifier}'),
        TextButton(
          onPressed: notifier.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        const SizedBox(height: 8),
        CodeBoxes(boxes: notifier.boxes),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Verify',
          isLoading: state.isSubmitting,
          onPressed: notifier.verify,
        ),
        ResendRow(
          seconds: state.resendIn.inSeconds,
          busy: state.isResending,
          onResend: notifier.resend,
        ),
      ],
    );
  }
}
