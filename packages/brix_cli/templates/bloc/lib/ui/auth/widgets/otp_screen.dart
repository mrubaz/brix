import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';

/// The code sent after signup. Typing the last digit verifies it; a
/// rejected code clears the boxes.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final BrixOtpCubit<User> _cubit = context.read<BrixOtpCubit<User>>();
  late final _boxes = OtpCodeBoxes(
    length: _cubit.otpLength,
    onCompleted: _verify,
  );

  void _verify() {
    FocusManager.instance.primaryFocus?.unfocus();
    _cubit.verify(_boxes.code);
  }

  @override
  void dispose() {
    _boxes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrixOtpCubit<User>, CodeEntryState>(
      listenWhen: (before, now) => now.failedAttempts != before.failedAttempts,
      listener: (context, state) => _boxes.clear(),
      builder: (context, state) => AuthPage(
        title: 'Check your email',
        subtitle:
            Dependencies.devTools?.codeHint ?? 'Enter the code we sent you.',
        children: [
          Text('Code sent to ${state.maskedIdentifier}'),
          TextButton(
            onPressed: _cubit.changeIdentifier,
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
            onResend: _cubit.resend,
          ),
        ],
      ),
    );
  }
}
