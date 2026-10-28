import 'dart:async';

import 'package:brix/auth.dart';
import 'package:brix/testing.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;

  setUp(() {
    provider = FakeAuthProvider(
      capabilities: const AuthCapabilities(otpAfterSignup: true, otpLength: 6),
    );
    store = InMemoryAuthSessionStore()..pendingIdentifier = 'rubaz@gmail.com';
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
  });

  OtpVerificationFlow<String> create({
    Duration cooldown = const Duration(seconds: 30),
  }) => OtpVerificationFlow(
    provider: provider,
    store: store,
    navigator: navigator,
    feedback: feedback,
    resendCooldown: cooldown,
  );

  group('start', () {
    test('reads the pending email and shows it masked', () async {
      final flow = create();

      await flow.start();

      expect(flow.state.identifier, 'rubaz@gmail.com');
      expect(flow.state.maskedIdentifier, 'ru•••@gmail.com');
      await flow.dispose();
    });

    test('no pending email: warning, back to signup', () async {
      store.pendingIdentifier = null;
      final flow = create();

      await flow.start();

      expect(feedback.warnings, [AuthWarning.pendingIdentifierMissing]);
      expect(navigator.visits, ['signup']);
      await flow.dispose();
    });

    test('the resend wait starts right away (a code was just sent)', () {
      fakeAsync((async) {
        final flow = create();
        flow.start();
        async.flushMicrotasks();

        expect(flow.state.resendIn, const Duration(seconds: 30));
        expect(flow.state.canResend, isFalse);
        async.elapse(const Duration(seconds: 10));
        expect(flow.state.resendIn, const Duration(seconds: 20));
        async.elapse(const Duration(seconds: 20));
        expect(flow.state.resendIn, Duration.zero);
        expect(flow.state.canResend, isTrue);
        flow.dispose();
      });
    });
  });

  group('verify', () {
    test('right code: pending email cleared, message, login', () async {
      provider.verifyOtpResult = const Success(null, message: 'Verified');
      final flow = create();
      await flow.start();

      await flow.verify(' 123456 ');

      expect(provider.verifyOtpCalls, ['rubaz@gmail.com|123456|signup']);
      expect(store.pendingIdentifier, isNull);
      expect(feedback.successes, ['Verified']);
      expect(navigator.visits, ['login:rubaz@gmail.com']);
      await flow.dispose();
    });

    test('wrong length: warning, no call', () async {
      final flow = create();
      await flow.start();

      await flow.verify('123');

      expect(feedback.warnings, [AuthWarning.otpIncomplete]);
      expect(provider.verifyOtpCalls, isEmpty);
      await flow.dispose();
    });

    test(
      'wrong code: error shown, failedAttempts goes up, email kept',
      () async {
        provider.verifyOtpResult = Failed(
          ValidationFailure(messages: ['Invalid OTP']),
        );
        final flow = create();
        await flow.start();

        await flow.verify('123456');
        await flow.verify('654321');

        expect(feedback.failures, hasLength(2));
        expect(flow.state.failedAttempts, 2);
        expect(store.pendingIdentifier, 'rubaz@gmail.com');
        expect(navigator.visits, isEmpty);
        await flow.dispose();
      },
    );

    test('thrown error is a failure and counts as a failed attempt', () async {
      final flow = create();
      await flow.start();
      provider.error = TimeoutException('slow');

      await flow.verify('123456');

      expect(feedback.failures.single, isA<NetworkFailure>());
      expect(flow.state.failedAttempts, 1);
      expect(flow.state.isSubmitting, isFalse);
      await flow.dispose();
    });

    test('auto submit plus button tap sends once', () async {
      final flow = create();
      await flow.start();
      provider.gate = Completer<void>();

      final first = flow.verify('123456');
      final second = flow.verify('123456');
      provider.gate!.complete();
      await Future.wait([first, second]);

      expect(provider.verifyOtpCalls, hasLength(1));
      await flow.dispose();
    });

    test('before start nothing is sent', () async {
      final flow = create();

      await flow.verify('123456');

      expect(provider.verifyOtpCalls, isEmpty);
      await flow.dispose();
    });
  });

  group('resend', () {
    test('blocked during the wait, allowed after, wait starts again', () {
      fakeAsync((async) {
        provider.resendOtpResult = const Success(null, message: 'Sent');
        final flow = create();
        flow.start();
        async.flushMicrotasks();

        flow.resend();
        async.flushMicrotasks();
        expect(provider.resendOtpCalls, isEmpty);

        async.elapse(const Duration(seconds: 30));
        flow.resend();
        async.flushMicrotasks();

        expect(provider.resendOtpCalls, ['rubaz@gmail.com|signup']);
        expect(feedback.successes, ['Sent']);
        expect(flow.state.resendIn, const Duration(seconds: 30));
        flow.dispose();
      });
    });

    test('a failed resend shows the error and keeps resend open', () async {
      provider.resendOtpResult = Failed(ServerFailure(messages: ['Down']));
      final flow = create(cooldown: Duration.zero);
      await flow.start();

      await flow.resend();

      expect(feedback.failures.single.messages, ['Down']);
      expect(flow.state.canResend, isTrue);
      await flow.dispose();
    });

    test('double tap sends once', () async {
      final flow = create(cooldown: Duration.zero);
      await flow.start();
      provider.gate = Completer<void>();

      final first = flow.resend();
      final second = flow.resend();
      provider.gate!.complete();
      await Future.wait([first, second]);

      expect(provider.resendOtpCalls, hasLength(1));
      await flow.dispose();
    });
  });

  test('change email: pending cleared, back to signup', () async {
    final flow = create();
    await flow.start();

    await flow.changeIdentifier();

    expect(store.pendingIdentifier, isNull);
    expect(navigator.visits, ['signup']);
    await flow.dispose();
  });

  test('dispose stops the countdown', () {
    fakeAsync((async) {
      final flow = create();
      flow.start();
      async.flushMicrotasks();

      flow.dispose();
      async.elapse(const Duration(seconds: 30));

      expect(flow.state.resendIn, const Duration(seconds: 30));
      expect(async.pendingTimers, isEmpty);
    });
  });

  group('maskIdentifier', () {
    test('email keeps two letters and the domain', () {
      expect(maskIdentifier('rubaz@gmail.com'), 'ru•••@gmail.com');
    });

    test('short email name keeps one letter', () {
      expect(maskIdentifier('ab@x.io'), 'a•••@x.io');
    });

    test('phone keeps the last three digits', () {
      expect(maskIdentifier('+923001234567'), '•••567');
    });
  });
}
