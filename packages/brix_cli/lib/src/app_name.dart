/// Checks a new app's name: it becomes the Dart package name, so it must be
/// lowercase letters, digits and underscores, start with a letter and not
/// be a Dart keyword.
abstract final class AppName {
  static final _pattern = RegExp(r'^[a-z][a-z0-9_]*$');

  static const _reserved = {
    'abstract', 'as', 'assert', 'async', 'await', 'base', 'break', 'case',
    'catch', 'class', 'const', 'continue', 'covariant', 'default',
    'deferred', 'do', 'dynamic', 'else', 'enum', 'export', 'extends',
    'extension', 'external', 'factory', 'false', 'final', 'finally', 'for',
    'function', 'get', 'hide', 'if', 'implements', 'import', 'in',
    'interface', 'is', 'late', 'library', 'mixin', 'new', 'null', 'of',
    'on', 'operator', 'part', 'required', 'rethrow', 'return', 'sealed',
    'set', 'show', 'static', 'super', 'switch', 'sync', 'this', 'throw',
    'true', 'try', 'type', 'typedef', 'var', 'void', 'when', 'while',
    'with', 'yield',
    // Would clash with the packages the app depends on.
    'flutter', 'brix', 'brix_getx', 'brix_network', 'brix_storage',
    'brix_ui', 'test',
  };

  /// `null` when [name] is fine, else why it is not.
  static String? problem(String name) {
    if (!_pattern.hasMatch(name)) {
      return 'Use lowercase letters, digits and underscores, starting with '
          'a letter (for example my_app).';
    }
    if (_reserved.contains(name)) {
      return '"$name" is a reserved word or a package name. Pick another.';
    }
    return null;
  }
}
