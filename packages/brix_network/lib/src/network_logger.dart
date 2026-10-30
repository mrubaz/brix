import 'dart:convert';
import 'dart:developer' as developer;

import 'package:brix/core.dart';

import 'downloaded_file.dart';
import 'network_request.dart';
import 'network_response.dart';

/// One finished call, for a [NetworkLogger].
class NetworkLogEntry {
  const NetworkLogEntry({
    required this.request,
    required this.took,
    this.response,
    this.failure,
  });

  final NetworkRequest request;
  final Duration took;

  /// `null` when the server was not reached.
  final NetworkResponse? response;

  /// Set when the call did not succeed.
  final Failure? failure;
}

/// Writes finished calls somewhere (console, crash reporter, file). Plug in
/// your own, or use [PrettyNetworkLogger].
abstract class NetworkLogger {
  const NetworkLogger();

  void log(NetworkLogEntry entry);
}

/// A readable console log, one box per call:
///
/// ```
/// ╭─ ▰ POST auth/login ────────────────────────────── 200 · 312 ms
/// │ to {"email": "ada@brix.dev", "password": "••••"}
/// │ ← {"success": true, "message": "Welcome back!", ...}
/// ╰────────────────────────────────────────────────────────────────
/// ```
///
/// Same look as brix's `BrixLogger`: green when it worked, yellow for a 4xx,
/// red for a 5xx or no connection; `▰` is the brix mark.
///
/// Passwords, tokens, codes and API keys are hidden (`••••`), long bodies
/// are cut, and it prints nothing in release builds.
class PrettyNetworkLogger extends NetworkLogger {
  PrettyNetworkLogger({
    bool? enabled,
    this.colors = true,
    this.maxLines = 20,
    this.showResponseBody = true,
    Set<String> hiddenKeys = const {},
    this.output,
  }) : enabled = enabled ?? !_isRelease,
       hiddenKeys = {...defaultHiddenKeys, ...hiddenKeys};

  static const _isRelease = bool.fromEnvironment('dart.vm.product');

  /// Keys whose values are never printed (compared without case, and any
  /// key ending in `password`, `token` or `secret` too).
  static const defaultHiddenKeys = {
    'authorization',
    'password',
    'otp',
    'pin',
    'cvv',
    'secret',
    'token',
    'apikey',
    'api_key',
    'key',
  };

  /// Off by default in release builds.
  final bool enabled;

  /// ANSI colours (VS Code, Android Studio, terminals). Turn off for the
  /// Xcode console.
  final bool colors;

  /// Lines per body before it is cut.
  final int maxLines;

  final bool showResponseBody;
  final Set<String> hiddenKeys;

  /// Where lines go, one call per line, e.g. `print` for `flutter run` in
  /// a terminal. Default: the IDE console through `dart:developer`, one
  /// call at a time, with colours on iOS too.
  final void Function(String line)? output;

  static const _width = 64;

  @override
  void log(NetworkLogEntry entry) {
    if (!enabled) return;
    final request = entry.request;
    final status = entry.response?.statusCode;
    final ok = entry.failure == null;
    final color = !ok
        ? (status != null && status < 500 ? _yellow : _red)
        : _green;
    final title = '${request.method.verb} ${_target(request.url)}';
    final result =
        '${ok ? '' : '✗ '}${status ?? entry.failure.runtimeType}'
        ' · ${_duration(entry.took)}';
    final fill = (_width - title.length - result.length - 7).clamp(2, _width);

    final lines = <String>[
      '${_paint('╭─ ', color)}${_paint('▰', _brick)} '
          '${_paint('$title ${'─' * fill} ', color)}'
          '${_paint(result, color, bold: true)}',
      if (request.isUpload)
        '│ → files: ${request.files.map((file) => '${file.field}=${file.fileName ?? file.path?.split('/').last}').join(', ')}',
      if (request.body != null) ..._block('→', request.body),
      if (showResponseBody && entry.response?.body != null)
        ..._block('←', entry.response!.body),
      if (!ok && entry.response == null) '│ ✗ ${entry.failure!.displayMessage}',
      _paint('╰${'─' * (_width - 1)}', color),
    ];
    final output = this.output;
    if (output != null) {
      lines.forEach(output);
    } else {
      developer.log(lines.join('\n'));
    }
  }

  /// [value] with every hidden key's value replaced by `••••`.
  Object? mask(Object? value) => switch (value) {
    Map() => {
      for (final MapEntry(:key, :value) in value.entries)
        key: _isHidden('$key') ? '••••' : mask(value),
    },
    List() => [for (final item in value) mask(item)],
    _ => value,
  };

  bool _isHidden(String key) {
    final lower = key.toLowerCase();
    return hiddenKeys.contains(lower) ||
        lower.endsWith('password') ||
        lower.endsWith('token') ||
        lower.endsWith('secret');
  }

  Iterable<String> _block(String arrow, Object? body) sync* {
    if (body is DownloadedFile) {
      yield '│ $arrow <binary ${body.sizeLabel}'
          '${body.contentType == null ? '' : ' · ${body.contentType}'}>';
      return;
    }
    final text = body is String
        ? body
        : const JsonEncoder.withIndent('  ').convert(mask(body));
    final all = text.split('\n');
    final shown = all.take(maxLines).toList();
    for (var i = 0; i < shown.length; i++) {
      yield '│ ${i == 0 ? arrow : ' '} ${shown[i]}';
    }
    if (all.length > maxLines) {
      yield '│   … ${all.length - maxLines} more lines';
    }
  }

  /// Path and query, hidden query values masked (e.g. Google's `key`).
  String _target(Uri url) {
    final query = {
      for (final MapEntry(:key, :value) in url.queryParameters.entries)
        key: _isHidden(key) ? '••••' : value,
    };
    final path = url.path.startsWith('/') ? url.path.substring(1) : url.path;
    if (query.isEmpty) return path;
    return '$path?${query.entries.map((e) => '${e.key}=${e.value}').join('&')}';
  }

  static String _duration(Duration took) => took.inMilliseconds < 1000
      ? '${took.inMilliseconds} ms'
      : '${(took.inMilliseconds / 1000).toStringAsFixed(1)} s';

  static const _green = '32';
  static const _yellow = '33';
  static const _red = '31';

  /// The brix orange (ANSI 256 colour 202).
  static const _brick = '38;5;202';

  String _paint(String text, String code, {bool bold = false}) =>
      colors ? '\x1B[${bold ? '1;' : ''}${code}m$text\x1B[0m' : text;
}
