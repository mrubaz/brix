import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late BrixLoginController<String> controller;

  setUp(() {
    Get.testMode = true;
    provider = FakeAuthProvider()
      ..loginResult = const Success(AuthSession(accessToken: 't', user: 'u'));
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
  });

  tearDown(Get.reset);

  BrixLoginController<String> create() => Get.put(
    BrixLoginController(
      LoginFlow(
        provider: provider,
        store: store,
        navigator: navigator,
        feedback: RecordingAuthFeedback(),
      ),
    ),
  );

  /// A form whose fields are required, like a real login screen.
  Future<void> pumpForm(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: controller.formKey,
          child: Column(
            children: [
              TextFormField(
                controller: controller.identifierController,
                validator: (value) => value!.isEmpty ? 'required' : null,
              ),
              TextFormField(
                controller: controller.passwordController,
                validator: (value) => value!.isEmpty ? 'required' : null,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  testWidgets('invalid form sends nothing', (tester) async {
    controller = create();
    await pumpForm(tester);

    await controller.login();

    expect(provider.loginCalls, isEmpty);
  });

  testWidgets('valid form logs in with the typed values', (tester) async {
    controller = create();
    await pumpForm(tester);
    controller.identifierController.text = ' a@b.com ';
    controller.passwordController.text = ' pw ';
    controller.toggleRememberMe();

    await controller.login();

    expect(provider.loginCalls, ['a@b.com| pw ']);
    expect(store.rememberedCredentials?.password, ' pw ');
    expect(navigator.visits, ['home']);
  });

  testWidgets('isSubmitting follows the flow', (tester) async {
    controller = create();
    await pumpForm(tester);
    controller.identifierController.text = 'a@b.com';
    controller.passwordController.text = 'pw';
    provider.gate = Completer<void>();

    final login = controller.login();
    expect(controller.isSubmitting.value, isTrue);
    provider.gate!.complete();
    await login;

    expect(controller.isSubmitting.value, isFalse);
  });

  testWidgets('remembered details fill the form on start', (tester) async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: 'pw',
    );

    controller = create();
    await tester.pump();

    expect(controller.identifierController.text, 'a@b.com');
    expect(controller.passwordController.text, 'pw');
    expect(controller.rememberMe.value, isTrue);
  });

  testWidgets('toggles flip password visibility and remember me', (
    tester,
  ) async {
    controller = create();

    controller
      ..togglePasswordVisibility()
      ..toggleRememberMe();

    expect(controller.obscurePassword.value, isFalse);
    expect(controller.rememberMe.value, isTrue);
  });

  testWidgets('closing the controller disposes the flow', (tester) async {
    controller = create();

    await Get.delete<BrixLoginController<String>>();

    expect(controller.flow.isDisposed, isTrue);
  });
}
