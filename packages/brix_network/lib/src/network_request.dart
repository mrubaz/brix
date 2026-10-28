import 'request_cancel.dart';
import 'upload_file.dart';

/// HTTP methods brix_network sends.
enum HttpMethod {
  get,
  post,
  put,
  patch,
  delete;

  /// `GET`, `POST`, …
  String get verb => name.toUpperCase();

  /// Safe to send again after a lost connection (the server state ends up
  /// the same). POST and PATCH are never retried.
  bool get isIdempotent =>
      this == HttpMethod.get ||
      this == HttpMethod.put ||
      this == HttpMethod.delete;
}

/// One request, as handed to a [NetworkClient]. Built by `BrixApi`.
class NetworkRequest {
  const NetworkRequest({
    required this.method,
    required this.url,
    this.headers = const {},
    this.body,
    this.files = const [],
    this.fields = const {},
    this.cancel,
    this.onSendProgress,
  });

  final HttpMethod method;

  /// Full URL, query included.
  final Uri url;

  final Map<String, String> headers;

  /// JSON-encodable body (`Map`, `List`, …) or `null`.
  final Object? body;

  /// Files for a multipart upload; empty for a normal request.
  final List<UploadFile> files;

  /// Text fields sent next to [files].
  final Map<String, String> fields;

  final RequestCancel? cancel;

  /// Bytes sent so far and in total (total is -1 when unknown).
  final void Function(int sent, int total)? onSendProgress;

  bool get isUpload => files.isNotEmpty;

  @override
  String toString() => 'NetworkRequest(${method.verb} $url)';
}
