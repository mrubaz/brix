import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// An app's profile notifier: one field, change check, typed body.
class _AppProfileNotifier extends BrixProfileNotifier<String, String> {
  _AppProfileNotifier(this._flow);

  final ProfileFlow<String, String> Function() _flow;

  late TextEditingController nameController;
  final filled = <String>[];

  @override
  ProfileFlow<String, String> createFlow() => _flow();

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
  void onUserLoaded(String user, {required bool fillForm}) {
    if (fillForm) {
      nameController.text = user;
      filled.add(user);
    }
  }

  @override
  bool canSave() => nameController.text != state.user;

  @override
  String buildUpdate() => nameController.text.trim();
}

class _DeleteAccountNotifier extends BrixDeleteAccountNotifier {
  _DeleteAccountNotifier(this._flow);

  final DeleteAccountFlow Function() _flow;

  @override
  DeleteAccountFlow createFlow() => _flow();
}

void main() {
  late FakeAccountProvider<String, String> account;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late InMemoryAuthSessionStore<String> store;
  late ProviderContainer container;

  setUp(() {
    account = FakeAccountProvider()..currentUserResult = const Success('Rubaz');
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    store = InMemoryAuthSessionStore();
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  group('BrixProfileNotifier', () {
    late NotifierProvider<_AppProfileNotifier, ProfileState<String>>
    profileProvider;
    late _AppProfileNotifier notifier;

    setUp(() {
      profileProvider =
          NotifierProvider<_AppProfileNotifier, ProfileState<String>>(
            () => _AppProfileNotifier(
              () => ProfileFlow(
                account: account,
                feedback: feedback,
                store: store,
              ),
            ),
          );
    });

    ProfileState<String> read() => container.read(profileProvider);

    Future<void> pumpForm(WidgetTester tester) async {
      container.read(profileProvider);
      notifier = container.read(profileProvider.notifier);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: notifier.formKey,
              child: TextFormField(controller: notifier.nameController),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    testWidgets('starts as loading', (tester) async {
      expect(read().isLoading, isTrue);
    });

    testWidgets('loads on start and fills the form', (tester) async {
      await pumpForm(tester);

      expect(read().user, 'Rubaz');
      expect(notifier.nameController.text, 'Rubaz');
      expect(read().isLoading, isFalse);
    });

    testWidgets('save sends the app body only when something changed', (
      tester,
    ) async {
      await pumpForm(tester);

      await notifier.save();
      expect(account.updateProfileCalls, isEmpty);

      notifier.nameController.text = ' Rubaz Khan ';
      account.currentUserResult = const Success('Rubaz Khan');
      await notifier.save();

      expect(account.updateProfileCalls, ['Rubaz Khan']);
      expect(read().user, 'Rubaz Khan');
    });

    testWidgets('an avatar upload keeps unsaved typing', (tester) async {
      await pumpForm(tester);
      notifier.nameController.text = 'typing…';
      account.currentUserResult = const Success('Rubaz with avatar');

      final ok = await notifier.uploadAvatar(
        const AvatarUpload(fileName: 'a.jpg', path: '/tmp/a.jpg'),
      );

      expect(ok, isTrue);
      expect(read().user, 'Rubaz with avatar');
      expect(notifier.nameController.text, 'typing…');
    });

    testWidgets('a failed first load offers a retry', (tester) async {
      account.currentUserResult = Failed(ServerFailure());
      await pumpForm(tester);

      expect(read().loadFailed, isTrue);

      account.currentUserResult = const Success('Rubaz');
      await notifier.load();
      expect(read().loadFailed, isFalse);
      expect(read().user, 'Rubaz');
    });

    testWidgets('disposing the provider disposes the flow and fields', (
      tester,
    ) async {
      await pumpForm(tester);
      final flow = notifier.flow;
      final name = notifier.nameController;
      await tester.pumpWidget(const SizedBox());

      container.dispose();

      expect(flow.isDisposed, isTrue);
      expect(() => name.addListener(() {}), throwsFlutterError);
    });
  });

  group('BrixDeleteAccountNotifier', () {
    late NotifierProvider<_DeleteAccountNotifier, CodeEntryState>
    deleteProvider;

    setUp(() {
      deleteProvider = NotifierProvider<_DeleteAccountNotifier, CodeEntryState>(
        () => _DeleteAccountNotifier(
          () => DeleteAccountFlow(
            account: account,
            store: store,
            navigator: navigator,
            feedback: feedback,
            identifier: 'a@b.com',
            resendCooldown: Duration.zero,
          ),
        ),
      );
    });

    _DeleteAccountNotifier create() {
      container.read(deleteProvider);
      return container.read(deleteProvider.notifier);
    }

    CodeEntryState read() => container.read(deleteProvider);

    testWidgets('boxes hidden until the code is requested', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final notifier = create();

      expect(read().isCodeSent, isFalse);
      final request = notifier.requestDeletion();
      expect(read().isRequesting, isTrue);
      await request;
      await tester.pump();

      expect(read().isCodeSent, isTrue);
      expect(read().isRequesting, isFalse);
      expect(account.requestDeletionCalls, ['a@b.com']);
    });

    testWidgets('the first box gets focus once the code is sent', (
      tester,
    ) async {
      final notifier = create();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(focusNode: notifier.boxes.focusNodes.first),
          ),
        ),
      );

      await notifier.requestDeletion();
      await tester.pump();

      expect(notifier.boxes.focusNodes.first.hasFocus, isTrue);
    });

    testWidgets('a full code does not delete on its own; confirm does', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      final notifier = create();
      await notifier.requestDeletion();

      notifier.boxes.onDigitChanged(0, '123456');
      await tester.pump();
      expect(account.deleteAccountCalls, isEmpty);

      await notifier.confirm();
      expect(account.deleteAccountCalls, ['a@b.com|123456|null']);
      expect(navigator.visits, ['login']);
    });
  });
}
