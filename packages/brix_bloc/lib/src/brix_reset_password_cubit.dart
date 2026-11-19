import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/auth.dart';

import 'brix_reset_password_state.dart';

/// Cubit for the "new password" screen, built on brix [ResetPasswordFlow]:
/// the code part, the new password with its unmet rules, resend and
/// "change email". It starts at once; opened without an email, it goes
/// back to login.
///
/// The screen owns the code boxes and passes the typed code to [submit].
class BrixResetPasswordCubit extends Cubit<BrixResetPasswordState> {
  BrixResetPasswordCubit(this.flow)
    : super(
        BrixResetPasswordState(
          code: flow.state,
          unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
        ),
      ) {
    _subscription = flow.changes.listen((code) {
      if (!isClosed) emit(state.copyWith(code: code));
    });
    flow.start();
  }

  final ResetPasswordFlow flow;
  late final StreamSubscription<CodeEntryState> _subscription;

  /// Digits in a code, for the boxes.
  int get otpLength => flow.otpLength;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  void newPasswordChanged(String value) {
    if (isClosed) return;
    emit(
      state.copyWith(
        newPassword: value,
        unmetPasswordRules: flow.passwordPolicy.unmetRules(value),
      ),
    );
  }

  void toggleNewPasswordVisibility() {
    if (isClosed) return;
    emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));
  }

  /// Sets the new password with [code]. Check the form first.
  Future<void> submit(String code) =>
      flow.submit(code: code, newPassword: state.newPassword);

  Future<void> resend() => flow.resend();

  /// Wrong email: back to the forgot password screen.
  Future<void> changeIdentifier() => flow.changeIdentifier();

  @override
  Future<void> close() async {
    // The flow first and at once: it stops its timers before anything waits.
    final disposing = flow.dispose();
    await _subscription.cancel();
    await disposing;
    return super.close();
  }
}
