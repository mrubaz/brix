import 'package:brix/testing.dart';
import 'package:brix_bloc/brix_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// An app's typed signup body.
class _Body {
  const _Body(this.email, this.password, this.name);
  final String email;
  final String password;
  final String name;
}

/// An app's signup cubit: one extra value and its own check.
class _AppSignupCubit extends BrixSignupCubit<_Body, String> {
  _AppSignupCubit(super.flow);

  String _name = '';
  bool termsAccepted = true;

  void nameChanged(String value) => _name = value;

  @override
  _Body buildRequest({required String identifier, required String password}) =>
      _Body(identifier, password, _name.trim());

  @override
  Future<bool> beforeSubmit() async => termsAccepted;
}

void main() {
  const strong = 'Asdf@_1234';
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late InMemoryAuthSessionStore<String> store;

  setUp(() {
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    store = InMemoryAuthSessionStore();
  });

  group('BrixSignupCubit', () {
    late FakeAuthProvider<_Body, String> provider;
    late _AppSignupCubit cubit;

    setUp(() {
      provider = FakeAuthProvider(
        capabilities: const AuthCapabilities(otpAfterSignup: true),
      );
      cubit = _AppSignupCubit(
        SignupFlow(
          provider: provider,
          store: store,
          navigator: navigator,
          feedback: feedback,
        ),
      );
    });

    tearDown(() => cubit.close());

    void fill() => cubit
      ..nameChanged(' Rubaz ')
      ..identifierChanged(' a@b.com ')
      ..passwordChanged(' $strong');

    test('builds the app body and opens the code screen', () async {
      fill();

      await cubit.signup();

      final body = provider.registerCalls.single;
      expect(body.email, 'a@b.com');
      expect(body.password, ' $strong');
      expect(body.name, 'Rubaz');
      expect(navigator.visits, ['otp:signup:a@b.com']);
    });

    test('the app check can stop the call', () async {
      fill();
      cubit.termsAccepted = false;

      await cubit.signup();

      expect(provider.registerCalls, isEmpty);
    });

    test('unmet rules, matching confirm and toggles', () {
      cubit.passwordChanged('abc');
      expect(cubit.state.passwordRulesMet, isFalse);
      cubit
        ..passwordChanged(strong)
        ..confirmPasswordChanged(strong);
      expect(cubit.state.passwordRulesMet, isTrue);
      expect(cubit.state.passwordsMatch, isTrue);

      cubit
        ..togglePasswordVisibility()
        ..toggleConfirmPasswordVisibility();
      expect(cubit.state.obscurePassword, isFalse);
      expect(cubit.state.obscureConfirmPassword, isFalse);
    });
  });

  group('BrixChangePasswordCubit', () {
    late FakeAccountProvider account;
    late BrixChangePasswordCubit cubit;

    setUp(() {
      account = FakeAccountProvider();
      cubit = BrixChangePasswordCubit(
        ChangePasswordFlow(
          account: account,
          store: store,
          navigator: navigator,
          feedback: feedback,
        ),
      );
    });

    tearDown(() => cubit.close());

    test('changes the password with what is typed and closes', () async {
      cubit
        ..currentPasswordChanged('Asdf@_123')
        ..newPasswordChanged(strong);

      await cubit.submit();

      expect(account.changePasswordCalls, ['Asdf@_123|$strong']);
      expect(navigator.visits, ['back']);
      expect(cubit.state.passwordRulesMet, isTrue);
    });

    test('three show / hide toggles', () {
      cubit
        ..toggleCurrentPasswordVisibility()
        ..toggleNewPasswordVisibility()
        ..toggleConfirmPasswordVisibility();

      expect(cubit.state.obscureCurrentPassword, isFalse);
      expect(cubit.state.obscureNewPassword, isFalse);
      expect(cubit.state.obscureConfirmPassword, isFalse);
    });
  });
}
