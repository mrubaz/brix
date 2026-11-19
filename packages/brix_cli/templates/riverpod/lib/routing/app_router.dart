import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../ui/account/widgets/change_password_screen.dart';
import '../ui/account/widgets/delete_account_screen.dart';
import '../ui/account/widgets/profile_screen.dart';
import '../ui/auth/widgets/forgot_password_screen.dart';
import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/otp_screen.dart';
import '../ui/auth/widgets/reset_password_screen.dart';
import '../ui/auth/widgets/signup_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/library/widgets/library_screen.dart';
import '../ui/settings/widgets/about_screen.dart';
import '../ui/settings/widgets/appearance_screen.dart';
import '../ui/settings/widgets/settings_screen.dart';
import '../ui/shell/widgets/main_shell.dart';
import '../ui/splash/widgets/splash_screen.dart';
import 'routes.dart';

/// The app's routes on go_router. Each screen watches its own auto dispose
/// provider, so its view model lives as long as the screen.
GoRouter createAppRouter(GlobalKey<NavigatorState> navigatorKey) => GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.login,
      // After a signup or a password reset the email is filled in.
      builder: (context, state) =>
          LoginScreen(identifier: state.extra as String?),
      routes: [
        GoRoute(
          path: 'signup',
          builder: (context, state) => const SignupScreen(),
          routes: [
            GoRoute(
              path: 'code',
              builder: (context, state) => const OtpScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
          routes: [
            GoRoute(
              path: 'reset',
              builder: (context, state) =>
                  ResetPasswordScreen(identifier: state.extra as String? ?? ''),
            ),
          ],
        ),
      ],
    ),
    // The logged in part: three tabs under one bottom bar.
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.library,
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.settings,
              builder: (context, state) => const SettingsScreen(),
              routes: [
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
                GoRoute(
                  path: 'change-password',
                  builder: (context, state) => const ChangePasswordScreen(),
                ),
                GoRoute(
                  path: 'delete-account',
                  builder: (context, state) => DeleteAccountScreen(
                    identifier: state.extra as String? ?? '',
                  ),
                ),
                GoRoute(
                  path: 'appearance',
                  builder: (context, state) => const AppearanceScreen(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
