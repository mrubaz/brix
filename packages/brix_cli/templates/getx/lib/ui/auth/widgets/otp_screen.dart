import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';

/// The code sent after signup. Typing the last digit verifies it.
class OtpScreen extends GetView<BrixOtpController<User>> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Check your email',
      subtitle:
          Dependencies.devTools?.codeHint ?? 'Enter the code we sent you.',
      children: [
        Obx(() => Text('Code sent to ${controller.maskedIdentifier.value}')),
        TextButton(
          onPressed: controller.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        const SizedBox(height: 8),
        CodeBoxes(boxes: controller.boxes),
        const SizedBox(height: 24),
        Obx(
          () => BrixButton(
            label: 'Verify',
            isLoading: controller.isSubmitting.value,
            onPressed: controller.verify,
          ),
        ),
        ResendRow(
          seconds: controller.resendSeconds,
          busy: controller.isResending,
          onResend: controller.resend,
        ),
      ],
    );
  }
}
