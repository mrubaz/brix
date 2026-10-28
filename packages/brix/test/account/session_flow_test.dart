import 'dart:async';

import 'package:brix/account.dart';
import 'package:brix/testing.dart';
import 'package:test/test.dart';

void main() {
  late FakeAuthProvider<void, String> auth;
  late FakeAccountProvider<String, void> account;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late List<String> events;

  const saved = AuthSession(accessToken: 'token', user: 'old-user');

  setUp(() {
    auth = FakeAuthProvider();
    account = FakeAccountProvider();
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    events = [];
  });

  SessionFlow<String> create({bool withAccount = true}) => SessionFlow(
    auth: auth,
    account: withAccount ? account : null,
    store: store,
    navigator: navigator,
    feedback: feedback,
    onSessionStarted: (session) => events.add('started:${session.user}'),
    onSessionEnded: () => events.add('ended'),
  );

  group('start', () {
    test('a waiting signup code opens the code screen', () async {
      store
        ..pendingIdentifier = ' a@b.com '
        ..session = saved;

      await create().start();

      expect(navigator.visits, ['otp:signup:a@b.com']);
      expect(account.currentUserCalls, 0);
    });

    test('nothing saved: login', () async {
      await create().start();

      expect(navigator.visits, ['login']);
      expect(events, isEmpty);
    });

    test('saved session: user refreshed and saved, then home', () async {
      store.session = saved;
      account.currentUserResult = const Success('new-user');

      await create().start();

      expect(store.session?.user, 'new-user');
      expect(store.session?.accessToken, 'token');
      expect(events, ['started:new-user']);
      expect(navigator.visits, ['home']);
    });

    test('rejected session (401): cleared, login', () async {
      store
        ..session = saved
        ..rememberedCredentials = const RememberedCredentials(
          identifier: 'a@b.com',
          password: 'pw',
        );
      account.currentUserResult = Failed(UnauthorizedFailure());

      await create().start();

      expect(store.session, isNull);
      expect(store.rememberedCredentials, isNotNull);
      expect(events, ['ended']);
      expect(navigator.visits, ['login']);
    });

    test('offline: shown, home with the saved user', () async {
      store.session = saved;
      account.currentUserResult = Failed(NetworkFailure());

      await create().start();

      expect(feedback.failures.single, isA<NetworkFailure>());
      expect(events, ['started:old-user']);
      expect(navigator.visits, ['home']);
    });

    test('a thrown error is shown, home with the saved user', () async {
      store.session = saved;
      account.error = TimeoutException('slow');

      await create().start();

      expect(feedback.failures.single, isA<NetworkFailure>());
      expect(navigator.visits, ['home']);
    });

    test('without an account backend the saved session opens home', () async {
      store.session = saved;

      await create(withAccount: false).start();

      expect(events, ['started:old-user']);
      expect(navigator.visits, ['home']);
    });

    test('a storage error counts as nothing saved', () async {
      final flow = SessionFlow<String>(
        auth: auth,
        store: _BrokenStore(),
        navigator: navigator,
        feedback: feedback,
      );

      await flow.start();

      expect(navigator.visits, ['login']);
    });
  });

  group('logout', () {
    test('server logout, session cleared (remember me kept), login', () async {
      store
        ..session = saved
        ..rememberedCredentials = const RememberedCredentials(
          identifier: 'a@b.com',
          password: 'pw',
        );
      final flow = create();

      await flow.logout();

      expect(auth.logoutCalls, 1);
      expect(store.session, isNull);
      expect(store.rememberedCredentials, isNotNull);
      expect(events, ['ended']);
      expect(navigator.visits, ['login']);
      expect(flow.state.isLoggingOut, isFalse);
    });

    test('a failing server still logs out locally', () async {
      store.session = saved;
      auth.error = TimeoutException('slow');

      await create().logout();

      expect(feedback.failures.single, isA<NetworkFailure>());
      expect(store.session, isNull);
      expect(navigator.visits, ['login']);
    });

    test('double tap logs out once', () async {
      auth.gate = Completer<void>();
      final flow = create();

      final first = flow.logout();
      final second = flow.logout();
      expect(flow.state.isLoggingOut, isTrue);
      auth.gate!.complete();
      await Future.wait([first, second]);

      expect(auth.logoutCalls, 1);
      expect(navigator.visits, ['login']);
    });
  });
}

class _BrokenStore extends InMemoryAuthSessionStore<String> {
  @override
  Future<String?> readPendingIdentifier() => throw StateError('broken');

  @override
  Future<AuthSession<String>?> readSession() => throw StateError('broken');
}
