import 'package:brix/account.dart';

import '../../domain/models/profile_update.dart';
import '../../domain/models/user.dart';
import '../services/local_accounts_service.dart';

/// Profile, password and account deletion on the device's local backend.
/// Only `main_development.dart` uses it.
class AccountRepositoryLocal extends AccountProvider<User, ProfileUpdate> {
  AccountRepositoryLocal(this._accounts, this._session);

  final LocalAccountsService _accounts;
  final AuthSessionStore<User> _session;

  static const _code = LocalAccountsService.demoCode;

  @override
  AccountDeletionMode get deletionMode => AccountDeletionMode.code;

  Future<String?> _email() async => (await _session.readSession())?.user.email;

  @override
  Future<Result<User>> currentUser() async {
    await _wait();
    final email = await _email();
    final account = email == null ? null : await _accounts.find(email);
    if (account == null) return Failed(UnauthorizedFailure());
    return Success(User(id: email!, name: account.name, email: email));
  }

  @override
  Future<Result<void>> updateProfile(ProfileUpdate update) async {
    await _wait();
    final email = await _email();
    final account = email == null ? null : await _accounts.find(email);
    if (account == null) return Failed(UnauthorizedFailure());
    await _accounts.put(email!, account.copyWith(name: update.name));
    return const Success(null, message: 'Profile saved.');
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _wait();
    final email = await _email();
    final account = email == null ? null : await _accounts.find(email);
    if (account == null) return Failed(UnauthorizedFailure());
    if (account.password != currentPassword) {
      return Failed(
        ValidationFailure(messages: ['The current password is wrong.']),
      );
    }
    await _accounts.put(email!, account.copyWith(password: newPassword));
    return const Success(null, message: 'Password changed.');
  }

  @override
  Future<Result<void>> requestAccountDeletion({
    required String identifier,
  }) async {
    await _wait();
    return const Success(null, message: 'We sent you a code: $_code');
  }

  @override
  Future<Result<void>> deleteAccount({
    required String identifier,
    String? code,
    String? password,
  }) async {
    await _wait();
    if (code != _code) {
      return Failed(ValidationFailure(messages: ['Wrong code. Try $_code.']));
    }
    await _accounts.remove(identifier);
    return const Success(null, message: 'Your account is deleted.');
  }

  static Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 600));
}
