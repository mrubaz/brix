import 'dart:developer' as developer;

/// How important a log line is. Lines below [BrixLogger.minLevel] are
/// skipped.
enum LogLevel { debug, info, warning, error }

/// A readable console log for apps, one box per message, so lines that
/// come one after another never run together:
///
/// ```
/// ╭─ ▰ INFO · My App ────────────────────────────── 14:32:05.123
/// │ Logged in
/// ╰────────────────────────────────────────────────────────────────
/// ╭─ ▰ ERROR · My App ───────────────────────────── 14:32:07.210
/// │ Saving failed
/// │ ↳ Bad state: boom
/// │   #0 SaveFlow.run (save_flow.dart:42)
/// ╰────────────────────────────────────────────────────────────────
/// ```
///
/// Each level has its own colour: debug grey, info blue, success green,
/// warning yellow, error red; `▰` is the brix mark. Prints nothing in
/// release builds unless [enabled] says so. Stack traces are cut to
/// [stackLines] lines.
class BrixLogger {
  BrixLogger({
    this.name = '',
    bool? enabled,
    this.minLevel = LogLevel.debug,
    this.colors = true,
    this.stackLines = 6,
    this.width = 64,
    this.output,
  }) : enabled = enabled ?? !_isRelease;

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

  /// Width of the box lines, in characters.
  final int width;

  /// Where lines go, one call per line – e.g. `print` to read the log in a
  /// terminal with `flutter run`. Default: the IDE console (VS Code,
  /// Android Studio) through `dart:developer`, one entry at a time, with
  /// colours on iOS too.
  final void Function(String line)? output;

  void debug(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.debug, message, error: error, stackTrace: stackTrace);

  void info(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.info, message, error: error, stackTrace: stackTrace);

  /// Something finished well (saved, sent, logged in). Logged at
  /// [LogLevel.info], shown in green.
  void success(Object? message, {Object? error, StackTrace? stackTrace}) =>
      _write(LogLevel.info, _success, message, error, stackTrace);

  void warning(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  void error(Object? message, {Object? error, StackTrace? stackTrace}) =>
      log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void log(
    LogLevel level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) => _write(level, _styles[level]!, message, error, stackTrace);

  void _write(
    LogLevel level,
    _Style style,
    Object? message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    if (!enabled || level.index < minLevel.index) return;
    final out = <String>[];
    final badge = colors ? ' ${style.label} ' : '[${style.label}]';
    final title = '▰ $badge${name.isEmpty ? '' : ' · $name'}';
    final time = _time();
    final fill = (width - title.length - time.length - 5).clamp(2, width);

    final rest = '${name.isEmpty ? '' : ' · $name'} ${'─' * fill} $time';
    out.add(
      '${_paint('╭─ ', style.color)}${_paint('▰', _brick)} '
      '${_paint(badge, style.badge)}${_paint(rest, style.color)}',
    );
    for (final line in '$message'.split('\n')) {
      out.add('${_paint('│', style.color)} ${_paint(line, style.text)}');
    }
    if (error != null) {
      out.add('${_paint('│', style.color)} ${_paint('↳ $error', style.text)}');
    }
    if (stackTrace != null && stackLines > 0) {
      for (final line
          in '$stackTrace'
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .take(stackLines)) {
        final frame = line.replaceAll(RegExp(r'\s+'), ' ').trim();
        out.add('${_paint('│', style.color)}   ${_paint(frame, _grey)}');
      }
    }
    out.add(_paint('╰${'─' * (width - 1)}', style.color));
    _emit(out);
  }

  /// A start-up box with the brix mark: app name, version, environment, …
  void banner(String title, {Map<String, String> details = const {}}) {
    if (!enabled) return;
    final out = <String>[];
    const logo = ['▆▆▆▆▆▆▆', '▆▆▆ ▆▆▆'];
    final text = [
      'brix · $title',
      for (final MapEntry(:key, :value) in details.entries) '$key: $value',
    ];
    final rows = text.length > logo.length ? text.length : logo.length;
    final textWidth = text.fold(
      0,
      (max, line) => line.length > max ? line.length : max,
    );
    final inner = 2 + logo.first.length + 3 + textWidth + 2;

    out.add(_paint('╭${'─' * inner}╮', _brick));
    for (var i = 0; i < rows; i++) {
      final mark = i < logo.length ? logo[i] : '';
      final line = i < text.length ? text[i] : '';
      final words = line.padRight(textWidth);
      out.add(
        '${_paint('│', _brick)}  '
        '${_paint(mark.padRight(logo.first.length), _brick)}   '
        '${i == 0 ? _paint(words, '1') : words}  ${_paint('│', _brick)}',
      );
    }
    out.add(_paint('╰${'─' * inner}╯', _brick));
    _emit(out);
  }

  /// One entry goes out as one message, so other logs cannot land inside
  /// it. `dart:developer` reaches the IDE console directly: the iOS
  /// console turns colour codes into text, this path keeps the colours.
  void _emit(List<String> lines) {
    final output = this.output;
    if (output != null) {
      lines.forEach(output);
    } else {
      developer.log(lines.join('\n'));
    }
  }

  String _time() {
    final now = DateTime.now();
    String two(int value) => '$value'.padLeft(2, '0');
    return '${two(now.hour)}:${two(now.minute)}:${two(now.second)}'
        '.${'${now.millisecond}'.padLeft(3, '0')}';
  }

  String _paint(String text, String code) =>
      colors && code.isNotEmpty ? '\x1B[${code}m$text\x1B[0m' : text;

  /// The brix orange (ANSI 256 colour 202).
  static const _brick = '38;5;202';
  static const _grey = '90';

  static const _success = _Style('SUCCESS', '32', '1;30;42', '32');
  static const _styles = {
    LogLevel.debug: _Style('DEBUG', '90', '1;97;100', '90'),
    LogLevel.info: _Style('INFO', '34', '1;97;44', '34'),
    LogLevel.warning: _Style('WARN', '33', '1;30;43', '33'),
    LogLevel.error: _Style('ERROR', '31', '1;97;41', '31'),
  };
}

/// How one kind of line looks: its label and ANSI codes for the box, the
/// label's badge and the text.
class _Style {
  const _Style(this.label, this.color, this.badge, this.text);

  final String label;
  final String color;
  final String badge;
  final String text;
}
