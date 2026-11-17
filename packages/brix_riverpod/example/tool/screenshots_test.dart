// Renders brix_riverpod's README / pub.dev screenshots from this example's
// real screens, notifiers and demo backend, on an iPhone:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there). macOS only.
import 'package:brix_riverpod_example/providers.dart';
import 'package:brix_riverpod_example/screens/forgot_password_screen.dart';
import 'package:brix_riverpod_example/screens/home_screen.dart';
import 'package:brix_riverpod_example/screens/login_screen.dart';
import 'package:brix_riverpod_example/screens/otp_screen.dart';
import 'package:brix_riverpod_example/screens/reset_password_screen.dart';
import 'package:brix_riverpod_example/screens/signup_screen.dart';
import 'package:brix_riverpod_example/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/screenshot_kit/iphone.dart';

const _out = '../../doc/screenshots';
const _email = 'ada@brix.dev';

void main() {
  late ProviderContainer container;

  setUpAll(loadAppleFonts);

  setUp(() => container = ProviderContainer());

  /// [screen] on an iPhone, inside a navigator so it gets the iOS back
  /// chevron when [canGoBack]. Every phone shares one container.
  Widget phone(Widget screen, {bool canGoBack = true}) => IPhone(
    child: UncontrolledProviderScope(
      container: container,
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
    ),
  );

  /// Keeps an auto-dispose provider alive between the two renders.
  void keep(ProviderListenable<Object?> provider) =>
      container.listen(provider, (_, _) {});

  /// Disposes the notifiers, so their code timers stop before the test ends.
  Future<void> closeAll(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('sign in screens', (tester) async {
    await container.read(sessionStoreProvider).savePendingIdentifier(_email);
    keep(loginProvider);
    keep(signupProvider);
    keep(otpProvider);

    final login = container.read(loginProvider.notifier);
    login.identifierController.text = _email;
    login.passwordController.text = 'Strong@123';
    login.toggleRememberMe();

    final signup = container.read(signupProvider.notifier);
    signup.nameController.text = 'Ada Lovelace';
    signup.identifierController.text = _email;
    signup.passwordController.text = 'Strong12';

    final row = [
      Captioned(
        caption: 'Log in',
        child: phone(const LoginScreen(), canGoBack: false),
      ),
      Captioned(
        caption: 'Sign up with live password rules',
        child: phone(const SignupScreen()),
      ),
      Captioned(caption: 'Email code', child: phone(const OtpScreen())),
    ];
    await shootRow(tester, '$_out/app_sign_in.png', row);
    final otp = container.read(otpProvider.notifier);
    for (var i = 0; i < 3; i++) {
      otp.boxes.controllers[i].text = '${i + 1}';
    }
    await tester.pump(const Duration(seconds: 1));
    await shootRow(tester, '$_out/app_sign_in.png', row);
    await closeAll(tester);
  });

  testWidgets('password reset and home', (tester) async {
    final reset = resetPasswordProvider(_email);
    keep(forgotPasswordProvider);
    keep(reset);
    keep(sessionProvider);

    container.read(forgotPasswordProvider.notifier).identifierController.text =
        _email;

    final row = [
      Captioned(
        caption: 'Forgot password',
        child: phone(const ForgotPasswordScreen()),
      ),
      Captioned(
        caption: 'Code and new password',
        child: phone(const ResetPasswordScreen(identifier: _email)),
      ),
      Captioned(
        caption: 'Home and logout',
        child: phone(const HomeScreen(), canGoBack: false),
      ),
    ];
    await shootRow(tester, '$_out/app_reset.png', row);
    final notifier = container.read(reset.notifier);
    notifier.boxes.onDigitChanged(0, '123456');
    notifier.newPasswordController.text = 'Newer@123';
    await tester.pump(const Duration(seconds: 1));
    await shootRow(tester, '$_out/app_reset.png', row);
    await closeAll(tester);
  });
}
