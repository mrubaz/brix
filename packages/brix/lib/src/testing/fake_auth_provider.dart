import 'dart:async';

import '../../auth.dart';

/// Provider whose answers are set by the test, and which records every call.
class FakeAuthProvider<TSignup, TUser> extends AuthProvider<TSignup, TUser> {
  FakeAuthProvider({this.capabilities = const AuthCapabilities()});

  @override
  final AuthCapabilities capabilities;

  /// What [login] answers.
  Result<AuthSession<TUser>>? loginResult;

  /// What [register] answers.
  Result<void> registerResult = const Success(null);

  /// What [forgotPassword] and [resetPassword] answer.
  Result<void> forgotPasswordResult = const Success(null);
  Result<void> resetPasswordResult = const Success(null);

  /// What [verifyOtp] and [resendOtp] answer.
  Result<void> verifyOtpResult = const Success(null);
  Result<void> resendOtpResult = const Success(null);

  /// Thrown by every call instead of answering, when set.
  Object? error;

  /// Complete this to finish a call the test holds open; null = answer now.
  Completer<void>? gate;

  /// Every call as received: `identifier|password`.
  final List<String> loginCalls = [];

  /// Every [register] request as received.
  final List<TSignup> registerCalls = [];

  /// Every call as received: the identifier.
  final List<String> forgotPasswordCalls = [];

  /// Every call as received: `identifier|code|newPassword`.
  final List<String> resetPasswordCalls = [];

  /// Every call as received: `identifier|code|purpose`.
  final List<String> verifyOtpCalls = [];

  /// Every call as received: `identifier|purpose`.
  final List<String> resendOtpCalls = [];

  int logoutCalls = 0;

  Future<void> _answer() async {
    await gate?.future;
    final error = this.error;
    if (error != null) throw error;
  }

  @override
  Future<Result<AuthSession<TUser>>> login({
    required String identifier,
    required String password,
  }) async {
    loginCalls.add('$identifier|$password');
    await _answer();
    return loginResult ?? Failed(UnknownFailure());
  }

  @override
  Future<Result<void>> logout() async {
    logoutCalls++;
    await _answer();
    return const Success(null);
  }

  @override
  Future<Result<void>> register(TSignup request) async {
    registerCalls.add(request);
    await _answer();
    return registerResult;
  }

  @override
  Future<Result<void>> forgotPassword({required String identifier}) async {
    forgotPasswordCalls.add(identifier);
    await _answer();
    return forgotPasswordResult;
  }

  @override
  Future<Result<void>> resetPassword({
    required String identifier,
    required String newPassword,
    String? code,
  }) async {
    resetPasswordCalls.add('$identifier|$code|$newPassword');
    await _answer();
    return resetPasswordResult;
  }

  @override
  Future<Result<void>> verifyOtp({
    required String identifier,
    required String code,
    required OtpPurpose purpose,
  }) async {
    verifyOtpCalls.add('$identifier|$code|${purpose.name}');
    await _answer();
    return verifyOtpResult;
  }

  @override
  Future<Result<void>> resendOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async {
    resendOtpCalls.add('$identifier|${purpose.name}');
    await _answer();
    return resendOtpResult;
  }
}
