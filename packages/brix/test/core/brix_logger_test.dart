import 'package:brix/core.dart';
import 'package:test/test.dart';

void main() {
  late List<String> lines;

  BrixLogger logger({
    bool enabled = true,
    LogLevel minLevel = LogLevel.debug,
  }) => BrixLogger(
    name: 'App',
    enabled: enabled,
    minLevel: minLevel,
    colors: false,
    stackLines: 2,
    output: lines.add,
  );

  setUp(() => lines = []);

  test('one line per message: time, level, name, text', () {
    logger().info('Logged in');

    expect(
      lines.single,
      matches(RegExp(r'^\d\d:\d\d:\d\d\.\d{3}  ✓ INFO   App  Logged in$')),
    );
  });

  test('an error shows the error and a short stack', () {
    logger().error(
      'Saving failed',
      error: StateError('boom'),
      stackTrace: StackTrace.fromString('#0 a\n#1 b\n#2 c\n#3 d'),
    );

    expect(lines[0], contains('✗ ERROR  App  Saving failed'));
    expect(lines[1], contains('↳ Bad state: boom'));
    expect(lines.sublist(2).map((line) => line.trim()), ['#0 a', '#1 b']);
  });

  test('below minLevel or disabled: nothing', () {
    logger(minLevel: LogLevel.warning).info('skip');
    logger(enabled: false).error('skip');

    expect(lines, isEmpty);
  });

  test('banner box', () {
    logger().banner('Pristine', details: {'env': 'staging'});

    expect(lines.first, startsWith('╔'));
    expect(lines[1], '║ Pristine     ║');
    expect(lines[2], '║ env: staging ║');
    expect(lines.last, startsWith('╚'));
  });
}
