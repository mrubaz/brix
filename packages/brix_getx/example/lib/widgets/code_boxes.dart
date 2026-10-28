import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';

/// One box per digit. Typing moves on, deleting a digit goes back, pasting
/// or autofill fills every box ([OtpCodeBoxes] does the work).
class CodeBoxes extends StatelessWidget {
  const CodeBoxes({super.key, required this.boxes});

  final OtpCodeBoxes boxes;

  @override
  Widget build(BuildContext context) {
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
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(border: OutlineInputBorder()),
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
