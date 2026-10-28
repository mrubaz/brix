import 'package:brix/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Shows what the flows report: the backend's text when it sent one, else
/// brix's default text (`displayMessage`, `warning.message`). Use your own
/// wording wherever you like, e.g. `switch` on the failure type.
class DemoFeedback extends AuthFeedback {
  @override
  void failure(Failure failure) =>
      _show(failure.displayMessage, Colors.red.shade700);

  @override
  void warning(AuthWarning warning) =>
      _show(warning.message, Colors.orange.shade800);

  @override
  void success(String? message) {
    if (message != null) _show(message, Colors.green.shade700);
  }

  void _show(String text, Color color) {
    final messenger = ScaffoldMessenger.maybeOf(Get.context!);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text), backgroundColor: color));
  }
}
