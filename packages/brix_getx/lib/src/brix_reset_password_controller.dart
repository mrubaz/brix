import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'brix_code_entry_controller.dart';
import 'password_rules_tracker.dart';

/// GetX controller for the "new password" screen, built on brix
/// [ResetPasswordFlow]: code boxes, a new password with a live rules
/// checklist, resend countdown and "change email". Opened without an
/// email, it goes back to login.
///
/// The last digit does not submit (the new password comes next); it moves
/// to [newPasswordFocus].
class BrixResetPasswordController
    extends BrixCodeEntryController<ResetPasswordFlow> {
  BrixResetPasswordController(super.flow);

  final formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final newPasswordFocus = FocusNode();
  final obscureNewPassword = true.obs;

  late final PasswordRulesTracker passwordRules = PasswordRulesTracker(
    policy: flow.passwordPolicy,
    field: newPasswordController,
  );

  @override
  void Function()? get onCodeCompleted => newPasswordFocus.requestFocus;

  @override
  void onReady() {
    super.onReady();
    flow.start();
  }

  void toggleNewPasswordVisibility() => obscureNewPassword.toggle();

  /// Validates the form, then sets the new password.
  Future<void> submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    await flow.submit(
      code: boxes.code,
      newPassword: newPasswordController.text,
    );
  }

  /// Wrong email: back to the forgot password screen.
  Future<void> changeIdentifier() => flow.changeIdentifier();

  @override
  void onClose() {
    passwordRules.dispose();
    newPasswordController.dispose();
    newPasswordFocus.dispose();
    super.onClose();
  }
}
