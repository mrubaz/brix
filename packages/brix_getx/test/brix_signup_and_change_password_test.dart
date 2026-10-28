import 'package:brix/testing.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// An app's typed signup body.
class _Body {
  const _Body(this.email, this.password, this.name);
  final String email;
  final String password;
  final String name;
}

/// An app's signup controller: one extra field and its own check.
class _AppSignupController extends BrixSignupController<_Body, String> {
  _AppSignupController(super.flow);

  final nameController = TextEditingController();
  bool termsAccepted = true;

  @override
  _Body buildRequest({required String identifier, required String password}) =>
      _Body(identifier, password, nameController.text.trim());

  @override
  Future<bool> beforeSubmit() async => termsAccepted;
}

void main() {
  const strong = 'Asdf@_1234';
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late InMemoryAuthSessionStore<String> store;

  setUp(() {
    Get.testMode = true;
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    store = InMemoryAuthSessionStore();
  });

  tearDown(Get.reset);

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

  group('BrixSignupController', () {
    late FakeAuthProvider<_Body, String> provider;
    late _AppSignupController controller;

    setUp(() {
      provider = FakeAuthProvider(
        capabilities: const AuthCapabilities(otpAfterSignup: true),
      );
      controller = Get.put(
        _AppSignupController(
          SignupFlow(
            provider: provider,
            store: store,
            navigator: navigator,
            feedback: feedback,
          ),
        ),
      );
    });

    Future<void> fill(WidgetTester tester) async {
      await pumpForm(tester, controller.formKey, [
        controller.nameController,
        controller.identifierController,
        controller.passwordController,
      ]);
      controller.nameController.text = ' Rubaz ';
      controller.identifierController.text = ' a@b.com ';
      controller.passwordController.text = ' $strong';
    }

    testWidgets('builds the app body and opens the code screen', (
      tester,
    ) async {
      await fill(tester);

      await controller.signup();

      final body = provider.registerCalls.single;
      expect(body.email, 'a@b.com');
      expect(body.password, ' $strong');
      expect(body.name, 'Rubaz');
      expect(navigator.visits, ['otp:signup:a@b.com']);
    });

    testWidgets('the app check can stop the call', (tester) async {
      await fill(tester);
      controller.termsAccepted = false;

      await controller.signup();

      expect(provider.registerCalls, isEmpty);
    });

    testWidgets('invalid form sends nothing', (tester) async {
      await pumpForm(tester, controller.formKey, [
        controller.identifierController,
      ]);

      await controller.signup();

      expect(provider.registerCalls, isEmpty);
    });

    testWidgets('checklist and toggles', (tester) async {
      controller.passwordController.text = 'abc';
      expect(controller.passwordRules.isMet, isFalse);
      controller.passwordController.text = strong;
      expect(controller.passwordRules.isMet, isTrue);

      controller
        ..togglePasswordVisibility()
        ..toggleConfirmPasswordVisibility();
      expect(controller.obscurePassword.value, isFalse);
      expect(controller.obscureConfirmPassword.value, isFalse);
    });
  });

  group('BrixChangePasswordController', () {
    late FakeAccountProvider account;
    late BrixChangePasswordController controller;

    setUp(() {
      account = FakeAccountProvider();
      controller = Get.put(
        BrixChangePasswordController(
          ChangePasswordFlow(
            account: account,
            store: store,
            navigator: navigator,
            feedback: feedback,
          ),
        ),
      );
    });

    testWidgets('valid form changes the password and closes', (tester) async {
      await pumpForm(tester, controller.formKey, [
        controller.currentPasswordController,
        controller.newPasswordController,
      ]);
      controller.currentPasswordController.text = 'Asdf@_123';
      controller.newPasswordController.text = strong;

      await controller.submit();

      expect(account.changePasswordCalls, ['Asdf@_123|$strong']);
      expect(navigator.visits, ['back']);
    });

    testWidgets('invalid form sends nothing', (tester) async {
      await pumpForm(tester, controller.formKey, [
        controller.currentPasswordController,
      ]);

      await controller.submit();

      expect(account.changePasswordCalls, isEmpty);
    });

    testWidgets('three show / hide toggles', (tester) async {
      controller
        ..toggleCurrentPasswordVisibility()
        ..toggleNewPasswordVisibility()
        ..toggleConfirmPasswordVisibility();

      expect(controller.obscureCurrentPassword.value, isFalse);
      expect(controller.obscureNewPassword.value, isFalse);
      expect(controller.obscureConfirmPassword.value, isFalse);
    });
  });

  group('BrixLoginController.prefillIdentifier', () {
    BrixLoginController<String> create() => Get.put(
      BrixLoginController(
        LoginFlow(
          provider: FakeAuthProvider<void, String>(),
          store: store,
          navigator: navigator,
          feedback: feedback,
        ),
      ),
    );

    testWidgets('remembered account: email and password filled', (
      tester,
    ) async {
      store.rememberedCredentials = const RememberedCredentials(
        identifier: 'a@b.com',
        password: strong,
      );
      final controller = create();

      await controller.prefillIdentifier('a@b.com');

      expect(controller.identifierController.text, 'a@b.com');
      expect(controller.passwordController.text, strong);
    });

    testWidgets('other account: email filled, password cleared', (
      tester,
    ) async {
      store.rememberedCredentials = const RememberedCredentials(
        identifier: 'x@b.com',
        password: 'other',
      );
      final controller = create();
      await tester.pump();

      await controller.prefillIdentifier('a@b.com');

      expect(controller.identifierController.text, 'a@b.com');
      expect(controller.passwordController.text, isEmpty);
    });
  });
}
