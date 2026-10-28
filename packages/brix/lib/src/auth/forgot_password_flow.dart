import '../core/result.dart';
import 'auth_capabilities.dart';
import 'auth_form_flow.dart';
import 'auth_navigator.dart';

/// The "forgot password" screen: asks the backend to send a reset code or
/// link, then moves on as [AuthCapabilities.resetMode] says.
class ForgotPasswordFlow extends AuthFormFlow<Object?> {
  ForgotPasswordFlow({
    required super.provider,
    required this._navigator,
    required super.feedback,
  });

  final AuthNavigator _navigator;

  /// Sends the reset code or link for [identifier] (trimmed).
  ///
  /// Code: opens the reset password screen. Link: back to login – the user
  /// finishes in the email.
  Future<void> submit({required String identifier}) => run(() async {
    final trimmedIdentifier = identifier.trim();
    final result = await provider.forgotPassword(identifier: trimmedIdentifier);
    switch (result) {
      case Success(:final message):
        feedback.success(message);
        switch (provider.capabilities.resetMode) {
          case ResetMode.otp:
            await _navigator.toResetPassword(identifier: trimmedIdentifier);
          case ResetMode.link:
            await _navigator.toLogin();
          case ResetMode.none:
            break;
        }
      case Failed(:final failure):
        feedback.failure(failure);
    }
  });
}
