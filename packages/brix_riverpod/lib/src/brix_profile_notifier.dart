import 'package:brix/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier for a profile screen, built on brix [ProfileFlow]. The
/// state is the flow's own [ProfileState]; it starts as loading and loads
/// right after the build.
///
/// The screen owns its form: it fills its fields from `state.user` the first
/// time a user arrives (so an avatar upload never wipes unsaved typing),
/// builds the app's typed update and calls [save].
abstract class BrixProfileNotifier<TUser, TProfileUpdate>
    extends Notifier<ProfileState<TUser>> {
  late ProfileFlow<TUser, TProfileUpdate> flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  ProfileFlow<TUser, TProfileUpdate> createFlow();

  @override
  ProfileState<TUser> build() {
    flow = createFlow();
    final subscription = flow.changes.listen((profile) {
      if (ref.mounted) state = profile;
    });
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    Future.microtask(() {
      if (ref.mounted) load();
    });
    return flow.state.copyWith(isLoading: true);
  }

  /// (Re)loads the profile; also the retry action.
  Future<void> load() => flow.load();

  /// Saves the app's [update]. Check the form first.
  Future<void> save(TProfileUpdate update) => flow.save(update);

  /// Uploads a new avatar. Returns whether it worked.
  Future<bool> uploadAvatar(AvatarUpload avatar) => flow.uploadAvatar(avatar);
}
