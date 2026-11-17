import 'package:brix/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier for the session actions, built on brix [SessionFlow]:
/// [start] on the splash screen, [logout] from a logout button (watch
/// `isLoggingOut` for its loader). The flow is disposed with the provider.
///
/// Extend it and return the app's flow from [createFlow], like
/// `BrixLoginNotifier`.
abstract class BrixSessionNotifier<TUser> extends Notifier<SessionState> {
  late SessionFlow<TUser> flow;

  /// Makes the flow, usually from the app's own providers. Called once per
  /// build.
  @protected
  SessionFlow<TUser> createFlow();

  @override
  SessionState build() {
    flow = createFlow();
    final subscription = flow.changes.listen((session) => state = session);
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    return flow.state;
  }

  /// Opens the first screen (code, home or login).
  Future<void> start() => flow.start();

  /// Logs out; double taps are ignored by the flow.
  Future<void> logout() => flow.logout();
}
