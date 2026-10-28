import 'package:brix/core.dart';

/// The request was stopped with a `RequestCancel` (e.g. its screen closed).
/// Usually nothing should be shown.
class CancelledFailure extends Failure {
  CancelledFailure();

  @override
  String get defaultMessage => 'The request was cancelled.';
}
