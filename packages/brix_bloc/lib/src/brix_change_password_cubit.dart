import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/account.dart';

import 'brix_change_password_state.dart';

/// Cubit for a change password screen, built on brix [ChangePasswordFlow]:
/// current, new and confirm with show / hide and the new password's unmet
/// rules in the state. Check the form, then call [submit].
class BrixChangePasswordCubit extends Cubit<BrixChangePasswordState> {
  BrixChangePasswordCubit(this.flow)
    : super(
        BrixChangePasswordState(
          unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
        ),
      ) {
    _subscription = flow.changes.listen(
      (form) => _emit(state.copyWith(isSubmitting: form.isSubmitting)),
    );
  }

  final ChangePasswordFlow flow;
  late final StreamSubscription<AuthFormState> _subscription;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  void _emit(BrixChangePasswordState next) {
    if (!isClosed) emit(next);
  }

  void currentPasswordChanged(String value) =>
      _emit(state.copyWith(currentPassword: value));

  void newPasswordChanged(String value) => _emit(
    state.copyWith(
      newPassword: value,
      unmetPasswordRules: flow.passwordPolicy.unmetRules(value),
    ),
  );

  void confirmPasswordChanged(String value) =>
      _emit(state.copyWith(confirmPassword: value));

  void toggleCurrentPasswordVisibility() => _emit(
    state.copyWith(obscureCurrentPassword: !state.obscureCurrentPassword),
  );

  void toggleNewPasswordVisibility() =>
      _emit(state.copyWith(obscureNewPassword: !state.obscureNewPassword));

  void toggleConfirmPasswordVisibility() => _emit(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  /// Changes the password with what is typed.
  Future<void> submit() => flow.submit(
    currentPassword: state.currentPassword,
    newPassword: state.newPassword,
  );

  @override
  Future<void> close() async {
    // The flow first and at once: it stops its timers before anything waits.
    final disposing = flow.dispose();
    await _subscription.cancel();
    await disposing;
    return super.close();
  }
}
