import 'package:brix/account.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier for a profile screen, built on brix [ProfileFlow].
/// The state is the flow's own [ProfileState]; it starts as loading and
/// loads right after the build.
///
/// The app keeps what differs per app: its form fields (make them in
/// [initFields], fill them in [onUserLoaded]), "did anything change"
/// ([canSave]) and its body ([buildUpdate]).
abstract class BrixProfileNotifier<TUser, TProfileUpdate>
    extends Notifier<ProfileState<TUser>> {
  late ProfileFlow<TUser, TProfileUpdate> flow;

  final formKey = GlobalKey<FormState>();

  /// False while an avatar upload reloads the user, so typed but unsaved
  /// form changes are kept.
  bool _fillForm = true;

  /// Makes the flow, usually from the app's own providers. Called on every
  /// build; the old flow is disposed first.
  @protected
  ProfileFlow<TUser, TProfileUpdate> createFlow();

  @override
  ProfileState<TUser> build() {
    flow = createFlow();
    initFields();
    _fillForm = true;
    final subscription = flow.changes.listen(_apply);
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
      disposeFields();
    });
    Future.microtask(() {
      if (ref.mounted) load();
    });
    return flow.state.copyWith(isLoading: true);
  }

  void _apply(ProfileState<TUser> next) {
    final previous = state.user;
    state = next;
    final loaded = next.user;
    if (loaded != null && !identical(loaded, previous)) {
      onUserLoaded(loaded, fillForm: _fillForm);
    }
  }

  /// Makes the app's form fields. Runs on every build, after [flow].
  @protected
  @mustCallSuper
  void initFields() {}

  /// Disposes what [initFields] made.
  @protected
  @mustCallSuper
  void disposeFields() {}

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
    if (state.isSaving || !canSave()) return;
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
}
