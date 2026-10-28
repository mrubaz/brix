import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'brix_auth_form_controller.dart';

/// GetX controller for a login screen, built on brix [LoginFlow].
///
/// Bind `formKey`, [identifierController] and [passwordController] in the
/// view, show `isSubmitting` on the button and call [login].
class BrixLoginController<TUser>
    extends BrixAuthFormController<LoginFlow<TUser>> {
  BrixLoginController(super.flow);

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();

  final rememberMe = false.obs;
  final obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fillRemembered();
  }

  Future<void> _fillRemembered() async {
    final saved = await flow.loadRemembered();
    if (saved == null || isClosed) return;
    identifierController.text = saved.identifier;
    passwordController.text = saved.password;
    rememberMe.value = true;
  }

  /// Fills the email, e.g. back from a reset or a verified signup. The
  /// password is filled only when "remember me" holds this account's.
  Future<void> prefillIdentifier(String identifier) async {
    identifierController.text = identifier;
    final saved = await flow.loadRemembered();
    if (isClosed) return;
    if (saved != null && saved.identifier == identifier) {
      passwordController.text = saved.password;
      rememberMe.value = true;
    } else {
      passwordController.clear();
    }
  }

  void togglePasswordVisibility() => obscurePassword.toggle();

  void toggleRememberMe() => rememberMe.toggle();

  /// Validates the form, then logs in. Double taps are ignored by the flow.
  Future<void> login() async {
    if (!validateForm()) return;
    await flow.submit(
      identifier: identifierController.text,
      password: passwordController.text,
      rememberMe: rememberMe.value,
    );
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
