import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/material.dart';
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
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  _LoginNotifier create() {
    container.read(loginProvider);
    return container.read(loginProvider.notifier);
  }

  BrixLoginState read() => container.read(loginProvider);

  /// A form whose fields are required, like a real login screen.
  Future<void> pumpForm(WidgetTester tester, _LoginNotifier notifier) =>
      tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: notifier.formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: notifier.identifierController,
                    validator: (value) => value!.isEmpty ? 'required' : null,
                  ),
                  TextFormField(
                    controller: notifier.passwordController,
                    validator: (value) => value!.isEmpty ? 'required' : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  testWidgets('invalid form sends nothing', (tester) async {
    final notifier = create();
    await pumpForm(tester, notifier);

    await notifier.login();

    expect(provider.loginCalls, isEmpty);
  });

  testWidgets('valid form logs in with the typed values', (tester) async {
    final notifier = create();
    await pumpForm(tester, notifier);
    notifier.identifierController.text = ' a@b.com ';
    notifier.passwordController.text = ' pw ';
    notifier.toggleRememberMe();

    await notifier.login();

    expect(provider.loginCalls, ['a@b.com| pw ']);
    expect(store.rememberedCredentials?.password, ' pw ');
    expect(navigator.visits, ['home']);
  });

  testWidgets('isSubmitting follows the flow', (tester) async {
    final notifier = create();
    await pumpForm(tester, notifier);
    notifier.identifierController.text = 'a@b.com';
    notifier.passwordController.text = 'pw';
    provider.gate = Completer<void>();

    final login = notifier.login();
    expect(read().isSubmitting, isTrue);
    provider.gate!.complete();
    await login;

    expect(read().isSubmitting, isFalse);
  });

  testWidgets('remembered details fill the form on start', (tester) async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );

    final notifier = create();
    await tester.pump();

    expect(notifier.identifierController.text, 'a@b.com');
    expect(notifier.passwordController.text, 'pw');
    expect(read().rememberMe, isTrue);
  });

  testWidgets('prefill keeps the password only for the remembered account', (
    tester,
  ) async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );
    final notifier = create();
    await tester.pump();

    await notifier.prefillIdentifier('other@b.com');

    expect(notifier.identifierController.text, 'other@b.com');
    expect(notifier.passwordController.text, isEmpty);
  });

  testWidgets('toggles flip password visibility and remember me', (
    tester,
  ) async {
    final notifier = create();

    notifier
      ..togglePasswordVisibility()
      ..toggleRememberMe();

    expect(read().obscurePassword, isFalse);
    expect(read().rememberMe, isTrue);
  });

  testWidgets('disposing the provider disposes the flow and fields', (
    tester,
  ) async {
    final notifier = create();
    final flow = notifier.flow;

    container.dispose();

    expect(flow.isDisposed, isTrue);
    expect(
      () => notifier.identifierController.addListener(() {}),
      throwsFlutterError,
    );
  });

  testWidgets('a rebuild makes a new flow and drops the old one', (
    tester,
  ) async {
    final first = create().flow;

    container.invalidate(loginProvider);
    final second = create().flow;

    expect(first.isDisposed, isTrue);
    expect(second.isDisposed, isFalse);
  });
}
