import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/models/profile_update.dart';
import '../../../domain/models/user.dart';

/// Loads the profile into the form and saves it; brix shows the loader,
/// errors and the success message.
class ProfileViewModel extends BrixProfileController<User, ProfileUpdate> {
  ProfileViewModel(super.flow);

  final nameController = TextEditingController();

  @override
  void onUserLoaded(User user, {required bool fillForm}) {
    if (fillForm) nameController.text = user.name;
  }

  @override
  ProfileUpdate buildUpdate() =>
      ProfileUpdate(name: nameController.text.trim());

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
