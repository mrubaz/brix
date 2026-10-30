import 'dart:async';

import '../auth/auth_feedback.dart';
import '../auth/auth_session.dart';
import '../auth/auth_session_store.dart';
import '../core/brix_flow.dart';
import '../core/result.dart';
import 'account_provider.dart';
import 'avatar_upload.dart';

/// State of the profile screen.
class ProfileState<TUser> {
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.loadFailed = false,
    this.isSaving = false,
    this.isUploadingAvatar = false,
  });

  /// The last loaded user; null before the first load.
  final TUser? user;

  final bool isLoading;

  /// The first load failed; the screen should offer a retry.
  final bool loadFailed;

  final bool isSaving;
  final bool isUploadingAvatar;

  ProfileState<TUser> copyWith({
    TUser? user,
    bool? isLoading,
    bool? loadFailed,
    bool? isSaving,
    bool? isUploadingAvatar,
  }) => ProfileState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    loadFailed: loadFailed ?? this.loadFailed,
    isSaving: isSaving ?? this.isSaving,
    isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
  );
}

/// The logged-in user's profile: load, save the app's typed update, new
/// avatar. After a save or an avatar the user is reloaded, and the saved
/// session gets the fresh user.
class ProfileFlow<TUser, TProfileUpdate> extends BrixFlow<ProfileState<TUser>> {
  ProfileFlow({
    required this._account,
    required this._feedback,
    this._store,
    this.onUserChanged,
  }) : super(ProfileState<TUser>());

  final AccountProvider<TUser, TProfileUpdate> _account;
  final AuthFeedback _feedback;

  /// When given, the saved session's user is replaced on every load.
  final AuthSessionStore<TUser>? _store;

  /// Runs with every loaded user, for app state outside the store.
  final FutureOr<void> Function(TUser user)? onUserChanged;

  /// Loads the user. [showLoader] false reloads quietly (after a save): no
  /// loader, and a failure does not turn the screen into a retry.
  Future<void> load({bool showLoader = true}) async {
    if (isDisposed) return;
    if (showLoader) emit(state.copyWith(isLoading: true, loadFailed: false));
    try {
      final result = await _account.currentUser();
      switch (result) {
        case Success(data: final user):
          await _remember(user);
          emit(state.copyWith(user: user));
        case Failed(:final failure):
          _feedback.failure(failure);
          if (showLoader) emit(state.copyWith(loadFailed: true));
      }
    } catch (error, stackTrace) {
      _feedback.failure(_account.mapError(error, stackTrace));
      if (showLoader) emit(state.copyWith(loadFailed: true));
    } finally {
      if (showLoader) emit(state.copyWith(isLoading: false));
    }
  }

  /// Saves [update], then reloads the user. Ignored while saving.
  Future<void> save(TProfileUpdate update) async {
    if (isDisposed || state.isSaving) return;
    emit(state.copyWith(isSaving: true));
    try {
      final result = await _account.updateProfile(update);
      switch (result) {
        case Success(:final message):
          await load(showLoader: false);
          _feedback.success(message);
        case Failed(:final failure):
          _feedback.failure(failure);
      }
    } catch (error, stackTrace) {
      _feedback.failure(_account.mapError(error, stackTrace));
    } finally {
      emit(state.copyWith(isSaving: false));
    }
  }

  /// Uploads [avatar], then reloads the user. Ignored while uploading.
  /// Returns whether it worked (the screen drops its preview either way).
  Future<bool> uploadAvatar(AvatarUpload avatar) async {
    if (isDisposed || state.isUploadingAvatar) return false;
    emit(state.copyWith(isUploadingAvatar: true));
    try {
      final result = await _account.uploadAvatar(avatar);
      switch (result) {
        case Success(:final message):
          await load(showLoader: false);
          _feedback.success(message);
          return true;
        case Failed(:final failure):
          _feedback.failure(failure);
          return false;
      }
    } catch (error, stackTrace) {
      _feedback.failure(_account.mapError(error, stackTrace));
      return false;
    } finally {
      emit(state.copyWith(isUploadingAvatar: false));
    }
  }

  Future<void> _remember(TUser user) async {
    final store = _store;
    if (store != null) {
      try {
        final session = await store.readSession();
        if (session != null) {
          await store.saveSession(
            AuthSession(
              accessToken: session.accessToken,
              user: user,
              refreshToken: session.refreshToken,
              expiresAt: session.expiresAt,
            ),
          );
        }
      } catch (_) {
        // The screen still shows the fresh user.
      }
    }
    await onUserChanged?.call(user);
  }
}
