import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _OtpNotifier extends BrixOtpNotifier<String> {
  _OtpNotifier(this._flow);

  final OtpVerificationFlow<String> Function() _flow;

  @override
  OtpVerificationFlow<String> createFlow() => _flow();
}

void main() {
  late FakeAuthProvider<void, String> provider;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late NotifierProvider<_OtpNotifier, CodeEntryState> otpProvider;
  late ProviderContainer container;

  setUp(() {
    provider = FakeAuthProvider(
      capabilities: const AuthCapabilities(otpAfterSignup: true, otpLength: 4),
    );
    store = InMemoryAuthSessionStore()..pendingIdentifier = 'rubaz@gmail.com';
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    otpProvider = NotifierProvider<_OtpNotifier, CodeEntryState>(
      () => _OtpNotifier(
        () => OtpVerificationFlow(
          provider: provider,
          store: store,
          navigator: navigator,
          feedback: feedback,
          resendCooldown: Duration.zero,
        ),
      ),
    );
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  _OtpNotifier create() {
    container.read(otpProvider);
    return container.read(otpProvider.notifier);
  }

  /// Boxes like a real screen; start runs right after the build.
  Future<_OtpNotifier> pumpScreen(WidgetTester tester) async {
    final notifier = create();
    final boxes = notifier.boxes;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              for (var i = 0; i < boxes.length; i++)
                Expanded(
                  child: TextField(
                    controller: boxes.controllers[i],
                    focusNode: boxes.focusNodes[i],
                    maxLength: boxes.length,
                    onChanged: (value) => boxes.onDigitChanged(i, value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    return notifier;
  }

  testWidgets('one box per digit of otpLength', (tester) async {
    final notifier = await pumpScreen(tester);

    expect(notifier.boxes.controllers, hasLength(4));
    expect(container.read(otpProvider).maskedIdentifier, 'ru•••@gmail.com');
  });

  testWidgets('typing moves on and the last digit submits', (tester) async {
    final notifier = await pumpScreen(tester);

    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
    }
    await tester.pump();

    expect(notifier.boxes.code, '1234');
    expect(provider.verifyOtpCalls, ['rubaz@gmail.com|1234|signup']);
    expect(navigator.visits, ['login:rubaz@gmail.com']);
  });

  testWidgets('a pasted code fills every box and submits', (tester) async {
    final notifier = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '9876');
    await tester.pump();

    expect(notifier.boxes.controllers.map((box) => box.text), [
      '9',
      '8',
      '7',
      '6',
    ]);
    expect(provider.verifyOtpCalls, hasLength(1));
  });

  testWidgets('a rejected code clears the boxes', (tester) async {
    provider.verifyOtpResult = Failed(
      ValidationFailure(messages: ['Invalid OTP']),
    );
    final notifier = await pumpScreen(tester);

    await tester.enterText(find.byType(TextField).first, '1234');
    await tester.pump();

    expect(notifier.boxes.code, isEmpty);
    expect(feedback.failures, hasLength(1));
  });

  testWidgets('resend and change email go through the flow', (tester) async {
    final notifier = await pumpScreen(tester);

    await notifier.resend();
    await notifier.changeIdentifier();

    expect(provider.resendOtpCalls, ['rubaz@gmail.com|signup']);
    expect(navigator.visits, ['signup']);
  });

  testWidgets('disposing the provider disposes the flow and boxes', (
    tester,
  ) async {
    final notifier = await pumpScreen(tester);
    final flow = notifier.flow;
    final box = notifier.boxes.controllers.first;
    await tester.pumpWidget(const SizedBox());

    container.dispose();

    expect(flow.isDisposed, isTrue);
    expect(() => box.addListener(() {}), throwsFlutterError);
  });

  testWidgets('a rebuild makes new boxes and drops the old ones', (
    tester,
  ) async {
    final first = create();
    final oldBox = first.boxes.controllers.first;

    container.invalidate(otpProvider);
    final second = create();

    expect(() => oldBox.addListener(() {}), throwsFlutterError);
    expect(second.boxes.controllers.first, isNot(same(oldBox)));
  });
}
