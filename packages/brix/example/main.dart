// A login with brix in plain Dart, no Flutter, no state library.
//
// Run: dart run example/main.dart
//
// An app writes three small classes once (provider, navigator, feedback)
// and gets the whole login behaviour: double-tap guard, trimmed email,
// untouched password, remember me, session saved, home opened.
import 'package:brix/auth.dart';

/// Your backend. Here an in-memory one; in an app it calls your API.
class DemoAuthProvider extends AuthProvider<void, String> {
  @override
  AuthCapabilities get capabilities => const AuthCapabilities();

  @override
  Future<Result<AuthSession<String>>> login({
    required String identifier,
    required String password,
  }) async {
    if (identifier == 'demo@brix.dev' && password == 'Demo@1234') {
      return Success(
        AuthSession(accessToken: 'token', user: 'Demo user'),
        message: 'Welcome back!',
      );
    }
    return Failed(ValidationFailure(messages: ['Wrong email or password.']));
  }

  @override
  Future<Result<void>> logout() async => const Success(null);
}

/// Your screens. Here it only prints where the app would go.
class PrintNavigator extends AuthNavigator {
  @override
  Future<void> toHome() async => print('→ home');

  @override
  Future<void> toLogin({String? identifier}) async => print('→ login');
}

/// Your alerts. Brix sends backend messages and default texts.
class PrintFeedback extends AuthFeedback {
  @override
  void failure(Failure failure) => print('error: ${failure.displayMessage}');

  @override
  void warning(AuthWarning warning) => print('warning: ${warning.message}');

  @override
  void success(String? message) {
    if (message != null) print('ok: $message');
  }
}

/// Keeps the session in memory. In an app: secure storage.
class MemoryStore extends AuthSessionStore<String> {
  AuthSession<String>? session;

  @override
  Future<void> saveSession(AuthSession<String> session) async =>
      this.session = session;

  @override
  Future<AuthSession<String>?> readSession() async => session;

  @override
  Future<void> clearSession() async => session = null;
}

Future<void> main() async {
  final store = MemoryStore();
  final flow = LoginFlow<String>(
    provider: DemoAuthProvider(),
    store: store,
    navigator: PrintNavigator(),
    feedback: PrintFeedback(),
  );
  flow.changes.listen((state) => print('busy: ${state.isSubmitting}'));

  await flow.submit(identifier: 'demo@brix.dev', password: 'wrong');
  await flow.submit(identifier: '  demo@brix.dev ', password: 'Demo@1234');
  print('logged in as: ${store.session?.user}');

  flow.dispose();
}
