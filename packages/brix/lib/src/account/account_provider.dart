import '../core/failure.dart';
import '../core/result.dart';
import 'account_deletion_mode.dart';
import 'avatar_upload.dart';

/// The backend for a logged-in user's own account: current user, profile,
/// avatar, password, deletion. Kept apart from `AuthProvider`, so an app
/// writes only the parts it has.
///
/// [TUser] is the app's user model, [TProfileUpdate] its typed profile
/// body. Every call fails with [UnsupportedFailure] until the subclass
/// overrides it, and calls added to brix later arrive the same way.
abstract class AccountProvider<TUser, TProfileUpdate> {
  const AccountProvider();

  /// How account deletion is confirmed; [AccountDeletionMode.none] until
  /// the subclass says otherwise.
  AccountDeletionMode get deletionMode => AccountDeletionMode.none;

  /// The logged-in user, fresh from the backend.
  Future<Result<TUser>> currentUser() async => _unsupported();

  Future<Result<void>> updateProfile(TProfileUpdate update) async =>
      _unsupported();

  Future<Result<void>> uploadAvatar(AvatarUpload avatar) async =>
      _unsupported();

  /// [currentPassword] and [newPassword] are sent exactly as typed.
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => _unsupported();

  /// [AccountDeletionMode.code]: sends the code to [identifier] (also used
  /// to send a new one).
  Future<Result<void>> requestAccountDeletion({
    required String identifier,
  }) async => _unsupported();

  /// Deletes the account. [code] or [password] as [deletionMode] needs.
  Future<Result<void>> deleteAccount({
    required String identifier,
    String? code,
    String? password,
  }) async => _unsupported();

  /// Turns an error thrown by this backend into a [Failure]. Override like
  /// `AuthProvider.mapError`.
  Failure mapError(Object error, StackTrace stackTrace) =>
      failureFromError(error, stackTrace);

  static Failed<T> _unsupported<T>() => Failed(UnsupportedFailure());
}
