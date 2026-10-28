import 'failure.dart';

/// Outcome of any brix call: [Success] or [Failed], nothing else.
///
/// ```dart
/// switch (result) {
///   case Success(:final data): ...
///   case Failed(failure: NetworkFailure()): ...
///   case Failed(:final failure): ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailed => this is Failed<T>;

  /// The data on success, otherwise null.
  T? get dataOrNull => switch (this) {
    Success(:final data) => data,
    Failed() => null,
  };

  /// The failure when failed, otherwise null.
  Failure? get failureOrNull => switch (this) {
    Success() => null,
    Failed(:final failure) => failure,
  };
}

/// The call worked. For calls without data use `Success<void>(null)`.
final class Success<T> extends Result<T> {
  const Success(this.data, {this.message});

  final T data;

  /// The backend's text, if any (e.g. "OTP sent to your email").
  final String? message;

  @override
  String toString() => 'Success($data)';
}

/// The call did not work; [failure] says why.
final class Failed<T> extends Result<T> {
  const Failed(this.failure);

  final Failure failure;

  @override
  String toString() => 'Failed($failure)';
}
