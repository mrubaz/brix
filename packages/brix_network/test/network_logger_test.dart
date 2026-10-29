import 'dart:typed_data';

import 'package:brix_network/brix_network.dart';
import 'package:test/test.dart';

void main() {
  late List<String> lines;

  PrettyNetworkLogger logger({bool enabled = true, int maxLines = 20}) =>
      PrettyNetworkLogger(
        enabled: enabled,
        colors: false,
        maxLines: maxLines,
        output: lines.add,
      );

  setUp(() => lines = []);

  NetworkLogEntry entry({
    Object? body,
    Object? responseBody,
    int status = 200,
    Failure? failure,
    String url = 'https://api.test/v1/auth/login',
  }) => NetworkLogEntry(
    request: NetworkRequest(
      method: HttpMethod.post,
      url: Uri.parse(url),
      body: body,
    ),
    took: const Duration(milliseconds: 312),
    response: NetworkResponse(statusCode: status, body: responseBody),
    failure: failure,
  );

  test('one box per call: method, path, status and time', () {
    logger().log(entry(responseBody: {'success': true}));

    expect(lines.first, startsWith('╭─ ▰ POST v1/auth/login'));
    expect(lines.first, endsWith('200 · 312 ms'));
    expect(lines.last, startsWith('╰'));
    expect(lines.first.length, lines.last.length);
  });

  test('passwords, tokens and codes never reach the log', () {
    logger().log(
      entry(
        body: {
          'email': 'ada@brix.dev',
          'password': 'Secret@123',
          'otp': '123456',
        },
        responseBody: {
          'data': {
            'accessToken': 'eyJhbGci',
            'user': {'refresh_token': 'r1', 'name': 'Ada'},
          },
        },
      ),
    );

    final text = lines.join('\n');
    expect(text, contains('ada@brix.dev'));
    expect(text, contains('Ada'));
    for (final secret in ['Secret@123', '123456', 'eyJhbGci', 'r1']) {
      expect(text, isNot(contains(secret)), reason: secret);
    }
    expect(text, contains('••••'));
  });

  test('API keys in the query are hidden', () {
    logger().log(
      entry(url: 'https://maps.example.com/geocode?latlng=1,2&key=AIzaSecret'),
    );

    expect(lines.first, contains('latlng=1,2'));
    expect(lines.first, isNot(contains('AIzaSecret')));
  });

  test('a failure is marked; long bodies are cut', () {
    logger(maxLines: 3).log(
      entry(
        status: 500,
        failure: ServerFailure(statusCode: 500),
        responseBody: {for (var i = 0; i < 10; i++) 'k$i': i},
      ),
    );

    expect(lines.first, contains('✗ 500'));
    expect(lines.any((line) => line.contains('more lines')), isTrue);
  });

  test('no connection: the failure text instead of a body', () {
    logger().log(
      NetworkLogEntry(
        request: NetworkRequest(
          method: HttpMethod.get,
          url: Uri.parse('https://api.test/v1/items'),
        ),
        took: const Duration(seconds: 2),
        failure: NetworkFailure(),
      ),
    );

    expect(lines.first, contains('✗ NetworkFailure · 2.0 s'));
    expect(lines, contains(startsWith('│ ✗ No internet connection')));
  });

  test('a file answer shows its size and type, not its bytes', () {
    logger().log(
      entry(
        responseBody: DownloadedFile(
          bytes: Uint8List(250 * 1024),
          contentType: 'application/pdf',
        ),
      ),
    );

    expect(lines, contains('│ ← <binary 250 KB · application/pdf>'));
  });

  test('disabled: prints nothing', () {
    logger(enabled: false).log(entry());

    expect(lines, isEmpty);
  });
}
