import 'package:brix/auth.dart';

/// What a signup screen shows: the loader, show / hide for both password
/// fields and the rules the typed password does not meet yet.
class BrixSignupState {
  BrixSignupState({
    this.isSubmitting = false,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    List<PasswordRule> unmetPasswordRules = const [],
  }) : unmetPasswordRules = List.unmodifiable(unmetPasswordRules);

  /// A signup call is running; the button should show a loader.
  final bool isSubmitting;

  final bool obscurePassword;

  final bool obscureConfirmPassword;

  /// Rules the typed password does not meet yet; empty = allowed.
  final List<PasswordRule> unmetPasswordRules;

  bool get passwordRulesMet => unmetPasswordRules.isEmpty;

  BrixSignupState copyWith({
    bool? isSubmitting,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    List<PasswordRule>? unmetPasswordRules,
  }) => BrixSignupState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    obscureConfirmPassword:
        obscureConfirmPassword ?? this.obscureConfirmPassword,
    unmetPasswordRules: unmetPasswordRules ?? this.unmetPasswordRules,
  );
}
