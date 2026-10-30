import 'dart:io';

import 'package:brix_cli/brix_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

/// Records commands; `flutter create` makes a folder like the real one.
class FakeRunner extends ProcessRunner {
  FakeRunner({this.createExit = 0, this.pubGetExit = 0});

  final int createExit;
  final int pubGetExit;
  final calls = <String>[];

  @override
  Future<ProcessResult> run(
    String executable,
    List<String> arguments, {
    String? workingDirectory,
  }) async {
    calls.add('$executable ${arguments.join(' ')}');
    if (arguments.first == 'create') {
      if (createExit != 0) {
        return ProcessResult(1, createExit, '', 'flutter: no SDK');
      }
      final app = Directory(p.join(workingDirectory!, arguments.last));
      File(p.join(app.path, 'lib', 'main.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('// counter app');
      File(p.join(app.path, 'test', 'widget_test.dart'))
        ..createSync(recursive: true)
        ..writeAsStringSync('// counter test');
      File(p.join(app.path, 'android', 'build.gradle.kts'))
        ..createSync(recursive: true)
        ..writeAsStringSync('// android');
    }
    final code = arguments.first == 'pub' ? pubGetExit : 0;
    return ProcessResult(1, code, '', '');
  }
}

void main() {
  late Directory work;
  late Template template;
  late List<String> lines;

  setUp(() {
    work = Directory.systemTemp.createTempSync('brix_cli_test');
    final t = Directory(p.join(work.path, 'template'));
    void file(String path, String text) => File(p.join(t.path, path))
      ..createSync(recursive: true)
      ..writeAsStringSync(text);
    file('lib/main.dart', "import 'package:brix_app/app.dart';");
    file('lib/ui/home/home_screen.dart', '// brix_app home');
    file('test/app_test.dart', "import 'package:brix_app/main.dart';");
    file('pubspec.yaml', 'name: brix_app');
    file('README.md', '# brix_app');
    file('brix.yaml', 'structure: flutter');
    file('analysis_options.yaml', 'include: x');
    file('.vscode/launch.json', '{"name": "brix_app"}');
    file('pubspec_overrides.yaml', 'never copied');
    template = Template(t);
    lines = [];
  });

  tearDown(() => work.deleteSync(recursive: true));

  BrixCli cli(FakeRunner runner) => BrixCli(
    runner: runner,
    template: template,
    out: lines.add,
    workingDirectory: work.path,
  );

  String read(String path) =>
      File(p.join(work.path, 'shop', path)).readAsStringSync();

  group('AppName', () {
    test('accepts package names', () {
      for (final name in ['my_app', 'shop', 'a1', 'todo_list_2']) {
        expect(AppName.problem(name), isNull, reason: name);
      }
    });

    test('rejects bad names, keywords and package names', () {
      for (final name in [
        '',
        'MyApp',
        'my-app',
        '1app',
        '_app',
        'my app',
        'class',
        'flutter',
        'brix_ui',
      ]) {
        expect(AppName.problem(name), isNotNull, reason: name);
      }
    });
  });

  group('brix', () {
    test('no arguments or --help shows the usage', () async {
      expect(await cli(FakeRunner()).run([]), 0);
      expect(lines.join('\n'), contains('brix create <app_name>'));
      lines.clear();
      expect(await cli(FakeRunner()).run(['--help']), 0);
      expect(lines.join('\n'), contains('brix create <app_name>'));
    });

    test('--version', () async {
      expect(await cli(FakeRunner()).run(['--version']), 0);
      expect(lines, ['brix_cli $brixCliVersion']);
    });

    test('version matches pubspec', () {
      final pubspec = File('pubspec.yaml').readAsStringSync();
      expect(pubspec, contains('version: $brixCliVersion'));
    });

    test('unknown command', () async {
      expect(await cli(FakeRunner()).run(['build']), 64);
      expect(lines.first, 'Unknown command "build".');
    });

    test('create without a name', () async {
      expect(await cli(FakeRunner()).run(['create']), 64);
      expect(lines.single, contains('brix create my_app'));
    });
  });

  group('create', () {
    test('makes the app: flutter create, template, pub get', () async {
      final runner = FakeRunner();
      expect(await cli(runner).run(['create', 'shop']), 0);
      expect(runner.calls, [
        'flutter create --org com.example --project-name shop shop',
        'flutter pub get',
      ]);
      expect(read('lib/main.dart'), "import 'package:shop/app.dart';");
      expect(read('lib/ui/home/home_screen.dart'), '// shop home');
      expect(read('test/app_test.dart'), "import 'package:shop/main.dart';");
      expect(read('pubspec.yaml'), 'name: shop');
      expect(read('README.md'), '# shop');
      expect(read('brix.yaml'), 'structure: flutter');
      expect(read('.vscode/launch.json'), '{"name": "shop"}');
      expect(lines.join('\n'), contains('cd shop'));
    });

    test('replaces the counter app, keeps the platform folders', () async {
      await cli(FakeRunner()).run(['create', 'shop']);
      final app = p.join(work.path, 'shop');
      expect(
        File(p.join(app, 'test', 'widget_test.dart')).existsSync(),
        isFalse,
      );
      expect(read('lib/main.dart'), isNot(contains('counter')));
      expect(
        File(p.join(app, 'android', 'build.gradle.kts')).existsSync(),
        isTrue,
      );
      expect(File(p.join(app, 'pubspec_overrides.yaml')).existsSync(), isFalse);
    });

    test('a bad name stops before anything runs', () async {
      final runner = FakeRunner();
      expect(await cli(runner).run(['create', 'My-App']), 64);
      expect(runner.calls, isEmpty);
      expect(lines.single, contains('lowercase'));
    });

    test('an existing folder is never touched', () async {
      final folder = Directory(p.join(work.path, 'shop'))..createSync();
      File(p.join(folder.path, 'keep.txt')).writeAsStringSync('mine');
      final runner = FakeRunner();
      expect(await cli(runner).run(['create', 'shop']), 73);
      expect(runner.calls, isEmpty);
      expect(File(p.join(folder.path, 'keep.txt')).readAsStringSync(), 'mine');
    });

    test('flutter create fails: its message and exit code', () async {
      final runner = FakeRunner(createExit: 2);
      expect(await cli(runner).run(['create', 'shop']), 2);
      expect(lines, contains('flutter: no SDK'));
      expect(runner.calls, hasLength(1));
    });

    test('pub get fails: the app is still made, with a hint', () async {
      expect(await cli(FakeRunner(pubGetExit: 1)).run(['create', 'shop']), 0);
      expect(lines.join('\n'), contains('run "flutter pub get" in shop'));
      expect(read('pubspec.yaml'), 'name: shop');
    });
  });

  group('bundled template', () {
    test('is found and has everything create copies', () async {
      final bundled = await Template.bundled();
      for (final entry in Template.entries) {
        final path = p.join(bundled.directory.path, entry);
        expect(
          FileSystemEntity.typeSync(path),
          isNot(FileSystemEntityType.notFound),
          reason: entry,
        );
      }
    });

    test('uses the placeholder package name', () async {
      final bundled = await Template.bundled();
      final pubspec = File(p.join(bundled.directory.path, 'pubspec.yaml'))
          .readAsStringSync();
      expect(pubspec, contains('name: ${Template.placeholder}'));
    });
  });
}
