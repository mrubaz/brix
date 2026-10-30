import 'dart:async';
import 'dart:convert';

import 'package:brix/core.dart';
import 'package:dio/dio.dart';

import 'downloaded_file.dart';
import 'network_client.dart';
import 'network_failures.dart';
import 'network_request.dart';
import 'network_response.dart';

/// The default [NetworkClient], on [Dio].
///
/// - [timeout] for connecting and for the answer (default 20 s);
/// - a lost connection or timeout is tried again [retries] times, with a
///   growing pause, only for GET, PUT and DELETE, never for POST, PATCH or
///   uploads, so nothing is created twice;
/// - uploads report their progress; `RequestCancel` stops a call.
///
/// Pass your own [Dio] to add interceptors, certificates or proxies.
class DioNetworkClient extends NetworkClient {
  DioNetworkClient({
    Dio? dio,
    this.timeout = const Duration(seconds: 20),
    this.retries = 2,
    this.retryDelay = const Duration(milliseconds: 400),
  }) : dio = dio ?? Dio();

  final Dio dio;
  final Duration timeout;

  /// Extra tries after a lost connection (idempotent requests only).
  final int retries;

  /// First pause before a retry; doubled each time.
  final Duration retryDelay;

  @override
  Future<NetworkResponse> send(NetworkRequest request) async {
    final canRetry = request.method.isIdempotent && !request.isUpload;
    for (var attempt = 0; ; attempt++) {
      try {
        return await _sendOnce(request);
      } on DioException catch (error) {
        if (error.type == DioExceptionType.cancel) throw CancelledFailure();
        if (!_isConnectionProblem(error)) rethrow;
        if (!canRetry ||
            attempt >= retries ||
            request.cancel?.isCancelled == true) {
          throw NetworkFailure();
        }
        await Future<void>.delayed(retryDelay * (1 << attempt));
      }
    }
  }

  Future<NetworkResponse> _sendOnce(NetworkRequest request) async {
    final cancelToken = CancelToken();
    unawaited(request.cancel?.whenCancelled.then((_) => cancelToken.cancel()));
    final response = await dio.requestUri<List<int>>(
      request.url,
      data: request.isUpload ? await _formData(request) : request.body,
      cancelToken: cancelToken,
      onSendProgress: request.onSendProgress,
      onReceiveProgress: request.onReceiveProgress,
      options: Options(
        method: request.method.verb,
        headers: request.headers,
        responseType: ResponseType.bytes,
        connectTimeout: timeout,
        receiveTimeout: timeout,
        // Every answer goes back to BrixApi, which reads 4xx / 5xx too.
        validateStatus: (_) => true,
      ),
    );
    final status = response.statusCode ?? 0;
    final bytes = response.data ?? const <int>[];
    final headers = {
      for (final MapEntry(:key, :value) in response.headers.map.entries)
        key: value.join(', '),
    };
    final isFile = request.wantsBytes && status >= 200 && status < 300;
    return NetworkResponse(
      statusCode: status,
      body: isFile
          ? DownloadedFile.fromBytes(bytes, headers: headers)
          : _decode(utf8.decode(bytes, allowMalformed: true)),
      headers: headers,
    );
  }

  /// Several files may share one field name (e.g. `files`).
  Future<FormData> _formData(NetworkRequest request) async {
    final form = FormData()..fields.addAll(request.fields.entries);
    for (final file in request.files) {
      final contentType = _mediaType(file.contentType);
      form.files.add(
        MapEntry(
          file.field,
          file.path != null
              ? await MultipartFile.fromFile(
                  file.path!,
                  filename: file.fileName,
                  contentType: contentType,
                )
              : MultipartFile.fromBytes(
                  file.bytes!,
                  filename: file.fileName,
                  contentType: contentType,
                ),
        ),
      );
    }
    return form;
  }

  static DioMediaType? _mediaType(String? type) =>
      type == null ? null : DioMediaType.parse(type);

  static bool _isConnectionProblem(DioException error) => switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.connectionError => true,
    _ => false,
  };

  /// JSON when it is JSON, the text otherwise, `null` when empty.
  static Object? _decode(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    try {
      return jsonDecode(text);
    } on FormatException {
      return text;
    }
  }

  @override
  void close() => dio.close();
}
