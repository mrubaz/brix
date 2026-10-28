import 'dart:async';

import 'package:brix/account.dart';
import 'package:brix/testing.dart';
import 'package:test/test.dart';

void main() {
  late FakeAccountProvider account;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late ChangePasswordFlow flow;
  const current = 'Asdf@_123';
  const next = 'Asdf@_1234';

  setUp(() {
    account = FakeAccountProvider();
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    flow = ChangePasswordFlow(
      account: account,
      store: store,
      navigator: navigator,
      feedback: feedback,
    );
  });

  tearDown(() => flow.dispose());

  test('success: both sent as typed, message, screen closes', () async {
    account.changePasswordResult = const Success(null, message: 'Updated');

    await flow.submit(currentPassword: ' $current', newPassword: '$next ');

    expect(account.changePasswordCalls, [' $current|$next ']);
    expect(feedback.successes, ['Updated']);
    expect(navigator.visits, ['back']);
  });

  test('remembered password is replaced with the new one', () async {
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: current,
    );

    await flow.submit(currentPassword: current, newPassword: next);

    expect(store.rememberedCredentials?.identifier, 'a@b.com');
    expect(store.rememberedCredentials?.password, next);
  });

  test('nothing remembered stays nothing remembered', () async {
    await flow.submit(currentPassword: current, newPassword: next);

    expect(store.rememberedCredentials, isNull);
  });

  test('same as the current password: warning, no call', () async {
    await flow.submit(currentPassword: next, newPassword: next);

    expect(feedback.warnings, [AuthWarning.samePassword]);
    expect(account.changePasswordCalls, isEmpty);
  });

  test('weak new password: warning, no call', () async {
    await flow.submit(currentPassword: current, newPassword: 'short');

    expect(feedback.warnings, [AuthWarning.weakPassword]);
    expect(account.changePasswordCalls, isEmpty);
  });

  test('wrong current password: backend message, screen stays', () async {
    final failure = ValidationFailure(messages: ['Current password is wrong']);
    account.changePasswordResult = Failed(failure);
    store.rememberedCredentials = const RememberedCredentials(
      identifier: 'a@b.com',
      password: current,
    );

    await flow.submit(currentPassword: 'nope', newPassword: next);

    expect(feedback.failures, [same(failure)]);
    expect(store.rememberedCredentials?.password, current);
    expect(navigator.visits, isEmpty);
  });

  test('a thrown error becomes a failure', () async {
    account.error = TimeoutException('slow');

    await flow.submit(currentPassword: current, newPassword: next);

    expect(feedback.failures.single, isA<NetworkFailure>());
    expect(flow.state.isSubmitting, isFalse);
  });

  test('double tap sends once', () async {
    account.gate = Completer<void>();

    final first = flow.submit(currentPassword: current, newPassword: next);
    final second = flow.submit(currentPassword: current, newPassword: next);
    account.gate!.complete();
    await Future.wait([first, second]);

    expect(account.changePasswordCalls, hasLength(1));
  });

  test('AccountProvider calls are unsupported until overridden', () async {
    final result = await const _EmptyAccount().changePassword(
      currentPassword: current,
      newPassword: next,
    );

    expect(result.failureOrNull, isA<UnsupportedFailure>());
  });
}

class _EmptyAccount extends AccountProvider<String, void> {
  const _EmptyAccount();
}
