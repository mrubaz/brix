/// How important a log line is. Lines below [BrixLogger.minLevel] are
/// skipped.
enum LogLevel { debug, info, warning, error }

/// A readable console log for apps, one line per message:
///
/// ```
/// 14:32:05.123  ✓ INFO   Pristine  Logged in
/// 14:32:06.004  ⚠ WARN   Pristine  JSON roles[0].level: expected a number
/// 14:32:07.210  ✗ ERROR  Pristine  Saving step failed
///                 ↳ StateError: boom
///                   #0  InspectionStepMixin.saveStepWith (inspection_step_mixin.dart:71)
/// ```
///
/// Prints nothing in release builds unless [enabled] says so. Stack traces
/// are cut to [stackLines] lines.
class BrixLogger {
  BrixLogger({
    this.name = '',
    bool? enabled,
    this.minLevel = LogLevel.debug,
    this.colors = true,
    this.stackLines = 6,
    void Function(String line)? output,
  }) : enabled = enabled ?? !_isRelease,
       _output = output ?? print;

  static const _isRelease = bool.fromEnvironment('dart.vm.product');

  /// Shown on every line, e.g. the app's name.
  final String name;

  /// Off by default in release builds.
  final bool enabled;
  final LogLevel minLevel;

  /// ANSI colours (VS Code, Android Studio, terminals). Turn off for the
  /// Xcode console.
  final bool colors;

  /// Stack trace lines shown with an error.
  final int stackLines;
  final void Function(String line) _output;

  void debug(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  void info(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  void warning(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void error(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void log(
    LogLevel level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enabled || level.index < minLevel.index) return;
    final (icon, label, color) = switch (level) {
      LogLevel.debug => ('·', 'DEBUG', '90'),
      LogLevel.info => ('✓', 'INFO ', '32'),
      LogLevel.warning => ('⚠', 'WARN ', '33'),
      LogLevel.error => ('✗', 'ERROR', '31'),
    };
    final tag = name.isEmpty ? '' : '$name  ';
    _output(_paint('${_time()}  $icon $label  $tag$message', color));
    if (error != null) _output(_paint('                ↳ $error', color));
    if (stackTrace != null && stackLines > 0) {
      for (final line
          in '$stackTrace'
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .take(stackLines)) {
        _output('                  ${line.replaceAll(RegExp(r'\s+'), ' ')}');
      }
    }
  }

  /// A start-up box: app name, version, environment, …
  void banner(String title, {Map<String, String> details = const {}}) {
    if (!enabled) return;
    final lines = [
      title,
      for (final MapEntry(:key, :value) in details.entries) '$key: $value',
    ];
    final width = lines.fold(
      0,
      (max, line) => line.length > max ? line.length : max,
    );
    _output(_paint('╔${'═' * (width + 2)}╗', '36'));
    for (final line in lines) {
      _output(_paint('║ ${line.padRight(width)} ║', '36'));
    }
    _output(_paint('╚${'═' * (width + 2)}╝', '36'));
  }

  String _time() {
    final now = DateTime.now();
    String two(int value) => '$value'.padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}'
        '.${'${now.millisecond}'.padLeft(3, '0')}';
  }

  String _paint(String text, String code) =>
      colors ? '\x1B[${code}m$text\x1B[0m' : text;
}
