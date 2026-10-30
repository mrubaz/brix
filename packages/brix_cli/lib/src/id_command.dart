import 'dart:io';

import 'package:path/path.dart' as p;

import 'app_id.dart';

/// `brix id <new.id>`: changes the app id on every platform of the app in
/// [workingDirectory], so nobody has to edit Gradle or Xcode files by hand.
class IdCommand {
  IdCommand({required this.out, String? workingDirectory})
    : root = workingDirectory ?? Directory.current.path;

  final void Function(String line) out;
  final String root;

  Future<int> run(String newId) async {
    final problem = AppId.problem(newId);
    if (problem != null) {
      out('Cannot use "$newId" as the app id. $problem');
      return 64;
    }
    final gradle = File(p.join(root, 'android', 'app', 'build.gradle.kts'));
    if (!gradle.existsSync()) {
      out(
        'Run this inside a Flutter app (android/app/build.gradle.kts was '
        'not found).',
      );
      return 66;
    }
    final oldId = RegExp(r'applicationId\s*=\s*"([^"]+)"')
        .firstMatch(gradle.readAsStringSync())?[1];
    if (oldId == null) {
      out('Could not find applicationId in android/app/build.gradle.kts.');
      return 65;
    }
    if (oldId == newId) {
      out('The app id is already $newId.');
      return 0;
    }

    out('Changing the app id from $oldId to $newId ...');
    _android(gradle, oldId, newId);
    _apple(oldId, newId);
    _linux(oldId, newId);
    out('');
    out('Done. Run "flutter clean" before the next build.');
    return 0;
  }

  void _android(File gradle, String oldId, String newId) {
    gradle.writeAsStringSync(
      gradle
          .readAsStringSync()
          .replaceAll('namespace = "$oldId"', 'namespace = "$newId"')
          .replaceAll('applicationId = "$oldId"', 'applicationId = "$newId"'),
    );
    for (final language in ['kotlin', 'java']) {
      final base = p.join(root, 'android', 'app', 'src', 'main', language);
      final oldDir = Directory(p.joinAll([base, ...oldId.split('.')]));
      if (!oldDir.existsSync()) continue;
      final newDir = Directory(p.joinAll([base, ...newId.split('.')]))
        ..createSync(recursive: true);
      for (final file in oldDir.listSync().whereType<File>()) {
        final moved = File(p.join(newDir.path, p.basename(file.path)));
        moved.writeAsStringSync(
          file.readAsStringSync().replaceFirst(
            'package $oldId',
            'package $newId',
          ),
        );
        file.deleteSync();
      }
      _removeEmptyUpTo(oldDir, Directory(base));
    }
    out('  ✓ Android');
  }

  void _apple(String oldId, String newId) {
    final oldApple = AppId.apple(oldId);
    final newApple = AppId.apple(newId);
    var changed = false;
    for (final path in [
      p.join('ios', 'Runner.xcodeproj', 'project.pbxproj'),
      p.join('macos', 'Runner.xcodeproj', 'project.pbxproj'),
      p.join('macos', 'Runner', 'Configs', 'AppInfo.xcconfig'),
    ]) {
      final file = File(p.join(root, path));
      if (!file.existsSync()) continue;
      final text = file.readAsStringSync();
      final oldOrg = oldId.substring(0, oldId.lastIndexOf('.'));
      final newOrg = newId.substring(0, newId.lastIndexOf('.'));
      final updated = text
          .replaceAllMapped(
            RegExp('PRODUCT_BUNDLE_IDENTIFIER = ${RegExp.escape(oldApple)}\\b'),
            (_) => 'PRODUCT_BUNDLE_IDENTIFIER = $newApple',
          )
          .replaceAllMapped(
            RegExp('(PRODUCT_COPYRIGHT = .*)${RegExp.escape(oldOrg)}'),
            (m) => '${m[1]}$newOrg',
          );
      if (updated != text) {
        file.writeAsStringSync(updated);
        changed = true;
      }
    }
    if (changed) out('  ✓ iOS and macOS ($newApple)');
  }

  void _linux(String oldId, String newId) {
    final file = File(p.join(root, 'linux', 'CMakeLists.txt'));
    if (!file.existsSync()) return;
    file.writeAsStringSync(
      file.readAsStringSync().replaceAll(
        'set(APPLICATION_ID "$oldId")',
        'set(APPLICATION_ID "$newId")',
      ),
    );
    out('  ✓ Linux');
  }

  /// Deletes [dir] and its parents while they are empty, stopping at [stop].
  void _removeEmptyUpTo(Directory dir, Directory stop) {
    var current = dir;
    while (p.isWithin(stop.path, current.path) &&
        current.existsSync() &&
        current.listSync().isEmpty) {
      current.deleteSync();
      current = current.parent;
    }
  }
}
