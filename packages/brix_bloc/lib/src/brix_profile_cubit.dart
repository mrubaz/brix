import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/account.dart';

/// Cubit for a profile screen, built on brix [ProfileFlow]. The state is the
/// flow's own [ProfileState]; it loads on start.
///
/// The screen owns its form: it fills its fields from `state.user` the first
/// time a user arrives (so an avatar upload never wipes unsaved typing),
/// builds the app's typed update and calls [save].
class BrixProfileCubit<TUser, TProfileUpdate>
    extends Cubit<ProfileState<TUser>> {
  BrixProfileCubit(this.flow) : super(flow.state.copyWith(isLoading: true)) {
    _subscription = flow.changes.listen((profile) {
      if (!isClosed) emit(profile);
    });
    load();
  }

  final ProfileFlow<TUser, TProfileUpdate> flow;
  late final StreamSubscription<ProfileState<TUser>> _subscription;

  /// (Re)loads the profile; also the retry action.
  Future<void> load() => flow.load();

  /// Saves the app's [update]. Check the form first.
  Future<void> save(TProfileUpdate update) => flow.save(update);

  /// Uploads a new avatar. Returns whether it worked.
  Future<bool> uploadAvatar(AvatarUpload avatar) => flow.uploadAvatar(avatar);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await flow.dispose();
    return super.close();
  }
}
