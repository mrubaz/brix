import 'package:brix/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brix_change_password_state.dart';

/// Riverpod notifier for a change password screen, built on brix
/// [ChangePasswordFlow]: current, new and confirm with show / hide and the
/// new password's unmet rules in the state. Check the form, then call
/// [submit].
abstract class BrixChangePasswordNotifier
    extends Notifier<BrixChangePasswordState> {
  late ChangePasswordFlow flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  ChangePasswordFlow createFlow();

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get passwordRules => flow.passwordPolicy.rules;

  @override
  BrixChangePasswordState build() {
    flow = createFlow();
    final subscription = flow.changes.listen(
      (form) => _set(state.copyWith(isSubmitting: form.isSubmitting)),
    );
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    return BrixChangePasswordState(
      unmetPasswordRules: flow.passwordPolicy.unmetRules(''),
    );
  }

  void _set(BrixChangePasswordState next) {
    if (ref.mounted) state = next;
  }

  void currentPasswordChanged(String value) =>
      _set(state.copyWith(currentPassword: value));

  void newPasswordChanged(String value) => _set(
    state.copyWith(
      newPassword: value,
      unmetPasswordRules: flow.passwordPolicy.unmetRules(value),
    ),
  );

  void confirmPasswordChanged(String value) =>
      _set(state.copyWith(confirmPassword: value));

  void toggleCurrentPasswordVisibility() => _set(
    state.copyWith(obscureCurrentPassword: !state.obscureCurrentPassword),
  );

  void toggleNewPasswordVisibility() =>
      _set(state.copyWith(obscureNewPassword: !state.obscureNewPassword));

  void toggleConfirmPasswordVisibility() => _set(
    state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword),
  );

  /// Changes the password with what is typed.
  Future<void> submit() => flow.submit(
    currentPassword: state.currentPassword,
    newPassword: state.newPassword,
  );
}
