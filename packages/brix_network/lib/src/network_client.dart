import 'network_request.dart';
import 'network_response.dart';

/// Sends one request. `DioNetworkClient` is the default; write your own to
/// use another library (`http`, `chopper`, a test fake, ...).
///
/// Return every answer the server gives, also 4xx / 5xx, `BrixApi` reads
/// them. Throw a `NetworkFailure` when the server could not be reached
/// (no connection, timeout) and a `CancelledFailure` when
/// [NetworkRequest.cancel] stopped it; anything else thrown becomes an
/// `UnknownFailure`.
abstract class NetworkClient {
  const NetworkClient();

  Future<NetworkResponse> send(NetworkRequest request);

  /// Frees connections. Optional.
  void close() {}
}
