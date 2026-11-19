import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/profile_update.dart';
import '../../../domain/models/user.dart';

/// Loads the profile into the form and saves it; brix shows the loader,
/// errors and the success message.
class ProfileViewModel extends BrixProfileNotifier<User, ProfileUpdate> {
  late TextEditingController nameController;

  @override
  ProfileFlow<User, ProfileUpdate> createFlow() => ProfileFlow(
    account: Dependencies.account,
    feedback: Dependencies.feedback,
    store: Dependencies.session,
  );

  @override
  void initFields() {
    super.initFields();
    nameController = TextEditingController();
  }

  @override
  void disposeFields() {
    nameController.dispose();
    super.disposeFields();
  }

  @override
  void onUserLoaded(User user, {required bool fillForm}) {
    if (fillForm) nameController.text = user.name;
  }

  @override
  ProfileUpdate buildUpdate() =>
      ProfileUpdate(name: nameController.text.trim());
}

final profileProvider =
    NotifierProvider.autoDispose<ProfileViewModel, ProfileState<User>>(
      ProfileViewModel.new,
    );
