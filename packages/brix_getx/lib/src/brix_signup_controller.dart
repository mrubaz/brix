import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'brix_auth_form_controller.dart';
import 'password_rules_tracker.dart';

/// GetX controller for a signup screen, built on brix [SignupFlow].
///
/// Holds the fields every signup has (email, password, confirm password)
/// with show / hide and a live password checklist. The app adds its own
/// fields and overrides [buildRequest] (its typed body) and, for its own
/// checks such as accepted terms, [beforeSubmit].
abstract class BrixSignupController<TSignup, TUser>
    extends BrixAuthFormController<SignupFlow<TSignup, TUser>> {
  BrixSignupController(super.flow);

  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;

  late final PasswordRulesTracker passwordRules = PasswordRulesTracker(
    policy: flow.passwordPolicy,
    field: passwordController,
  );

  void togglePasswordVisibility() => obscurePassword.toggle();

  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  /// The app's signup body. [identifier] is trimmed; put [password] in
  /// exactly as given.
  TSignup buildRequest({required String identifier, required String password});

  /// App checks after the form is valid and before the call. Return false
  /// to stop (show your own message).
  @protected
  Future<bool> beforeSubmit() async => true;

  /// Validates the form, runs [beforeSubmit], then signs up.
  Future<void> signup() async {
    if (isSubmitting.value || !validateForm()) return;
    if (!await beforeSubmit()) return;
    final identifier = identifierController.text.trim();
    final password = passwordController.text;
    await flow.submit(
      request: buildRequest(identifier: identifier, password: password),
      identifier: identifier,
      password: password,
    );
  }

  @override
  void onClose() {
    passwordRules.dispose();
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
