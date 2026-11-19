import 'package:brix/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brix_reset_password_state.dart';

/// Riverpod notifier for the "new password" screen, built on brix
/// [ResetPasswordFlow]: the code part, the new password with its unmet
/// rules, resend and "change email". It starts right after the build;
/// opened without an email, it goes back to login.
///
/// The screen owns the code boxes and passes the typed code to [submit].
abstract class BrixResetPasswordNotifier
    extends Notifier<BrixResetPasswordState> {
  late ResetPasswordFlow flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  ResetPasswordFlow createFlow();

  /// Digits in a code, for the boxes.
  int get otpLength => flow.otpLength;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  @override
  BrixResetPasswordState build() {
    flow = createFlow();
    final subscription = flow.changes.listen((code) {
      if (ref.mounted) state = state.copyWith(code: code);
    });
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    Future.microtask(() {
      if (ref.mounted) flow.start();
    });
    return BrixResetPasswordState(
      code: flow.state,
      unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
    );
  }

  void newPasswordChanged(String value) {
    if (!ref.mounted) return;
    state = state.copyWith(
      newPassword: value,
      unmetPasswordRules: flow.passwordPolicy.unmetRules(value),
    );
  }

  void toggleNewPasswordVisibility() {
    if (!ref.mounted) return;
    state = state.copyWith(obscureNewPassword: !state.obscureNewPassword);
  }

  /// Sets the new password with [code]. Check the form first.
  Future<void> submit(String code) =>
      flow.submit(code: code, newPassword: state.newPassword);

  Future<void> resend() => flow.resend();

  /// Wrong email: back to the forgot password screen.
  Future<void> changeIdentifier() => flow.changeIdentifier();
}
