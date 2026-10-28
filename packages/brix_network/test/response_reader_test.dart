import 'package:brix_network/brix_network.dart';
import 'package:test/test.dart';

NetworkResponse _res(int status, Object? body) =>
    NetworkResponse(statusCode: status, body: body);

void main() {
  group('envelope (Node / Express, NestJS, Laravel, custom)', () {
    const reader = ResponseReader.envelope();

    test('success: data, message and success flag', () {
      final reply = reader.read(
        _res(200, {
          'success': true,
          'message': 'Welcome back!',
          'data': {'id': 'u1'},
        }),
      );

      expect(reply.data, {'id': 'u1'});
      expect(reply.message, 'Welcome back!');
      expect(reply.success, isTrue);
      expect(reply.messages, isEmpty);
    });

    test('errors as text, list or field map', () {
      expect(reader.read(_res(400, {'error': 'Bad input'})).messages, [
        'Bad input',
      ]);
      expect(
        reader
            .read(
              _res(400, {
                'errors': ['One', 'Two', 'One'],
              }),
            )
            .messages,
        ['One', 'Two'],
      );
      final reply = reader.read(
        _res(422, {
          'message': 'Validation failed',
          'errors': {
            'email': ['Already registered'],
            'address': {'city': 'Required'},
          },
        }),
      );
      expect(reply.fieldErrors, {
        'email': ['Already registered'],
        'address.city': ['Required'],
      });
      expect(reply.messages, ['Already registered', 'Required']);
    });

    test('no detailed errors: the main message explains the failure', () {
      expect(reader.read(_res(401, {'message': 'Token expired'})).messages, [
        'Token expired',
      ]);
    });

    test('a 200 with success false is a failure with its message', () {
      final reply = reader.read(
        _res(200, {'success': false, 'message': 'Not allowed'}),
      );

      expect(reply.success, isFalse);
      expect(reply.messages, ['Not allowed']);
    });

    test('custom keys and paths (errors nested under data)', () {
      const custom = ResponseReader.envelope(
        dataKey: 'result',
        messageKey: 'msg',
        errorKeys: ['data.errors', 'data.fieldErrors'],
      );
      final reply = custom.read(
        _res(400, {
          'msg': 'Failed',
          'data': {
            'fieldErrors': {
              'phone': ['Too short'],
            },
          },
        }),
      );

      expect(reply.fieldErrors, {
        'phone': ['Too short'],
      });
      expect(custom.read(_res(200, {'result': 5})).data, 5);
    });

    test('an HTML error page or a plain text body', () {
      expect(
        reader.read(_res(502, '<html>Bad Gateway</html>')).messages,
        isEmpty,
      );
      expect(reader.read(_res(503, 'Maintenance')).messages, ['Maintenance']);
      expect(reader.read(_res(200, [1, 2])).data, [1, 2]);
    });
  });

  group('FastAPI', () {
    const reader = ResponseReader.fastApi();

    test('success: the body is the data', () {
      expect(reader.read(_res(200, {'id': 1})).data, {'id': 1});
    });

    test('detail as text', () {
      expect(reader.read(_res(404, {'detail': 'Not found'})).messages, [
        'Not found',
      ]);
    });

    test('validation list: loc gives the field', () {
      final reply = reader.read(
        _res(422, {
          'detail': [
            {
              'loc': ['body', 'email'],
              'msg': 'value is not a valid email address',
              'type': 'value_error',
            },
            {
              'loc': ['body'],
              'msg': 'Field required',
            },
          ],
        }),
      );

      expect(reply.fieldErrors, {
        'email': ['value is not a valid email address'],
      });
      expect(reply.messages, [
        'value is not a valid email address',
        'Field required',
      ]);
    });
  });

  group('Django REST', () {
    const reader = ResponseReader.djangoRest();

    test('field errors, non-field errors and detail', () {
      final reply = reader.read(
        _res(400, {
          'username': ['A user with that username already exists.'],
          'non_field_errors': ['Passwords do not match.'],
        }),
      );

      expect(reply.fieldErrors, {
        'username': ['A user with that username already exists.'],
      });
      expect(reply.messages, [
        'A user with that username already exists.',
        'Passwords do not match.',
      ]);
      expect(reader.read(_res(401, {'detail': 'Invalid token.'})).messages, [
        'Invalid token.',
      ]);
    });
  });

  test('custom reader', () {
    final reader = ResponseReader.custom(
      (response) => ApiReply(data: (response.body as Map)['payload']),
    );

    expect(reader.read(_res(200, {'payload': 7})).data, 7);
  });

  group('StandardStatus.map', () {
    const reply = ApiReply(
      messages: ['Bad'],
      fieldErrors: {
        'email': ['Taken'],
      },
    );

    test('every status becomes the right failure', () {
      expect(StandardStatus.map(422, reply), isA<ValidationFailure>());
      expect(StandardStatus.map(400, reply).fieldError('email'), 'Taken');
      expect(StandardStatus.map(401, reply), isA<UnauthorizedFailure>());
      expect(StandardStatus.map(408, reply), isA<NetworkFailure>());
      expect(
        StandardStatus.map(403, reply),
        isA<ServerFailure>().having((f) => f.statusCode, 'status', 403),
      );
      expect(StandardStatus.map(500, reply).messages, ['Bad']);
    });
  });
}
