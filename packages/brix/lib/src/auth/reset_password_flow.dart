import '../core/result.dart';
import 'auth_capabilities.dart';
import 'auth_navigator.dart';
import 'auth_session_store.dart';
import 'auth_warning.dart';
import 'code_entry_flow.dart';
import 'otp_purpose.dart';
import 'password_policy.dart';
import 'remembered_credentials.dart';

/// The "new password" screen of [ResetMode.otp]: the emailed code plus a new
/// password, a new code after a cooldown, or back to change the email.
///
/// Call [start] when the screen opens and [dispose] when it closes.
class ResetPasswordFlow extends AuthCodeEntryFlow<Object?> {
  ResetPasswordFlow({
    required super.provider,
    required this._navigator,
    required super.feedback,
    required super.identifier,
    this.store,
    this.passwordPolicy = const PasswordPolicy(),
    super.resendCooldown = const Duration(seconds: 30),
  }) : super(purpose: OtpPurpose.passwordReset);

  final AuthNavigator _navigator;

  /// When given, "remember me" details for this account get the new
  /// password, so the login form is not filled with the old one.
  final AuthSessionStore<dynamic>? store;

  final PasswordPolicy passwordPolicy;

  /// The account the code was sent to, handed over by the forgot password
  /// screen.
  String? get identifier => state.identifier;

  bool get hasIdentifier => identifier != null;

  /// Without an identifier there is nothing to reset: back to login.
  /// Otherwise the resend wait starts (a code was just sent).
  Future<void> start() async {
    if (!hasIdentifier) {
      await _navigator.toLogin();
      return;
    }
    startCooldown();
  }

  /// Sets [newPassword] (sent exactly as typed) with the emailed [code]
  /// (trimmed). Warns without a backend call when the code has the wrong
  /// length or the password breaks the [passwordPolicy].
  Future<void> submit({
    required String code,
    required String newPassword,
  }) async {
    final identifier = this.identifier;
    if (isDisposed || state.isSubmitting) return;
    if (identifier == null) return start();
    final trimmedCode = code.trim();
    if (!checkCodeLength(trimmedCode)) return;
    if (!passwordPolicy.allows(newPassword)) {
      feedback.warning(AuthWarning.weakPassword);
      return;
    }
    await submitOnce(() async {
      final result = await provider.resetPassword(
        identifier: identifier,
        newPassword: newPassword,
        code: trimmedCode,
      );
      switch (result) {
        case Success(:final message):
          await _updateRemembered(identifier, newPassword);
          feedback.success(message);
          await _navigator.toLogin(identifier: identifier);
        case Failed(:final failure):
          feedback.failure(failure);
          markFailed();
      }
    });
  }

  /// Wrong email: back to the forgot password screen.
  Future<void> changeIdentifier() => _navigator.toForgotPassword();

  Future<void> _updateRemembered(String identifier, String password) async {
    final store = this.store;
    if (store == null) return;
    try {
      final saved = await store.readRememberedCredentials();
      if (saved?.identifier != identifier) return;
      await store.saveRememberedCredentials(
        RememberedCredentials(identifier: identifier, password: password),
      );
    } catch (_) {
      // The password is reset; a stale saved one only means typing it.
    }
  }
}
