import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_auth_form_notifier.dart';
import 'brix_signup_state.dart';

/// Riverpod notifier for a signup screen, built on brix [SignupFlow].
///
/// Holds the fields every signup has (email, password, confirm password)
/// with show / hide and the unmet password rules in the state. The app
/// adds its own fields in `initFields` / `disposeFields` and overrides
/// [buildRequest] (its typed body) and, for its own checks such as
/// accepted terms, [beforeSubmit].
abstract class BrixSignupNotifier<TSignup, TUser>
    extends BrixAuthFormNotifier<SignupFlow<TSignup, TUser>, BrixSignupState> {
  late TextEditingController identifierController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  @override
  void initFields() {
    super.initFields();
    identifierController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    passwordController.addListener(
      () => state = state.copyWith(
        unmetPasswordRules: flow.passwordPolicy.unmetRules(
          passwordController.text,
        ),
      ),
    );
  }

  @override
  BrixSignupState initialState() =>
      BrixSignupState(unmetPasswordRules: flow.passwordPolicy.unmetRules(''));

  @override
  BrixSignupState withSubmitting(BrixSignupState current, bool isSubmitting) =>
      current.copyWith(isSubmitting: isSubmitting);

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleConfirmPasswordVisibility() => state = state.copyWith(
    obscureConfirmPassword: !state.obscureConfirmPassword,
  );

  /// The app's signup body. [identifier] is trimmed; put [password] in
  /// exactly as given.
  TSignup buildRequest({required String identifier, required String password});

  /// App checks after the form is valid and before the call. Return false
  /// to stop (show your own message).
  @protected
  Future<bool> beforeSubmit() async => true;

  /// Validates the form, runs [beforeSubmit], then signs up.
  Future<void> signup() async {
    if (state.isSubmitting || !validateForm()) return;
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
  void disposeFields() {
    identifierController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.disposeFields();
  }
}
