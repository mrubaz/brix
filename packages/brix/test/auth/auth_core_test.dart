import 'dart:async';

import 'package:brix/auth.dart';
import 'package:test/test.dart';

void main() {
  test('AuthSession.toString never contains the tokens', () {
    const session = AuthSession<String>(
      accessToken: 'secret-access',
      refreshToken: 'secret-refresh',
      user: 'user-1',
    );

    expect(session.toString(), isNot(contains('secret')));
    expect(session.toString(), contains('user-1'));
  });

  test('capability defaults are the simplest flow', () {
    const capabilities = AuthCapabilities();

    expect(capabilities.otpAfterSignup, isFalse);
    expect(capabilities.resetMode, ResetMode.none);
    expect(capabilities.otpLength, 6);
  });

  group('AuthProvider defaults', () {
    const provider = _LoginOnlyProvider();

    Future<void> expectUnsupported(Future<Result<void>> call) async {
      final result = await call;
      expect(result.failureOrNull, isA<UnsupportedFailure>());
    }

    test('optional calls fail as unsupported until overridden', () async {
      await expectUnsupported(provider.register('body'));
      await expectUnsupported(
        provider.verifyOtp(
          identifier: 'a@b.com',
          code: '123456',
          purpose: OtpPurpose.signup,
        ),
      );
      await expectUnsupported(
        provider.resendOtp(identifier: 'a@b.com', purpose: OtpPurpose.signup),
      );
      await expectUnsupported(provider.forgotPassword(identifier: 'a@b.com'));
      await expectUnsupported(
        provider.resetPassword(identifier: 'a@b.com', newPassword: 'pw'),
      );
    });

    test('mapError uses the core default', () {
      expect(
        provider.mapError(TimeoutException('slow'), StackTrace.current),
        isA<NetworkFailure>(),
      );
      expect(
        provider.mapError(StateError('boom'), StackTrace.current),
        isA<UnknownFailure>(),
      );
    });
  });
}

/// A provider written with only the two required calls.
class _LoginOnlyProvider extends AuthProvider<String, String> {
  const _LoginOnlyProvider();

  @override
  AuthCapabilities get capabilities => const AuthCapabilities();

  @override
  Future<Result<AuthSession<String>>> login({
    required String identifier,
    required String password,
  }) async => Success(AuthSession(accessToken: 'token', user: identifier));

  @override
  Future<Result<void>> logout() async => const Success(null);
}
