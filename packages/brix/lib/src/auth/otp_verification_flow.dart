import '../core/result.dart';
import 'auth_navigator.dart';
import 'auth_session_store.dart';
import 'auth_warning.dart';
import 'code_entry_flow.dart';
import 'otp_purpose.dart';

/// The code screen after signup: verify the emailed code, ask for a new one
/// after a cooldown, or go back to change the email.
///
/// Call [start] when the screen opens and [dispose] when it closes.
class OtpVerificationFlow<TUser> extends AuthCodeEntryFlow<TUser> {
  OtpVerificationFlow({
    required super.provider,
    required this._store,
    required this._navigator,
    required super.feedback,
    super.purpose = OtpPurpose.signup,
    this.resendCooldown = const Duration(seconds: 30),
  }) : super(resendCooldown: resendCooldown);

  final AuthSessionStore<TUser> _store;
  final AuthNavigator _navigator;

  /// Wait between two codes. The first code was just sent, so the wait also
  /// runs when the screen opens. [Duration.zero] turns it off.
  final Duration resendCooldown;

  /// Reads where the code was sent. Without it there is nothing to verify:
  /// warns and goes back to signup.
  Future<void> start() async {
    String? identifier;
    try {
      identifier = await _store.readPendingIdentifier();
    } catch (_) {
      identifier = null;
    }
    if (isDisposed) return;
    if (identifier == null || identifier.trim().isEmpty) {
      feedback.warning(AuthWarning.pendingIdentifierMissing);
      await _navigator.toSignup();
      return;
    }
    setIdentifier(identifier);
    startCooldown();
  }

  /// Checks [code] (trimmed). A code of the wrong length is a warning, no
  /// backend call. Ignored while a check is running (double tap, auto
  /// submit plus button).
  Future<void> verify(String code) async {
    final identifier = state.identifier;
    if (isDisposed || identifier == null || state.isSubmitting) return;
    final trimmedCode = code.trim();
    if (!checkCodeLength(trimmedCode)) return;
    await submitOnce(() async {
      final result = await provider.verifyOtp(
        identifier: identifier,
        code: trimmedCode,
        purpose: purpose,
      );
      switch (result) {
        case Success(:final message):
          await _store.clearPendingIdentifier();
          feedback.success(message);
          await _navigator.toLogin(identifier: identifier);
        case Failed(:final failure):
          feedback.failure(failure);
          markFailed();
      }
    });
  }

  /// Wrong email: forget it and go back to signup.
  Future<void> changeIdentifier() async {
    try {
      await _store.clearPendingIdentifier();
    } catch (_) {
      // Nothing to keep; signup saves the new one.
    }
    await _navigator.toSignup();
  }
}
