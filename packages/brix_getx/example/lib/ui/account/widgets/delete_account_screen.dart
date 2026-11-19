import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/auth_page.dart';
import '../../core/widgets/code_boxes.dart';
import '../../core/widgets/resend_row.dart';

/// Asks for a code by email, then deletes the account with it.
class DeleteAccountScreen extends GetView<BrixDeleteAccountController> {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Delete account',
      subtitle: 'This removes your account and its data for good.',
      children: [
        Obx(() {
          if (!controller.isCodeSent.value) {
            return BrixButton.destructive(
              label: 'Send me a code',
              isLoading: controller.isRequesting.value,
              onPressed: controller.requestDeletion,
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Code sent to ${controller.maskedIdentifier.value}'),
              if (Dependencies.devTools case final dev?) Text(dev.codeHint),
              const SizedBox(height: 12),
              CodeBoxes(boxes: controller.boxes),
              const SizedBox(height: 24),
              BrixButton.destructive(
                label: 'Delete my account',
                isLoading: controller.isSubmitting.value,
                onPressed: controller.confirm,
              ),
              ResendRow(
                seconds: controller.resendSeconds,
                busy: controller.isResending,
                onResend: controller.resend,
              ),
            ],
          );
        }),
      ],
    );
  }
}
