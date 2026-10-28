import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_auth_form_controller.dart';

/// GetX controller for a "forgot password" screen, built on brix
/// [ForgotPasswordFlow]. Bind `formKey` and [identifierController], show
/// `isSubmitting` on the button and call [submit].
class BrixForgotPasswordController
    extends BrixAuthFormController<ForgotPasswordFlow> {
  BrixForgotPasswordController(super.flow);

  final identifierController = TextEditingController();

  /// Validates the form, then asks for the reset code or link.
  Future<void> submit() async {
    if (!validateForm()) return;
    await flow.submit(identifier: identifierController.text);
  }

  @override
  void onClose() {
    identifierController.dispose();
    super.onClose();
  }
}
