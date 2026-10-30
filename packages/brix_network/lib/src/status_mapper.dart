import 'package:brix/core.dart';

import 'response_reader.dart';

/// Turns a failed answer into a `Failure`. Pass your own to `BrixApi` to
/// change the mapping, and call [StandardStatus.map] for the rest.
typedef StatusMapper = Failure Function(int statusCode, ApiReply reply);

/// The default mapping.
abstract final class StandardStatus {
  /// - 400, 409, 422 to `ValidationFailure` (with field errors)
  /// - 401 to `UnauthorizedFailure` (session ended to logout)
  /// - 408, 504 to `NetworkFailure` (timed out)
  /// - everything else (403, 404, 5xx, a 200 with `success: false`) to
  ///   `ServerFailure` with the status code
  static Failure map(int statusCode, ApiReply reply) => switch (statusCode) {
    400 || 409 || 422 => ValidationFailure(
      messages: reply.messages,
      fieldErrors: reply.fieldErrors,
    ),
    401 => UnauthorizedFailure(messages: reply.messages),
    408 || 504 => NetworkFailure(messages: reply.messages),
    _ => ServerFailure(statusCode: statusCode, messages: reply.messages),
  };
}
