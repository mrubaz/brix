import 'package:web/web.dart' as web;

/// The local backend's data in the browser's local storage, under its own
/// key, so clearing the app's preferences does not touch it.
class LocalBox {
  LocalBox([Object? _]);

  static const _key = 'brix_local_backend';

  Future<String?> read() async => web.window.localStorage.getItem(_key);

  Future<void> write(String text) async =>
      web.window.localStorage.setItem(_key, text);
}
