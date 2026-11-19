import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/profile_update.dart';
import '../../../domain/models/user.dart';

/// Loads the profile and saves it; brix shows the loader, errors and the
/// success message.
class ProfileViewModel extends BrixProfileNotifier<User, ProfileUpdate> {
  @override
  ProfileFlow<User, ProfileUpdate> createFlow() => ProfileFlow(
    account: Dependencies.account,
    feedback: Dependencies.feedback,
    store: Dependencies.session,
  );
}

final profileProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState<User>>(
      ProfileViewModel.new,
    );
