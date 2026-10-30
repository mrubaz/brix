/// What the server answered, before it is read into a `Result`.
class NetworkResponse {
  const NetworkResponse({
    required this.statusCode,
    this.body,
    this.headers = const {},
  });

  final int statusCode;

  /// Decoded JSON (`Map`, `List`, ...), the text when it was not JSON,
  /// `null` for an empty body, or a `DownloadedFile` for a successful
  /// file download (`NetworkRequest.wantsBytes`).
  final Object? body;

  final Map<String, String> headers;

  bool get isSuccessful => statusCode >= 200 && statusCode < 300;

  @override
  String toString() => 'NetworkResponse($statusCode)';
}
