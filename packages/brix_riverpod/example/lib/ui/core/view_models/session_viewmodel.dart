import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';

/// App start (splash) and logout (settings).
class SessionViewModel extends BrixSessionNotifier<User> {
  @override
  SessionFlow<User> createFlow() => Dependencies.sessionFlow();
}

final sessionProvider =
    NotifierProvider.autoDispose<SessionViewModel, SessionState>(
      SessionViewModel.new,
    );
