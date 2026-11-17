import 'package:flutter/material.dart';

import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

/// Route names and the screen each one opens. Each screen watches its own
/// auto-dispose provider, so its notifier and flow live as long as the
/// route.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';

  static Route<void> build(RouteSettings settings) => MaterialPageRoute(
    settings: settings,
    builder: (_) => switch (settings.name) {
      login => LoginScreen(identifier: settings.arguments as String?),
      signup => const SignupScreen(),
      otp => const OtpScreen(),
      forgotPassword => const ForgotPasswordScreen(),
      resetPassword => ResetPasswordScreen(
        identifier: settings.arguments as String? ?? '',
      ),
      home => const HomeScreen(),
      _ => const SplashScreen(),
    },
  );
}
