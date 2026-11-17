import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ForgotNotifier extends BrixForgotPasswordNotifier {
  _ForgotNotifier(this._flow);

  final ForgotPasswordFlow Function() _flow;

  @override
  ForgotPasswordFlow createFlow() => _flow();
}

class _ResetNotifier extends BrixResetPasswordNotifier {
  _ResetNotifier(this._flow);

  final ResetPasswordFlow Function() _flow;

  @override
  ResetPasswordFlow createFlow() => _flow();
}

void main() {
  late FakeAuthProvider<void, Object?> provider;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late ProviderContainer container;

  setUp(() {
    provider = FakeAuthProvider(
      capabilities: const AuthCapabilities(resetMode: ResetMode.otp),
    );
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

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

  group('BrixForgotPasswordNotifier', () {
    late NotifierProvider<_ForgotNotifier, AuthFormState> forgotProvider;

    setUp(() {
      forgotProvider = NotifierProvider<_ForgotNotifier, AuthFormState>(
        () => _ForgotNotifier(
          () => ForgotPasswordFlow(
            provider: provider,
            navigator: navigator,
            feedback: feedback,
          ),
        ),
      );
    });

    _ForgotNotifier create() {
      container.read(forgotProvider);
      return container.read(forgotProvider.notifier);
    }

    testWidgets('invalid form sends nothing', (tester) async {
      final notifier = create();
      await pumpForm(tester, notifier.formKey, [notifier.identifierController]);

      await notifier.submit();

      expect(provider.forgotPasswordCalls, isEmpty);
    });

    testWidgets('valid form sends the email and opens reset', (tester) async {
      final notifier = create();
      await pumpForm(tester, notifier.formKey, [notifier.identifierController]);
      notifier.identifierController.text = 'a@b.com';

      await notifier.submit();

      expect(provider.forgotPasswordCalls, ['a@b.com']);
      expect(navigator.visits, ['reset:a@b.com']);
      expect(container.read(forgotProvider).isSubmitting, isFalse);
    });
  });

  group('BrixResetPasswordNotifier', () {
    const strong = 'New@pass1';

    NotifierProvider<_ResetNotifier, BrixResetPasswordState> resetProvider(
      String? identifier,
    ) => NotifierProvider<_ResetNotifier, BrixResetPasswordState>(
      () => _ResetNotifier(
        () => ResetPasswordFlow(
          provider: provider,
          navigator: navigator,
          feedback: feedback,
          identifier: identifier,
          resendCooldown: Duration.zero,
        ),
      ),
    );

    _ResetNotifier create(
      NotifierProvider<_ResetNotifier, BrixResetPasswordState> reset,
    ) {
      container.read(reset);
      return container.read(reset.notifier);
    }

    /// Code boxes plus the new password field, like the real screen.
    Future<void> pumpScreen(WidgetTester tester, _ResetNotifier notifier) =>
        tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Form(
                key: notifier.formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (var i = 0; i < notifier.boxes.length; i++)
                          Expanded(
                            child: TextField(
                              controller: notifier.boxes.controllers[i],
                              focusNode: notifier.boxes.focusNodes[i],
                              maxLength: notifier.boxes.length,
                              onChanged: (value) =>
                                  notifier.boxes.onDigitChanged(i, value),
                            ),
                          ),
                      ],
                    ),
                    TextFormField(
                      controller: notifier.newPasswordController,
                      focusNode: notifier.newPasswordFocus,
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
      final reset = resetProvider(' a@b.com ');
      final notifier = create(reset);
      await pumpScreen(tester, notifier);

      notifier.boxes.onDigitChanged(0, '123456');
      notifier.newPasswordController.text = strong;
      await notifier.submit();

      expect(container.read(reset).code.maskedIdentifier, 'a•••@b.com');
      expect(provider.resetPasswordCalls, ['a@b.com|123456|$strong']);
      expect(navigator.visits, ['login:a@b.com']);
    });

    testWidgets('a full code moves to the password field, no auto submit', (
      tester,
    ) async {
      final notifier = create(resetProvider('a@b.com'));
      await pumpScreen(tester, notifier);

      await tester.enterText(find.byType(TextField).first, '123456');
      await tester.pump();

      expect(notifier.newPasswordFocus.hasFocus, isTrue);
      expect(provider.resetPasswordCalls, isEmpty);
    });

    testWidgets('the unmet rules follow the typed password', (tester) async {
      final reset = resetProvider('a@b.com');
      final notifier = create(reset);
      expect(container.read(reset).passwordRulesMet, isFalse);

      notifier.newPasswordController.text = 'abc';
      expect(
        container.read(reset).unmetPasswordRules,
        contains(PasswordRule.minLength),
      );

      notifier.newPasswordController.text = strong;
      expect(container.read(reset).passwordRulesMet, isTrue);
      expect(notifier.passwordRules, isNotEmpty);
    });

    testWidgets('a wrong code clears the boxes', (tester) async {
      provider.resetPasswordResult = Failed(
        ValidationFailure(messages: ['Invalid OTP']),
      );
      final notifier = create(resetProvider('a@b.com'));
      await pumpScreen(tester, notifier);

      notifier.boxes.onDigitChanged(0, '123456');
      notifier.newPasswordController.text = strong;
      await notifier.submit();

      expect(notifier.boxes.code, isEmpty);
      expect(notifier.newPasswordController.text, strong);
    });

    testWidgets('resend and change email go through the flow', (tester) async {
      final notifier = create(resetProvider('a@b.com'));

      await notifier.resend();
      await notifier.changeIdentifier();

      expect(provider.resendOtpCalls, ['a@b.com|passwordReset']);
      expect(navigator.visits, ['forgot']);
    });

    testWidgets('opened without an identifier goes to login', (tester) async {
      create(resetProvider(null));
      await tester.pump();

      expect(navigator.visits, ['login']);
    });

    testWidgets('toggle flips new password visibility', (tester) async {
      final reset = resetProvider('a@b.com');
      create(reset).toggleNewPasswordVisibility();

      expect(container.read(reset).obscureNewPassword, isFalse);
    });
  });
}
