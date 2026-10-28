import 'dart:async';
import 'dart:typed_data';

import 'package:brix_network/brix_network.dart';
import 'package:test/test.dart';

/// Answers from a queue (or a function) and records every request.
class FakeClient extends NetworkClient {
  FakeClient([this.answer]);

  FutureOr<NetworkResponse> Function(NetworkRequest request)? answer;
  final sent = <NetworkRequest>[];
  Completer<void>? gate;

  @override
  Future<NetworkResponse> send(NetworkRequest request) async {
    sent.add(request);
    if (gate case final gate?) await gate.future;
    return answer!(request);
  }
}

class RecordingLogger extends NetworkLogger {
  final entries = <NetworkLogEntry>[];

  @override
  void log(NetworkLogEntry entry) => entries.add(entry);
}

class User {
  User(this.id, this.name);

  factory User.fromJson(Json json) =>
      User(json.string('id'), json.string('name'));

  final String id;
  final String name;
}

NetworkResponse ok(Object? body) =>
    NetworkResponse(statusCode: 200, body: body);

void main() {
  late FakeClient client;
  late RecordingLogger logger;
  late int logouts;
  String? token;

  BrixApi api({bool Function(String path)? logoutOn401}) => BrixApi(
    baseUrl: 'https://api.test/v1',
    client: client,
    token: () => token,
    logger: logger,
    onUnauthorized: () async => logouts++,
    logoutOn401: logoutOn401 ?? (_) => true,
  );

  setUp(() {
    client = FakeClient();
    logger = RecordingLogger();
    logouts = 0;
    token = 'secret';
  });

  group('success', () {
    test('data parsed into the model, backend message kept', () async {
      client.answer = (_) => ok({
        'success': true,
        'message': 'Loaded',
        'data': {'id': 'u1', 'name': 'Ada'},
      });

      final result = await api().get('auth/profile', parse: User.fromJson);

      final user = (result as Success<User>).data;
      expect(user.name, 'Ada');
      expect(result.message, 'Loaded');
    });

    test('a list with items, and a call without data', () async {
      client.answer = (_) => ok({
        'data': [
          {'id': '1', 'name': 'A'},
          {'id': '2', 'name': 'B'},
        ],
      });
      final list = await api().get(
        'users',
        parse: (data) => data.items(User.fromJson),
      );
      expect((list as Success<List<User>>).data.map((u) => u.id), ['1', '2']);

      client.answer = (_) => ok({'message': 'Saved'});
      final saved = await api().patch<void>('auth/profile', body: {'a': 1});
      expect(saved, isA<Success<void>>());
      expect(client.sent.last.body, {'a': 1});
    });
  });

  group('request', () {
    test(
      'url from base + path + query (nulls left out, lists repeated)',
      () async {
        client.answer = (_) => ok({});

        await api().get(
          '/inspections',
          query: {
            'page': 2,
            'status': null,
            'ids': [1, 2],
          },
        );

        final url = client.sent.single.url;
        expect(
          url.toString().split('?').first,
          'https://api.test/v1/inspections',
        );
        expect(url.queryParametersAll, {
          'page': ['2'],
          'ids': ['1', '2'],
        });
      },
    );

    test(
      'token as Bearer header; none when empty or withToken false',
      () async {
        client.answer = (_) => ok({});

        await api().get('a');
        expect(client.sent.last.headers['Authorization'], 'Bearer secret');

        token = null;
        await api().get('b');
        expect(client.sent.last.headers.containsKey('Authorization'), isFalse);

        token = 'secret';
        await api().get(
          'https://maps.example.com/geocode?key=k',
          withToken: false,
        );
        expect(client.sent.last.url.host, 'maps.example.com');
        expect(client.sent.last.headers.containsKey('Authorization'), isFalse);
      },
    );

    test('upload sends files and fields with the chosen method', () async {
      client.answer = (_) => ok({});

      await api().upload<void>(
        'auth/profile/avatar',
        method: HttpMethod.patch,
        files: [UploadFile.path('avatar', '/tmp/me.png')],
        fields: {'note': 'hi'},
      );

      final request = client.sent.single;
      expect(request.method, HttpMethod.patch);
      expect(request.files.single.field, 'avatar');
      expect(request.fields, {'note': 'hi'});
    });

    test('identical GETs at the same time share one request', () async {
      client
        ..gate = Completer<void>()
        ..answer = (_) => ok({'data': 1});

      final first = api().get('stats', parse: (d) => d.raw);
      final shared = BrixApi(baseUrl: 'https://api.test/v1', client: client);
      final a = shared.get('stats', parse: (d) => d.raw);
      final b = shared.get('stats', parse: (d) => d.raw);
      client.gate!.complete();
      await Future.wait([first, a, b]);

      // `first` came from another BrixApi; the two shared calls joined.
      expect(client.sent, hasLength(2));
    });

    test('POSTs are never joined', () async {
      client.answer = (_) => ok({});
      final shared = api();

      await Future.wait([shared.post('a'), shared.post('a')]);

      expect(client.sent, hasLength(2));
    });
  });

  group('download', () {
    test('a file arrives with its bytes and details', () async {
      client.answer = (request) {
        expect(request.wantsBytes, isTrue);
        return NetworkResponse(
          statusCode: 200,
          body: DownloadedFile(
            bytes: Uint8List.fromList([1, 2, 3]),
            contentType: 'application/pdf',
          ),
        );
      };

      final result = await api().download('report.pdf');

      final file = (result as Success<DownloadedFile>).data;
      expect(file.bytes, [1, 2, 3]);
      expect(file.isPdf, isTrue);
    });

    test('an error answer becomes a failure with its message', () async {
      client.answer = (_) => const NetworkResponse(
        statusCode: 404,
        body: {'message': 'Document not found'},
      );

      final result = await api().download('report.pdf');

      final failure = (result as Failed).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.messages, ['Document not found']);
    });

    test('progress is handed to the client', () async {
      client.answer = (request) {
        request.onReceiveProgress!(50, 100);
        return NetworkResponse(
          statusCode: 200,
          body: DownloadedFile(bytes: Uint8List(1)),
        );
      };
      final seen = <int>[];

      await api().download(
        'big.zip',
        onProgress: (received, _) => seen.add(received),
      );

      expect(seen, [50]);
    });
  });

  group('failures', () {
    test('422 → ValidationFailure with field errors', () async {
      client.answer = (_) => NetworkResponse(
        statusCode: 422,
        body: {
          'message': 'Invalid',
          'errors': {
            'email': ['Already registered'],
          },
        },
      );

      final result = await api().post('auth/register');

      final failure = (result as Failed).failure;
      expect(failure, isA<ValidationFailure>());
      expect(failure.fieldError('email'), 'Already registered');
    });

    test('a 200 with success false is a failure', () async {
      client.answer = (_) => ok({'success': false, 'message': 'Not allowed'});

      final result = await api().get('x');

      expect((result as Failed).failure.messages, ['Not allowed']);
    });

    test('no connection / timeout from the client → NetworkFailure', () async {
      client.answer = (_) => throw NetworkFailure();

      final result = await api().get('x');

      expect((result as Failed).failure, isA<NetworkFailure>());
    });

    test('anything else thrown → UnknownFailure, never an exception', () async {
      client.answer = (_) => throw StateError('boom');

      final result = await api().get('x');

      expect((result as Failed).failure, isA<UnknownFailure>());
    });

    test('a model that cannot be built → UnknownFailure', () async {
      client.answer = (_) => ok({'data': {}});

      final result = await api().get<User>(
        'x',
        parse: (_) => throw const FormatException('bad'),
      );

      expect((result as Failed).failure, isA<UnknownFailure>());
    });
  });

  group('401', () {
    test('several 401s at once log out only once', () async {
      client.answer = (_) => const NetworkResponse(statusCode: 401);
      final shared = api();

      final results = await Future.wait([
        shared.get('a'),
        shared.get('b'),
        shared.post('c'),
      ]);

      expect(logouts, 1);
      expect(
        results.map((r) => (r as Failed).failure),
        everyElement(isA<UnauthorizedFailure>()),
      );
    });

    test('excluded paths (wrong password on login) do not log out', () async {
      client.answer = (_) => const NetworkResponse(
        statusCode: 401,
        body: {'message': 'Wrong password'},
      );

      final result = await api(logoutOn401: (path) => path != 'auth/login')
          .post('auth/login');

      expect(logouts, 0);
      expect((result as Failed).failure.messages, ['Wrong password']);
    });

    test('a later 401 logs out again', () async {
      client.answer = (_) => const NetworkResponse(statusCode: 401);
      final shared = api();

      await shared.get('a');
      await shared.get('b');

      expect(logouts, 2);
    });
  });

  group('logging', () {
    test(
      'each call is logged with its result; cancelled calls are not',
      () async {
        client.answer = (_) => ok({});
        await api().get('a');
        client.answer = (_) => const NetworkResponse(statusCode: 500);
        await api().get('b');
        client.answer = (_) => throw CancelledFailure();
        await api().get('c');

        expect(logger.entries, hasLength(2));
        expect(logger.entries.first.failure, isNull);
        expect(logger.entries.last.failure, isA<ServerFailure>());
        expect(logger.entries.last.response?.statusCode, 500);
      },
    );
  });
}
