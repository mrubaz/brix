import 'package:brix/account.dart';
import 'package:flutter/widgets.dart';

import 'brix_auth_form_notifier.dart';
import 'brix_change_password_state.dart';

/// Riverpod notifier for a change password screen, built on brix
/// [ChangePasswordFlow]: current, new and confirm fields with show / hide
/// and the new password's unmet rules in the state.
///
/// Extend it and return the app's flow from [createFlow], like
/// `BrixLoginNotifier`.
abstract class BrixChangePasswordNotifier
    extends BrixAuthFormNotifier<ChangePasswordFlow, BrixChangePasswordState> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  @override
  void initFields() {
    super.initFields();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    newPasswordController.addListener(
      () => state = state.copyWith(
        unmetPasswordRules: flow.passwordPolicy.unmetRules(
          newPasswordController.text,
        ),
      ),
    );
  }

  @override
  BrixChangePasswordState initialState() => BrixChangePasswordState(
    unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
  );

  @override
  BrixChangePasswordState withSubmitting(
    BrixChangePasswordState current,
    bool isSubmitting,
  ) => current.copyWith(isSubmitting: isSubmitting);

  void toggleCurrentPasswordVisibility() => state = state.copyWith(
    obscureCurrentPassword: !state.obscureCurrentPassword,
  );

  void toggleNewPasswordVisibility() =>
      state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);

  void toggleConfirmPasswordVisibility() => state = state.copyWith(
    obscureConfirmPassword: !state.obscureConfirmPassword,
  );

  /// Validates the form, then changes the password.
  Future<void> submit() async {
    if (!validateForm()) return;
    await flow.submit(
      currentPassword: currentPasswordController.text,
      newPassword: newPasswordController.text,
    );
  }

  @override
  void disposeFields() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.disposeFields();
  }
}
