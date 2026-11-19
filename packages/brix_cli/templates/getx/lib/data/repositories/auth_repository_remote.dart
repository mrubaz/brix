import 'package:brix/auth.dart';
import 'package:brix_network/brix_network.dart';

import '../../domain/models/signup_request.dart';
import '../../domain/models/user.dart';

/// Your REST API for auth, the only class that knows its endpoints. Change
/// the paths and fields to match your backend.
class AuthRepositoryRemote extends AuthProvider<SignupRequest, User> {
  AuthRepositoryRemote(this._api);

  final BrixApi _api;

  @override
  AuthCapabilities get capabilities =>
      const AuthCapabilities(otpAfterSignup: true, resetMode: ResetMode.otp);

  @override
  Future<Result<AuthSession<User>>> login({
    required String identifier,
    required String password,
  }) => _api.post(
    'auth/login',
    body: {'email': identifier, 'password': password},
    parse: (data) => AuthSession(
      accessToken: data.string('token'),
      user: User.fromJson(data.child('user')),
    ),
  );

  @override
  Future<Result<void>> logout() => _api.post('auth/logout');

  @override
  Future<Result<void>> register(SignupRequest request) =>
      _api.post('auth/register', body: request.toJson());

  @override
  Future<Result<void>> verifyOtp({
    required String identifier,
    required String code,
    required OtpPurpose purpose,
  }) => _api.post(
    'auth/verify-otp',
    body: {'email': identifier, 'otp': code, 'purpose': purpose.name},
  );

  @override
  Future<Result<void>> resendOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) => _api.post(
    'auth/resend-otp',
    body: {'email': identifier, 'purpose': purpose.name},
  );

  @override
  Future<Result<void>> forgotPassword({required String identifier}) =>
      _api.post('auth/forgot-password', body: {'email': identifier});

  @override
  Future<Result<void>> resetPassword({
    required String identifier,
    required String newPassword,
    String? code,
  }) => _api.post(
    'auth/reset-password',
    body: {'email': identifier, 'otp': code, 'password': newPassword},
  );
}
