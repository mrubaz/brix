import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import '../routes.dart';

/// Opens the screens the flows ask for, on Flutter's named routes.
///
/// Route futures are started, never awaited, they complete only when the
/// new screen closes and would keep the flow busy.
class DemoNavigator extends AuthNavigator {
  DemoNavigator({required this.navigatorKey, required this.prefillLogin});

  final GlobalKey<NavigatorState> navigatorKey;

  /// Fills the email on a login screen that is already open.
  final Future<void> Function(String identifier) prefillLogin;

  NavigatorState get _navigator => navigatorKey.currentState!;

  @override
  Future<void> toHome() async {
    _navigator.pushNamedAndRemoveUntil(Routes.home, (_) => false);
  }

  /// [identifier] fills the login form (after a reset or a verified signup).
  @override
  Future<void> toLogin({String? identifier}) async {
    final reused = _backToOrOpen(Routes.login, arguments: identifier);
    if (reused && identifier != null) await prefillLogin(identifier);
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
    _navigator.pushNamed(Routes.otp);
  }

  @override
  Future<void> toForgotPassword() async {
    _backToOrOpen(Routes.forgotPassword);
  }

  @override
  Future<void> toResetPassword({required String identifier}) async {
    _navigator.pushNamed(Routes.resetPassword, arguments: identifier);
  }

  /// Goes back to [route] when it is already open under this screen,
  /// otherwise opens it alone. Returns whether it was already open.
  bool _backToOrOpen(String route, {Object? arguments}) {
    var found = false;
    _navigator.popUntil((current) {
      if (current.settings.name == route) {
        found = true;
        return true;
      }
      return current.isFirst;
    });
    if (!found) {
      _navigator.pushNamedAndRemoveUntil(
        route,
        (_) => false,
        arguments: arguments,
      );
    }
    return found;
  }
}
