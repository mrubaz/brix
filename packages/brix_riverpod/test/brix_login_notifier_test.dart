import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _LoginNotifier extends BrixLoginNotifier<String> {
  _LoginNotifier(this._flow);

  final LoginFlow<String> Function() _flow;

  @override
  LoginFlow<String> createFlow() => _flow();
}

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late NotifierProvider<_LoginNotifier, BrixLoginState> loginProvider;
  late ProviderContainer container;

  setUp(() {
    provider = FakeAuthProvider()
      ..loginResult = const Success(AuthSession(accessToken: 't', user: 'u'));
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
    loginProvider = NotifierProvider<_LoginNotifier, BrixLoginState>(
      () => _LoginNotifier(
        () => LoginFlow(
          provider: provider,
          store: store,
          navigator: navigator,
          feedback: RecordingAuthFeedback(),
        ),
      ),
    );
    container = ProviderContainer.test();
  });

  _LoginNotifier create() {
    container.listen(loginProvider, (_, _) {});
    return container.read(loginProvider.notifier);
  }

  BrixLoginState read() => container.read(loginProvider);

  test('logs in with the typed values', () async {
    final notifier = create()
      ..identifierChanged(' a@b.com ')
      ..passwordChanged(' pw ')
      ..toggleRememberMe();

    await notifier.login();

    expect(provider.loginCalls, ['a@b.com| pw ']);
    expect(store.rememberedCredentials?.password, ' pw ');
    expect(navigator.visits, ['home']);
  });

  test('isSubmitting follows the flow', () async {
    final notifier = create()
      ..identifierChanged('a@b.com')
      ..passwordChanged('pw');
    provider.gate = Completer<void>();

    final login = notifier.login();
    expect(read().isSubmitting, isTrue);
    provider.gate!.complete();
    await login;

    expect(read().isSubmitting, isFalse);
  });

  test('remembered details fill the state on start', () async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );

    create();
    await pumpEventQueue();

    expect(read().identifier, 'a@b.com');
    expect(read().password, 'pw');
    expect(read().rememberMe, isTrue);
  });

  test('prefill keeps the password only for the remembered account', () async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );
    final notifier = create();
    await pumpEventQueue();

    await notifier.prefillIdentifier('other@b.com');
    expect(read().identifier, 'other@b.com');
    expect(read().password, isEmpty);

    await notifier.prefillIdentifier('a@b.com');
    expect(read().password, 'pw');
  });

  test('toggles flip password visibility and remember me', () {
    create()
      ..togglePasswordVisibility()
      ..toggleRememberMe();

    expect(read().obscurePassword, isFalse);
    expect(read().rememberMe, isTrue);
  });

  test('disposing the container disposes the flow', () {
    final flow = create().flow;

    container.dispose();

    expect(flow.isDisposed, isTrue);
  });
}
