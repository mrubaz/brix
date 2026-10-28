import 'dart:async';

import 'package:brix/account.dart';
import 'package:get/get.dart';

/// GetX controller for the session actions, built on brix [SessionFlow]:
/// [start] on the splash screen, [logout] from a logout button (show
/// [isLoggingOut] on it). The flow is disposed with the controller.
class BrixSessionController<TUser> extends GetxController {
  BrixSessionController(this.flow);

  final SessionFlow<TUser> flow;

  final isLoggingOut = false.obs;

  StreamSubscription<SessionState>? _stateSubscription;

  @override
  void onInit() {
    super.onInit();
    _stateSubscription = flow.changes.listen(
      (state) => isLoggingOut.value = state.isLoggingOut,
    );
  }

  /// Opens the first screen (code, home or login).
  Future<void> start() => flow.start();

  /// Logs out; double taps are ignored by the flow.
  Future<void> logout() => flow.logout();

  @override
  void onClose() {
    _stateSubscription?.cancel();
    flow.dispose();
    super.onClose();
  }
}
