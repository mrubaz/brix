import 'auth_capabilities.dart';
import 'otp_purpose.dart';

/// Opens the app's screens for the auth flows, so brix never knows route
/// names or the navigation library.
///
/// Every call completes once the screen is opened – never wait for the new
/// screen to close (e.g. do not return `Get.toNamed`'s future), or the flow
/// stays busy.
///
/// Only [toHome] and [toLogin] must be written. The others are needed only
/// when [AuthCapabilities] turns their flow on; until overridden they throw
/// [UnsupportedError], which points at a missing override, not a user error.
abstract class AuthNavigator {
  const AuthNavigator();

  /// The first screen after a successful login. Replaces the auth screens.
  Future<void> toHome();

  /// Login, replacing every screen before it (after logout, reset, verify).
  /// [identifier] fills the login form when given (e.g. after a reset).
  Future<void> toLogin({String? identifier});

  Future<void> toSignup() async => _unsupported('toSignup');

  /// The code screen for [identifier].
  Future<void> toOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async => _unsupported('toOtp');

  /// Back to the forgot password screen (wrong email on the reset screen).
  Future<void> toForgotPassword() async => _unsupported('toForgotPassword');

  /// Closes the current screen (e.g. change password after saving).
  Future<void> back() async => _unsupported('back');

  /// The new password screen, used when [ResetMode.otp] is on.
  Future<void> toResetPassword({required String identifier}) async =>
      _unsupported('toResetPassword');

  Never _unsupported(String method) =>
      throw UnsupportedError('$runtimeType does not override $method');
}
