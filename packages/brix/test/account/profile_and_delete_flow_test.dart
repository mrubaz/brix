import 'dart:async';

import 'package:brix/account.dart';
import 'package:brix/testing.dart';
import 'package:fake_async/fake_async.dart';
import 'package:test/test.dart';

/// An app's typed profile body.
class _Update {
  const _Update(this.name);
  final String name;
}

void main() {
  late FakeAccountProvider<String, _Update> account;
  late InMemoryAuthSessionStore<String> store;
  late RecordingAuthNavigator navigator;
  late RecordingAuthFeedback feedback;
  late List<String> events;

  setUp(() {
    account = FakeAccountProvider();
    store = InMemoryAuthSessionStore()
      ..session = const AuthSession(accessToken: 'token', user: 'old');
    navigator = RecordingAuthNavigator();
    feedback = RecordingAuthFeedback();
    events = [];
  });

  group('ProfileFlow', () {
    ProfileFlow<String, _Update> create() => ProfileFlow(
      account: account,
      feedback: feedback,
      store: store,
      onUserChanged: (user) => events.add('user:$user'),
    );

    test('load: user shown, saved session and app told', () async {
      account.currentUserResult = const Success('fresh');
      final flow = create();

      await flow.load();

      expect(flow.state.user, 'fresh');
      expect(flow.state.isLoading, isFalse);
      expect(store.session?.user, 'fresh');
      expect(store.session?.accessToken, 'token');
      expect(events, ['user:fresh']);
    });

    test('load failure: error shown, retry state', () async {
      account.currentUserResult = Failed(ServerFailure(messages: ['Down']));
      final flow = create();

      await flow.load();

      expect(feedback.failures.single.messages, ['Down']);
      expect(flow.state.loadFailed, isTrue);
      expect(flow.state.isLoading, isFalse);
    });

    test('save: update sent, user reloaded, message', () async {
      account
        ..currentUserResult = const Success('saved')
        ..updateProfileResult = const Success(null, message: 'Updated');
      final flow = create();
      const update = _Update('Rubaz');

      await flow.save(update);

      expect(account.updateProfileCalls, [same(update)]);
      expect(flow.state.user, 'saved');
      expect(feedback.successes, ['Updated']);
      expect(flow.state.isSaving, isFalse);
    });

    test('save failure: error shown, no reload', () async {
      account.updateProfileResult = Failed(ValidationFailure(messages: ['x']));
      final flow = create();

      await flow.save(const _Update('Rubaz'));

      expect(feedback.failures, hasLength(1));
      expect(account.currentUserCalls, 0);
    });

    test('a quiet reload failure keeps the screen (no retry state)', () async {
      account.currentUserResult = Failed(NetworkFailure());
      final flow = create();

      await flow.save(const _Update('Rubaz'));

      expect(flow.state.loadFailed, isFalse);
    });

    test('double tap saves once', () async {
      account.gate = Completer<void>();
      final flow = create();

      final first = flow.save(const _Update('a'));
      final second = flow.save(const _Update('b'));
      account.gate!.complete();
      await Future.wait([first, second]);

      expect(account.updateProfileCalls, hasLength(1));
    });

    test('avatar: uploaded, reloaded, true; failure false', () async {
      account.currentUserResult = const Success('with-avatar');
      final flow = create();
      const upload = AvatarUpload(fileName: 'a.jpg', path: '/tmp/a.jpg');

      expect(await flow.uploadAvatar(upload), isTrue);
      expect(account.uploadAvatarCalls, [same(upload)]);
      expect(flow.state.user, 'with-avatar');

      account.uploadAvatarResult = Failed(ServerFailure());
      expect(await flow.uploadAvatar(upload), isFalse);
      expect(flow.state.isUploadingAvatar, isFalse);
    });

    test('a thrown error is shown, never crashes', () async {
      account.error = TimeoutException('slow');
      final flow = create();

      await flow.load();
      await flow.save(const _Update('a'));

      expect(feedback.failures, everyElement(isA<NetworkFailure>()));
      expect(flow.state.loadFailed, isTrue);
    });
  });

  group('DeleteAccountFlow (code)', () {
    DeleteAccountFlow create({
      String? identifier = 'a@b.com',
      Duration cooldown = Duration.zero,
    }) => DeleteAccountFlow(
      account: account,
      store: store,
      navigator: navigator,
      feedback: feedback,
      identifier: identifier,
      resendCooldown: cooldown,
      onAccountDeleted: () => events.add('deleted'),
    );

    test('request: code sent, boxes may show', () async {
      account.requestDeletionResult = const Success(null, message: 'Code sent');
      final flow = create();
      expect(flow.state.isCodeSent, isFalse);

      await flow.requestDeletion();

      expect(account.requestDeletionCalls, ['a@b.com']);
      expect(flow.state.isCodeSent, isTrue);
      expect(feedback.successes, ['Code sent']);
    });

    test('a failed request keeps the boxes hidden', () async {
      account.requestDeletionResult = Failed(ServerFailure(messages: ['No']));
      final flow = create();

      await flow.requestDeletion();

      expect(flow.state.isCodeSent, isFalse);
      expect(feedback.failures, hasLength(1));
    });

    test('no logged-in user: warning, nothing sent', () async {
      await create(identifier: null).requestDeletion();

      expect(feedback.warnings, [AuthWarning.notLoggedIn]);
      expect(account.requestDeletionCalls, isEmpty);
    });

    test('right code: everything cleared (remember me too), login', () async {
      store
        ..rememberedCredentials = const RememberedCredentials(
          identifier: 'a@b.com',
          password: 'pw',
        )
        ..pendingIdentifier = 'a@b.com';
      account.deleteAccountResult = const Success(null, message: 'Deleted');
      final flow = create();
      await flow.requestDeletion();

      await flow.confirm(' 123456 ');

      expect(account.deleteAccountCalls, ['a@b.com|123456|null']);
      expect(store.session, isNull);
      expect(store.rememberedCredentials, isNull);
      expect(store.pendingIdentifier, isNull);
      expect(events, ['deleted']);
      expect(feedback.successes.last, 'Deleted');
      expect(navigator.visits, ['login']);
    });

    test('wrong code: error, failed attempt, nothing cleared', () async {
      account.deleteAccountResult = Failed(ValidationFailure(messages: ['x']));
      final flow = create();
      await flow.requestDeletion();

      await flow.confirm('123456');

      expect(flow.state.failedAttempts, 1);
      expect(store.session, isNotNull);
      expect(navigator.visits, isEmpty);
    });

    test('short code: warning, no call', () async {
      final flow = create();
      await flow.requestDeletion();

      await flow.confirm('12');

      expect(feedback.warnings, [AuthWarning.otpIncomplete]);
      expect(account.deleteAccountCalls, isEmpty);
    });

    test('a second request is a resend after the cooldown', () {
      fakeAsync((async) {
        final flow = create(cooldown: const Duration(seconds: 30));
        flow.requestDeletion();
        async.flushMicrotasks();
        expect(flow.state.resendIn, const Duration(seconds: 30));

        flow.resend();
        async.flushMicrotasks();
        expect(account.requestDeletionCalls, hasLength(1));

        async.elapse(const Duration(seconds: 30));
        flow.resend();
        async.flushMicrotasks();
        expect(account.requestDeletionCalls, hasLength(2));
        flow.dispose();
      });
    });
  });

  test('DeleteAccountFlow (confirm mode) deletes without a code', () async {
    account = FakeAccountProvider(deletionMode: AccountDeletionMode.confirm);
    final flow = DeleteAccountFlow(
      account: account,
      store: store,
      navigator: navigator,
      feedback: feedback,
      identifier: 'a@b.com',
    );

    await flow.requestDeletion();
    await flow.deleteWithoutCode();

    expect(account.requestDeletionCalls, isEmpty);
    expect(account.deleteAccountCalls, ['a@b.com|null|null']);
    expect(navigator.visits, ['login']);
    await flow.dispose();
  });
}
