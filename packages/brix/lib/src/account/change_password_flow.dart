import '../auth/auth_form_flow.dart';
import '../auth/auth_navigator.dart';
import '../auth/auth_session_store.dart';
import '../auth/auth_warning.dart';
import '../auth/password_policy.dart';
import '../auth/remembered_credentials.dart';
import '../core/failure.dart';
import '../core/result.dart';
import 'account_provider.dart';

/// The change password screen of a logged-in user. The user stays logged
/// in on this device; ending other sessions is the backend's job.
class ChangePasswordFlow extends FormFlow {
  ChangePasswordFlow({
    required this._account,
    required this._store,
    required this._navigator,
    required super.feedback,
    this.passwordPolicy = const PasswordPolicy(),
  });

  final AccountProvider<dynamic, dynamic> _account;
  final AuthSessionStore<dynamic> _store;
  final AuthNavigator _navigator;
  final PasswordPolicy passwordPolicy;

  @override
  Failure mapError(Object error, StackTrace stackTrace) =>
      _account.mapError(error, stackTrace);

  /// Changes the password; both are sent exactly as typed. Warns without a
  /// backend call when the new one equals the current one or breaks the
  /// [passwordPolicy]. On success the saved "remember me" password is
  /// updated and the screen closes.
  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (isDisposed || state.isSubmitting) return;
    if (newPassword == currentPassword) {
      feedback.warning(AuthWarning.samePassword);
      return;
    }
    if (!passwordPolicy.allows(newPassword)) {
      feedback.warning(AuthWarning.weakPassword);
      return;
    }
    await run(() async {
      final result = await _account.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      switch (result) {
        case Success(:final message):
          await _updateRemembered(newPassword);
          feedback.success(message);
          await _navigator.back();
        case Failed(:final failure):
          feedback.failure(failure);
      }
    });
  }

  /// A remembered old password would fill the login form with a password
  /// that no longer works.
  Future<void> _updateRemembered(String password) async {
    try {
      final saved = await _store.readRememberedCredentials();
      if (saved == null) return;
      await _store.saveRememberedCredentials(
        RememberedCredentials(identifier: saved.identifier, password: password),
      );
    } catch (_) {
      // The password is changed; a stale saved one only means typing it.
    }
  }
}
