import '../../auth.dart';

/// Navigator that only records where the flows went, for tests.
class RecordingAuthNavigator extends AuthNavigator {
  /// One entry per call, e.g. `home`, `login`, `login:a@b.com`,
  /// `otp:signup:a@b.com`, `forgot`, `back`.
  final List<String> visits = [];

  @override
  Future<void> toHome() async => visits.add('home');

  @override
  Future<void> toLogin({String? identifier}) async =>
      visits.add(identifier == null ? 'login' : 'login:$identifier');

  @override
  Future<void> toForgotPassword() async => visits.add('forgot');

  @override
  Future<void> back() async => visits.add('back');

  @override
  Future<void> toSignup() async => visits.add('signup');

  @override
  Future<void> toOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async => visits.add('otp:${purpose.name}:$identifier');

  @override
  Future<void> toResetPassword({required String identifier}) async =>
      visits.add('reset:$identifier');
}
