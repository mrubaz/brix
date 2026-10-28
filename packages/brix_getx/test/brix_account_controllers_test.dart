import 'package:brix/testing.dart';
import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// An app's profile controller: one field, change check, typed body.
class _AppProfileController extends BrixProfileController<String, String> {
  _AppProfileController(super.flow);

  final nameController = TextEditingController();
  final filled = <String>[];

  @override
  void onUserLoaded(String user, {required bool fillForm}) {
    if (fillForm) {
      nameController.text = user;
      filled.add(user);
    }
  }

  @override
  bool canSave() => nameController.text != user.value;

  @override
  String buildUpdate() => nameController.text.trim();
}

void main() {
  late FakeAccountProvider<String, String> account;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late InMemoryAuthSessionStore<String> store;

  setUp(() {
    Get.testMode = true;
    account = FakeAccountProvider()..currentUserResult = const Success('Rubaz');
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    store = InMemoryAuthSessionStore();
  });

  tearDown(Get.reset);

  group('BrixProfileController', () {
    late _AppProfileController controller;

    Future<void> pumpForm(WidgetTester tester) async {
      controller = Get.put(
        _AppProfileController(
          ProfileFlow(account: account, feedback: feedback, store: store),
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: controller.formKey,
              child: TextFormField(controller: controller.nameController),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('loads on start and fills the form', (tester) async {
      await pumpForm(tester);

      expect(controller.user.value, 'Rubaz');
      expect(controller.nameController.text, 'Rubaz');
      expect(controller.isLoading.value, isFalse);
    });

    testWidgets('save sends the app body only when something changed', (
      tester,
    ) async {
      await pumpForm(tester);

      await controller.save();
      expect(account.updateProfileCalls, isEmpty);

      controller.nameController.text = ' Rubaz Khan ';
      account.currentUserResult = const Success('Rubaz Khan');
      await controller.save();

      expect(account.updateProfileCalls, ['Rubaz Khan']);
      expect(controller.user.value, 'Rubaz Khan');
    });

    testWidgets('an avatar upload keeps unsaved typing', (tester) async {
      await pumpForm(tester);
      controller.nameController.text = 'typing…';
      account.currentUserResult = const Success('Rubaz with avatar');

      final ok = await controller.uploadAvatar(
        const AvatarUpload(fileName: 'a.jpg', path: '/tmp/a.jpg'),
      );

      expect(ok, isTrue);
      expect(controller.user.value, 'Rubaz with avatar');
      expect(controller.nameController.text, 'typing…');
    });

    testWidgets('a failed first load offers a retry', (tester) async {
      account.currentUserResult = Failed(ServerFailure());
      await pumpForm(tester);

      expect(controller.loadFailed.value, isTrue);

      account.currentUserResult = const Success('Rubaz');
      await controller.load();
      expect(controller.loadFailed.value, isFalse);
      expect(controller.user.value, 'Rubaz');
    });
  });

  group('BrixDeleteAccountController', () {
    BrixDeleteAccountController create() => Get.put(
      BrixDeleteAccountController(
        DeleteAccountFlow(
          account: account,
          store: store,
          navigator: navigator,
          feedback: feedback,
          identifier: 'a@b.com',
          resendCooldown: Duration.zero,
        ),
      ),
    );

    testWidgets('boxes hidden until the code is requested', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final controller = create();

      expect(controller.isCodeSent.value, isFalse);
      await controller.requestDeletion();
      await tester.pump();

      expect(controller.isCodeSent.value, isTrue);
      expect(controller.isRequesting.value, isFalse);
      expect(account.requestDeletionCalls, ['a@b.com']);
    });

    testWidgets('a full code does not delete on its own; confirm does', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final controller = create();
      await controller.requestDeletion();

      controller.boxes.onDigitChanged(0, '123456');
      await tester.pump();
      expect(account.deleteAccountCalls, isEmpty);

      await controller.confirm();
      expect(account.deleteAccountCalls, ['a@b.com|123456|null']);
      expect(navigator.visits, ['login']);
    });
  });
}
