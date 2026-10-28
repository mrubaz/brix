import 'dart:io';

import 'package:test/test.dart';

/// Brix core stays pure Dart and works on every platform (mobile, web,
/// server): no `dart:io` / `dart:ui` / `dart:html`, and no other packages
/// except `meta` (the Dart team's annotations, e.g. `@protected`).
void main() {
  test('lib/ imports only dart: core libraries and its own files', () {
    const banned = {'dart:io', 'dart:ui', 'dart:html', 'dart:ffi'};
    const allowedPackages = {'package:meta/meta.dart'};
    final problems = <String>[
      for (final (file, uri) in _imports(Directory('lib')))
        if (banned.contains(uri) ||
            (uri.startsWith('package:') &&
                !uri.startsWith('package:brix/') &&
                !allowedPackages.contains(uri)))
          '${file.path}: $uri',
    ];
    expect(problems, isEmpty);
  });
}

final _directive = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

/// Every import / export URI in the Dart files under [dir].
Iterable<(File, String)> _imports(Directory dir) sync* {
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'));
  for (final file in files) {
    for (final line in file.readAsLinesSync()) {
      final match = _directive.firstMatch(line);
      if (match != null) yield (file, match.group(1)!);
    }
  }
}
