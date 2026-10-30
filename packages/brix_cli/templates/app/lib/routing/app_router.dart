import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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
import 'view_model_scope.dart';

/// The app's routes on go_router, each screen with its view model.
GoRouter createAppRouter(GlobalKey<NavigatorState> navigatorKey) => GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => ViewModelScope(
        create: () => BrixSessionController<User>(Dependencies.sessionFlow()),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => ViewModelScope(
        create: () => LoginViewModel(
          LoginFlow(
            provider: Dependencies.auth,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
        // After a signup or a password reset the email is filled in.
        onCreated: (viewModel) {
          if (state.extra case final String email) {
            viewModel.prefillIdentifier(email);
          }
        },
        child: const LoginScreen(),
      ),
      routes: [
        GoRoute(
          path: 'signup',
          builder: (context, state) => ViewModelScope(
            create: () => SignupViewModel(
              SignupFlow(
                provider: Dependencies.auth,
                store: Dependencies.session,
                navigator: Dependencies.navigator,
                feedback: Dependencies.feedback,
              ),
            ),
            child: const SignupScreen(),
          ),
          routes: [
            GoRoute(
              path: 'code',
              builder: (context, state) => ViewModelScope(
                create: () => BrixOtpController<User>(
                  OtpVerificationFlow(
                    provider: Dependencies.auth,
                    store: Dependencies.session,
                    navigator: Dependencies.navigator,
                    feedback: Dependencies.feedback,
                  ),
                ),
                child: const OtpScreen(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) => ViewModelScope(
            create: () => BrixForgotPasswordController(
              ForgotPasswordFlow(
                provider: Dependencies.auth,
                navigator: Dependencies.navigator,
                feedback: Dependencies.feedback,
              ),
            ),
            child: const ForgotPasswordScreen(),
          ),
          routes: [
            GoRoute(
              path: 'reset',
              builder: (context, state) => ViewModelScope(
                create: () => BrixResetPasswordController(
                  ResetPasswordFlow(
                    provider: Dependencies.auth,
                    navigator: Dependencies.navigator,
                    feedback: Dependencies.feedback,
                    identifier: state.extra as String? ?? '',
                    store: Dependencies.session,
                  ),
                ),
                child: const ResetPasswordScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.home,
      builder: (context, state) => ViewModelScope(
        create: () => BrixSessionController<User>(Dependencies.sessionFlow()),
        child: const HomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'profile',
          builder: (context, state) => ViewModelScope(
            create: () => ProfileViewModel(
              ProfileFlow(
                account: Dependencies.account,
                feedback: Dependencies.feedback,
                store: Dependencies.session,
              ),
            ),
            child: const ProfileScreen(),
          ),
        ),
        GoRoute(
          path: 'change-password',
          builder: (context, state) => ViewModelScope(
            create: () => BrixChangePasswordController(
              ChangePasswordFlow(
                account: Dependencies.account,
                store: Dependencies.session,
                navigator: Dependencies.navigator,
                feedback: Dependencies.feedback,
              ),
            ),
            child: const ChangePasswordScreen(),
          ),
        ),
        GoRoute(
          path: 'delete-account',
          builder: (context, state) => ViewModelScope(
            create: () => BrixDeleteAccountController(
              DeleteAccountFlow(
                account: Dependencies.account,
                store: Dependencies.session,
                navigator: Dependencies.navigator,
                feedback: Dependencies.feedback,
                identifier: state.extra as String? ?? '',
              ),
            ),
            child: const DeleteAccountScreen(),
          ),
        ),
      ],
    ),
  ],
);
