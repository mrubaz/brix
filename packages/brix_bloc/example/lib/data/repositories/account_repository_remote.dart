import 'package:brix/account.dart';
import 'package:brix_network/brix_network.dart';

import '../../domain/models/profile_update.dart';
import '../../domain/models/user.dart';

/// Your REST API for the account. Change the paths and fields to match
/// your backend.
class AccountRepositoryRemote extends AccountProvider<User, ProfileUpdate> {
  AccountRepositoryRemote(this._api);

  final BrixApi _api;

  @override
  AccountDeletionMode get deletionMode => AccountDeletionMode.code;

  @override
  Future<Result<User>> currentUser() =>
      _api.get('auth/profile', parse: User.fromJson);

  @override
  Future<Result<void>> updateProfile(ProfileUpdate update) =>
      _api.patch('auth/profile', body: update.toJson());

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _api.patch(
    'auth/change-password',
    body: {'currentPassword': currentPassword, 'newPassword': newPassword},
  );

  @override
  Future<Result<void>> requestAccountDeletion({required String identifier}) =>
      _api.post('auth/account/delete/request', body: {'email': identifier});

  @override
  Future<Result<void>> deleteAccount({
    required String identifier,
    String? code,
    String? password,
  }) => _api.post(
    'auth/account/delete/verify',
    body: {'email': identifier, 'otp': code},
  );
}
