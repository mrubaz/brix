import 'dart:async';

import 'package:brix/account.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// GetX controller for a profile screen, built on brix [ProfileFlow].
///
/// The app keeps what differs per app: its form fields (fill them in
/// [onUserLoaded]), "did anything change" ([canSave]) and its body
/// ([buildUpdate]). Loads on start.
abstract class BrixProfileController<TUser, TProfileUpdate>
    extends GetxController {
  BrixProfileController(this.flow);

  final ProfileFlow<TUser, TProfileUpdate> flow;

  final formKey = GlobalKey<FormState>();
  final user = Rxn<TUser>();
  final isLoading = true.obs;
  final loadFailed = false.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;

  StreamSubscription<ProfileState<TUser>>? _stateSubscription;

  /// False while an avatar upload reloads the user, so typed but unsaved
  /// form changes are kept.
  bool _fillForm = true;

  @override
  void onInit() {
    super.onInit();
    _stateSubscription = flow.changes.listen(_apply);
    load();
  }

  void _apply(ProfileState<TUser> state) {
    isLoading.value = state.isLoading;
    loadFailed.value = state.loadFailed;
    isSaving.value = state.isSaving;
    isUploadingAvatar.value = state.isUploadingAvatar;
    final loaded = state.user;
    if (loaded != null && !identical(loaded, user.value)) {
      user.value = loaded;
      onUserLoaded(loaded, fillForm: _fillForm);
    }
  }

  /// A user was loaded. Fill the form when [fillForm] is true.
  @protected
  void onUserLoaded(TUser user, {required bool fillForm}) {}

  /// The app's profile body from its form.
  @protected
  TProfileUpdate buildUpdate();

  /// App check before saving (e.g. something changed). Default: always.
  @protected
  bool canSave() => true;

  /// (Re)loads the profile; also the retry action.
  Future<void> load() => flow.load();

  /// Validates the form, then saves.
  Future<void> save() async {
    if (isSaving.value || !canSave()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;
    await flow.save(buildUpdate());
  }

  /// Uploads a new avatar without touching unsaved form changes. Returns
  /// whether it worked.
  Future<bool> uploadAvatar(AvatarUpload avatar) async {
    _fillForm = false;
    try {
      return await flow.uploadAvatar(avatar);
    } finally {
      _fillForm = true;
    }
  }

  @override
  void onClose() {
    _stateSubscription?.cancel();
    flow.dispose();
    super.onClose();
  }
}
