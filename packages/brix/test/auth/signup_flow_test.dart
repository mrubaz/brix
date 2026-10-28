import 'dart:async';

import 'package:brix/auth.dart';
import 'package:brix/testing.dart';
import 'package:test/test.dart';

/// A typed signup body, like an app's own model.
class _SignupBody {
  const _SignupBody(this.email, this.password);
  final String email;
  final String password;
}

void main() {
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  const strong = 'Asdf@_1234';

  setUp(() {
    store = InMemoryAuthSessionStore();
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
  });

  SignupFlow<_SignupBody, String> flowWith(
    FakeAuthProvider<_SignupBody, String> provider,
  ) => SignupFlow(
    provider: provider,
    store: store,
    navigator: navigator,
    feedback: feedback,
  );

  FakeAuthProvider<_SignupBody, String> providerWith({required bool otp}) =>
      FakeAuthProvider(capabilities: AuthCapabilities(otpAfterSignup: otp));

  test('code backend: body sent, pending email saved, code screen', () async {
    final provider = providerWith(otp: true)
      ..registerResult = const Success(null, message: 'Check your email');
    const body = _SignupBody('a@b.com', ' $strong ');

    await flowWith(provider)
        .submit(request: body, identifier: ' a@b.com ', password: ' $strong ');

    expect(provider.registerCalls, [same(body)]);
    expect(store.pendingIdentifier, 'a@b.com');
    expect(feedback.successes, ['Check your email']);
    expect(navigator.visits, ['otp:signup:a@b.com']);
  });

  test('no code: login with the email filled in', () async {
    final provider = providerWith(otp: false);

    await flowWith(provider).submit(
      request: const _SignupBody('a@b.com', strong),
      identifier: 'a@b.com',
      password: strong,
    );

    expect(store.pendingIdentifier, isNull);
    expect(navigator.visits, ['login:a@b.com']);
  });

  test('weak password: warning, no backend call', () async {
    final provider = providerWith(otp: true);

    await flowWith(provider).submit(
      request: const _SignupBody('a@b.com', 'short'),
      identifier: 'a@b.com',
      password: 'short',
    );

    expect(feedback.warnings, [AuthWarning.weakPassword]);
    expect(provider.registerCalls, isEmpty);
  });

  test('backend refusal is shown, nothing saved', () async {
    final failure = ValidationFailure(messages: ['Email already exists']);
    final provider = providerWith(otp: true)..registerResult = Failed(failure);

    await flowWith(provider).submit(
      request: const _SignupBody('a@b.com', strong),
      identifier: 'a@b.com',
      password: strong,
    );

    expect(feedback.failures, [same(failure)]);
    expect(store.pendingIdentifier, isNull);
    expect(navigator.visits, isEmpty);
  });

  test('a thrown error becomes a failure', () async {
    final provider = providerWith(otp: true)..error = TimeoutException('slow');
    final flow = flowWith(provider);

    await flow.submit(
      request: const _SignupBody('a@b.com', strong),
      identifier: 'a@b.com',
      password: strong,
    );

    expect(feedback.failures.single, isA<NetworkFailure>());
    expect(flow.state.isSubmitting, isFalse);
  });

  test('double tap sends once', () async {
    final provider = providerWith(otp: true)..gate = Completer<void>();
    final flow = flowWith(provider);
    const body = _SignupBody('a@b.com', strong);

    final first = flow.submit(
      request: body,
      identifier: 'a@b.com',
      password: strong,
    );
    final second = flow.submit(
      request: body,
      identifier: 'a@b.com',
      password: strong,
    );
    provider.gate!.complete();
    await Future.wait([first, second]);

    expect(provider.registerCalls, hasLength(1));
  });
}
