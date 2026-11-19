import 'package:brix/auth.dart';
import 'package:equatable/equatable.dart';

/// What a change password screen shows: the three typed passwords, show /
/// hide for each, the new password's unmet rules and the loader.
class BrixChangePasswordState extends Equatable {
  BrixChangePasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.obscureCurrentPassword = true,
    this.obscureNewPassword = true,
    this.obscureConfirmPassword = true,
    List<PasswordRule> unmetPasswordRules = const [],
    this.isSubmitting = false,
  }) : unmetPasswordRules = List.unmodifiable(unmetPasswordRules);

  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool obscureCurrentPassword;
  final bool obscureNewPassword;
  final bool obscureConfirmPassword;

  /// Rules the typed new password does not meet yet; empty = allowed.
  final List<PasswordRule> unmetPasswordRules;

  /// A call is running; the button should show a loader.
  final bool isSubmitting;

  bool get passwordRulesMet => unmetPasswordRules.isEmpty;

  /// The confirm field matches the new password.
  bool get passwordsMatch => newPassword == confirmPassword;

  BrixChangePasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? obscureCurrentPassword,
    bool? obscureNewPassword,
    bool? obscureConfirmPassword,
    List<PasswordRule>? unmetPasswordRules,
    bool? isSubmitting,
  }) => BrixChangePasswordState(
    currentPassword: currentPassword ?? this.currentPassword,
    newPassword: newPassword ?? this.newPassword,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    obscureCurrentPassword:
        obscureCurrentPassword ?? this.obscureCurrentPassword,
    obscureNewPassword: obscureNewPassword ?? this.obscureNewPassword,
    obscureConfirmPassword:
        obscureConfirmPassword ?? this.obscureConfirmPassword,
    unmetPasswordRules: unmetPasswordRules ?? this.unmetPasswordRules,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    confirmPassword,
    obscureCurrentPassword,
    obscureNewPassword,
    obscureConfirmPassword,
    unmetPasswordRules,
    isSubmitting,
  ];
}
