import 'package:brix/auth.dart';
import 'package:equatable/equatable.dart';

/// What a signup screen shows: the typed email and passwords, show / hide
/// for both password fields, the rules the password does not meet yet and
/// the loader.
class BrixSignupState extends Equatable {
  BrixSignupState({
    this.identifier = '',
    this.password = '',
    this.confirmPassword = '',
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    List<PasswordRule> unmetPasswordRules = const [],
    this.isSubmitting = false,
  }) : unmetPasswordRules = List.unmodifiable(unmetPasswordRules);

  final String identifier;
  final String password;
  final String confirmPassword;
  final bool obscurePassword;
  final bool obscureConfirmPassword;

  /// Rules the typed password does not meet yet; empty = allowed.
  final List<PasswordRule> unmetPasswordRules;

  /// A signup call is running; the button should show a loader.
  final bool isSubmitting;

  bool get passwordRulesMet => unmetPasswordRules.isEmpty;

  /// The confirm field matches the password.
  bool get passwordsMatch => password == confirmPassword;

  BrixSignupState copyWith({
    String? identifier,
    String? password,
    String? confirmPassword,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    List<PasswordRule>? unmetPasswordRules,
    bool? isSubmitting,
  }) => BrixSignupState(
    identifier: identifier ?? this.identifier,
    password: password ?? this.password,
    confirmPassword: confirmPassword ?? this.confirmPassword,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    obscureConfirmPassword:
        obscureConfirmPassword ?? this.obscureConfirmPassword,
    unmetPasswordRules: unmetPasswordRules ?? this.unmetPasswordRules,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  @override
  List<Object?> get props => [
    identifier,
    password,
    confirmPassword,
    obscurePassword,
    obscureConfirmPassword,
    unmetPasswordRules,
    isSubmitting,
  ];
}
