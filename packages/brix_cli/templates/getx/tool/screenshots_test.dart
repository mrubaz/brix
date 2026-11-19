// Renders brix_cli's README / pub.dev screenshots from this app's real
// screens, view models and local backend, on an iPhone:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there). macOS only.
import 'dart:io';

import 'package:brix_app/config/dependencies.dart';
import 'package:brix_app/dev/local_accounts_service.dart';
import 'package:brix_app/dev/local_backend.dart';
import 'package:brix_app/dev/local_box.dart';
import 'package:brix_app/domain/models/user.dart';
import 'package:brix_app/routing/app_router.dart';
import 'package:brix_app/routing/routes.dart';
import 'package:brix_app/ui/auth/view_models/login_viewmodel.dart';
import 'package:brix_app/ui/auth/view_models/signup_viewmodel.dart';
import 'package:brix_app/ui/auth/widgets/forgot_password_screen.dart';
import 'package:brix_app/ui/auth/widgets/login_screen.dart';
import 'package:brix_app/ui/auth/widgets/otp_screen.dart';
import 'package:brix_app/ui/auth/widgets/reset_password_screen.dart';
import 'package:brix_app/ui/auth/widgets/signup_screen.dart';
import 'package:brix_app/ui/core/themes/theme.dart';
import 'package:brix_app/ui/splash/widgets/splash_screen.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import '../../../../../tool/screenshot_kit/iphone.dart';

const _out = '../../../doc/screenshots';

/// [screen] on an iPhone, inside a navigator so it gets the iOS back
/// chevron when [canGoBack].
Widget _phone(Widget screen, {bool canGoBack = true}) => IPhone(
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: iosTheme(AppTheme.light),
    home: Navigator(
      pages: [
        if (canGoBack) const MaterialPage(child: SizedBox()),
        MaterialPage(child: screen),
      ],
      onDidRemovePage: (_) {},
    ),
  ),
);

void main() {
  late Directory dir;

  setUpAll(() async {
    await loadAppleFonts();
    // The setup screen has its own MaterialApp with Flutter's default font;
    // on an iPhone that is San Francisco, so draw it with SF Pro here too.
    final roboto = FontLoader('Roboto')
      ..addFont(
        Future.value(
          ByteData.sublistView(
            File('/System/Library/Fonts/SFNS.ttf').readAsBytesSync(),
          ),
        ),
      );
    await roboto.load();
  });

  setUp(() async {
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('shots');
    final accounts = LocalAccountsService(
      LocalBox(File('${dir.path}/backend.json')),
    );
    await accounts.put(
      'ada@brix.dev',
      const LocalAccount(name: 'Ada', password: 'Strong@123', verified: true),
    );
    startWithLocalBackend(
      accounts: accounts,
      storage: BrixStorage(values: MemoryStore(), secrets: MemoryStore()),
    );
    // Screenshots show the screens, not the toasts about them.
    Get.replace<AuthFeedback>(const _Quiet());
  });

  tearDown(() {
    Get.reset();
    dir.deleteSync(recursive: true);
  });

  testWidgets('flow 1: splash, login, signup', (tester) async {
    Get.put(BrixSessionController<User>(Dependencies.sessionFlow()));
    final login = Get.put(
      LoginViewModel(
        LoginFlow(
          provider: Dependencies.auth,
          store: Dependencies.session,
          navigator: Dependencies.navigator,
          feedback: Dependencies.feedback,
        ),
      ),
    );
    login.identifierController.text = 'ada@brix.dev';
    login.passwordController.text = 'Strong@123';
    login.rememberMe.value = true;
    final signup = Get.put(
      SignupViewModel(
        SignupFlow(
          provider: Dependencies.auth,
          store: Dependencies.session,
          navigator: Dependencies.navigator,
          feedback: Dependencies.feedback,
        ),
      ),
    );
    signup.nameController.text = 'Ada Lovelace';
    signup.identifierController.text = 'ada@brix.dev';
    signup.passwordController.text = 'Strong12';
    await shootRow(tester, '$_out/app_1_start.png', [
      Captioned(
        caption: '1. Splash',
        child: _phone(const SplashScreen(), canGoBack: false),
      ),
      Captioned(
        caption: '2. Log in',
        child: _phone(const LoginScreen(), canGoBack: false),
      ),
      Captioned(caption: '3. Sign up', child: _phone(const SignupScreen())),
    ]);
    await _closeAll(tester);
  });

  testWidgets('flow 2: code, forgot, reset', (tester) async {
    await Dependencies.session.savePendingIdentifier('ada@brix.dev');
    final otp = Get.put(
      BrixOtpController<User>(
        OtpVerificationFlow(
          provider: Dependencies.auth,
          store: Dependencies.session,
          navigator: Dependencies.navigator,
          feedback: Dependencies.feedback,
        ),
      ),
    );
    final forgot = Get.put(
      BrixForgotPasswordController(
        ForgotPasswordFlow(
          provider: Dependencies.auth,
          navigator: Dependencies.navigator,
          feedback: Dependencies.feedback,
        ),
      ),
    );
    forgot.identifierController.text = 'ada@brix.dev';
    final reset = Get.put(
      BrixResetPasswordController(
        ResetPasswordFlow(
          provider: Dependencies.auth,
          navigator: Dependencies.navigator,
          feedback: Dependencies.feedback,
          identifier: 'ada@brix.dev',
          store: Dependencies.session,
        ),
      ),
    );
    final row = [
      Captioned(caption: '4. Email code', child: _phone(const OtpScreen())),
      Captioned(
        caption: '5. Forgot password',
        child: _phone(const ForgotPasswordScreen()),
      ),
      Captioned(
        caption: '6. New password',
        child: _phone(const ResetPasswordScreen()),
      ),
    ];
    await shootRow(tester, '$_out/app_2_code_password.png', row);
    for (var i = 0; i < 3; i++) {
      otp.boxes.controllers[i].text = '${i + 1}';
    }
    reset.boxes.onDigitChanged(0, '123456');
    reset.newPasswordController.text = 'Newer@123';
    await tester.pump(const Duration(seconds: 1));
    await shootRow(tester, '$_out/app_2_code_password.png', row);
    await _closeAll(tester);
  });

  testWidgets('flow 3: home, library, settings', (tester) async {
    await _logIn();
    await shootRow(tester, '$_out/app_3_tabs.png', [
      Captioned(caption: '7. Home', child: _routed(Routes.home)),
      Captioned(caption: '8. Brix library', child: _routed(Routes.library)),
      Captioned(caption: '9. Settings', child: _routed(Routes.settings)),
    ]);
    await _closeAll(tester);
  });

  testWidgets('flow 4: profile, change password, delete account', (
    tester,
  ) async {
    await _logIn();
    final row = [
      Captioned(caption: '10. Profile', child: _routed(Routes.profile)),
      Captioned(
        caption: '11. Change password',
        child: _routed(Routes.changePassword),
      ),
      Captioned(
        caption: '12. Delete account',
        child: _routed(Routes.deleteAccount, extra: 'ada@brix.dev'),
      ),
    ];
    await shootRow(tester, '$_out/app_4_account.png', row);
    final change = Get.find<BrixChangePasswordController>();
    change.currentPasswordController.text = 'Strong@123';
    change.newPasswordController.text = 'Newer@12';
    unawaited(Get.find<BrixDeleteAccountController>().requestDeletion());
    await tester.pump(const Duration(seconds: 1));
    await shootRow(tester, '$_out/app_4_account.png', row);
    await _closeAll(tester);
  });

  testWidgets('flow 5: appearance, about', (tester) async {
    await _logIn();
    await shootRow(tester, '$_out/app_5_appearance_about.png', [
      Captioned(caption: '13. Appearance', child: _routed(Routes.appearance)),
      Captioned(caption: '14. About', child: _routed(Routes.about)),
    ]);
    await _closeAll(tester);
  });
}

/// Ada is logged in, so home greets her and profile shows her.
Future<void> _logIn() => Dependencies.session.saveSession(
  const AuthSession(
    accessToken: 'local-token',
    user: User(id: 'ada@brix.dev', name: 'Ada', email: 'ada@brix.dev'),
  ),
);

/// The real app at [location], with its own router: the bottom bar, back
/// buttons and view models are the app's own.
Widget _routed(String location, {Object? extra}) {
  final router = createAppRouter(GlobalKey<NavigatorState>())
    ..go(location, extra: extra);
  return IPhone(
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: iosTheme(AppTheme.light),
      routerConfig: router,
    ),
  );
}

void unawaited(Future<void> future) {}

/// Closes the view models, so their code timers stop before the test ends.
Future<void> _closeAll(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await Get.deleteAll(force: true);
  await tester.pump(const Duration(seconds: 1));
}

class _Quiet extends AuthFeedback {
  const _Quiet();

  @override
  void failure(Failure failure) {}

  @override
  void warning(AuthWarning warning) {}

  @override
  void success(String? message) {}
}
