/// Brix account block: what a logged-in user does with their own account
/// (current user, profile, avatar, change password, delete account, app
/// start and logout).
///
/// Also exports the auth block it builds on.
library;

export 'auth.dart';
export 'src/account/account_deletion_mode.dart';
export 'src/account/account_provider.dart';
export 'src/account/avatar_upload.dart';
export 'src/account/change_password_flow.dart';
export 'src/account/delete_account_flow.dart';
export 'src/account/profile_flow.dart';
export 'src/account/session_flow.dart';
