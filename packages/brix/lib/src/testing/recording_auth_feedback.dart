import '../../auth.dart';

/// Feedback that only records what would have been shown – for tests.
class RecordingAuthFeedback extends AuthFeedback {
  final List<Failure> failures = [];
  final List<AuthWarning> warnings = [];

  /// Includes `null` when a success came without a backend message.
  final List<String?> successes = [];

  @override
  void failure(Failure failure) => failures.add(failure);

  @override
  void warning(AuthWarning warning) => warnings.add(warning);

  @override
  void success(String? message) => successes.add(message);
}
