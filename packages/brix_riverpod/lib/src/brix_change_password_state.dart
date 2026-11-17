import 'package:brix/auth.dart';

/// What a change password screen shows: the loader, show / hide for the
/// three fields and the rules the new password does not meet yet.
class BrixChangePasswordState {
  BrixChangePasswordState({
    this.isSubmitting = false,
    this.obscureCurrentPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    List<PasswordRule> unmetPasswordRules = const [],
  }) : unmetPasswordRules = List.unmodifiable(unmetPasswordRules);

  /// A call is running; the button should show a loader.
  final bool isSubmitting;

  final bool obscureCurrentPassword;

  final bool obscureNewPassword;

  final bool obscureConfirmPassword;

  /// Rules the typed new password does not meet yet; empty = allowed.
  final List<PasswordRule> unmetPasswordRules;

  bool get passwordRulesMet => unmetPasswordRules.isEmpty;

  BrixChangePasswordState copyWith({
    bool? isSubmitting,
    bool? obscureCurrentPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    List<PasswordRule>? unmetPasswordRules,
  }) => BrixChangePasswordState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    obscureCurrentPassword:
        obscureCurrentPassword ?? this.obscureCurrentPassword,
    obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
    obscureConfirmPassword:
        obscureConfirmPassword ?? this.obscureConfirmPassword,
    unmetPasswordRules: unmetPasswordRules ?? this.unmetPasswordRules,
  );
}
