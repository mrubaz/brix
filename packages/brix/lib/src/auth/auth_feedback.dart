import '../core/failure.dart';
import 'auth_warning.dart';

/// Shows the auth flows' results in the app's own alert style.
abstract class AuthFeedback {
  const AuthFeedback();

  /// A backend call failed. [Failure.messages] may be empty (no connection,
  /// unknown error) – the app then shows its own text for the failure type.
  void failure(Failure failure);

  /// A local check failed before any backend call.
  void warning(AuthWarning warning);

  /// A call succeeded. [message] is the backend's text, `null` when it sent
  /// none – the app decides whether to show anything then.
  void success(String? message);
}
