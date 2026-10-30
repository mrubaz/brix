/// A safe way to read decoded JSON (from any backend: REST, Firebase,
/// Supabase, ...) into your own models.
///
/// Reading never throws. A missing key or a value of the wrong type gives
/// the fallback (or `null` for the `...OrNull` readers), and is reported to
/// [Json.onProblem] so you see it while developing. Values are converted
/// when it is safe: `"12"` to 12, `12` to "12", `"true"` / `1` to true,
/// ISO text or epoch milliseconds to [DateTime].
///
/// Keys may be paths: `json.string('profile.firstName')`.
///
/// ```dart
/// factory User.fromJson(Json json) => User(
///   id: json.string('id'),
///   name: json.string('profile.firstName'),
///   age: json.integer('age'),
///   createdAt: json.dateOrNull('createdAt'),
///   roles: json.list('roles', Role.fromJson),
/// );
///
/// final user = User.fromJson(Json(jsonDecode(body)));
/// ```
class Json {
  /// Wraps a decoded JSON value (usually a `Map` or a `List`).
  Json(this.raw) : path = '';

  Json._(this.raw, this.path);

  /// The decoded value as it is.
  final Object? raw;

  /// Where this value sits in the document, e.g. `profile.roles[0]`; empty
  /// for the top.
  final String path;

  /// Called for every key that is missing or has a type that cannot be
  /// converted, with its path and what went wrong. `null` (the default)
  /// stays silent. Point it at your logger while developing:
  /// `Json.onProblem = (path, problem) => log('JSON $path: $problem');`
  static void Function(String path, String problem)? onProblem;

  /// Whether [key] is present (a value, even `null`).
  bool has(String key) => _lookup(key).found;

  /// The value at [key] as raw data, or `null`.
  Object? value(String key) => _lookup(key).value;

  /// The object at [key], for reading nested values (an empty one when it
  /// is missing).
  Json child(String key) {
    final found = _lookup(key);
    if (!found.found) _report(key, 'missing');
    return Json._(found.value, _join(key));
  }

  /// Text at [key]. Numbers and booleans are turned into text.
  String string(String key, [String fallback = '']) =>
      _required(key, _toString, 'text') ?? fallback;

  String? stringOrNull(String key) => _optional(key, _toString, 'text');

  /// Whole number at [key]. Accepts `12`, `12.0` and `"12"`.
  int integer(String key, [int fallback = 0]) =>
      _required(key, _toInt, 'a whole number') ?? fallback;

  int? integerOrNull(String key) => _optional(key, _toInt, 'a whole number');

  /// Number at [key]. Accepts `1`, `1.5` and `"1.5"`.
  double decimal(String key, [double fallback = 0]) =>
      _required(key, _toDouble, 'a number') ?? fallback;

  double? decimalOrNull(String key) => _optional(key, _toDouble, 'a number');

  /// `true` / `false` at [key]. Also accepts `"true"`, `"false"`, `1`, `0`.
  bool boolean(String key, [bool fallback = false]) =>
      _required(key, _toBool, 'true / false') ?? fallback;

  bool? booleanOrNull(String key) => _optional(key, _toBool, 'true / false');

  /// Date at [key]: ISO 8601 text or epoch milliseconds.
  DateTime? dateOrNull(String key) => _optional(key, _toDate, 'a date');

  /// The list at [key], each item read with [parse]. Items that are not
  /// objects are skipped and reported. Missing to empty list.
  List<T> list<T>(String key, T Function(Json json) parse) {
    final found = _lookup(key);
    if (!found.found || found.value == null) {
      if (!found.found) _report(key, 'missing');
      return const [];
    }
    return Json._(found.value, _join(key)).items(parse);
  }

  /// A list of texts at [key] (numbers turned into text).
  List<String> strings(String key) {
    final found = _lookup(key);
    final value = found.value;
    if (value is! List) {
      if (found.found && value != null) _report(key, 'expected a list');
      return const [];
    }
    return [for (final item in value) ?_toString(item)];
  }

  /// When this value itself is a list: each item read with [parse].
  List<T> items<T>(T Function(Json json) parse) {
    final value = raw;
    if (value is! List) {
      if (value != null) _reportSelf('expected a list');
      return const [];
    }
    return [
      for (var i = 0; i < value.length; i++)
        if (value[i] is Map) parse(Json._(value[i], '$path[$i]')),
    ];
  }

  // ---------------------------------------------------------------------

  ({bool found, Object? value}) _lookup(String key) {
    Object? current = raw;
    for (final part in key.split('.')) {
      if (current is Map && current.containsKey(part)) {
        current = current[part];
      } else {
        return (found: false, value: null);
      }
    }
    return (found: true, value: current);
  }

  T? _required<T>(String key, T? Function(Object?) convert, String type) {
    final found = _lookup(key);
    if (!found.found) {
      _report(key, 'missing');
      return null;
    }
    return _convert(key, found.value, convert, type);
  }

  T? _optional<T>(String key, T? Function(Object?) convert, String type) {
    final found = _lookup(key);
    if (!found.found) return null;
    return _convert(key, found.value, convert, type);
  }

  T? _convert<T>(
    String key,
    Object? value,
    T? Function(Object?) convert,
    String type,
  ) {
    if (value == null) return null;
    final converted = convert(value);
    if (converted == null) {
      _report(key, 'expected $type, got ${value.runtimeType} "$value"');
    }
    return converted;
  }

  String _join(String key) => path.isEmpty ? key : '$path.$key';

  void _report(String key, String problem) =>
      onProblem?.call(_join(key), problem);

  void _reportSelf(String problem) =>
      onProblem?.call(path.isEmpty ? '(root)' : path, problem);

  static String? _toString(Object? value) => switch (value) {
    String() => value,
    num() || bool() => '$value',
    _ => null,
  };

  static int? _toInt(Object? value) => switch (value) {
    int() => value,
    double() when value == value.roundToDouble() => value.toInt(),
    String() => int.tryParse(value.trim()),
    _ => null,
  };

  static double? _toDouble(Object? value) => switch (value) {
    num() => value.toDouble(),
    String() => double.tryParse(value.trim()),
    _ => null,
  };

  static bool? _toBool(Object? value) => switch (value) {
    bool() => value,
    1 => true,
    0 => false,
    String() => switch (value.trim().toLowerCase()) {
      'true' || '1' => true,
      'false' || '0' => false,
      _ => null,
    },
    _ => null,
  };

  static DateTime? _toDate(Object? value) => switch (value) {
    String() => DateTime.tryParse(value.trim()),
    int() => DateTime.fromMillisecondsSinceEpoch(value),
    _ => null,
  };

  /// Shows the shape, not the values, a [Json] may hold tokens or
  /// personal data that must not reach a log.
  @override
  String toString() =>
      'Json(${path.isEmpty ? '' : '$path: '}${raw.runtimeType})';
}
