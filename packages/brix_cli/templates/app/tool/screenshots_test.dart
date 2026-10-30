// Renders brix_cli's README / pub.dev screenshots from this app's real
// screens, view models and local backend, on an iPhone:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there). macOS only.
import 'dart:io';

import 'package:brix_app/config/dependencies.dart';
import 'package:brix_app/data/repositories/account_repository_local.dart';
import 'package:brix_app/data/repositories/auth_repository_local.dart';
import 'package:brix_app/data/services/local_accounts_service.dart';
import 'package:brix_app/domain/models/user.dart';
import 'package:brix_app/main_development.dart';
import 'package:brix_app/ui/account/view_models/profile_viewmodel.dart';
import 'package:brix_app/ui/account/widgets/delete_account_screen.dart';
import 'package:brix_app/ui/account/widgets/profile_screen.dart';
import 'package:brix_app/ui/auth/view_models/login_viewmodel.dart';
import 'package:brix_app/ui/auth/view_models/signup_viewmodel.dart';
import 'package:brix_app/ui/auth/widgets/login_screen.dart';
import 'package:brix_app/ui/auth/widgets/otp_screen.dart';
import 'package:brix_app/ui/auth/widgets/signup_screen.dart';
import 'package:brix_app/ui/core/themes/theme.dart';
import 'package:brix_app/ui/home/widgets/home_screen.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:flutter/material.dart';
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

  setUpAll(loadAppleFonts);

  setUp(() async {
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('shots');
    final accounts = LocalAccountsService(File('${dir.path}/backend.json'));
    await accounts.put(
      'ada@brix.dev',
      const LocalAccount(name: 'Ada', password: 'Strong@123', verified: true),
    );
    Dependencies.init(
      apiUrl: '',
      storage: BrixStorage(values: MemoryStore(), secrets: MemoryStore()),
      backend: (api, session) => (
        auth: AuthRepositoryLocal(accounts),
        account: AccountRepositoryLocal(accounts, session),
      ),
      devTools: LocalDevTools(accounts),
    );
    // Screenshots show the screens, not the toasts about them.
    Get.replace<AuthFeedback>(const _Quiet());
  });

  tearDown(() {
    Get.reset();
    dir.deleteSync(recursive: true);
  });

  testWidgets('sign in screens', (tester) async {
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

    await shootRow(tester, '$_out/app_sign_in.png', [
      Captioned(
        caption: 'Log in',
        child: _phone(const LoginScreen(), canGoBack: false),
      ),
      Captioned(
        caption: 'Sign up with live password rules',
        child: _phone(const SignupScreen()),
      ),
      Captioned(caption: 'Email code', child: _phone(const OtpScreen())),
    ]);
    for (var i = 0; i < 3; i++) {
      otp.boxes.controllers[i].text = '${i + 1}';
    }
    await tester.pump(const Duration(seconds: 1));
    await shootRow(tester, '$_out/app_sign_in.png', [
      Captioned(
        caption: 'Log in',
        child: _phone(const LoginScreen(), canGoBack: false),
      ),
      Captioned(
        caption: 'Sign up with live password rules',
        child: _phone(const SignupScreen()),
      ),
      Captioned(caption: 'Email code', child: _phone(const OtpScreen())),
    ]);
    await _closeAll(tester);
  });

  testWidgets('account screens', (tester) async {
    await Dependencies.session.saveSession(
      const AuthSession(
        accessToken: 'local-token',
        user: User(id: 'ada@brix.dev', name: 'Ada', email: 'ada@brix.dev'),
      ),
    );
    Get.put(BrixSessionController<User>(Dependencies.sessionFlow()));
    Get.put(
      ProfileViewModel(
        ProfileFlow(
          account: Dependencies.account,
          feedback: Dependencies.feedback,
          store: Dependencies.session,
        ),
      ),
    );
    final delete = Get.put(
      BrixDeleteAccountController(
        DeleteAccountFlow(
          account: Dependencies.account,
          store: Dependencies.session,
          navigator: Dependencies.navigator,
          feedback: Dependencies.feedback,
          identifier: 'ada@brix.dev',
        ),
      ),
    );
    unawaited(delete.requestDeletion());

    await tester.pump(const Duration(seconds: 1));
    await shootRow(tester, '$_out/app_account.png', [
      Captioned(
        caption: 'Home',
        child: _phone(const HomeScreen(), canGoBack: false),
      ),
      Captioned(caption: 'Profile', child: _phone(const ProfileScreen())),
      Captioned(
        caption: 'Delete account with a code',
        child: _phone(const DeleteAccountScreen()),
      ),
    ]);
    await _closeAll(tester);
  });
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
