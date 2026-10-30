import 'network_response.dart';

/// What a [ResponseReader] found in a server answer.
class ApiReply {
  const ApiReply({
    this.data,
    this.message,
    this.messages = const [],
    this.fieldErrors = const {},
    this.success,
  });

  /// The payload to parse into your model.
  final Object? data;

  /// The backend's main text, e.g. "Profile updated".
  final String? message;

  /// Error texts to show, most useful first.
  final List<String> messages;

  /// Problems per form field: `{'email': ['Already registered']}`.
  final Map<String, List<String>> fieldErrors;

  /// The body's own success flag (`"success": false` with status 200), or
  /// `null` when the body has none, then the status code decides.
  final bool? success;
}

/// Reads your backend's answer: where the data, the message and the errors
/// are. Pick the preset for your backend, or write your own:
///
/// ```dart
/// ResponseReader.envelope()     // {success, message, data, errors}
/// ResponseReader.fastApi()      // FastAPI: {detail: ...}
/// ResponseReader.djangoRest()   // Django REST: {field: [...], detail}
/// ResponseReader.custom((response) => ApiReply(data: ..., message: ...))
/// ```
abstract class ResponseReader {
  const ResponseReader();

  /// `{success, message, data, errors}` style, common for Node / Express,
  /// Laravel, NestJS and most custom APIs. Each key is configurable;
  /// [errorKeys] are tried in order and may be paths (`data.errors`).
  /// Errors may be a text, a list of texts, or a map of field to texts.
  const factory ResponseReader.envelope({
    String dataKey,
    String messageKey,
    String successKey,
    List<String> errorKeys,
  }) = EnvelopeReader;

  /// FastAPI: errors in `detail`, a text, or a list of
  /// `{loc: [..., field], msg}` (validation). Success bodies are the data.
  const factory ResponseReader.fastApi() = FastApiReader;

  /// Django REST Framework: errors as `{detail}`, `{non_field_errors: [...]}`
  /// or `{field: [...]}`. Success bodies are the data.
  const factory ResponseReader.djangoRest() = DjangoRestReader;

  /// Your own rules.
  const factory ResponseReader.custom(
    ApiReply Function(NetworkResponse response) read,
  ) = _CustomReader;

  ApiReply read(NetworkResponse response);
}

class EnvelopeReader extends ResponseReader {
  const EnvelopeReader({
    this.dataKey = 'data',
    this.messageKey = 'message',
    this.successKey = 'success',
    this.errorKeys = const ['errors', 'error'],
  });

  final String dataKey;
  final String messageKey;
  final String successKey;
  final List<String> errorKeys;

  @override
  ApiReply read(NetworkResponse response) {
    final body = response.body;
    if (body is! Map) return _plain(response);
    final errors = _Errors();
    for (final key in errorKeys) {
      errors.collect(_at(body, key));
    }
    final message = _text(body[messageKey]);
    final success = switch (body[successKey]) {
      final bool flag => flag,
      _ => null,
    };
    final failed = !response.isSuccessful || success == false;
    return ApiReply(
      data: body.containsKey(dataKey) ? body[dataKey] : null,
      message: message,
      // No detailed errors: the main message explains the failure.
      messages: failed && errors.isEmpty && message != null
          ? [message]
          : errors.messages,
      fieldErrors: errors.fields,
      success: success,
    );
  }
}

class FastApiReader extends ResponseReader {
  const FastApiReader();

  @override
  ApiReply read(NetworkResponse response) {
    final body = response.body;
    if (response.isSuccessful) return ApiReply(data: body);
    if (body is! Map) return _plain(response);
    final errors = _Errors();
    final detail = body['detail'];
    if (detail is List) {
      for (final item in detail) {
        if (item is Map) {
          final text = _text(item['msg']);
          if (text == null) continue;
          // `loc` is e.g. ['body', 'email']: the last part is the field.
          final loc = item['loc'];
          if (loc is List && loc.length >= 2) {
            errors.addField('${loc.last}', text);
          } else {
            errors.addMessage(text);
          }
        } else {
          errors.collect(item);
        }
      }
    } else {
      errors.collect(detail);
    }
    return ApiReply(messages: errors.messages, fieldErrors: errors.fields);
  }
}

class DjangoRestReader extends ResponseReader {
  const DjangoRestReader();

  @override
  ApiReply read(NetworkResponse response) {
    final body = response.body;
    if (response.isSuccessful) return ApiReply(data: body);
    if (body is! Map) return _plain(response);
    final errors = _Errors();
    for (final MapEntry(:key, :value) in body.entries) {
      if (key == 'detail' || key == 'non_field_errors') {
        errors.collect(value);
      } else {
        errors.collectField('$key', value);
      }
    }
    return ApiReply(messages: errors.messages, fieldErrors: errors.fields);
  }
}

class _CustomReader extends ResponseReader {
  const _CustomReader(this._read);

  final ApiReply Function(NetworkResponse response) _read;

  @override
  ApiReply read(NetworkResponse response) => _read(response);
}

/// A body that is not a JSON object: a list is data, a text on an error is
/// the message (e.g. a proxy's "Bad Gateway").
ApiReply _plain(NetworkResponse response) {
  final body = response.body;
  if (response.isSuccessful) return ApiReply(data: body);
  final text = body is String ? _text(body) : null;
  return ApiReply(messages: [?text]);
}

Object? _at(Map body, String path) {
  Object? current = body;
  for (final part in path.split('.')) {
    if (current is Map && current.containsKey(part)) {
      current = current[part];
    } else {
      return null;
    }
  }
  return current;
}

String? _text(Object? value) {
  if (value is! String) return null;
  final text = value.trim();
  // An HTML error page is no message for a user.
  if (text.isEmpty || text.startsWith('<')) return null;
  return text;
}

/// Collects error texts from any shape: text, list, or field to texts map.
class _Errors {
  final messages = <String>[];
  final fields = <String, List<String>>{};

  bool get isEmpty => messages.isEmpty;

  void addMessage(String text) {
    if (!messages.contains(text)) messages.add(text);
  }

  void addField(String field, String text) {
    final list = fields.putIfAbsent(field, () => []);
    if (!list.contains(text)) list.add(text);
    addMessage(text);
  }

  void collect(Object? value) {
    switch (value) {
      case String():
        if (_text(value) case final text?) addMessage(text);
      case List():
        for (final item in value) {
          collect(item);
        }
      case Map():
        for (final MapEntry(:key, :value) in value.entries) {
          collectField('$key', value);
        }
    }
  }

  void collectField(String field, Object? value) {
    switch (value) {
      case String():
        if (_text(value) case final text?) addField(field, text);
      case List():
        for (final item in value) {
          collectField(field, item);
        }
      case Map():
        // Nested objects (e.g. `address: {city: [...]}`) to `address.city`.
        for (final MapEntry(:key, :value) in value.entries) {
          collectField('$field.$key', value);
        }
    }
  }
}
