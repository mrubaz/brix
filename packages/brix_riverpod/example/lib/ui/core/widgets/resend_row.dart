import 'package:flutter/material.dart';

/// "Resend code", disabled with a countdown until it may be used again.
class ResendRow extends StatelessWidget {
  const ResendRow({
    super.key,
    required this.seconds,
    required this.busy,
    required this.onResend,
  });

  final int seconds;
  final bool busy;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    final waiting = seconds > 0;
    return TextButton(
      onPressed: waiting || busy ? null : onResend,
      child: Text(waiting ? 'Resend code in ${seconds}s' : 'Resend code'),
    );
  }
}
