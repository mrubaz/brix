import 'package:brix/auth.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// Opens the screens the brix flows ask for, on go_router.
///
/// Routes are started and not awaited: a pushed route completes only when
/// its screen closes, which would keep the flow busy.
class AppNavigator extends AuthNavigator {
  AppNavigator(this._router);

  final GoRouter _router;

  @override
  Future<void> toHome() async => _router.go(Routes.home);

  /// [identifier] fills the login form (after a reset or a verified signup).
  /// A login screen already open gets it too (`LoginScreen.didUpdateWidget`).
  @override
  Future<void> toLogin({String? identifier}) async =>
      _router.go(Routes.login, extra: identifier);

  @override
  Future<void> toSignup() async => _router.go(Routes.signup);

  @override
  Future<void> toOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async => _router.go(Routes.otp);

  @override
  Future<void> toForgotPassword() async => _router.go(Routes.forgotPassword);

  @override
  Future<void> toResetPassword({required String identifier}) async =>
      _router.go(Routes.resetPassword, extra: identifier);

  /// After a password change.
  @override
  Future<void> back() async => _router.pop();
}
