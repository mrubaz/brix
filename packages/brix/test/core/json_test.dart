import 'package:brix/core.dart';
import 'package:test/test.dart';

void main() {
  late List<String> problems;

  setUp(() {
    problems = [];
    Json.onProblem = (path, problem) => problems.add('$path: $problem');
  });

  tearDown(() => Json.onProblem = null);

  final user = Json({
    'id': 'u1',
    'age': '31', // a number sent as text (common in Django / PHP backends)
    'score': 4.5,
    'count': 3.0,
    'active': 1,
    'verified': 'false',
    'createdAt': '2026-10-28T10:00:00Z',
    'updatedAt': 1793174400000, // epoch milliseconds (Firebase style)
    'profile': {'firstName': 'Ada', 'lastName': null},
    'roles': [
      {'name': 'admin'},
      'not an object',
      {'name': 'viewer'},
    ],
    'tags': ['a', 2, null, true],
  });

  group('reading values', () {
    test('text, numbers, booleans and dates are converted safely', () {
      expect(user.string('id'), 'u1');
      expect(user.integer('age'), 31);
      expect(user.decimal('score'), 4.5);
      expect(user.integer('count'), 3);
      expect(user.boolean('active'), isTrue);
      expect(user.boolean('verified'), isFalse);
      expect(user.dateOrNull('createdAt'), DateTime.utc(2026, 10, 28, 10));
      expect(
        user.dateOrNull('updatedAt'),
        DateTime.fromMillisecondsSinceEpoch(1793174400000),
      );
      expect(problems, isEmpty);
    });

    test('numbers and booleans read as text', () {
      expect(user.string('score'), '4.5');
      expect(user.string('active'), '1');
    });

    test('nested values by path or child', () {
      expect(user.string('profile.firstName'), 'Ada');
      expect(user.child('profile').string('firstName'), 'Ada');
      expect(user.stringOrNull('profile.lastName'), isNull);
      expect(problems, isEmpty);
    });

    test('lists of objects skip and report items that are not objects', () {
      final names = user.list('roles', (role) => role.string('name'));

      expect(names, ['admin', 'viewer']);
      expect(user.strings('tags'), ['a', '2', 'true']);
    });

    test('a top-level list reads with items, paths per item', () {
      final paths = <String>[];
      Json([
        {'id': 1},
        {'id': 2},
      ]).items((item) {
        paths.add(item.path);
        return item.integer('id');
      });

      expect(paths, ['[0]', '[1]']);
    });
  });

  group('never throws', () {
    test('missing keys give the fallback and are reported', () {
      expect(user.string('email'), '');
      expect(user.string('email', 'none'), 'none');
      expect(user.integer('missing', 7), 7);
      expect(user.list('missing', (json) => json), isEmpty);
      expect(problems, [
        'email: missing',
        'email: missing',
        'missing: missing',
        'missing: missing',
      ]);
    });

    test('OrNull readers stay silent when the key is missing', () {
      expect(user.stringOrNull('email'), isNull);
      expect(user.integerOrNull('missing'), isNull);
      expect(user.dateOrNull('missing'), isNull);
      expect(problems, isEmpty);
    });

    test(
      'a value that cannot be converted gives the fallback and a report',
      () {
        final json = Json({'age': 'thirty', 'when': 'yesterday'});

        expect(json.integer('age'), 0);
        expect(json.dateOrNull('when'), isNull);
        expect(problems, [
          'age: expected a whole number, got String "thirty"',
          'when: expected a date, got String "yesterday"',
        ]);
      },
    );

    test('reading from null, a list or a text does not throw', () {
      for (final raw in <Object?>[null, [], 'text', 42]) {
        final json = Json(raw);
        expect(json.string('a'), '');
        expect(json.child('a').integer('b'), 0);
        expect(json.items((item) => item), isEmpty);
      }
    });

    test('nested reports carry the full path', () {
      Json({
        'roles': [
          {'level': 'high'},
        ],
      }).list('roles', (role) => role.integer('level'));

      expect(problems, [
        'roles[0].level: expected a whole number, got String "high"',
      ]);
    });
  });

  test('toString never shows values (tokens, personal data)', () {
    final json = Json({'accessToken': 'secret-token'});

    expect(json.toString(), isNot(contains('secret-token')));
  });
}
