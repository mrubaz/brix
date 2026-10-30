import 'package:brix/auth.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';
import '../routes.dart';

/// Opens the screens the flows ask for, on GetX named routes.
///
/// Route futures are started, never awaited, they complete only when the
/// new screen closes and would keep the flow busy.
class DemoNavigator extends AuthNavigator {
  @override
  Future<void> toHome() async {
    Get.offAllNamed(Routes.home);
  }

  /// [identifier] fills the login form (after a reset or a verified signup).
  @override
  Future<void> toLogin({String? identifier}) async {
    final reused = _backToOrOpen(Routes.login, arguments: identifier);
    if (reused && identifier != null) {
      await Get.find<LoginController>().prefillIdentifier(identifier);
    }
  }

  @override
  Future<void> toSignup() async {
    _backToOrOpen(Routes.signup);
  }

  @override
  Future<void> toOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async {
    Get.toNamed(Routes.otp);
  }

  @override
  Future<void> toForgotPassword() async {
    _backToOrOpen(Routes.forgotPassword);
  }

  @override
  Future<void> toResetPassword({required String identifier}) async {
    Get.toNamed(Routes.resetPassword, arguments: identifier);
  }

  /// Goes back to [route] when it is already open under this screen,
  /// otherwise opens it alone. A second copy of an open route would make
  /// GetX delete the new screen's controller.
  bool _backToOrOpen(String route, {Object? arguments}) {
    var found = false;
    Get.until((current) {
      if (current.settings.name == route) {
        found = true;
        return true;
      }
      return current.isFirst;
    });
    if (!found) Get.offAllNamed(route, arguments: arguments);
    return found;
  }
}
