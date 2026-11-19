import 'package:brix/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brix_signup_state.dart';

/// Riverpod notifier for a signup screen, built on brix [SignupFlow]: email,
/// password and confirm with show / hide and the unmet password rules in
/// the state. No Flutter objects inside.
///
/// Extend it for the app's own values and body: keep extra values in your
/// subclass (for example `nameChanged`), build the typed body in
/// [buildRequest], and add checks such as accepted terms in [beforeSubmit].
abstract class BrixSignupNotifier<TSignup, TUser>
    extends Notifier<BrixSignupState> {
  late SignupFlow<TSignup, TUser> flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  SignupFlow<TSignup, TUser> createFlow();

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  @override
  BrixSignupState build() {
    flow = createFlow();
    final subscription = flow.changes.listen(
      (form) => _set(state.copyWith(isSubmitting: form.isSubmitting)),
    );
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    return BrixSignupState(
      unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
    );
  }

  void _set(BrixSignupState next) {
    if (ref.mounted) state = next;
  }

  void identifierChanged(String value) =>
      _set(state.copyWith(identifier: value));

  void passwordChanged(String value) => _set(
    state.copyWith(
      password: value,
      unmetPasswordRules: flow.passwordPolicy.unmetRules(value),
    ),
  );

  void confirmPasswordChanged(String value) =>
      _set(state.copyWith(confirmPassword: value));

  void togglePasswordVisibility() =>
      _set(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleConfirmPasswordVisibility() => _set(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  /// The app's signup body. [identifier] is trimmed; put [password] in
  /// exactly as given.
  TSignup buildRequest({required String identifier, required String password});

  /// App checks before the call. Return false to stop (show your own
  /// message).
  @protected
  Future<bool> beforeSubmit() async => true;

  /// Runs [beforeSubmit], then signs up with what is typed. Check the form
  /// first.
  Future<void> signup() async {
    if (state.isSubmitting) return;
    if (!await beforeSubmit()) return;
    final identifier = state.identifier.trim();
    final password = state.password;
    await flow.submit(
      request: buildRequest(identifier: identifier, password: password),
      identifier: identifier,
      password: password,
    );
  }
}
