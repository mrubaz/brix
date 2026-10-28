import '../core/failure.dart';
import '../core/result.dart';
import 'auth_capabilities.dart';
import 'auth_session.dart';
import 'otp_purpose.dart';

/// The backend behind the auth flows. Each app writes one subclass for its
/// backend (REST, Firebase, Supabase, …).
///
/// [TSignup] is the app's own typed signup body; [TUser] its user model.
///
/// Only [login] and [logout] must be written. Every other call fails with
/// [UnsupportedFailure] until the subclass overrides it, and calls added to
/// brix later arrive the same way – so adapters never break on update.
///
/// Return [Failed] for anything the backend rejects. Errors may also be
/// thrown; the flows catch them and turn them into a [Failure] with
/// [mapError]. Pass values through as given – never trim or change a
/// password.
abstract class AuthProvider<TSignup, TUser> {
  const AuthProvider();

  AuthCapabilities get capabilities;

  Future<Result<AuthSession<TUser>>> login({
    required String identifier,
    required String password,
  });

  /// Ends the session on the server. Local data is cleared by the flows even
  /// when this fails.
  Future<Result<void>> logout();

  Future<Result<void>> register(TSignup request) async => _unsupported();

  Future<Result<void>> verifyOtp({
    required String identifier,
    required String code,
    required OtpPurpose purpose,
  }) async => _unsupported();

  Future<Result<void>> resendOtp({
    required String identifier,
    required OtpPurpose purpose,
  }) async => _unsupported();

  /// Sends the reset code or link, depending on [AuthCapabilities.resetMode].
  Future<Result<void>> forgotPassword({required String identifier}) async =>
      _unsupported();

  /// [code] is required when [AuthCapabilities.resetMode] is [ResetMode.otp].
  Future<Result<void>> resetPassword({
    required String identifier,
    required String newPassword,
    String? code,
  }) async => _unsupported();

  /// Turns an error thrown by this backend into a [Failure]. Override to map
  /// the backend's own errors (socket errors, SDK error codes) and call
  /// `super.mapError` for the rest.
  Failure mapError(Object error, StackTrace stackTrace) =>
      failureFromError(error, stackTrace);

  static Result<void> _unsupported() => Failed(UnsupportedFailure());
}
