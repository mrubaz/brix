import 'package:flutter/foundation.dart';

/// App settings from `--dart-define`.
///
/// ```
/// flutter run --dart-define=API_URL=https://api.example.com/v1/
/// ```
abstract final class AppConfig {
  /// Your REST API. Needed by `main.dart` (the release entry point).
  static const apiUrl = String.fromEnvironment('API_URL');

  /// Why the app cannot start against [url], or `null` when it can.
  /// A release build needs an `https` URL, so passwords never travel open.
  static String? problem({String url = apiUrl, bool release = kReleaseMode}) {
    if (url.isEmpty) {
      return 'Set your API before running main.dart:\n'
          'flutter run --dart-define=API_URL=https://your.api/v1/\n\n'
          'To try the app without an API: flutter run -t lib/main_development.dart';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return 'API_URL is not a valid address: $url';
    }
    if (release && uri.scheme != 'https') {
      return 'A release build needs an https API_URL: $url';
    }
    return null;
  }
}
