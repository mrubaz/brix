import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SessionNotifier extends BrixSessionNotifier<String> {
  _SessionNotifier(this._flow);

  final SessionFlow<String> _flow;

  @override
  SessionFlow<String> createFlow() => _flow;
}

void main() {
  late FakeAuthProvider<void, String> auth;
  late RecordingAuthNavigator navigator;
  late SessionFlow<String> flow;
  late NotifierProvider<_SessionNotifier, SessionState> sessionProvider;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthProvider();
    navigator = RecordingAuthNavigator();
    flow = SessionFlow(
      auth: auth,
      store: InMemoryAuthSessionStore<String>(),
      navigator: navigator,
      feedback: RecordingAuthFeedback(),
    );
    sessionProvider = NotifierProvider<_SessionNotifier, SessionState>(
      () => _SessionNotifier(flow),
    );
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  _SessionNotifier create() {
    container.read(sessionProvider);
    return container.read(sessionProvider.notifier);
  }

  test('start opens login when nothing is saved', () async {
    await create().start();

    expect(navigator.visits, ['login']);
  });

  test('isLoggingOut follows the flow during logout', () async {
    final notifier = create();
    auth.gate = Completer<void>();

    final logout = notifier.logout();
    expect(container.read(sessionProvider).isLoggingOut, isTrue);
    auth.gate!.complete();
    await logout;

    expect(container.read(sessionProvider).isLoggingOut, isFalse);
    expect(navigator.visits, ['login']);
  });

  test('disposing the provider disposes the flow', () {
    create();

    container.dispose();

    expect(flow.isDisposed, isTrue);
  });
}
