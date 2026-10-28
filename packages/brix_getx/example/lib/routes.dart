import 'package:brix/account.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:get/get.dart';

import 'controllers/login_controller.dart';
import 'controllers/signup_controller.dart';
import 'demo/demo_auth_provider.dart';
import 'demo/demo_feedback.dart';
import 'demo/demo_navigator.dart';
import 'demo/demo_session_store.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/splash_screen.dart';

/// Route names and, per route, the brix flow its controller runs on.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';
  static const resetPassword = '/reset-password';
  static const home = '/home';

  // The app's four adapters, shared by every flow.
  static final _provider = DemoAuthProvider();
  static final _store = DemoSessionStore();
  static final _navigator = DemoNavigator();
  static final _feedback = DemoFeedback();

  static SessionFlow<String> _sessionFlow() => SessionFlow(
    auth: _provider,
    store: _store,
    navigator: _navigator,
    feedback: _feedback,
  );

  static final pages = [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      binding: _put(() => BrixSessionController<String>(_sessionFlow())),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: _put(
        () => LoginController(
          LoginFlow(
            provider: _provider,
            store: _store,
            navigator: _navigator,
            feedback: _feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: signup,
      page: () => const SignupScreen(),
      binding: _put(
        () => SignupController(
          SignupFlow(
            provider: _provider,
            store: _store,
            navigator: _navigator,
            feedback: _feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: otp,
      page: () => const OtpScreen(),
      binding: _put(
        () => BrixOtpController<String>(
          OtpVerificationFlow(
            provider: _provider,
            store: _store,
            navigator: _navigator,
            feedback: _feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: _put(
        () => BrixForgotPasswordController(
          ForgotPasswordFlow(
            provider: _provider,
            navigator: _navigator,
            feedback: _feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: _put(
        () => BrixResetPasswordController(
          ResetPasswordFlow(
            provider: _provider,
            navigator: _navigator,
            feedback: _feedback,
            identifier: Get.arguments as String? ?? '',
            store: _store,
          ),
        ),
      ),
    ),
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: _put(() => BrixSessionController<String>(_sessionFlow())),
    ),
  ];

  /// The route's controller, created when the route opens and removed with
  /// it.
  static Bindings _put<T>(T Function() create) =>
      BindingsBuilder<T>(() => Get.put<T>(create()));
}
