import 'dart:async';

import '../core/result.dart';
import 'auth_form_flow.dart';
import 'auth_navigator.dart';
import 'auth_session.dart';
import 'auth_session_store.dart';
import 'remembered_credentials.dart';

/// Everything the login screen does, without any UI or state library.
///
/// Form validation stays in the app (it needs Flutter); call [submit] only
/// with valid input.
class LoginFlow<TUser> extends AuthFormFlow<TUser> {
  LoginFlow({
    required super.provider,
    required this._store,
    required this._navigator,
    required super.feedback,
    this.onLoggedIn,
  });

  final AuthSessionStore<TUser> _store;
  final AuthNavigator _navigator;

  /// Runs after the session is saved, before home opens – for app state
  /// that lives outside the store (e.g. a cached current user).
  final FutureOr<void> Function(AuthSession<TUser> session)? onLoggedIn;

  /// The saved "remember me" details to fill the form with, or `null`.
  /// A storage error counts as nothing saved.
  Future<RememberedCredentials?> loadRemembered() async {
    try {
      return await _store.readRememberedCredentials();
    } catch (_) {
      return null;
    }
  }

  /// Logs in. Ignored while a login is already running (double tap).
  ///
  /// [identifier] is trimmed; [password] is sent exactly as typed.
  Future<void> submit({
    required String identifier,
    required String password,
    bool rememberMe = false,
  }) => run(() async {
    final trimmedIdentifier = identifier.trim();
    final result = await provider.login(
      identifier: trimmedIdentifier,
      password: password,
    );
    switch (result) {
      case Success(data: final session, :final message):
        await _store.saveSession(session);
        if (rememberMe) {
          await _store.saveRememberedCredentials(
            RememberedCredentials(
              identifier: trimmedIdentifier,
              password: password,
            ),
          );
        } else {
          await _store.clearRememberedCredentials();
        }
        await onLoggedIn?.call(session);
        feedback.success(message);
        await _navigator.toHome();
      case Failed(:final failure):
        feedback.failure(failure);
    }
  });
}
