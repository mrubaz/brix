import 'dart:async';

import 'package:brix/testing.dart';
import 'package:brix_bloc/brix_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeAccountProvider<String, String> account;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late InMemoryAuthSessionStore<String> store;

  setUp(() {
    account = FakeAccountProvider()..currentUserResult = const Success('Rubaz');
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    store = InMemoryAuthSessionStore();
  });

  group('BrixProfileCubit', () {
    BrixProfileCubit<String, String> create() => BrixProfileCubit(
      ProfileFlow(account: account, feedback: feedback, store: store),
    );

    test('starts as loading, then has the user', () async {
      final cubit = create();
      expect(cubit.state.isLoading, isTrue);

      await pumpEventQueue();

      expect(cubit.state.isLoading, isFalse);
      expect(cubit.state.user, 'Rubaz');
      await cubit.close();
    });

    test('save sends the app update', () async {
      final cubit = create();
      await pumpEventQueue();
      account.currentUserResult = const Success('Rubaz Khan');

      await cubit.save('Rubaz Khan');

      expect(account.updateProfileCalls, ['Rubaz Khan']);
      expect(cubit.state.user, 'Rubaz Khan');
      await cubit.close();
    });

    test('an avatar upload reloads the user', () async {
      final cubit = create();
      await pumpEventQueue();
      account.currentUserResult = const Success('Rubaz with avatar');

      final ok = await cubit.uploadAvatar(
        const AvatarUpload(fileName: 'a.jpg', path: '/tmp/a.jpg'),
      );

      expect(ok, isTrue);
      expect(cubit.state.user, 'Rubaz with avatar');
      await cubit.close();
    });

    test('a failed first load offers a retry', () async {
      account.currentUserResult = Failed(ServerFailure());
      final cubit = create();
      await pumpEventQueue();
      expect(cubit.state.loadFailed, isTrue);

      account.currentUserResult = const Success('Rubaz');
      await cubit.load();

      expect(cubit.state.loadFailed, isFalse);
      expect(cubit.state.user, 'Rubaz');
      await cubit.close();
    });
  });

  group('BrixDeleteAccountCubit', () {
    BrixDeleteAccountCubit create() => BrixDeleteAccountCubit(
      DeleteAccountFlow(
        account: account,
        store: store,
        navigator: navigator,
        feedback: feedback,
        identifier: 'a@b.com',
        resendCooldown: Duration.zero,
      ),
    );

    test('no code until it is requested', () async {
      final cubit = create();
      expect(cubit.state.isCodeSent, isFalse);
      account.gate = Completer<void>();

      final request = cubit.requestDeletion();
      expect(cubit.state.isRequesting, isTrue);
      account.gate!.complete();
      await request;

      expect(cubit.state.isCodeSent, isTrue);
      expect(cubit.state.isRequesting, isFalse);
      expect(account.requestDeletionCalls, ['a@b.com']);
      await cubit.close();
    });

    test('confirm deletes with the code and opens login', () async {
      final cubit = create();
      await cubit.requestDeletion();

      await cubit.confirm('123456');

      expect(account.deleteAccountCalls, ['a@b.com|123456|null']);
      expect(navigator.visits, ['login']);
      await cubit.close();
    });
  });
}
