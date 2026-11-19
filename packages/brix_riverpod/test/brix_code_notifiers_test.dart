import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _OtpNotifier extends BrixOtpNotifier<String> {
  _OtpNotifier(this._flow);

  final OtpVerificationFlow<String> Function() _flow;

  @override
  OtpVerificationFlow<String> createFlow() => _flow();
}

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
  group('BrixOtpNotifier', () {
    late FakeAuthProvider<void, String> provider;
    late RecordingAuthNavigator navigator;
    late RecordingAuthFeedback feedback;
    late NotifierProvider<_OtpNotifier, CodeEntryState> otpProvider;
    late ProviderContainer container;

    setUp(() {
      provider = FakeAuthProvider(
        capabilities: const AuthCapabilities(
          otpAfterSignup: true,
          otpLength: 4,
        ),
      );
      final store = InMemoryAuthSessionStore<String>()
        ..pendingIdentifier = 'rubaz@gmail.com';
      navigator = RecordingAuthNavigator();
      feedback = RecordingAuthFeedback();
      otpProvider = NotifierProvider<_OtpNotifier, CodeEntryState>(
        () => _OtpNotifier(
          () => OtpVerificationFlow(
            provider: provider,
            store: store,
            navigator: navigator,
            feedback: feedback,
            resendCooldown: Duration.zero,
          ),
        ),
      );
      container = ProviderContainer.test();
    });

    Future<_OtpNotifier> create() async {
      container.listen(otpProvider, (_, _) {});
      await pumpEventQueue();
      return container.read(otpProvider.notifier);
    }

    CodeEntryState read() => container.read(otpProvider);

    test('starts with the pending email and the code length', () async {
      final notifier = await create();

      expect(notifier.otpLength, 4);
      expect(read().maskedIdentifier, 'ru•••@gmail.com');
    });

    test('a right code opens login with the email', () async {
      final notifier = await create();

      await notifier.verify('1234');

      expect(provider.verifyOtpCalls, ['rubaz@gmail.com|1234|signup']);
      expect(navigator.visits, ['login:rubaz@gmail.com']);
    });

    test('a rejected code counts a failed attempt', () async {
      provider.verifyOtpResult = Failed(
        ValidationFailure(messages: ['Invalid OTP']),
      );
      final notifier = await create();

      await notifier.verify('1234');

      expect(read().failedAttempts, 1);
      expect(feedback.failures, hasLength(1));
    });

    test('resend and change email go through the flow', () async {
      final notifier = await create();

      await notifier.resend();
      await notifier.changeIdentifier();

      expect(provider.resendOtpCalls, ['rubaz@gmail.com|signup']);
      expect(navigator.visits, ['signup']);
    });

    test('disposing the container disposes the flow', () async {
      final flow = (await create()).flow;

      container.dispose();

      expect(flow.isDisposed, isTrue);
    });
  });

  group('BrixForgotPasswordNotifier and BrixResetPasswordNotifier', () {
    const strong = 'New@pass1';
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
      container = ProviderContainer.test();
    });

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

    Future<_ResetNotifier> reset(
      NotifierProvider<_ResetNotifier, BrixResetPasswordState> reset,
    ) async {
      container.listen(reset, (_, _) {});
      await pumpEventQueue();
      return container.read(reset.notifier);
    }

    test('forgot sends the typed email and opens reset', () async {
      final forgotProvider =
          NotifierProvider<_ForgotNotifier, BrixForgotPasswordState>(
            () => _ForgotNotifier(
              () => ForgotPasswordFlow(
                provider: provider,
                navigator: navigator,
                feedback: feedback,
              ),
            ),
          );
      container.listen(forgotProvider, (_, _) {});
      final notifier = container.read(forgotProvider.notifier)
        ..identifierChanged('a@b.com');

      await notifier.submit();

      expect(provider.forgotPasswordCalls, ['a@b.com']);
      expect(navigator.visits, ['reset:a@b.com']);
      expect(container.read(forgotProvider).isSubmitting, isFalse);
    });

    test(
      'reset sends the code and new password, login with the email',
      () async {
        final p = resetProvider(' a@b.com ');
        final notifier = await reset(p)
          ..newPasswordChanged(strong);

        await notifier.submit('123456');

        expect(container.read(p).code.maskedIdentifier, 'a•••@b.com');
        expect(provider.resetPasswordCalls, ['a@b.com|123456|$strong']);
        expect(navigator.visits, ['login:a@b.com']);
      },
    );

    test('the unmet rules follow the typed password', () async {
      final p = resetProvider('a@b.com');
      final notifier = await reset(p);
      expect(container.read(p).passwordRulesMet, isFalse);

      notifier.newPasswordChanged('abc');
      expect(
        container.read(p).unmetPasswordRules,
        contains(PasswordRule.minLength),
      );

      notifier.newPasswordChanged(strong);
      expect(container.read(p).passwordRulesMet, isTrue);
      expect(notifier.passwordRules, isNotEmpty);
    });

    test('a wrong code counts a failed attempt, the password stays', () async {
      provider.resetPasswordResult = Failed(
        ValidationFailure(messages: ['Invalid OTP']),
      );
      final p = resetProvider('a@b.com');
      final notifier = await reset(p)
        ..newPasswordChanged(strong);

      await notifier.submit('123456');

      expect(container.read(p).code.failedAttempts, 1);
      expect(container.read(p).newPassword, strong);
    });

    test('resend and change email go through the flow', () async {
      final notifier = await reset(resetProvider('a@b.com'));

      await notifier.resend();
      await notifier.changeIdentifier();

      expect(provider.resendOtpCalls, ['a@b.com|passwordReset']);
      expect(navigator.visits, ['forgot']);
    });

    test('opened without an identifier goes to login', () async {
      await reset(resetProvider(null));

      expect(navigator.visits, ['login']);
    });

    test('toggle flips new password visibility', () async {
      final p = resetProvider('a@b.com');
      (await reset(p)).toggleNewPasswordVisibility();

      expect(container.read(p).obscureNewPassword, isFalse);
    });
  });
}
