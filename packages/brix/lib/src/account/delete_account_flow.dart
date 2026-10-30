import 'dart:async';

import '../auth/auth_navigator.dart';
import '../auth/auth_session_store.dart';
import '../auth/auth_warning.dart';
import '../auth/code_entry_flow.dart';
import '../core/failure.dart';
import '../core/result.dart';
import 'account_deletion_mode.dart';
import 'account_provider.dart';

/// Deleting the logged-in user's account, as the backend's
/// [AccountDeletionMode] says. On success everything the store keeps is
/// cleared ("remember me" too, the account is gone) and login opens.
///
/// [AccountDeletionMode.code]: [requestDeletion] sends the code (the boxes
/// show once [CodeEntryState.isCodeSent]), [confirm] checks it, `resend` sends a
/// new one after the cooldown. [AccountDeletionMode.confirm] /
/// [AccountDeletionMode.password]: [deleteWithoutCode].
class DeleteAccountFlow extends CodeEntryFlow {
  DeleteAccountFlow({
    required this._account,
    required this._store,
    required this._navigator,
    required super.feedback,
    required super.identifier,
    this.otpLength = 6,
    super.resendCooldown = const Duration(seconds: 30),
    this.onAccountDeleted,
  }) : super(codeSent: false);

  final AccountProvider<dynamic, dynamic> _account;
  final AuthSessionStore<dynamic> _store;
  final AuthNavigator _navigator;

  @override
  final int otpLength;

  /// Runs after the local data is cleared, for app state outside the
  /// store (e.g. a cached current user).
  final FutureOr<void> Function()? onAccountDeleted;

  AccountDeletionMode get mode => _account.deletionMode;

  @override
  Future<Result<void>> sendCode(String identifier) =>
      _account.requestAccountDeletion(identifier: identifier);

  @override
  Failure mapError(Object error, StackTrace stackTrace) =>
      _account.mapError(error, stackTrace);

  /// Code mode: sends the first code (later ones through `resend`).
  /// Without a logged-in user: warning.
  Future<void> requestDeletion() async {
    if (state.identifier == null) {
      feedback.warning(AuthWarning.notLoggedIn);
      return;
    }
    if (state.isCodeSent || mode != AccountDeletionMode.code) return;
    await resend();
  }

  /// Code mode: deletes with the typed [code] (trimmed). A code of the
  /// wrong length is a warning, no backend call.
  Future<void> confirm(String code) async {
    final identifier = state.identifier;
    if (isDisposed || identifier == null || state.isSubmitting) return;
    final trimmedCode = code.trim();
    if (!checkCodeLength(trimmedCode)) return;
    await submitOnce(() async {
      final result = await _account.deleteAccount(
        identifier: identifier,
        code: trimmedCode,
      );
      switch (result) {
        case Success(:final message):
          await _finish(message);
        case Failed(:final failure):
          feedback.failure(failure);
          markFailed();
      }
    });
  }

  /// Confirm / password mode: deletes at once ([password] as typed).
  Future<void> deleteWithoutCode({String? password}) async {
    final identifier = state.identifier;
    if (identifier == null) {
      feedback.warning(AuthWarning.notLoggedIn);
      return;
    }
    await submitOnce(() async {
      final result = await _account.deleteAccount(
        identifier: identifier,
        password: password,
      );
      switch (result) {
        case Success(:final message):
          await _finish(message);
        case Failed(:final failure):
          feedback.failure(failure);
      }
    });
  }

  Future<void> _finish(String? message) async {
    try {
      await _store.clearAll();
    } catch (_) {
      // The account is gone; stale local data only means a login attempt
      // that fails.
    }
    await onAccountDeleted?.call();
    feedback.success(message);
    await _navigator.toLogin();
  }
}
