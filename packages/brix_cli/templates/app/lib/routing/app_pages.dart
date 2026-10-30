import 'package:brix_getx/brix_getx.dart';
import 'package:get/get.dart';

import '../config/dependencies.dart';
import '../domain/models/user.dart';
import '../ui/account/view_models/profile_viewmodel.dart';
import '../ui/account/widgets/change_password_screen.dart';
import '../ui/account/widgets/delete_account_screen.dart';
import '../ui/account/widgets/profile_screen.dart';
import '../ui/auth/view_models/login_viewmodel.dart';
import '../ui/auth/view_models/signup_viewmodel.dart';
import '../ui/auth/widgets/forgot_password_screen.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/otp_screen.dart';
import '../ui/auth/widgets/reset_password_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/splash/widgets/splash_screen.dart';
import 'routes.dart';

/// Every screen with its view model. A view model is created when its route
/// opens and removed with it.
abstract final class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: _put(
        () => BrixSessionController<User>(Dependencies.sessionFlow()),
      ),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: _put(
        () => LoginViewModel(
          LoginFlow(
            provider: Dependencies.auth,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignupScreen(),
      binding: _put(
        () => SignupViewModel(
          SignupFlow(
            provider: Dependencies.auth,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpScreen(),
      binding: _put(
        () => BrixOtpController<User>(
          OtpVerificationFlow(
            provider: Dependencies.auth,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: _put(
        () => BrixForgotPasswordController(
          ForgotPasswordFlow(
            provider: Dependencies.auth,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordScreen(),
      binding: _put(
        () => BrixResetPasswordController(
          ResetPasswordFlow(
            provider: Dependencies.auth,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
            identifier: Get.arguments as String? ?? '',
            store: Dependencies.session,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: _put(
        () => BrixSessionController<User>(Dependencies.sessionFlow()),
      ),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileScreen(),
      binding: _put(
        () => ProfileViewModel(
          ProfileFlow(
            account: Dependencies.account,
            feedback: Dependencies.feedback,
            store: Dependencies.session,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordScreen(),
      binding: _put(
        () => BrixChangePasswordController(
          ChangePasswordFlow(
            account: Dependencies.account,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
      ),
    ),
    GetPage(
      name: Routes.deleteAccount,
      page: () => const DeleteAccountScreen(),
      binding: _put(
        () => BrixDeleteAccountController(
          DeleteAccountFlow(
            account: Dependencies.account,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
            identifier: Get.arguments as String? ?? '',
          ),
        ),
      ),
    ),
  ];

  static Bindings _put<T>(T Function() create) =>
      BindingsBuilder<T>(() => Get.put<T>(create()));
}
