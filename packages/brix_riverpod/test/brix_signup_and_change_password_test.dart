import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// An app's typed signup body.
class _Body {
  const _Body(this.email, this.password, this.name);
  final String email;
  final String password;
  final String name;
}

/// An app's signup notifier: one extra value and its own check.
class _AppSignupNotifier extends BrixSignupNotifier<_Body, String> {
  _AppSignupNotifier(this._flow);

  final SignupFlow<_Body, String> Function() _flow;

  String _name = '';
  bool termsAccepted = true;

  @override
  SignupFlow<_Body, String> createFlow() => _flow();

  void nameChanged(String value) => _name = value;

  @override
  _Body buildRequest({required String identifier, required String password}) =>
      _Body(identifier, password, _name.trim());

  @override
  Future<bool> beforeSubmit() async => termsAccepted;
}

class _ChangeNotifier extends BrixChangePasswordNotifier {
  _ChangeNotifier(this._flow);

  final ChangePasswordFlow Function() _flow;

  @override
  ChangePasswordFlow createFlow() => _flow();
}

void main() {
  const strong = 'Asdf@_1234';
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late InMemoryAuthSessionStore<String> store;
  late ProviderContainer container;

  setUp(() {
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    store = InMemoryAuthSessionStore();
    container = ProviderContainer.test();
  });

  group('BrixSignupNotifier', () {
    late FakeAuthProvider<_Body, String> provider;
    late NotifierProvider<_AppSignupNotifier, BrixSignupState> signupProvider;
    late _AppSignupNotifier notifier;

    setUp(() {
      provider = FakeAuthProvider(
        capabilities: const AuthCapabilities(otpAfterSignup: true),
      );
      signupProvider = NotifierProvider<_AppSignupNotifier, BrixSignupState>(
        () => _AppSignupNotifier(
          () => SignupFlow(
            provider: provider,
            store: store,
            navigator: navigator,
            feedback: feedback,
          ),
        ),
      );
      container.listen(signupProvider, (_, _) {});
      notifier = container.read(signupProvider.notifier);
    });

    BrixSignupState read() => container.read(signupProvider);

    void fill() => notifier
      ..nameChanged(' Rubaz ')
      ..identifierChanged(' a@b.com ')
      ..passwordChanged(' $strong');

    test('builds the app body and opens the code screen', () async {
      fill();

      await notifier.signup();

      final body = provider.registerCalls.single;
      expect(body.email, 'a@b.com');
      expect(body.password, ' $strong');
      expect(body.name, 'Rubaz');
      expect(navigator.visits, ['otp:signup:a@b.com']);
    });

    test('the app check can stop the call', () async {
      fill();
      notifier.termsAccepted = false;

      await notifier.signup();

      expect(provider.registerCalls, isEmpty);
    });

    test('unmet rules, matching confirm and toggles', () {
      notifier.passwordChanged('abc');
      expect(read().passwordRulesMet, isFalse);
      notifier
        ..passwordChanged(strong)
        ..confirmPasswordChanged(strong);
      expect(read().passwordRulesMet, isTrue);
      expect(read().passwordsMatch, isTrue);

      notifier
        ..togglePasswordVisibility()
        ..toggleConfirmPasswordVisibility();
      expect(read().obscurePassword, isFalse);
      expect(read().obscureConfirmPassword, isFalse);
    });
  });

  group('BrixChangePasswordNotifier', () {
    late FakeAccountProvider account;
    late NotifierProvider<_ChangeNotifier, BrixChangePasswordState>
    changeProvider;
    late _ChangeNotifier notifier;

    setUp(() {
      account = FakeAccountProvider();
      changeProvider =
          NotifierProvider<_ChangeNotifier, BrixChangePasswordState>(
            () => _ChangeNotifier(
              () => ChangePasswordFlow(
                account: account,
                store: store,
                navigator: navigator,
                feedback: feedback,
              ),
            ),
          );
      container.listen(changeProvider, (_, _) {});
      notifier = container.read(changeProvider.notifier);
    });

    BrixChangePasswordState read() => container.read(changeProvider);

    test('changes the password with what is typed and closes', () async {
      notifier
        ..currentPasswordChanged('Asdf@_123')
        ..newPasswordChanged(strong);

      await notifier.submit();

      expect(account.changePasswordCalls, ['Asdf@_123|$strong']);
      expect(navigator.visits, ['back']);
      expect(read().passwordRulesMet, isTrue);
    });

    test('three show / hide toggles', () {
      notifier
        ..toggleCurrentPasswordVisibility()
        ..toggleNewPasswordVisibility()
        ..toggleConfirmPasswordVisibility();

      expect(read().obscureCurrentPassword, isFalse);
      expect(read().obscureNewPassword, isFalse);
      expect(read().obscureConfirmPassword, isFalse);
    });
  });
}
