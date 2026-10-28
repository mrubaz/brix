import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Filled button that shows a spinner and ignores taps while [busy] is true.
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.busy,
    required this.onPressed,
  });

  final String label;
  final RxBool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => FilledButton(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: busy.value ? null : onPressed,
        child: busy.value
            ? const SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}
