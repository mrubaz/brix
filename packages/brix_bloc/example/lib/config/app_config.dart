import 'package:flutter/foundation.dart';

/// Where your API lives.
///
/// Write it once in [_apiUrl], or give it per run:
///
/// ```
/// flutter run --dart-define-from-file=env/production.json
/// ```
///
/// While [apiUrl] is empty, debug builds run on a test backend on the
/// device (`lib/dev`), and release builds show a setup message.
abstract final class AppConfig {
  /// Your API, for example `https://api.example.com/v1/`.
  static const _apiUrl = '';

  /// [_apiUrl], unless a run passes `API_URL` (VS Code launch settings and
  /// the `env/*.json` files do).
  static const apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: _apiUrl,
  );

  /// Why the app cannot start against [url], or `null` when it can.
  /// A release build needs an `https` URL, so passwords never travel open.
  static String? problem({String url = apiUrl, bool release = kReleaseMode}) {
    if (url.isEmpty) {
      return 'Add your API address in lib/config/app_config.dart, or run with '
          '--dart-define-from-file=env/production.json.\n\n'
          'Debug builds without an API run on a test backend instead.';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'The API address is not valid: $url';
    }
    if (release && uri.scheme != 'https') {
      return 'A release build needs an https API address: $url';
    }
    return null;
  }
}
