@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// The app is the same in every state library; only screens, view models,
/// routing and setup differ. This fails when a shared file changes in one
/// template and not in the others.
void main() {
  const templates = ['getx', 'bloc', 'riverpod'];

  /// Files and folders every template has the same.
  const shared = [
    'README.md',
    'analysis_options.yaml',
    'brix.yaml',
    'env',
    'lib/config/app_config.dart',
    'lib/config/dev_tools.dart',
    'lib/data',
    'lib/dev',
    'lib/domain',
    'lib/routing/routes.dart',
    'lib/ui/core/themes',
    'lib/ui/core/widgets/app_logo.dart',
    'lib/ui/core/widgets/auth_page.dart',
    'lib/ui/core/widgets/settings_group.dart',
    'lib/ui/core/widgets/settings_row.dart',
    'lib/ui/core/widgets/setup_steps.dart',
    'lib/ui/core/widgets/tab_page.dart',
    'lib/ui/home',
    'lib/ui/library',
    'lib/ui/setup',
    'lib/ui/shell',
    'test/config',
    'test/dev',
    'test/ui',
  ];

  String root(String template) => p.join('templates', template);

  List<String> filesIn(String template, String entry) {
    final path = p.join(root(template), entry);
    if (File(path).existsSync()) return [entry];
    return [
      for (final file in Directory(path).listSync(recursive: true))
        if (file is File) p.relative(file.path, from: root(template)),
    ]..sort();
  }

  for (final entry in shared) {
    test('$entry is the same in every template', () {
      final files = filesIn('getx', entry);
      expect(files, isNotEmpty);
      for (final template in templates.skip(1)) {
        expect(filesIn(template, entry), files, reason: template);
        for (final file in files) {
          expect(
            File(p.join(root(template), file)).readAsStringSync(),
            File(p.join(root('getx'), file)).readAsStringSync(),
            reason: '$file differs in $template',
          );
        }
      }
    });
  }
}
