/// Checks and converts app ids such as `com.mycompany.my_app`.
abstract final class AppId {
  static final _segment = RegExp(r'^[a-z][a-z0-9_]*$');

  /// `null` when [id] is fine, else why it is not. An id has at least two
  /// parts of lowercase letters, digits and underscores, each starting with
  /// a letter.
  static String? problem(String id) {
    final parts = id.split('.');
    if (parts.length < 2 || parts.any((part) => !_segment.hasMatch(part))) {
      return 'Use parts of lowercase letters, digits and underscores, '
          'joined by dots (for example com.mycompany.my_app).';
    }
    return null;
  }

  /// `null` when [org] is fine for `--org`, else why it is not.
  static String? orgProblem(String org) {
    final parts = org.split('.');
    if (parts.any((part) => !_segment.hasMatch(part))) {
      return 'Use parts of lowercase letters, digits and underscores, '
          'joined by dots (for example com.mycompany).';
    }
    return null;
  }

  /// The iOS / macOS form of [id]: Apple ids allow no underscores, so
  /// `com.my_company.my_app` becomes `com.myCompany.myApp`, like
  /// `flutter create` does.
  static String apple(String id) => id
      .split('.')
      .map(
        (part) => part.replaceAllMapped(
          RegExp(r'_([a-z0-9])'),
          (m) => m[1]!.toUpperCase(),
        ),
      )
      .join('.');
}
