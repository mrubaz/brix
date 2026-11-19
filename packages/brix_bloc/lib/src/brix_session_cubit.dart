import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/account.dart';

/// Cubit for the session actions, built on brix [SessionFlow]: [start] on
/// the splash screen, [logout] from a logout button (`isLoggingOut` for its
/// loader). The flow is disposed when the cubit closes.
class BrixSessionCubit<TUser> extends Cubit<SessionState> {
  BrixSessionCubit(this.flow) : super(flow.state) {
    _subscription = flow.changes.listen((session) {
      if (!isClosed) emit(session);
    });
  }

  final SessionFlow<TUser> flow;
  late final StreamSubscription<SessionState> _subscription;

  /// Opens the first screen (code, home or login).
  Future<void> start() => flow.start();

  /// Logs out; double taps are ignored by the flow.
  Future<void> logout() => flow.logout();

  @override
  Future<void> close() async {
    // The flow first and at once: it stops its timers before anything waits.
    final disposing = flow.dispose();
    await _subscription.cancel();
    await disposing;
    return super.close();
  }
}
