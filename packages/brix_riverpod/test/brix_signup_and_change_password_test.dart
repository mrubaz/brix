import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// An app's typed signup body.
class _Body {
  const _Body(this.email, this.password, this.name);
  final String email;
  final String password;
  final String name;
}

/// An app's signup notifier: one extra field and its own check.
class _AppSignupNotifier extends BrixSignupNotifier<_Body, String> {
  _AppSignupNotifier(this._flow);

  final SignupFlow<_Body, String> Function() _flow;

  late TextEditingController nameController;
  bool termsAccepted = true;

  @override
  SignupFlow<_Body, String> createFlow() => _flow();

  @override
  void initFields() {
    super.initFields();
    nameController = TextEditingController();
  }

  @override
  void disposeFields() {
    nameController.dispose();
    super.disposeFields();
  }

  @override
  _Body buildRequest({required String identifier, required String password}) =>
      _Body(identifier, password, nameController.text.trim());

  @override
  Future<bool> beforeSubmit() async => termsAccepted;
}

class _ChangePasswordNotifier extends BrixChangePasswordNotifier {
  _ChangePasswordNotifier(this._flow);

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
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  Future<void> pumpForm(
    WidgetTester tester,
    GlobalKey<FormState> key,
    List<TextEditingController> fields,
  ) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Form(
          key: key,
          child: Column(
            children: [
              for (final field in fields)
                TextFormField(
                  controller: field,
                  validator: (value) => value!.isEmpty ? 'required' : null,
                ),
            ],
          ),
        ),
      ),
    ),
  );

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
      container.read(signupProvider);
      notifier = container.read(signupProvider.notifier);
    });

    BrixSignupState read() => container.read(signupProvider);

    Future<void> fill(WidgetTester tester) async {
      await pumpForm(tester, notifier.formKey, [
        notifier.nameController,
        notifier.identifierController,
        notifier.passwordController,
      ]);
      notifier.nameController.text = ' Rubaz ';
      notifier.identifierController.text = ' a@b.com ';
      notifier.passwordController.text = ' $strong';
    }

    testWidgets('builds the app body and opens the code screen', (
      tester,
    ) async {
      await fill(tester);

      await notifier.signup();

      final body = provider.registerCalls.single;
      expect(body.email, 'a@b.com');
      expect(body.password, ' $strong');
      expect(body.name, 'Rubaz');
      expect(navigator.visits, ['otp:signup:a@b.com']);
    });

    testWidgets('the app check can stop the call', (tester) async {
      await fill(tester);
      notifier.termsAccepted = false;

      await notifier.signup();

      expect(provider.registerCalls, isEmpty);
    });

    testWidgets('invalid form sends nothing', (tester) async {
      await pumpForm(tester, notifier.formKey, [notifier.identifierController]);

      await notifier.signup();

      expect(provider.registerCalls, isEmpty);
    });

    testWidgets('unmet rules and toggles', (tester) async {
      notifier.passwordController.text = 'abc';
      expect(read().passwordRulesMet, isFalse);
      notifier.passwordController.text = strong;
      expect(read().passwordRulesMet, isTrue);

      notifier
        ..togglePasswordVisibility()
        ..toggleConfirmPasswordVisibility();
      expect(read().obscurePassword, isFalse);
      expect(read().obscureConfirmPassword, isFalse);
    });

    testWidgets('app fields are made again after a rebuild', (tester) async {
      final oldName = notifier.nameController;

      container.invalidate(signupProvider);
      container.read(signupProvider);

      expect(() => oldName.addListener(() {}), throwsFlutterError);
      expect(notifier.nameController, isNot(same(oldName)));
      notifier.nameController.text = 'still works';
    });
  });

  group('BrixChangePasswordNotifier', () {
    late FakeAccountProvider account;
    late NotifierProvider<_ChangePasswordNotifier, BrixChangePasswordState>
    changeProvider;
    late _ChangePasswordNotifier notifier;

    setUp(() {
      account = FakeAccountProvider();
      changeProvider =
          NotifierProvider<_ChangePasswordNotifier, BrixChangePasswordState>(
            () => _ChangePasswordNotifier(
              () => ChangePasswordFlow(
                account: account,
                store: store,
                navigator: navigator,
                feedback: feedback,
              ),
            ),
          );
      container.read(changeProvider);
      notifier = container.read(changeProvider.notifier);
    });

    testWidgets('valid form changes the password and closes', (tester) async {
      await pumpForm(tester, notifier.formKey, [
        notifier.currentPasswordController,
        notifier.newPasswordController,
      ]);
      notifier.currentPasswordController.text = 'Asdf@_123';
      notifier.newPasswordController.text = strong;

      await notifier.submit();

      expect(account.changePasswordCalls, ['Asdf@_123|$strong']);
      expect(navigator.visits, ['back']);
      expect(container.read(changeProvider).passwordRulesMet, isTrue);
    });

    testWidgets('invalid form sends nothing', (tester) async {
      await pumpForm(tester, notifier.formKey, [
        notifier.currentPasswordController,
      ]);

      await notifier.submit();

      expect(account.changePasswordCalls, isEmpty);
    });

    testWidgets('three show / hide toggles', (tester) async {
      notifier
        ..toggleCurrentPasswordVisibility()
        ..toggleNewPasswordVisibility()
        ..toggleConfirmPasswordVisibility();

      final state = container.read(changeProvider);
      expect(state.obscureCurrentPassword, isFalse);
      expect(state.obscureNewPassword, isFalse);
      expect(state.obscureConfirmPassword, isFalse);
    });
  });
}
