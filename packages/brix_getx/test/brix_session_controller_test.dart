import 'dart:async';

import 'package:brix/account.dart';
import 'package:brix/testing.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeAuthProvider<void, String> auth;
  late RecordingAuthNavigator navigator;
  late BrixSessionController<String> controller;

  setUp(() {
    Get.testMode = true;
    auth = FakeAuthProvider();
    navigator = RecordingAuthNavigator();
    controller = Get.put(
      BrixSessionController(
        SessionFlow(
          auth: auth,
          store: InMemoryAuthSessionStore<String>(),
          navigator: navigator,
          feedback: RecordingAuthFeedback(),
        ),
      ),
    );
  });

  tearDown(Get.reset);

  test('start opens login when nothing is saved', () async {
    await controller.start();

    expect(navigator.visits, ['login']);
  });

  test('isLoggingOut follows the flow during logout', () async {
    auth.gate = Completer<void>();

    final logout = controller.logout();
    expect(controller.isLoggingOut.value, isTrue);
    auth.gate!.complete();
    await logout;

    expect(controller.isLoggingOut.value, isFalse);
    expect(navigator.visits, ['login']);
  });

  test('closing disposes the flow', () async {
    await Get.delete<BrixSessionController<String>>();

    expect(controller.flow.isDisposed, isTrue);
  });
}
