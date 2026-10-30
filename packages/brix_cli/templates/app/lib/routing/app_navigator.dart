import 'package:brix/auth.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../ui/auth/view_models/login_viewmodel.dart';

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
  @override
  Future<void> toLogin({String? identifier}) async {
    _router.go(Routes.login, extra: identifier);
    // A login screen already open under this one is kept, so fill it here.
    if (identifier != null && Get.isRegistered<LoginViewModel>()) {
      await Get.find<LoginViewModel>().prefillIdentifier(identifier);
    }
  }

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
