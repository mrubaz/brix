import 'package:flutter/widgets.dart';

/// The text fields of a code entered one digit per box. Used by every code
/// screen controller, so typing, paste and clearing behave the same.
///
/// Give each box `maxLength: length` (not 1), so a whole pasted code
/// reaches [onDigitChanged], and `AutofillHints.oneTimeCode` for the
/// keyboard's code suggestion.
class OtpCodeBoxes {
  OtpCodeBoxes({required this.length, this.onCompleted})
    : controllers = List.generate(length, (_) => TextEditingController()),
      focusNodes = List.generate(length, (_) => FocusNode());

  /// Number of boxes (digits in a code).
  final int length;

  /// Runs when every box has a digit (auto submit). Null = do nothing.
  final VoidCallback? onCompleted;

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;

  /// The digits typed so far, in box order.
  String get code => controllers.map((box) => box.text).join();

  bool get isComplete => code.length == length;

  /// Call from box [index]'s `onChanged`. Typing moves to the next box; a
  /// pasted or autofilled code fills every box.
  void onDigitChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      controllers[index].clear();
      return;
    }
    if (digits.length >= length) {
      for (var i = 0; i < length; i++) {
        _setBox(i, digits[i]);
      }
      FocusManager.instance.primaryFocus?.unfocus();
      _completeIfFull();
      return;
    }
    // Typed into a box that already had a digit: keep the new one.
    _setBox(index, digits[digits.length - 1]);
    if (index < length - 1) {
      focusNodes[index + 1].requestFocus();
    } else {
      focusNodes[index].unfocus();
    }
    _completeIfFull();
  }

  /// Call when backspace is pressed in an empty box [index].
  void onDigitDeleted(int index) {
    if (index > 0) focusNodes[index - 1].requestFocus();
  }

  /// Empties every box and puts the cursor in the first one (wrong code).
  void clear() {
    for (final box in controllers) {
      box.clear();
    }
    focusNodes.first.requestFocus();
  }

  void dispose() {
    for (final box in controllers) {
      box.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
  }

  void _completeIfFull() {
    if (isComplete) onCompleted?.call();
  }

  void _setBox(int index, String digit) {
    controllers[index].value = TextEditingValue(
      text: digit,
      selection: const TextSelection.collapsed(offset: 1),
    );
  }
}
