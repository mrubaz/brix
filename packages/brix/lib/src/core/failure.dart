import 'dart:async';

/// Why something did not work. Every block (auth, network, account, ...)
/// reports problems with these classes instead of plain strings, so an app
/// can react to the kind of problem, not only show a text.
///
/// Open for extension: a block or an app may add its own subclasses. A
/// `switch` over failures should therefore end with a `Failure()` case.
abstract class Failure {
  Failure({
    Iterable<String> messages = const [],
    Map<String, List<String>> fieldErrors = const {},
  }) : messages = List.unmodifiable(messages),
       fieldErrors = Map.unmodifiable({
         for (final entry in fieldErrors.entries)
           entry.key: List<String>.unmodifiable(entry.value),
       });

  /// Texts from the backend, ready to show. Empty when the backend gave
  /// none, then show [displayMessage] (or the app's own text).
  final List<String> messages;

  /// Problems per form field, e.g. `{'email': ['Already registered']}`, so
  /// a form can show them under the right field. Empty when the backend
  /// sent none.
  final Map<String, List<String>> fieldErrors;

  /// The first problem for [field], or null, handy as a field's
  /// `errorText`.
  String? fieldError(String field) => fieldErrors[field]?.firstOrNull;

  /// All [messages] on one line each, or null when there are none.
  String? get message => messages.isEmpty ? null : messages.join('\n');

  /// Plain English text for this kind of problem, for when the backend sent
  /// no message. Each failure type has its own; an app's own failure types
  /// override it, and an app may always show its own text instead.
  String get defaultMessage => 'Something went wrong. Please try again.';

  /// What to show the user: the backend's [message], else [defaultMessage].
  String get displayMessage => message ?? defaultMessage;

  @override
  String toString() => '$runtimeType($messages)';
}

/// The input was rejected (HTTP 400 / 422, form rules on the server).
class ValidationFailure extends Failure {
  ValidationFailure({super.messages, super.fieldErrors});

  @override
  String get defaultMessage => 'Please check what you entered.';
}

/// Not logged in or the session ended (HTTP 401).
class UnauthorizedFailure extends Failure {
  UnauthorizedFailure({super.messages});

  @override
  String get defaultMessage => 'Your session has ended. Please log in again.';
}

/// The server failed or answered with an unexpected status.
class ServerFailure extends Failure {
  ServerFailure({this.statusCode, super.messages});

  /// Null when the backend has no status codes (e.g. Firebase).
  final int? statusCode;

  @override
  String get defaultMessage =>
      'The server could not complete this. Please try again later.';

  @override
  String toString() => 'ServerFailure($statusCode, $messages)';
}

/// No connection or the request timed out.
class NetworkFailure extends Failure {
  NetworkFailure({super.messages});

  @override
  String get defaultMessage =>
      'No internet connection. Check your connection and try again.';
}

/// The backend does not offer this call (e.g. OTP on a link-only backend).
class UnsupportedFailure extends Failure {
  UnsupportedFailure({super.messages});

  @override
  String get defaultMessage => 'This is not available.';
}

/// Anything else. [cause] keeps the original error for logging; it is never
/// meant to be shown to the user.
class UnknownFailure extends Failure {
  UnknownFailure({this.cause, this.stackTrace, super.messages});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => 'UnknownFailure($cause)';
}

/// Default way to turn a thrown error into a [Failure].
///
/// Only checks what pure Dart can see ([TimeoutException]). Adapters that
/// know their own exceptions (socket errors, SDK error codes) map those first
/// and call this for the rest.
Failure failureFromError(Object error, StackTrace stackTrace) {
  if (error is Failure) return error;
  if (error is TimeoutException) return NetworkFailure();
  return UnknownFailure(cause: error, stackTrace: stackTrace);
}
