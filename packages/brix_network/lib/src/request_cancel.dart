import 'dart:async';

/// Stops a running request, e.g. when its screen closes. The call then
/// ends with a `CancelledFailure`, which apps usually ignore.
///
/// ```dart
/// final cancel = RequestCancel();
/// api.get('reports', cancel: cancel);
/// // screen closed:
/// cancel.cancel();
/// ```
class RequestCancel {
  final _completer = Completer<void>();

  bool get isCancelled => _completer.isCompleted;

  /// Completes when [cancel] is called.
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (!_completer.isCompleted) _completer.complete();
  }
}
