import 'package:brix/core.dart';
import 'package:test/test.dart';

void main() {
  late List<String> lines;

  BrixLogger logger({
    bool enabled = true,
    LogLevel minLevel = LogLevel.debug,
    bool colors = false,
    String name = 'App',
  }) => BrixLogger(
    name: name,
    enabled: enabled,
    minLevel: minLevel,
    colors: colors,
    stackLines: 2,
    width: 40,
    output: lines.add,
  );

  setUp(() => lines = []);

  test('one box per message: level, name, time, text', () {
    logger().info('Logged in');

    expect(lines, hasLength(3));
    expect(
      lines[0],
      matches(RegExp(r'^╭─ ▰ \[INFO\] · App ─+ \d\d:\d\d:\d\d\.\d{3}$')),
    );
    expect(lines[0].length, 40);
    expect(lines[1], '│ Logged in');
    expect(lines[2], '╰${'─' * 39}');
  });

  test('messages one after another stay in separate boxes', () {
    logger()
      ..info('one')
      ..info('two');

    expect(lines.where((line) => line.startsWith('╭')), hasLength(2));
    expect(lines.where((line) => line.startsWith('╰')), hasLength(2));
    expect(lines[3], startsWith('╭'));
  });

  test('each level has its own label; success is logged at info', () {
    logger()
      ..debug('d')
      ..success('s')
      ..warning('w')
      ..error('e');

    final titles = lines.where((line) => line.startsWith('╭')).toList();
    expect(titles[0], contains('[DEBUG]'));
    expect(titles[1], contains('[SUCCESS]'));
    expect(titles[2], contains('[WARN]'));
    expect(titles[3], contains('[ERROR]'));

    lines.clear();
    logger(minLevel: LogLevel.warning).success('skipped like info');
    expect(lines, isEmpty);
  });

  test('a multi-line message keeps every line inside the box', () {
    logger().info('first\nsecond');

    expect(lines.sublist(1, 3), ['│ first', '│ second']);
  });

  test('an error shows the error and a short stack', () {
    logger().error(
      'Saving failed',
      error: StateError('boom'),
      stackTrace: StackTrace.fromString('#0 a\n#1 b\n#2 c\n#3 d'),
    );

    expect(lines[1], '│ Saving failed');
    expect(lines[2], '│ ↳ Bad state: boom');
    expect(lines.sublist(3, 5), ['│   #0 a', '│   #1 b']);
    expect(lines.last, startsWith('╰'));
  });

  test('without a name the title has only the level', () {
    logger(name: '').warning('w');

    expect(lines[0], startsWith('╭─ ▰ [WARN] ─'));
  });

  test('colours: badge and text per level, brix mark in orange', () {
    logger(colors: true).error('e');

    expect(lines[0], contains('\x1B[38;5;202m▰'));
    expect(lines[0], contains('\x1B[1;97;41m ERROR \x1B[0m'));
    expect(lines[1], contains('\x1B[31me\x1B[0m'));

    lines.clear();
    logger(colors: true).info('i');
    expect(lines[0], contains('\x1B[1;97;44m INFO \x1B[0m'));

    lines.clear();
    logger(colors: true).success('s');
    expect(lines[0], contains('\x1B[1;30;42m SUCCESS \x1B[0m'));
  });

  test('below minLevel or disabled: nothing', () {
    logger(minLevel: LogLevel.warning).info('skip');
    logger(enabled: false).error('skip');

    expect(lines, isEmpty);
  });

  test('banner: brix mark beside the title and details', () {
    logger().banner('Pristine', details: {'env': 'staging'});

    expect(lines.first, startsWith('╭'));
    expect(lines[1], '│  ▆▆▆▆▆▆▆   brix · Pristine  │');
    expect(lines[2], '│  ▆▆▆ ▆▆▆   env: staging     │');
    expect(lines.last, startsWith('╰'));
    expect(lines.map((line) => line.length).toSet(), hasLength(1));
  });
}
