import '../core/result.dart';
import 'auth_form_flow.dart';
import 'auth_navigator.dart';
import 'auth_session_store.dart';
import 'auth_warning.dart';
import 'otp_purpose.dart';
import 'password_policy.dart';

/// The signup screen. The app builds its own typed body ([TSignup]); the
/// flow checks the password, sends it once, then opens the code screen
/// (when the backend sends one) or login.
///
/// Checks that belong to one app (e.g. accepted terms) run in the app
/// before [submit].
class SignupFlow<TSignup, TUser> extends AuthFormFlow<TUser> {
  SignupFlow({
    required super.provider,
    required this._store,
    required this._navigator,
    required super.feedback,
    this.passwordPolicy = const PasswordPolicy(),
  });

  final AuthSessionStore<TUser> _store;
  final AuthNavigator _navigator;
  final PasswordPolicy passwordPolicy;

  /// Registers with [request]. [identifier] (trimmed) is where a code goes;
  /// [password] is only checked against the [passwordPolicy] here – put it
  /// in [request] exactly as typed.
  Future<void> submit({
    required TSignup request,
    required String identifier,
    required String password,
  }) async {
    if (isDisposed || state.isSubmitting) return;
    if (!passwordPolicy.allows(password)) {
      feedback.warning(AuthWarning.weakPassword);
      return;
    }
    final trimmedIdentifier = identifier.trim();
    await run(() async {
      final result = await provider.register(request);
      switch (result) {
        case Success(:final message):
          feedback.success(message);
          if (provider.capabilities.otpAfterSignup) {
            await _store.savePendingIdentifier(trimmedIdentifier);
            await _navigator.toOtp(
              identifier: trimmedIdentifier,
              purpose: OtpPurpose.signup,
            );
          } else {
            await _navigator.toLogin(identifier: trimmedIdentifier);
          }
        case Failed(:final failure):
          feedback.failure(failure);
      }
    });
  }
}
