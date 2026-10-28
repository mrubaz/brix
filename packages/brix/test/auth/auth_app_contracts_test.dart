import 'package:brix/auth.dart';
import 'package:test/test.dart';

import 'package:brix/testing.dart';

void main() {
  const session = AuthSession<String>(accessToken: 'token', user: 'user-1');
  const credentials = RememberedCredentials(
    identifier: 'a@b.com',
    password: 'secret-pw ',
  );

  test('RememberedCredentials.toString never contains the password', () {
    expect(credentials.toString(), isNot(contains('secret')));
    expect(credentials.toString(), contains('a@b.com'));
  });

  group('AuthSessionStore defaults', () {
    final store = _SessionOnlyStore();

    test('pending identifier is not kept until overridden', () async {
      await store.savePendingIdentifier('a@b.com');
      expect(await store.readPendingIdentifier(), isNull);
      await store.clearPendingIdentifier();
    });

    test('remembered credentials are not kept until overridden', () async {
      await store.saveRememberedCredentials(credentials);
      expect(await store.readRememberedCredentials(), isNull);
      await store.clearRememberedCredentials();
    });
  });

  group('InMemoryAuthSessionStore', () {
    late InMemoryAuthSessionStore<String> store;

    setUp(() => store = InMemoryAuthSessionStore<String>());

    test('saves and reads every value, password unchanged', () async {
      await store.saveSession(session);
      await store.savePendingIdentifier('a@b.com');
      await store.saveRememberedCredentials(credentials);

      expect(await store.readSession(), same(session));
      expect(await store.readPendingIdentifier(), 'a@b.com');
      expect((await store.readRememberedCredentials())?.password, 'secret-pw ');
    });

    test('clearSession keeps the remembered credentials', () async {
      await store.saveSession(session);
      await store.savePendingIdentifier('a@b.com');
      await store.saveRememberedCredentials(credentials);

      await store.clearSession();

      expect(await store.readSession(), isNull);
      expect(await store.readPendingIdentifier(), isNull);
      expect(await store.readRememberedCredentials(), same(credentials));
    });
  });

  group('AuthNavigator defaults', () {
    final navigator = _HomeLoginNavigator();

    test('required routes are the app\'s own', () async {
      await navigator.toHome();
      await navigator.toLogin();
      expect(navigator.visited, ['home', 'login']);
    });

    test('optional routes throw until overridden', () {
      expect(navigator.toSignup, throwsUnsupportedError);
      expect(
        () =>
            navigator.toOtp(identifier: 'a@b.com', purpose: OtpPurpose.signup),
        throwsA(
          isA<UnsupportedError>().having(
            (error) => error.message,
            'message',
            contains('toOtp'),
          ),
        ),
      );
      expect(
        () => navigator.toResetPassword(identifier: 'a@b.com'),
        throwsUnsupportedError,
      );
    });
  });

  group('AuthWarning', () {
    test('holds only the checks brix itself reports', () {
      expect(AuthWarning.values.map((warning) => warning.name), [
        'otpIncomplete',
        'pendingIdentifierMissing',
        'weakPassword',
        'samePassword',
        'notLoggedIn',
      ]);
    });

    test('every warning brings its own text', () {
      for (final warning in AuthWarning.values) {
        expect(warning.message, isNotEmpty, reason: warning.name);
      }
    });

    test('an app switch with a default case survives new warnings', () {
      const appOwn = AuthWarning('termsNotAccepted', 'Accept the terms.');
      String textFor(AuthWarning warning) => switch (warning) {
        AuthWarning.otpIncomplete => 'app text',
        _ => warning.message,
      };

      expect(textFor(AuthWarning.otpIncomplete), 'app text');
      expect(
        textFor(AuthWarning.samePassword),
        AuthWarning.samePassword.message,
      );
      expect(textFor(appOwn), 'Accept the terms.');
    });

    test('an app warning goes through the same feedback', () {
      final feedback = _RecordingFeedback();
      const appOwn = AuthWarning('termsNotAccepted', 'Accept the terms.');

      feedback.warning(appOwn);

      expect(feedback.warnings, [appOwn]);
    });
  });

  test('OtpPurpose: signup and password reset, switchable with a default', () {
    expect(OtpPurpose.values.map((purpose) => purpose.name), [
      'signup',
      'passwordReset',
    ]);
    String route(OtpPurpose purpose) => switch (purpose) {
      OtpPurpose.signup => 'otp',
      _ => 'other',
    };
    expect(route(OtpPurpose.signup), 'otp');
    expect(route(OtpPurpose.passwordReset), 'other');
  });

  test('AuthFeedback receives failures, warnings and nullable success', () {
    final feedback = _RecordingFeedback();
    final failure = NetworkFailure();

    feedback
      ..failure(failure)
      ..warning(AuthWarning.otpIncomplete)
      ..success(null)
      ..success('Done');

    expect(feedback.failures, [same(failure)]);
    expect(feedback.warnings, [AuthWarning.otpIncomplete]);
    expect(feedback.successes, [null, 'Done']);
  });
}

class _SessionOnlyStore extends AuthSessionStore<String> {
  @override
  Future<void> saveSession(AuthSession<String> session) async {}

  @override
  Future<AuthSession<String>?> readSession() async => null;

  @override
  Future<void> clearSession() async {}
}

class _HomeLoginNavigator extends AuthNavigator {
  final List<String> visited = [];

  @override
  Future<void> toHome() async => visited.add('home');

  @override
  Future<void> toLogin({String? identifier}) async => visited.add('login');
}

class _RecordingFeedback extends AuthFeedback {
  final List<Failure> failures = [];
  final List<AuthWarning> warnings = [];
  final List<String?> successes = [];

  @override
  void failure(Failure failure) => failures.add(failure);

  @override
  void warning(AuthWarning warning) => warnings.add(warning);

  @override
  void success(String? message) => successes.add(message);
}
