import 'dart:async';

/// Countdown before a new code may be asked for. Reports the time left
/// every second through [onTick], ending with [Duration.zero].
class ResendCooldown {
  ResendCooldown({required this.duration, required this.onTick});

  /// Length of one wait; [Duration.zero] turns the cooldown off.
  final Duration duration;
  final void Function(Duration left) onTick;

  Timer? _timer;
  Duration _left = Duration.zero;

  Duration get left => _left;
  bool get isRunning => _left > Duration.zero;

  /// Starts (or restarts) the wait.
  void start() {
    _timer?.cancel();
    if (duration <= Duration.zero) return;
    _set(duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = _left - const Duration(seconds: 1);
      if (next <= Duration.zero) {
        timer.cancel();
        _set(Duration.zero);
      } else {
        _set(next);
      }
    });
  }

  /// Stops the countdown where it is (screen closed).
  void cancel() => _timer?.cancel();

  void _set(Duration left) {
    _left = left;
    onTick(left);
  }
}
