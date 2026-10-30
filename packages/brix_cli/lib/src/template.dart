import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart' as p;

/// The app `brix create` copies: `templates/app` inside this package.
/// Its package name `brix_app` becomes the new app's name.
class Template {
  const Template(this.directory);

  /// The template that ships with brix_cli.
  static Future<Template> bundled() async {
    final lib = await Isolate.resolvePackageUri(
      Uri.parse('package:brix_cli/brix_cli.dart'),
    );
    if (lib == null) {
      throw StateError('brix_cli: cannot find the bundled app template.');
    }
    final root = p.dirname(p.dirname(lib.toFilePath()));
    return Template(Directory(p.join(root, 'templates', 'app')));
  }

  static const placeholder = 'brix_app';

  /// What is copied; platform folders come from `flutter create`.
  static const entries = [
    'lib',
    'test',
    'pubspec.yaml',
    'analysis_options.yaml',
    'brix.yaml',
    'README.md',
    '.vscode/launch.json',
    'env',
  ];

  final Directory directory;

  /// Copies the template into [target], with [appName] instead of
  /// [placeholder] in every file. Replaces `lib/` and `test/` there.
  Future<void> copyTo(Directory target, String appName) async {
    for (final folder in ['lib', 'test']) {
      final existing = Directory(p.join(target.path, folder));
      if (existing.existsSync()) existing.deleteSync(recursive: true);
    }
    for (final entry in entries) {
      final from = p.join(directory.path, entry);
      if (FileSystemEntity.isDirectorySync(from)) {
        for (final file in Directory(from).listSync(recursive: true)) {
          if (file is! File) continue;
          final relative = p.relative(file.path, from: directory.path);
          _write(file, File(p.join(target.path, relative)), appName);
        }
      } else if (File(from).existsSync()) {
        _write(File(from), File(p.join(target.path, entry)), appName);
      }
    }
  }

  void _write(File from, File to, String appName) {
    to.parent.createSync(recursive: true);
    to.writeAsStringSync(
      from.readAsStringSync().replaceAll(placeholder, appName),
    );
  }
}
