import 'dart:async';

import 'package:brix/auth.dart';
import 'package:brix/testing.dart';
import 'package:test/test.dart';

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late List<AuthSession<String>> loggedIn;
  late LoginFlow<String> flow;

  const session = AuthSession(accessToken: 'token', user: 'user-1');

  setUp(() {
    provider = FakeAuthProvider();
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    loggedIn = [];
    flow = LoginFlow(
      provider: provider,
      store: store,
      navigator: navigator,
      feedback: feedback,
      onLoggedIn: loggedIn.add,
    );
  });

  tearDown(() => flow.dispose());

  group('success', () {
    setUp(() => provider.loginResult = const Success(session, message: 'Hi'));

    test(
      'saves the session, runs the hook, shows the message, goes home',
      () async {
        await flow.submit(identifier: 'a@b.com', password: 'pw');

        expect(store.session, same(session));
        expect(loggedIn, [session]);
        expect(feedback.successes, ['Hi']);
        expect(feedback.failures, isEmpty);
        expect(navigator.visits, ['home']);
        expect(flow.state.isSubmitting, isFalse);
      },
    );

    test('identifier is trimmed, password sent exactly as typed', () async {
      await flow.submit(identifier: '  a@b.com ', password: ' pass word ');

      expect(provider.loginCalls, ['a@b.com| pass word ']);
    });

    test(
      'remember me on keeps trimmed identifier and untouched password',
      () async {
        await flow.submit(
          identifier: ' a@b.com ',
          password: ' pw ',
          rememberMe: true,
        );

        expect(store.rememberedCredentials?.identifier, 'a@b.com');
        expect(store.rememberedCredentials?.password, ' pw ');
      },
    );

    test('remember me off clears earlier saved details', () async {
      store.rememberedCredentials = const RememberedCredentials(
        identifier: 'old@b.com',
        password: 'old',
      );

      await flow.submit(identifier: 'a@b.com', password: 'pw');

      expect(store.rememberedCredentials, isNull);
    });
  });

  test('backend failure is shown, nothing saved, no navigation', () async {
    final failure = UnauthorizedFailure(messages: ['Wrong password']);
    provider.loginResult = Failed(failure);

    await flow.submit(identifier: 'a@b.com', password: 'pw', rememberMe: true);

    expect(feedback.failures, [same(failure)]);
    expect(store.session, isNull);
    expect(store.rememberedCredentials, isNull);
    expect(loggedIn, isEmpty);
    expect(navigator.visits, isEmpty);
    expect(flow.state.isSubmitting, isFalse);
  });

  test('a thrown error becomes a failure through mapError', () async {
    provider.error = TimeoutException('slow');

    await flow.submit(identifier: 'a@b.com', password: 'pw');

    expect(feedback.failures.single, isA<NetworkFailure>());
    expect(flow.state.isSubmitting, isFalse);
  });

  test('a second submit while busy is ignored (double tap)', () async {
    provider
      ..loginResult = const Success(session)
      ..gate = Completer<void>();

    final first = flow.submit(identifier: 'a@b.com', password: 'pw');
    final second = flow.submit(identifier: 'a@b.com', password: 'pw');
    expect(flow.state.isSubmitting, isTrue);
    provider.gate!.complete();
    await Future.wait([first, second]);

    expect(provider.loginCalls, hasLength(1));
    expect(navigator.visits, ['home']);
  });

  test('changes report busy then idle', () async {
    provider.loginResult = const Success(session);
    final states = <bool>[];
    flow.changes.listen((state) => states.add(state.isSubmitting));

    await flow.submit(identifier: 'a@b.com', password: 'pw');

    expect(states, [true, false]);
  });

  test('submit after dispose does nothing', () async {
    await flow.dispose();

    await flow.submit(identifier: 'a@b.com', password: 'pw');

    expect(provider.loginCalls, isEmpty);
  });

  group('loadRemembered', () {
    test('returns the saved details', () async {
      store.rememberedCredentials = const RememberedCredentials(
        identifier: 'a@b.com',
        password: 'pw',
      );

      expect((await flow.loadRemembered())?.identifier, 'a@b.com');
    });

    test('a storage error counts as nothing saved', () async {
      final failing = LoginFlow<String>(
        provider: provider,
        store: _ThrowingStore(),
        navigator: navigator,
        feedback: feedback,
      );

      expect(await failing.loadRemembered(), isNull);
      await failing.dispose();
    });
  });
}

class _ThrowingStore extends InMemoryAuthSessionStore<String> {
  @override
  Future<RememberedCredentials?> readRememberedCredentials() =>
      throw StateError('keystore broken');
}
