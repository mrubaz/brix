import 'package:brix/testing.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;

  setUp(() {
    Get.testMode = true;
    provider = FakeAuthProvider(
      capabilities: const AuthCapabilities(otpAfterSignup: true, otpLength: 4),
    );
    store = InMemoryAuthSessionStore()..pendingIdentifier = 'rubaz@gmail.com';
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
  });

  tearDown(Get.reset);

  /// Boxes like a real screen; onReady (start) runs after the first frame.
  Future<BrixOtpController<String>> pumpScreen(WidgetTester tester) async {
    final controller = Get.put(
      BrixOtpController(
        OtpVerificationFlow(
          provider: provider,
          store: store,
          navigator: navigator,
          feedback: feedback,
          resendCooldown: Duration.zero,
        ),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              for (var i = 0; i < controller.boxes.length; i++)
                Expanded(
                  child: TextField(
                    controller: controller.boxes.controllers[i],
                    focusNode: controller.boxes.focusNodes[i],
                    maxLength: controller.boxes.length,
                    onChanged: (value) =>
                        controller.boxes.onDigitChanged(i, value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    return controller;
  }

  testWidgets('one box per digit of otpLength', (tester) async {
    final controller = await pumpScreen(tester);

    expect(controller.boxes.controllers, hasLength(4));
    expect(controller.maskedIdentifier.value, 'ru•••@gmail.com');
  });

  testWidgets('typing moves on and the last digit submits', (tester) async {
    final controller = await pumpScreen(tester);

    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
    }
    await tester.pump();

    expect(controller.boxes.code, '1234');
    expect(provider.verifyOtpCalls, ['rubaz@gmail.com|1234|signup']);
    expect(navigator.visits, ['login:rubaz@gmail.com']);
  });

  testWidgets('a pasted code fills every box and submits', (tester) async {
    final controller = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '9876');
    await tester.pump();

    expect(controller.boxes.controllers.map((box) => box.text), [
      '9',
      '8',
      '7',
      '6',
    ]);
    expect(provider.verifyOtpCalls, hasLength(1));
  });

  testWidgets('typing over a digit keeps the new one', (tester) async {
    final controller = await pumpScreen(tester);
    controller.boxes.controllers[0].text = '1';

    controller.boxes.onDigitChanged(0, '15');

    expect(controller.boxes.controllers[0].text, '5');
  });

  testWidgets('a rejected code clears the boxes', (tester) async {
    provider.verifyOtpResult = Failed(
      ValidationFailure(messages: ['Invalid OTP']),
    );
    final controller = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.pump();

    expect(controller.boxes.code, isEmpty);
    expect(feedback.failures, hasLength(1));
  });

  testWidgets('resend and change email go through the flow', (tester) async {
    final controller = await pumpScreen(tester);

    await controller.resend();
    await controller.changeIdentifier();

    expect(provider.resendOtpCalls, ['rubaz@gmail.com|signup']);
    expect(navigator.visits, ['signup']);
  });

  testWidgets('closing disposes the flow', (tester) async {
    final controller = await pumpScreen(tester);

    await Get.delete<BrixOtpController<String>>();

    expect(controller.flow.isDisposed, isTrue);
  });
}
