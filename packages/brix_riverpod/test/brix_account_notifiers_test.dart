import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ProfileNotifier extends BrixProfileNotifier<String, String> {
  _ProfileNotifier(this._flow);

  final ProfileFlow<String, String> Function() _flow;

  @override
  ProfileFlow<String, String> createFlow() => _flow();
}

class _DeleteNotifier extends BrixDeleteAccountNotifier {
  _DeleteNotifier(this._flow);

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
    container = ProviderContainer.test();
  });

  group('BrixProfileNotifier', () {
    late NotifierProvider<_ProfileNotifier, ProfileState<String>>
    profileProvider;

    setUp(() {
      profileProvider =
          NotifierProvider<_ProfileNotifier, ProfileState<String>>(
            () => _ProfileNotifier(
              () => ProfileFlow(
                account: account,
                feedback: feedback,
                store: store,
              ),
            ),
          );
    });

    _ProfileNotifier create() {
      container.listen(profileProvider, (_, _) {});
      return container.read(profileProvider.notifier);
    }

    ProfileState<String> read() => container.read(profileProvider);

    test('starts as loading, then has the user', () async {
      create();
      expect(read().isLoading, isTrue);

      await pumpEventQueue();

      expect(read().isLoading, isFalse);
      expect(read().user, 'Rubaz');
    });

    test('save sends the app update', () async {
      final notifier = create();
      await pumpEventQueue();
      account.currentUserResult = const Success('Rubaz Khan');

      await notifier.save('Rubaz Khan');

      expect(account.updateProfileCalls, ['Rubaz Khan']);
      expect(read().user, 'Rubaz Khan');
    });

    test('an avatar upload reloads the user', () async {
      final notifier = create();
      await pumpEventQueue();
      account.currentUserResult = const Success('Rubaz with avatar');

      final ok = await notifier.uploadAvatar(
        const AvatarUpload(fileName: 'a.jpg', path: '/tmp/a.jpg'),
      );

      expect(ok, isTrue);
      expect(read().user, 'Rubaz with avatar');
    });

    test('a failed first load offers a retry', () async {
      account.currentUserResult = Failed(ServerFailure());
      final notifier = create();
      await pumpEventQueue();
      expect(read().loadFailed, isTrue);

      account.currentUserResult = const Success('Rubaz');
      await notifier.load();

      expect(read().loadFailed, isFalse);
      expect(read().user, 'Rubaz');
    });
  });

  group('BrixDeleteAccountNotifier', () {
    late NotifierProvider<_DeleteNotifier, CodeEntryState> deleteProvider;

    setUp(() {
      deleteProvider = NotifierProvider<_DeleteNotifier, CodeEntryState>(
        () => _DeleteNotifier(
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

    _DeleteNotifier create() {
      container.listen(deleteProvider, (_, _) {});
      return container.read(deleteProvider.notifier);
    }

    CodeEntryState read() => container.read(deleteProvider);

    test('no code until it is requested', () async {
      final notifier = create();
      expect(read().isCodeSent, isFalse);
      account.gate = Completer<void>();

      final request = notifier.requestDeletion();
      expect(read().isRequesting, isTrue);
      account.gate!.complete();
      await request;

      expect(read().isCodeSent, isTrue);
      expect(read().isRequesting, isFalse);
      expect(account.requestDeletionCalls, ['a@b.com']);
    });

    test('confirm deletes with the code and opens login', () async {
      final notifier = create();
      await notifier.requestDeletion();

      await notifier.confirm('123456');

      expect(account.deleteAccountCalls, ['a@b.com|123456|null']);
      expect(navigator.visits, ['login']);
    });
  });
}
