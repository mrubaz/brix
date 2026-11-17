/// What a login screen shows: the loader, "remember me" and whether the
/// password is hidden.
class BrixLoginState {
  const BrixLoginState({
    this.isSubmitting = false,
    this.rememberMe = false,
    this.obscurePassword = true,
  });

  /// A login call is running; the button should show a loader.
  final bool isSubmitting;

  final bool rememberMe;

  final bool obscurePassword;

  BrixLoginState copyWith({
    bool? isSubmitting,
    bool? rememberMe,
    bool? obscurePassword,
  }) => BrixLoginState(
    isSubmitting: isSubmitting ?? this.isSubmitting,
    rememberMe: rememberMe ?? this.rememberMe,
    obscurePassword: obscurePassword ?? this.obscurePassword,
  );
}
