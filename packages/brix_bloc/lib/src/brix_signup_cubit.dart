import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/auth.dart';

import 'brix_signup_state.dart';

/// Cubit for a signup screen, built on brix [SignupFlow]: email, password
/// and confirm with show / hide and the unmet password rules in the state.
///
/// Extend it for the app's own fields and body: keep extra values in your
/// subclass (for example `nameChanged`), build the typed body in
/// [buildRequest], and add checks such as accepted terms in [beforeSubmit].
abstract class BrixSignupCubit<TSignup, TUser> extends Cubit<BrixSignupState> {
  BrixSignupCubit(this.flow)
    : super(
        BrixSignupState(unmetPasswordRules: flow.passwordPolicy.unmetRules('')),
      ) {
    _subscription = flow.changes.listen(
      (form) => _emit(state.copyWith(isSubmitting: form.isSubmitting)),
    );
  }

  final SignupFlow<TSignup, TUser> flow;
  late final StreamSubscription<AuthFormState> _subscription;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  void _emit(BrixSignupState next) {
    if (!isClosed) emit(next);
  }

  void identifierChanged(String value) =>
      _emit(state.copyWith(identifier: value));

  void passwordChanged(String value) => _emit(
    state.copyWith(
      password: value,
      unmetPasswordRules: flow.passwordPolicy.unmetRules(value),
    ),
  );

  void confirmPasswordChanged(String value) =>
      _emit(state.copyWith(confirmPassword: value));

  void togglePasswordVisibility() =>
      _emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleConfirmPasswordVisibility() => _emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  /// The app's signup body. [identifier] is trimmed; put [password] in
  /// exactly as given.
  TSignup buildRequest({required String identifier, required String password});

  /// App checks before the call. Return false to stop (show your own
  /// message).
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

  @override
  Future<void> close() async {
    // The flow first and at once: it stops its timers before anything waits.
    final disposing = flow.dispose();
    await _subscription.cancel();
    await disposing;
    return super.close();
  }
}
