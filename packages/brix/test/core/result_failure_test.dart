import 'dart:async';

import 'package:brix/core.dart';
import 'package:test/test.dart';

void main() {
  group('Result', () {
    test('Success keeps data and message', () {
      const Result<int> result = Success(7, message: 'Done');

      expect(result.isSuccess, isTrue);
      expect(result.isFailed, isFalse);
      expect(result.dataOrNull, 7);
      expect(result.failureOrNull, isNull);
      expect((result as Success<int>).message, 'Done');
    });

    test('Failed keeps the failure, no data', () {
      final failure = NetworkFailure();
      final Result<int> result = Failed(failure);

      expect(result.isFailed, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, same(failure));
    });

    test('switch can match on the failure type', () {
      String describe(Result<int> result) => switch (result) {
        Success(:final data) => 'data $data',
        Failed(failure: ValidationFailure(:final message)) =>
          'invalid $message',
        Failed(failure: NetworkFailure()) => 'offline',
        Failed() => 'other',
      };

      expect(describe(const Success(1)), 'data 1');
      expect(
        describe(Failed(ValidationFailure(messages: ['Email taken']))),
        'invalid Email taken',
      );
      expect(describe(Failed(NetworkFailure())), 'offline');
      expect(describe(Failed(ServerFailure(statusCode: 500))), 'other');
    });
  });

  group('Failure', () {
    test('messages are a read-only copy', () {
      final source = ['First'];
      final failure = ValidationFailure(messages: source);

      source.add('Second');

      expect(failure.messages, ['First']);
      expect(() => failure.messages.add('Third'), throwsUnsupportedError);
    });

    test('message joins messages, null when there are none', () {
      expect(ServerFailure(messages: ['A', 'B']).message, 'A\nB');
      expect(NetworkFailure().message, isNull);
    });

    test('each type has a default text; the backend message wins', () {
      final failures = [
        ValidationFailure(),
        UnauthorizedFailure(),
        ServerFailure(statusCode: 500),
        NetworkFailure(),
        UnsupportedFailure(),
        UnknownFailure(),
      ];
      for (final failure in failures) {
        expect(failure.defaultMessage, isNotEmpty, reason: '$failure');
        expect(failure.displayMessage, failure.defaultMessage);
      }
      expect(
        failures.map((failure) => failure.defaultMessage).toSet(),
        hasLength(failures.length),
      );
      expect(
        NetworkFailure(messages: ['Offline mode']).displayMessage,
        'Offline mode',
      );
    });

    test('an app failure type brings its own default text', () {
      expect(_AccountLockedFailure().displayMessage, 'Account locked.');
      expect(
        _AccountLockedFailure(messages: ['Locked for 5 minutes'])
            .displayMessage,
        'Locked for 5 minutes',
      );
    });

    test('apps can add their own failure types', () {
      final Failure failure = _AccountLockedFailure();

      expect(failure, isA<Failure>());
      expect(failure.messages, isEmpty);
    });

    test('UnknownFailure.toString shows the cause, not a stack trace', () {
      final failure = UnknownFailure(
        cause: StateError('boom'),
        stackTrace: StackTrace.current,
      );

      expect(failure.toString(), contains('boom'));
      expect(failure.toString(), isNot(contains('#0')));
    });
  });

  group('failureFromError', () {
    test('a timeout is a network failure', () {
      expect(
        failureFromError(TimeoutException('slow'), StackTrace.current),
        isA<NetworkFailure>(),
      );
    });

    test('a thrown Failure is kept as it is', () {
      final failure = UnauthorizedFailure();

      expect(failureFromError(failure, StackTrace.current), same(failure));
    });

    test('anything else is unknown and keeps the cause', () {
      final error = StateError('boom');
      final failure = failureFromError(error, StackTrace.current);

      expect(failure, isA<UnknownFailure>());
      expect((failure as UnknownFailure).cause, same(error));
      expect(failure.stackTrace, isNotNull);
    });
  });
}

class _AccountLockedFailure extends Failure {
  _AccountLockedFailure({super.messages});

  @override
  String get defaultMessage => 'Account locked.';
}
