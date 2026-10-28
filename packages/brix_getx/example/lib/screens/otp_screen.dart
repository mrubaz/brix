import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/auth_page.dart';
import '../widgets/busy_button.dart';
import '../widgets/code_boxes.dart';
import '../widgets/resend_row.dart';

/// Signup code. The email comes from the session store, so the screen also
/// works after an app restart.
class OtpScreen extends GetView<BrixOtpController<String>> {
  const OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Check your email',
      subtitle: 'Demo code: 123456',
      children: [
        Obx(() => Text('Code sent to ${controller.maskedIdentifier.value}')),
        TextButton(
          onPressed: controller.changeIdentifier,
          child: const Text('Wrong email? Change it'),
        ),
        const SizedBox(height: 8),
        CodeBoxes(boxes: controller.boxes),
        const SizedBox(height: 24),
        BusyButton(
          label: 'Verify',
          busy: controller.isSubmitting,
          onPressed: controller.verify,
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
