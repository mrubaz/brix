import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_code_entry_notifier.dart';
import 'brix_reset_password_state.dart';

/// Riverpod notifier for the "new password" screen, built on brix
/// [ResetPasswordFlow]: code boxes, a new password with its unmet rules in
/// the state, resend countdown and "change email". Opened without an
/// email, it goes back to login.
///
/// The last digit does not submit (the new password comes next); it moves
/// to [newPasswordFocus].
abstract class BrixResetPasswordNotifier
    extends BrixCodeEntryNotifier<ResetPasswordFlow, BrixResetPasswordState> {
  final formKey = GlobalKey<FormState>();

  late TextEditingController newPasswordController;
  late FocusNode newPasswordFocus;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  @override
  void initFields() {
    super.initFields();
    newPasswordController = TextEditingController();
    newPasswordFocus = FocusNode();
    newPasswordController.addListener(
      () => state = state.copyWith(
        unmetPasswordRules: flow.passwordPolicy.unmetRules(
          newPasswordController.text,
        ),
      ),
    );
  }

  @override
  BrixResetPasswordState build() {
    final initial = super.build();
    startAfterBuild(flow.start);
    return initial;
  }

  @override
  BrixResetPasswordState initialState(CodeEntryState code) =>
      BrixResetPasswordState(
        code: code,
        unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
      );

  @override
  BrixResetPasswordState withCodeEntry(
    BrixResetPasswordState current,
    CodeEntryState code,
  ) => current.copyWith(code: code);

  @override
  void Function()? get onCodeCompleted =>
      () => newPasswordFocus.requestFocus();

  void toggleNewPasswordVisibility() =>
      state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);

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
  void disposeFields() {
    newPasswordController.dispose();
    newPasswordFocus.dispose();
    super.disposeFields();
  }
}
