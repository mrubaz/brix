import 'package:brix/auth.dart';
import 'package:brix/testing.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeAuthProvider<void, Object?> provider;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;

  setUp(() {
    Get.testMode = true;
    provider = FakeAuthProvider(
      capabilities: const AuthCapabilities(resetMode: ResetMode.otp),
    );
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
  });

  tearDown(Get.reset);

  /// A form whose fields are required, like the real screens.
  Future<void> pumpForm(
    WidgetTester tester,
    GlobalKey<FormState> key,
    List<TextEditingController> fields,
  ) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: key,
          child: Column(
            children: [
              for (final field in fields)
                TextFormField(
                  controller: field,
                  validator: (value) => value!.isEmpty ? 'required' : null,
                ),
            ],
          ),
        ),
      ),
    ),
  );

  group('BrixForgotPasswordController', () {
    late BrixForgotPasswordController controller;

    setUp(() {
      controller = Get.put(
        BrixForgotPasswordController(
          ForgotPasswordFlow(
            provider: provider,
            navigator: navigator,
            feedback: feedback,
          ),
        ),
      );
    });

    testWidgets('invalid form sends nothing', (tester) async {
      await pumpForm(tester, controller.formKey, [
        controller.identifierController,
      ]);

      await controller.submit();

      expect(provider.forgotPasswordCalls, isEmpty);
    });

    testWidgets('valid form sends the email and opens reset', (tester) async {
      await pumpForm(tester, controller.formKey, [
        controller.identifierController,
      ]);
      controller.identifierController.text = 'a@b.com';

      await controller.submit();

      expect(provider.forgotPasswordCalls, ['a@b.com']);
      expect(navigator.visits, ['reset:a@b.com']);
      expect(controller.isSubmitting.value, isFalse);
    });
  });

  group('BrixResetPasswordController', () {
    const strong = 'New@pass1';

    BrixResetPasswordController create(String? identifier) => Get.put(
      BrixResetPasswordController(
        ResetPasswordFlow(
          provider: provider,
          navigator: navigator,
          feedback: feedback,
          identifier: identifier,
          resendCooldown: Duration.zero,
        ),
      ),
    );

    /// Code boxes plus the new password field, like the real screen.
    Future<void> pumpScreen(
      WidgetTester tester,
      BrixResetPasswordController controller,
    ) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: controller.formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    for (var i = 0; i < controller.boxes.length; i++)
                      Expanded(
                        child: TextField(
                          controller: controller.boxes.controllers[i],
                          focusNode: controller.boxes.focusNodes[i],
                          maxLength: controller.boxes.length,
                          onChanged: (value) =>
                              controller.boxes.onDigitChanged(i, value),
                        ),
                      ),
                  ],
                ),
                TextFormField(
                  controller: controller.newPasswordController,
                  focusNode: controller.newPasswordFocus,
                  validator: (value) => value!.isEmpty ? 'required' : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    testWidgets('code + new password sent, login with the email', (
      tester,
    ) async {
      final controller = create(' a@b.com ');
      await pumpScreen(tester, controller);

      controller.boxes.onDigitChanged(0, '123456');
      controller.newPasswordController.text = strong;
      await controller.submit();

      expect(controller.maskedIdentifier.value, 'a•••@b.com');
      expect(provider.resetPasswordCalls, ['a@b.com|123456|$strong']);
      expect(navigator.visits, ['login:a@b.com']);
    });

    testWidgets('a full code moves to the password field, no auto submit', (
      tester,
    ) async {
      final controller = create('a@b.com');
      await pumpScreen(tester, controller);

      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pump();

      expect(controller.newPasswordFocus.hasFocus, isTrue);
      expect(provider.resetPasswordCalls, isEmpty);
    });

    testWidgets('the checklist follows the typed password', (tester) async {
      final controller = create('a@b.com');

      controller.newPasswordController.text = 'abc';
      expect(controller.passwordRules.unmet, contains(PasswordRule.minLength));

      controller.newPasswordController.text = strong;
      expect(controller.passwordRules.isMet, isTrue);
    });

    testWidgets('a wrong code clears the boxes', (tester) async {
      provider.resetPasswordResult = Failed(
        ValidationFailure(messages: ['Invalid OTP']),
      );
      final controller = create('a@b.com');
      await pumpScreen(tester, controller);

      controller.boxes.onDigitChanged(0, '123456');
      controller.newPasswordController.text = strong;
      await controller.submit();

      expect(controller.boxes.code, isEmpty);
      expect(controller.newPasswordController.text, strong);
    });

    testWidgets('resend and change email go through the flow', (tester) async {
      final controller = create('a@b.com');

      await controller.resend();
      await controller.changeIdentifier();

      expect(provider.resendOtpCalls, ['a@b.com|passwordReset']);
      expect(navigator.visits, ['forgot']);
    });

    testWidgets('opened without an identifier goes to login', (tester) async {
      // onReady runs after the first frame of the screen.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      create(null);
      await tester.pump();

      expect(navigator.visits, ['login']);
    });

    testWidgets('toggle flips new password visibility', (tester) async {
      final controller = create('a@b.com');

      controller.toggleNewPasswordVisibility();

      expect(controller.obscureNewPassword.value, isFalse);
    });
  });
}
