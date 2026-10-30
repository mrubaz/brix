import 'dart:async';

import '../auth/auth_feedback.dart';
import '../auth/auth_navigator.dart';
import '../auth/auth_provider.dart';
import '../auth/auth_session.dart';
import '../auth/auth_session_store.dart';
import '../auth/otp_purpose.dart';
import '../core/brix_flow.dart';
import '../core/failure.dart';
import '../core/result.dart';
import 'account_provider.dart';

/// State of the session actions.
class SessionState {
  const SessionState({this.isLoggingOut = false});

  /// A logout is running; the logout button should show a loader.
  final bool isLoggingOut;
}

/// Starts and ends the user's session: what opens when the app starts, and
/// logout.
class SessionFlow<TUser> extends BrixFlow<SessionState> {
  SessionFlow({
    required this._auth,
    required this._store,
    required this._navigator,
    required this._feedback,
    this._account,
    this.onSessionStarted,
    this.onSessionEnded,
  }) : super(const SessionState());

  final AuthProvider<dynamic, TUser> _auth;
  final AuthSessionStore<TUser> _store;
  final AuthNavigator _navigator;
  final AuthFeedback _feedback;

  /// When given, the saved user is refreshed from the backend on start, and
  /// a rejected session (401) sends the user to login.
  final AccountProvider<TUser, dynamic>? _account;

  /// Runs before home opens with the (refreshed) session, for app state
  /// outside the store (e.g. a cached current user).
  final FutureOr<void> Function(AuthSession<TUser> session)? onSessionStarted;

  /// Runs after the local session is cleared (logout, rejected session).
  final FutureOr<void> Function()? onSessionEnded;

  /// Opens the right first screen:
  /// - a signup code still waiting to the code screen;
  /// - a saved session to its user refreshed, then home; a rejected session
  ///   to cleared, login; other errors (e.g. offline) to shown, home with the
  ///   saved user;
  /// - nothing saved to login.
  ///
  /// Storage errors count as nothing saved.
  Future<void> start() async {
    final pending = await _read(_store.readPendingIdentifier);
    if (pending != null && pending.trim().isNotEmpty) {
      await _navigator.toOtp(
        identifier: pending.trim(),
        purpose: OtpPurpose.signup,
      );
      return;
    }
    final saved = await _read(_store.readSession);
    if (saved == null) {
      await _navigator.toLogin();
      return;
    }
    var session = saved;
    final account = _account;
    if (account != null) {
      try {
        final result = await account.currentUser();
        switch (result) {
          case Success(data: final user):
            session = AuthSession(
              accessToken: session.accessToken,
              user: user,
              refreshToken: session.refreshToken,
              expiresAt: session.expiresAt,
            );
            await _store.saveSession(session);
          case Failed(failure: UnauthorizedFailure()):
            await _endLocally();
            await _navigator.toLogin();
            return;
          case Failed(:final failure):
            _feedback.failure(failure);
        }
      } catch (error, stackTrace) {
        _feedback.failure(account.mapError(error, stackTrace));
      }
    }
    await onSessionStarted?.call(session);
    await _navigator.toHome();
  }

  /// Logs out on the backend, then always locally, a failed server call
  /// is shown but never keeps the user logged in. "Remember me" stays.
  /// Ignored while a logout is running.
  Future<void> logout() async {
    if (isDisposed || state.isLoggingOut) return;
    emit(const SessionState(isLoggingOut: true));
    try {
      final result = await _auth.logout();
      if (result case Failed(:final failure)) _feedback.failure(failure);
    } catch (error, stackTrace) {
      _feedback.failure(_auth.mapError(error, stackTrace));
    } finally {
      await _endLocally();
      emit(const SessionState());
      await _navigator.toLogin();
    }
  }

  Future<void> _endLocally() async {
    try {
      await _store.clearSession();
    } catch (_) {
      // Nothing more to clear.
    }
    await onSessionEnded?.call();
  }

  static Future<T?> _read<T>(Future<T?> Function() read) async {
    try {
      return await read();
    } catch (_) {
      return null;
    }
  }
}
