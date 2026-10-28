import 'dart:async';

import 'package:brix/core.dart';

import 'dio_network_client.dart';
import 'network_client.dart';
import 'network_failures.dart';
import 'network_logger.dart';
import 'network_request.dart';
import 'network_response.dart';
import 'request_cancel.dart';
import 'response_reader.dart';
import 'status_mapper.dart';
import 'upload_file.dart';

/// Turns JSON data into your model. `json.items(Item.fromJson)` for lists.
typedef Parse<T> = T Function(Json data);

/// Your REST API. Every call returns a `Result`: `Success(data, message)`
/// or `Failed(failure)` – no exceptions, no global error list.
///
/// ```dart
/// final api = BrixApi(
///   baseUrl: 'https://api.example.com/v1/',
///   token: () => storage.readToken(),
///   onUnauthorized: () => sessionFlow.logout(),
/// );
///
/// final profile = await api.get('auth/profile', parse: User.fromJson);
/// final saved = await api.patch<void>('auth/profile', body: update.toJson());
/// final list = await api.get('items', parse: (data) => data.items(Item.fromJson));
/// ```
///
/// Everything that differs between backends is a parameter: the [client]
/// (Dio by default), where data / messages / errors are ([reader]), how
/// status codes become failures ([statusMapper]), the token, the logger.
class BrixApi {
  BrixApi({
    required String baseUrl,
    NetworkClient? client,
    this.reader = const ResponseReader.envelope(),
    this.statusMapper = StandardStatus.map,
    this.token,
    this.authHeader = _bearer,
    this.headers = const {'Accept': 'application/json'},
    this.logger,
    this.onUnauthorized,
    this.logoutOn401 = _always,
  }) : baseUrl = Uri.parse(baseUrl.endsWith('/') ? baseUrl : '$baseUrl/'),
       client = client ?? DioNetworkClient();

  /// Relative paths are resolved against this.
  final Uri baseUrl;

  final NetworkClient client;
  final ResponseReader reader;
  final StatusMapper statusMapper;

  /// Reads the current token (e.g. from secure storage); `null` or empty
  /// sends no auth header.
  final FutureOr<String?> Function()? token;

  /// The header(s) for a token. Default: `Authorization: Bearer <token>`.
  final Map<String, String> Function(String token) authHeader;

  /// Sent with every request.
  final Map<String, String> headers;

  final NetworkLogger? logger;

  /// Runs once when the server says the session ended (401) – e.g. clear
  /// the session and open login. Several 401s at the same time run it once.
  final FutureOr<void> Function()? onUnauthorized;

  /// Which paths log out on a 401. Default: all. A wrong password on login
  /// is often a 401 too – exclude it: `logoutOn401: (path) => path != 'auth/login'`.
  final bool Function(String path) logoutOn401;

  final _inFlight = <String, Future<NetworkResponse>>{};
  Future<void>? _loggingOut;

  Future<Result<T>> get<T>(
    String path, {
    Map<String, Object?>? query,
    Parse<T>? parse,
    Map<String, String>? headers,
    RequestCancel? cancel,
    bool withToken = true,
  }) => request(
    HttpMethod.get,
    path,
    query: query,
    parse: parse,
    headers: headers,
    cancel: cancel,
    withToken: withToken,
  );

  Future<Result<T>> post<T>(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Parse<T>? parse,
    Map<String, String>? headers,
    RequestCancel? cancel,
    bool withToken = true,
  }) => request(
    HttpMethod.post,
    path,
    body: body,
    query: query,
    parse: parse,
    headers: headers,
    cancel: cancel,
    withToken: withToken,
  );

  Future<Result<T>> put<T>(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Parse<T>? parse,
    Map<String, String>? headers,
    RequestCancel? cancel,
    bool withToken = true,
  }) => request(
    HttpMethod.put,
    path,
    body: body,
    query: query,
    parse: parse,
    headers: headers,
    cancel: cancel,
    withToken: withToken,
  );

  Future<Result<T>> patch<T>(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Parse<T>? parse,
    Map<String, String>? headers,
    RequestCancel? cancel,
    bool withToken = true,
  }) => request(
    HttpMethod.patch,
    path,
    body: body,
    query: query,
    parse: parse,
    headers: headers,
    cancel: cancel,
    withToken: withToken,
  );

  Future<Result<T>> delete<T>(
    String path, {
    Object? body,
    Map<String, Object?>? query,
    Parse<T>? parse,
    Map<String, String>? headers,
    RequestCancel? cancel,
    bool withToken = true,
  }) => request(
    HttpMethod.delete,
    path,
    body: body,
    query: query,
    parse: parse,
    headers: headers,
    cancel: cancel,
    withToken: withToken,
  );

  /// Multipart upload. Field names are your backend's
  /// (`UploadFile.path('avatar', file.path)`).
  Future<Result<T>> upload<T>(
    String path, {
    required List<UploadFile> files,
    Map<String, String> fields = const {},
    HttpMethod method = HttpMethod.post,
    Parse<T>? parse,
    void Function(int sent, int total)? onProgress,
    RequestCancel? cancel,
  }) => request(
    method,
    path,
    files: files,
    fields: fields,
    parse: parse,
    onProgress: onProgress,
    cancel: cancel,
  );

  /// Any call. [path] may also be a full URL (another API) – then
  /// [baseUrl] is not used; pass `withToken: false` for third-party APIs.
  Future<Result<T>> request<T>(
    HttpMethod method,
    String path, {
    Object? body,
    Map<String, Object?>? query,
    List<UploadFile> files = const [],
    Map<String, String> fields = const {},
    Parse<T>? parse,
    Map<String, String>? headers,
    void Function(int sent, int total)? onProgress,
    RequestCancel? cancel,
    bool withToken = true,
  }) async {
    final request = NetworkRequest(
      method: method,
      url: _url(path, query),
      headers: {
        ...this.headers,
        if (withToken) ...await _authHeaders(),
        ...?headers,
      },
      body: body,
      files: files,
      fields: fields,
      cancel: cancel,
      onSendProgress: onProgress,
    );

    final watch = Stopwatch()..start();
    NetworkResponse? response;
    final Result<T> result;
    try {
      response = await _send(request);
      result = await _read(path, response, parse);
    } on Failure catch (failure) {
      _log(request, watch, null, failure);
      return Failed(failure);
    } catch (error, stackTrace) {
      final failure = failureFromError(error, stackTrace);
      _log(request, watch, response, failure);
      return Failed(failure);
    }
    _log(request, watch, response, switch (result) {
      Failed(:final failure) => failure,
      Success() => null,
    });
    return result;
  }

  /// Stops the client's connections.
  void close() => client.close();

  // ---------------------------------------------------------------------

  /// Identical GETs that run at the same time share one request.
  Future<NetworkResponse> _send(NetworkRequest request) {
    if (request.method != HttpMethod.get || request.cancel != null) {
      return client.send(request);
    }
    final key = request.url.toString();
    return _inFlight[key] ??= client.send(request).whenComplete(() {
      // A block body: returning the removed future would make whenComplete
      // wait for itself.
      _inFlight.remove(key);
    });
  }

  Future<Result<T>> _read<T>(
    String path,
    NetworkResponse response,
    Parse<T>? parse,
  ) async {
    final reply = reader.read(response);
    if (response.isSuccessful && reply.success != false) {
      try {
        final data = parse == null ? null : parse(Json(reply.data));
        return Success(data as T, message: reply.message);
      } catch (error, stackTrace) {
        return Failed(UnknownFailure(cause: error, stackTrace: stackTrace));
      }
    }
    final failure = statusMapper(response.statusCode, reply);
    if (failure is UnauthorizedFailure && logoutOn401(path)) {
      await _logoutOnce();
    }
    return Failed(failure);
  }

  Future<void> _logoutOnce() {
    final onUnauthorized = this.onUnauthorized;
    if (onUnauthorized == null) return Future.value();
    return _loggingOut ??= Future(() async {
      try {
        await onUnauthorized();
      } catch (_) {
        // A failing logout must not turn the 401 into a crash.
      } finally {
        _loggingOut = null;
      }
    });
  }

  Future<Map<String, String>> _authHeaders() async {
    final read = token;
    if (read == null) return const {};
    final value = await read();
    return value == null || value.isEmpty ? const {} : authHeader(value);
  }

  Uri _url(String path, Map<String, Object?>? query) {
    final isAbsolute =
        path.startsWith('http://') || path.startsWith('https://');
    final url = isAbsolute
        ? Uri.parse(path)
        : baseUrl.resolve(path.startsWith('/') ? path.substring(1) : path);
    if (query == null || query.isEmpty) return url;
    return url.replace(
      queryParameters: {
        ...url.queryParameters,
        for (final MapEntry(:key, :value) in query.entries)
          if (value != null)
            key: value is Iterable
                ? [for (final item in value) '$item']
                : '$value',
      },
    );
  }

  void _log(
    NetworkRequest request,
    Stopwatch watch,
    NetworkResponse? response,
    Failure? failure,
  ) {
    if (failure is CancelledFailure) return;
    logger?.log(
      NetworkLogEntry(
        request: request,
        took: watch.elapsed,
        response: response,
        failure: failure,
      ),
    );
  }

  static Map<String, String> _bearer(String token) => {
    'Authorization': 'Bearer $token',
  };

  static bool _always(String path) => true;
}
