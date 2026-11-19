import 'package:brix_bloc/brix_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../config/dependencies.dart';
import '../domain/models/profile_update.dart';
import '../domain/models/user.dart';
import '../ui/account/widgets/change_password_screen.dart';
import '../ui/account/widgets/delete_account_screen.dart';
import '../ui/account/widgets/profile_screen.dart';
import '../ui/auth/view_models/signup_viewmodel.dart';
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

/// The app's routes on go_router. Each screen gets its cubit from a
/// `BlocProvider`, which closes it when the screen goes away.
GoRouter createAppRouter(GlobalKey<NavigatorState> navigatorKey) => GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => BlocProvider(
        create: (_) => BrixSessionCubit<User>(Dependencies.sessionFlow()),
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => BlocProvider(
        create: (_) => BrixLoginCubit<User>(
          LoginFlow(
            provider: Dependencies.auth,
            store: Dependencies.session,
            navigator: Dependencies.navigator,
            feedback: Dependencies.feedback,
          ),
        ),
        // After a signup or a password reset the email is filled in.
        child: LoginScreen(identifier: state.extra as String?),
      ),
      routes: [
        GoRoute(
          path: 'signup',
          builder: (context, state) => BlocProvider(
            create: (_) => SignupViewModel(
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
              builder: (context, state) => BlocProvider(
                create: (_) => BrixOtpCubit<User>(
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
          builder: (context, state) => BlocProvider(
            create: (_) => BrixForgotPasswordCubit(
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
              builder: (context, state) => BlocProvider(
                create: (_) => BrixResetPasswordCubit(
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
              builder: (context, state) => BlocProvider(
                create: (_) =>
                    BrixSessionCubit<User>(Dependencies.sessionFlow()),
                child: const SettingsScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'profile',
                  builder: (context, state) => BlocProvider(
                    create: (_) => BrixProfileCubit<User, ProfileUpdate>(
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
                  builder: (context, state) => BlocProvider(
                    create: (_) => BrixChangePasswordCubit(
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
                  builder: (context, state) => BlocProvider(
                    create: (_) => BrixDeleteAccountCubit(
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
