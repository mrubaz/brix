import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';
import '../view_models/otp_viewmodel.dart';

/// The code sent after signup. Typing the last digit verifies it.
class OtpScreen extends ConsumerWidget {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(otpProvider);
    final otp = ref.read(otpProvider.notifier);
    return AuthPage(
      title: 'Check your email',
      subtitle:
          Dependencies.devTools?.codeHint ?? 'Enter the code we sent you.',
      children: [
        Text('Code sent to ${state.maskedIdentifier}'),
        TextButton(
          onPressed: otp.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        const SizedBox(height: 8),
        CodeBoxes(boxes: otp.boxes),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Verify',
          isLoading: state.isSubmitting,
          onPressed: otp.verify,
        ),
        ResendRow(
          seconds: state.resendIn.inSeconds,
          busy: state.isResending,
          onResend: otp.resend,
        ),
      ],
    );
  }
}
