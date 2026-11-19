import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_bloc/brix_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;

  setUp(() {
    provider = FakeAuthProvider()
      ..loginResult = const Success(AuthSession(accessToken: 't', user: 'u'));
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
  });

  BrixLoginCubit<String> create() => BrixLoginCubit(
    LoginFlow(
      provider: provider,
      store: store,
      navigator: navigator,
      feedback: RecordingAuthFeedback(),
    ),
  );

  test('logs in with the typed values', () async {
    final cubit = create()
      ..identifierChanged(' a@b.com ')
      ..passwordChanged(' pw ')
      ..toggleRememberMe();

    await cubit.login();

    expect(provider.loginCalls, ['a@b.com| pw ']);
    expect(store.rememberedCredentials?.password, ' pw ');
    expect(navigator.visits, ['home']);
    await cubit.close();
  });

  test('isSubmitting follows the flow', () async {
    final cubit = create()
      ..identifierChanged('a@b.com')
      ..passwordChanged('pw');
    provider.gate = Completer<void>();

    final login = cubit.login();
    expect(cubit.state.isSubmitting, isTrue);
    provider.gate!.complete();
    await login;

    expect(cubit.state.isSubmitting, isFalse);
    await cubit.close();
  });

  test('remembered details fill the state on start', () async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );

    final cubit = create();
    await pumpEventQueue();

    expect(cubit.state.identifier, 'a@b.com');
    expect(cubit.state.password, 'pw');
    expect(cubit.state.rememberMe, isTrue);
    await cubit.close();
  });

  test('prefill keeps the password only for the remembered account', () async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );
    final cubit = create();
    await pumpEventQueue();

    await cubit.prefillIdentifier('other@b.com');
    expect(cubit.state.identifier, 'other@b.com');
    expect(cubit.state.password, isEmpty);

    await cubit.prefillIdentifier('a@b.com');
    expect(cubit.state.password, 'pw');
    await cubit.close();
  });

  test('toggles flip password visibility and remember me', () async {
    final cubit = create()
      ..togglePasswordVisibility()
      ..toggleRememberMe();

    expect(cubit.state.obscurePassword, isFalse);
    expect(cubit.state.rememberMe, isTrue);
    await cubit.close();
  });

  test('equal states are not emitted twice', () async {
    final cubit = create();
    final states = <BrixLoginState>[];
    final listening = cubit.stream.listen(states.add);

    cubit
      ..identifierChanged('a@b.com')
      ..identifierChanged('a@b.com');
    await pumpEventQueue();

    expect(states, hasLength(1));
    await listening.cancel();
    await cubit.close();
  });

  test('closing disposes the flow', () async {
    final cubit = create();
    final flow = cubit.flow;

    await cubit.close();

    expect(flow.isDisposed, isTrue);
  });
}
