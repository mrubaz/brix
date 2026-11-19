import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';
import '../view_models/otp_viewmodel.dart';

/// The code sent after signup. Typing the last digit verifies it; a
/// rejected code clears the boxes.
class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  OtpViewModel get _viewModel => ref.read(otpProvider.notifier);
  late final _boxes = OtpCodeBoxes(
    length: _viewModel.otpLength,
    onCompleted: _verify,
  );

  void _verify() {
    FocusManager.instance.primaryFocus?.unfocus();
    _viewModel.verify(_boxes.code);
  }

  @override
  void dispose() {
    _boxes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // A rejected code clears the boxes.
    ref.listen(otpProvider, (before, now) {
      if (before != null && now.failedAttempts != before.failedAttempts) {
        _boxes.clear();
      }
    });
    final state = ref.watch(otpProvider);
    return AuthPage(
      title: 'Check your email',
      subtitle:
          Dependencies.devTools?.codeHint ?? 'Enter the code we sent you.',
      children: [
        Text('Code sent to ${state.maskedIdentifier}'),
        TextButton(
          onPressed: _viewModel.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        const SizedBox(height: 8),
        CodeBoxes(boxes: _boxes),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Verify',
          isLoading: state.isSubmitting,
          onPressed: _verify,
        ),
        ResendRow(
          seconds: state.resendIn.inSeconds,
          busy: state.isResending,
          onResend: _viewModel.resend,
        ),
      ],
    );
  }
}
