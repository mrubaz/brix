import 'package:brix/auth.dart';
import 'package:equatable/equatable.dart';

/// What the "new password" screen shows: the code part, the typed new
/// password, its visibility and the rules it does not meet yet.
class BrixResetPasswordState extends Equatable {
  BrixResetPasswordState({
    this.code = const CodeEntryState(),
    this.newPassword = '',
    this.obscureNewPassword = true,
    List<PasswordRule> unmetPasswordRules = const [],
  }) : unmetPasswordRules = List.unmodifiable(unmetPasswordRules);

  /// Busy, resend countdown, masked email and failed attempts, from the flow.
  final CodeEntryState code;
  final String newPassword;
  final bool obscureNewPassword;

  /// Rules the typed new password does not meet yet; empty = allowed.
  final List<PasswordRule> unmetPasswordRules;

  bool get passwordRulesMet => unmetPasswordRules.isEmpty;

  BrixResetPasswordState copyWith({
    CodeEntryState? code,
    String? newPassword,
    bool? obscureNewPassword,
    List<PasswordRule>? unmetPasswordRules,
  }) => BrixResetPasswordState(
    code: code ?? this.code,
    newPassword: newPassword ?? this.newPassword,
    obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
    unmetPasswordRules: unmetPasswordRules ?? this.unmetPasswordRules,
  );

  @override
  List<Object?> get props => [
    code,
    newPassword,
    obscureNewPassword,
    unmetPasswordRules,
  ];
}
