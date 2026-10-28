import 'dart:async';

import '../../account.dart';

/// Account backend whose answers are set by the test, and which records
/// every call.
class FakeAccountProvider<TUser, TProfileUpdate>
    extends AccountProvider<TUser, TProfileUpdate> {
  FakeAccountProvider({this.deletionMode = AccountDeletionMode.code});

  @override
  final AccountDeletionMode deletionMode;

  /// What [currentUser] answers; null = unsupported.
  Result<TUser>? currentUserResult;
  Result<void> updateProfileResult = const Success(null);
  Result<void> uploadAvatarResult = const Success(null);
  Result<void> changePasswordResult = const Success(null);
  Result<void> requestDeletionResult = const Success(null);
  Result<void> deleteAccountResult = const Success(null);

  /// Thrown by every call instead of answering, when set.
  Object? error;

  /// Complete this to finish a call the test holds open; null = answer now.
  Completer<void>? gate;

  int currentUserCalls = 0;
  final List<TProfileUpdate> updateProfileCalls = [];
  final List<AvatarUpload> uploadAvatarCalls = [];

  /// `currentPassword|newPassword`.
  final List<String> changePasswordCalls = [];

  /// The identifier of every request.
  final List<String> requestDeletionCalls = [];

  /// `identifier|code|password`.
  final List<String> deleteAccountCalls = [];

  Future<void> _answer() async {
    await gate?.future;
    final error = this.error;
    if (error != null) throw error;
  }

  @override
  Future<Result<TUser>> currentUser() async {
    currentUserCalls++;
    await _answer();
    return currentUserResult ?? Failed(UnsupportedFailure());
  }

  @override
  Future<Result<void>> updateProfile(TProfileUpdate update) async {
    updateProfileCalls.add(update);
    await _answer();
    return updateProfileResult;
  }

  @override
  Future<Result<void>> uploadAvatar(AvatarUpload avatar) async {
    uploadAvatarCalls.add(avatar);
    await _answer();
    return uploadAvatarResult;
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changePasswordCalls.add('$currentPassword|$newPassword');
    await _answer();
    return changePasswordResult;
  }

  @override
  Future<Result<void>> requestAccountDeletion({
    required String identifier,
  }) async {
    requestDeletionCalls.add(identifier);
    await _answer();
    return requestDeletionResult;
  }

  @override
  Future<Result<void>> deleteAccount({
    required String identifier,
    String? code,
    String? password,
  }) async {
    deleteAccountCalls.add('$identifier|$code|$password');
    await _answer();
    return deleteAccountResult;
  }
}
