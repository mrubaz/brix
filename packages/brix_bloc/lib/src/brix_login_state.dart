import 'package:equatable/equatable.dart';

/// What a login screen shows: the typed email and password, "remember me",
/// whether the password is hidden, and the loader.
class BrixLoginState extends Equatable {
  const BrixLoginState({
    this.identifier = '',
    this.password = '',
    this.rememberMe = false,
    this.obscurePassword = true,
    this.isSubmitting = false,
  });

  final String identifier;
  final String password;
  final bool rememberMe;
  final bool obscurePassword;

  /// A login call is running; the button should show a loader.
  final bool isSubmitting;

  BrixLoginState copyWith({
    String? identifier,
    String? password,
    bool? rememberMe,
    bool? obscurePassword,
    bool? isSubmitting,
  }) => BrixLoginState(
    identifier: identifier ?? this.identifier,
    password: password ?? this.password,
    rememberMe: rememberMe ?? this.rememberMe,
    obscurePassword: obscurePassword ?? this.obscurePassword,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );

  @override
  List<Object?> get props => [
    identifier,
    password,
    rememberMe,
    obscurePassword,
    isSubmitting,
  ];
}
