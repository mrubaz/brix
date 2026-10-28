import 'dart:async';

import 'package:brix/auth.dart';
import 'package:brix/testing.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

void main() {
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;

  setUp(() {
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
  });

  FakeAuthProvider<void, Object?> providerWith(ResetMode mode) =>
      FakeAuthProvider(
        capabilities: AuthCapabilities(resetMode: mode, otpLength: 6),
      );

  group('ForgotPasswordFlow', () {
    ForgotPasswordFlow flowWith(FakeAuthProvider<void, Object?> provider) =>
        ForgotPasswordFlow(
          provider: provider,
          navigator: navigator,
          feedback: feedback,
        );

    test('code mode: trimmed email, message, reset screen', () async {
      final provider = providerWith(ResetMode.otp)
        ..forgotPasswordResult = const Success(null, message: 'Code sent');

      await flowWith(provider).submit(identifier: ' a@b.com ');

      expect(provider.forgotPasswordCalls, ['a@b.com']);
      expect(feedback.successes, ['Code sent']);
      expect(navigator.visits, ['reset:a@b.com']);
    });

    test('link mode: back to login', () async {
      final provider = providerWith(ResetMode.link);

      await flowWith(provider).submit(identifier: 'a@b.com');

      expect(navigator.visits, ['login']);
    });

    test('failure is shown and the screen stays', () async {
      final failure = ValidationFailure(messages: ['Email not found']);
      final provider = providerWith(ResetMode.otp)
        ..forgotPasswordResult = Failed(failure);

      await flowWith(provider).submit(identifier: 'a@b.com');

      expect(feedback.failures, [same(failure)]);
      expect(navigator.visits, isEmpty);
    });

    test('a thrown error becomes a failure', () async {
      final provider = providerWith(ResetMode.otp)
        ..error = TimeoutException('slow');
      final flow = flowWith(provider);

      await flow.submit(identifier: 'a@b.com');

      expect(feedback.failures.single, isA<NetworkFailure>());
      expect(flow.state.isSubmitting, isFalse);
    });

    test('double tap sends once', () async {
      final provider = providerWith(ResetMode.otp)..gate = Completer<void>();
      final flow = flowWith(provider);

      final first = flow.submit(identifier: 'a@b.com');
      final second = flow.submit(identifier: 'a@b.com');
      provider.gate!.complete();
      await Future.wait([first, second]);

      expect(provider.forgotPasswordCalls, hasLength(1));
    });
  });

  group('ResetPasswordFlow', () {
    late FakeAuthProvider<void, Object?> provider;
    late InMemoryAuthSessionStore<Object?> store;
    const strong = 'New@pass1';

    setUp(() {
      provider = providerWith(ResetMode.otp);
      store = InMemoryAuthSessionStore();
    });

    ResetPasswordFlow flowFor(
      String? identifier, {
      Duration cooldown = Duration.zero,
    }) => ResetPasswordFlow(
      provider: provider,
      navigator: navigator,
      feedback: feedback,
      identifier: identifier,
      store: store,
      resendCooldown: cooldown,
    );

    test(
      'success: trimmed code, untouched password, login with the email',
      () async {
        provider.resetPasswordResult = const Success(null, message: 'Updated');
        final flow = flowFor(' a@b.com ');

        await flow.submit(code: ' 123456 ', newPassword: ' $strong ');

        expect(provider.resetPasswordCalls, ['a@b.com|123456| $strong ']);
        expect(feedback.successes, ['Updated']);
        expect(navigator.visits, ['login:a@b.com']);
      },
    );

    test('remembered details of this account get the new password', () async {
      store.rememberedCredentials = const RememberedCredentials(
        identifier: 'a@b.com',
        password: 'old',
      );

      await flowFor('a@b.com').submit(code: '123456', newPassword: strong);

      expect(store.rememberedCredentials?.password, strong);
    });

    test('remembered details of another account stay', () async {
      store.rememberedCredentials = const RememberedCredentials(
        identifier: 'x@b.com',
        password: 'old',
      );

      await flowFor('a@b.com').submit(code: '123456', newPassword: strong);

      expect(store.rememberedCredentials?.password, 'old');
    });

    test('code of the wrong length: warning, no backend call', () async {
      await flowFor('a@b.com').submit(code: '123', newPassword: strong);

      expect(feedback.warnings, [AuthWarning.otpIncomplete]);
      expect(provider.resetPasswordCalls, isEmpty);
    });

    test('weak new password: warning, no backend call', () async {
      await flowFor('a@b.com').submit(code: '123456', newPassword: 'short');

      expect(feedback.warnings, [AuthWarning.weakPassword]);
      expect(provider.resetPasswordCalls, isEmpty);
    });

    test('wrong code: error shown, failedAttempts up, screen stays', () async {
      final failure = ValidationFailure(messages: ['Invalid code']);
      provider.resetPasswordResult = Failed(failure);
      final flow = flowFor('a@b.com');

      await flow.submit(code: '123456', newPassword: strong);

      expect(feedback.failures, [same(failure)]);
      expect(flow.state.failedAttempts, 1);
      expect(navigator.visits, isEmpty);
    });

    test('double tap sends once', () async {
      provider.gate = Completer<void>();
      final flow = flowFor('a@b.com');

      final first = flow.submit(code: '123456', newPassword: strong);
      final second = flow.submit(code: '123456', newPassword: strong);
      provider.gate!.complete();
      await Future.wait([first, second]);

      expect(provider.resetPasswordCalls, hasLength(1));
    });

    test('resend asks for a reset code', () async {
      final flow = flowFor('a@b.com');

      await flow.resend();

      expect(provider.resendOtpCalls, ['a@b.com|passwordReset']);
    });

    test('change email goes back to forgot password', () async {
      await flowFor('a@b.com').changeIdentifier();

      expect(navigator.visits, ['forgot']);
    });

    test('masked email for the screen', () {
      expect(
        flowFor('rubaz@gmail.com').state.maskedIdentifier,
        'ru•••@gmail.com',
      );
    });

    for (final identifier in [null, '', '  ']) {
      test(
        'no identifier ("$identifier"): start and submit go to login',
        () async {
          final flow = flowFor(identifier);

          expect(flow.hasIdentifier, isFalse);
          await flow.start();
          await flow.submit(code: '123456', newPassword: strong);

          expect(navigator.visits, ['login', 'login']);
          expect(provider.resetPasswordCalls, isEmpty);
        },
      );
    }

    test('start begins the resend wait', () {
      fakeAsync((async) {
        final flow = flowFor('a@b.com', cooldown: const Duration(seconds: 30));
        flow.start();
        async.flushMicrotasks();

        expect(flow.state.resendIn, const Duration(seconds: 30));
        async.elapse(const Duration(seconds: 30));
        expect(flow.state.canResend, isTrue);
        flow.dispose();
      });
    });
  });
}
