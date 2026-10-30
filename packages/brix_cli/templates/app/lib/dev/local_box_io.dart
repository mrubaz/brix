import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// The local backend's data in a file in the app's support folder.
class LocalBox {
  /// [file] is set in tests.
  LocalBox([this._file]);

  File? _file;

  Future<File> _resolve() async {
    if (_file != null) return _file!;
    final dir = await getApplicationSupportDirectory();
    return _file = File('${dir.path}/brix_local_backend.json');
  }

  Future<String?> read() async {
    final file = await _resolve();
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  Future<void> write(String text) async {
    final file = await _resolve();
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(text);
  }
}
