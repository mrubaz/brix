import 'package:brix/auth.dart';

/// What the "new password" screen shows: the code part, the new password's
/// visibility and the rules it does not meet yet.
class BrixResetPasswordState {
  BrixResetPasswordState({
    this.code = const CodeEntryState(),
    this.obscureNewPassword = true,
    List<PasswordRule> unmetPasswordRules = const [],
  }) : unmetPasswordRules = List.unmodifiable(unmetPasswordRules);

  /// Busy, resend countdown and masked email, from the flow.
  final CodeEntryState code;

  final bool obscureNewPassword;

  /// Rules the typed new password does not meet yet; empty = allowed.
  final List<PasswordRule> unmetPasswordRules;

  bool get passwordRulesMet => unmetPasswordRules.isEmpty;

  BrixResetPasswordState copyWith({
    CodeEntryState? code,
    bool? obscureNewPassword,
    List<PasswordRule>? unmetPasswordRules,
  }) => BrixResetPasswordState(
    code: code ?? this.code,
    obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
    unmetPasswordRules: unmetPasswordRules ?? this.unmetPasswordRules,
  );
}
