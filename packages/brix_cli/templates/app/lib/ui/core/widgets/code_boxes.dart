import 'package:brix_getx/brix_getx.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// One box per digit. Typing moves on, deleting a digit goes back, pasting
/// or autofill fills every box ([OtpCodeBoxes] does the work).
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({super.key, required this.boxes});

  final OtpCodeBoxes boxes;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    OutlineInputBorder edge(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(brix.shape.radius),
      borderSide: BorderSide(color: color, width: width),
    );
    return AutofillGroup(
      child: Row(
        children: [
          for (var i = 0; i < boxes.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: boxes.controllers[i],
                focusNode: boxes.focusNodes[i],
                autofocus: i == 0,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                autofillHints: i == 0
                    ? const [AutofillHints.oneTimeCode]
                    : null,
                style: brix.typography.title.copyWith(
                  fontSize: 24,
                  color: brix.colors.text,
                ),
                cursorColor: brix.colors.primary,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: brix.colors.surface,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: edge(Colors.transparent, 0),
                  enabledBorder: edge(Colors.transparent, 0),
                  focusedBorder: edge(brix.colors.primary, 2),
                ),
                onChanged: (value) {
                  boxes.onDigitChanged(i, value);
                  if (value.isEmpty) boxes.onDigitDeleted(i);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
