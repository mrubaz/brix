import 'package:brix/account.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'brix_auth_form_controller.dart';
import 'password_rules_tracker.dart';

/// GetX controller for a change password screen, built on brix
/// [ChangePasswordFlow]: current, new and confirm fields with show / hide
/// and a live checklist for the new password.
class BrixChangePasswordController
    extends BrixAuthFormController<ChangePasswordFlow> {
  BrixChangePasswordController(super.flow);

  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  late final PasswordRulesTracker passwordRules = PasswordRulesTracker(
    policy: flow.passwordPolicy,
    field: newPasswordController,
  );

  void toggleCurrentPasswordVisibility() => obscureCurrentPassword.toggle();

  void toggleNewPasswordVisibility() => obscureNewPassword.toggle();

  void toggleConfirmPasswordVisibility() => obscureConfirmPassword.toggle();

  /// Validates the form, then changes the password.
  Future<void> submit() async {
    if (!validateForm()) return;
    await flow.submit(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
    );
  }

  @override
  void onClose() {
    passwordRules.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
