import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:brix_network/brix_network.dart';
import 'package:dio/dio.dart';
import 'package:test/test.dart';

/// A Dio adapter that answers without a network and records what was sent.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.answer);

  FutureOr<ResponseBody> Function(RequestOptions options) answer;
  final requests = <RequestOptions>[];
  final bodies = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (requestStream != null) {
      final bytes = await requestStream.expand((chunk) => chunk).toList();
      bodies.add(utf8.decode(bytes, allowMalformed: true));
    }
    if (cancelFuture != null) {
      return Future.any([
        Future(() => answer(options)),
        cancelFuture.then<ResponseBody>(
          (_) => throw DioException.requestCancelled(
            requestOptions: options,
            reason: 'cancelled',
          ),
        ),
      ]);
    }
    return answer(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody json(int status, Object body) => ResponseBody.fromString(
  jsonEncode(body),
  status,
  headers: {
    Headers.contentTypeHeader: ['application/json'],
  },
);

DioException lostConnection(RequestOptions options) => DioException(
  requestOptions: options,
  type: DioExceptionType.connectionError,
);

void main() {
  late FakeAdapter adapter;
  late DioNetworkClient client;

  setUp(() {
    adapter = FakeAdapter((_) => json(200, {'ok': true}));
    client = DioNetworkClient(
      dio: Dio()..httpClientAdapter = adapter,
      retryDelay: Duration.zero,
    );
  });

  NetworkRequest request(
    HttpMethod method, {
    Object? body,
    List<UploadFile> files = const [],
    RequestCancel? cancel,
  }) => NetworkRequest(
    method: method,
    url: Uri.parse('https://api.test/v1/items'),
    headers: const {'Authorization': 'Bearer t'},
    body: body,
    files: files,
    fields: files.isEmpty ? const {} : const {'note': 'hi'},
    cancel: cancel,
  );

  test('JSON answers are decoded; method, headers and body are sent', () async {
    final response = await client.send(
      request(HttpMethod.post, body: {'name': 'Ada'}),
    );

    expect(response.statusCode, 200);
    expect(response.body, {'ok': true});
    expect(adapter.requests.single.method, 'POST');
    expect(adapter.requests.single.headers['Authorization'], 'Bearer t');
    expect(jsonDecode(adapter.bodies.single), {'name': 'Ada'});
  });

  test('error statuses come back as answers, not exceptions', () async {
    adapter.answer = (_) => json(422, {'message': 'Invalid'});

    final response = await client.send(request(HttpMethod.get));

    expect(response.statusCode, 422);
    expect(response.body, {'message': 'Invalid'});
  });

  test('text and empty bodies', () async {
    adapter.answer = (_) => ResponseBody.fromString('Bad Gateway', 502);
    expect((await client.send(request(HttpMethod.get))).body, 'Bad Gateway');

    adapter.answer = (_) => ResponseBody.fromString('', 204);
    expect((await client.send(request(HttpMethod.delete))).body, isNull);
  });

  test('a lost connection is retried for GET, then NetworkFailure', () async {
    adapter.answer = (options) => throw lostConnection(options);

    await expectLater(
      client.send(request(HttpMethod.get)),
      throwsA(isA<NetworkFailure>()),
    );
    expect(adapter.requests, hasLength(3)); // 1 + 2 retries
  });

  test('GET succeeds when a retry gets through', () async {
    var calls = 0;
    adapter.answer = (options) =>
        ++calls == 1 ? throw lostConnection(options) : json(200, {'ok': 1});

    final response = await client.send(request(HttpMethod.get));

    expect(response.body, {'ok': 1});
    expect(calls, 2);
  });

  test('POST and uploads are never retried (nothing created twice)', () async {
    adapter.answer = (options) => throw lostConnection(options);

    await expectLater(
      client.send(request(HttpMethod.post)),
      throwsA(isA<NetworkFailure>()),
    );
    expect(adapter.requests, hasLength(1));
  });

  test('a cancelled request ends with CancelledFailure', () async {
    final done = Completer<ResponseBody>();
    adapter.answer = (_) => done.future;
    final cancel = RequestCancel();

    final sending = client.send(request(HttpMethod.get, cancel: cancel));
    await Future<void>.delayed(Duration.zero);
    cancel.cancel();

    await expectLater(sending, throwsA(isA<CancelledFailure>()));
  });

  test('wantsBytes: a file comes back with its bytes, type and name', () async {
    final pdf = [0x25, 0x50, 0x44, 0x46, 0xFF, 0x00, 0xE2]; // not valid UTF-8
    adapter.answer = (_) => ResponseBody.fromBytes(
      pdf,
      200,
      headers: {
        'content-type': ['application/pdf'],
        'content-disposition': ['attachment; filename="report.pdf"'],
      },
    );

    final response = await client.send(
      NetworkRequest(
        method: HttpMethod.get,
        url: Uri.parse('https://api.test/v1/report.pdf'),
        wantsBytes: true,
      ),
    );

    final file = response.body! as DownloadedFile;
    expect(file.bytes, pdf);
    expect(file.contentType, 'application/pdf');
    expect(file.fileName, 'report.pdf');
    expect(file.isPdf, isTrue);
  });

  test('wantsBytes: an error answer is still read as JSON', () async {
    adapter.answer = (_) => json(404, {'message': 'Document not found'});

    final response = await client.send(
      NetworkRequest(
        method: HttpMethod.get,
        url: Uri.parse('https://api.test/v1/report.pdf'),
        wantsBytes: true,
      ),
    );

    expect(response.body, {'message': 'Document not found'});
  });

  test('upload: several files with one field name, plus fields', () async {
    await client.send(
      request(
        HttpMethod.post,
        files: [
          UploadFile.bytes('files', utf8.encode('one'), fileName: 'a.txt'),
          UploadFile.bytes(
            'files',
            utf8.encode('two'),
            fileName: 'b.png',
            contentType: 'image/png',
          ),
        ],
      ),
    );

    final sent = adapter.bodies.single;
    expect('name="files"'.allMatches(sent), hasLength(2));
    expect(sent, contains('filename="a.txt"'));
    expect(sent, contains('filename="b.png"'));
    expect(sent, contains('image/png'));
    expect(sent, contains('name="note"'));
  });
}
