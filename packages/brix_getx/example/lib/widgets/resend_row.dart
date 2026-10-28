import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// "Resend code" – disabled with a countdown until it may be used again.
class ResendRow extends StatelessWidget {
  const ResendRow({
    super.key,
    required this.seconds,
    required this.busy,
    required this.onResend,
  });

  final RxInt seconds;
  final RxBool busy;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final waiting = seconds.value > 0;
      return TextButton(
        onPressed: waiting || busy.value ? null : onResend,
        child: Text(
          waiting ? 'Resend code in ${seconds.value}s' : 'Resend code',
        ),
      );
    });
  }
}
