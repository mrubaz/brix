import 'package:brix/testing.dart';
import 'package:brix_bloc/brix_bloc.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrixOtpCubit', () {
    late FakeAuthProvider<void, String> provider;
    late InMemoryAuthSessionStore<String> store;
    late RecordingAuthNavigator navigator;
    late RecordingAuthFeedback feedback;

    setUp(() {
      provider = FakeAuthProvider(
        capabilities: const AuthCapabilities(
          otpAfterSignup: true,
          otpLength: 4,
        ),
      );
      store = InMemoryAuthSessionStore()..pendingIdentifier = 'rubaz@gmail.com';
      navigator = RecordingAuthNavigator();
      feedback = RecordingAuthFeedback();
    });

    Future<BrixOtpCubit<String>> create() async {
      final cubit = BrixOtpCubit(
        OtpVerificationFlow(
          provider: provider,
          store: store,
          navigator: navigator,
          feedback: feedback,
          resendCooldown: Duration.zero,
        ),
      );
      await pumpEventQueue();
      return cubit;
    }

    test('starts with the pending email and the code length', () async {
      final cubit = await create();

      expect(cubit.otpLength, 4);
      expect(cubit.state.maskedIdentifier, 'ru•••@gmail.com');
      await cubit.close();
    });

    test('a right code opens login with the email', () async {
      final cubit = await create();

      await cubit.verify('1234');

      expect(provider.verifyOtpCalls, ['rubaz@gmail.com|1234|signup']);
      expect(navigator.visits, ['login:rubaz@gmail.com']);
      await cubit.close();
    });

    test('a rejected code counts a failed attempt', () async {
      provider.verifyOtpResult = Failed(
        ValidationFailure(messages: ['Invalid OTP']),
      );
      final cubit = await create();

      await cubit.verify('1234');

      expect(cubit.state.failedAttempts, 1);
      expect(feedback.failures, hasLength(1));
      await cubit.close();
    });

    test('resend and change email go through the flow', () async {
      final cubit = await create();

      await cubit.resend();
      await cubit.changeIdentifier();

      expect(provider.resendOtpCalls, ['rubaz@gmail.com|signup']);
      expect(navigator.visits, ['signup']);
      await cubit.close();
    });

    test('closing stops the resend countdown at once', () {
      fakeAsync((async) {
        final cubit = BrixOtpCubit(
          OtpVerificationFlow(
            provider: provider,
            store: store,
            navigator: navigator,
            feedback: feedback,
          ),
        );
        async.flushMicrotasks();
        expect(async.periodicTimerCount, 1);

        cubit.close();

        expect(async.periodicTimerCount, 0);
      });
    });

    test('closing disposes the flow', () async {
      final cubit = await create();
      final flow = cubit.flow;

      await cubit.close();

      expect(flow.isDisposed, isTrue);
    });
  });

  group('BrixForgotPasswordCubit and BrixResetPasswordCubit', () {
    const strong = 'New@pass1';
    late FakeAuthProvider<void, Object?> provider;
    late RecordingAuthNavigator navigator;
    late RecordingAuthFeedback feedback;

    setUp(() {
      provider = FakeAuthProvider(
        capabilities: const AuthCapabilities(resetMode: ResetMode.otp),
      );
      navigator = RecordingAuthNavigator();
      feedback = RecordingAuthFeedback();
    });

    Future<BrixResetPasswordCubit> reset(String? identifier) async {
      final cubit = BrixResetPasswordCubit(
        ResetPasswordFlow(
          provider: provider,
          navigator: navigator,
          feedback: feedback,
          identifier: identifier,
          resendCooldown: Duration.zero,
        ),
      );
      await pumpEventQueue();
      return cubit;
    }

    test('forgot sends the typed email and opens reset', () async {
      final cubit = BrixForgotPasswordCubit(
        ForgotPasswordFlow(
          provider: provider,
          navigator: navigator,
          feedback: feedback,
        ),
      )..identifierChanged('a@b.com');

      await cubit.submit();

      expect(provider.forgotPasswordCalls, ['a@b.com']);
      expect(navigator.visits, ['reset:a@b.com']);
      expect(cubit.state.isSubmitting, isFalse);
      await cubit.close();
    });

    test(
      'reset sends the code and new password, login with the email',
      () async {
        final cubit = await reset(' a@b.com ');
        cubit.newPasswordChanged(strong);

        await cubit.submit('123456');

        expect(cubit.state.code.maskedIdentifier, 'a•••@b.com');
        expect(provider.resetPasswordCalls, ['a@b.com|123456|$strong']);
        expect(navigator.visits, ['login:a@b.com']);
        await cubit.close();
      },
    );

    test('the unmet rules follow the typed password', () async {
      final cubit = await reset('a@b.com');
      expect(cubit.state.passwordRulesMet, isFalse);

      cubit.newPasswordChanged('abc');
      expect(cubit.state.unmetPasswordRules, contains(PasswordRule.minLength));

      cubit.newPasswordChanged(strong);
      expect(cubit.state.passwordRulesMet, isTrue);
      expect(cubit.passwordRules, isNotEmpty);
      await cubit.close();
    });

    test('a wrong code counts a failed attempt, the password stays', () async {
      provider.resetPasswordResult = Failed(
        ValidationFailure(messages: ['Invalid OTP']),
      );
      final cubit = await reset('a@b.com');
      cubit.newPasswordChanged(strong);

      await cubit.submit('123456');

      expect(cubit.state.code.failedAttempts, 1);
      expect(cubit.state.newPassword, strong);
      await cubit.close();
    });

    test('resend and change email go through the flow', () async {
      final cubit = await reset('a@b.com');

      await cubit.resend();
      await cubit.changeIdentifier();

      expect(provider.resendOtpCalls, ['a@b.com|passwordReset']);
      expect(navigator.visits, ['forgot']);
      await cubit.close();
    });

    test('opened without an identifier goes to login', () async {
      final cubit = await reset(null);

      expect(navigator.visits, ['login']);
      await cubit.close();
    });

    test('toggle flips new password visibility', () async {
      final cubit = await reset('a@b.com');

      cubit.toggleNewPasswordVisibility();

      expect(cubit.state.obscureNewPassword, isFalse);
      await cubit.close();
    });
  });
}
