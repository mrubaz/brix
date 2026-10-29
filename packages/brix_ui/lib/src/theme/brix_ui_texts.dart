/// Every text brix_ui shows on its own. English by default; pass your own
/// for another language or wording.
///
/// ```dart
/// BrixTheme.light(texts: const BrixUiTexts(ok: 'ٹھیک ہے'))
/// ```
class BrixUiTexts {
  const BrixUiTexts({
    this.ok = 'OK',
    this.warningTitle = 'Please check',
    this.errorTitle = 'Something went wrong',
    this.showPassword = 'Show password',
    this.hidePassword = 'Hide password',
    this.requiredField = 'This field is required.',
  });

  /// The button that closes an alert.
  final String ok;

  /// Title of `BrixAlert.warning` when none is given.
  final String warningTitle;

  /// Title of `BrixAlert.error` when none is given.
  final String errorTitle;

  /// Password field button, while the text is hidden.
  final String showPassword;

  /// Password field button, while the text is shown.
  final String hidePassword;

  /// Error of a required `BrixTextField` left empty.
  final String requiredField;

  BrixUiTexts copyWith({
    String? ok,
    String? warningTitle,
    String? errorTitle,
    String? showPassword,
    String? hidePassword,
    String? requiredField,
  }) {
    return BrixUiTexts(
      ok: ok ?? this.ok,
      warningTitle: warningTitle ?? this.warningTitle,
      errorTitle: errorTitle ?? this.errorTitle,
      showPassword: showPassword ?? this.showPassword,
      hidePassword: hidePassword ?? this.hidePassword,
      requiredField: requiredField ?? this.requiredField,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixUiTexts &&
      other.ok == ok &&
      other.warningTitle == warningTitle &&
      other.errorTitle == errorTitle &&
      other.showPassword == showPassword &&
      other.hidePassword == hidePassword &&
      other.requiredField == requiredField;

  @override
  int get hashCode => Object.hash(
    ok,
    warningTitle,
    errorTitle,
    showPassword,
    hidePassword,
    requiredField,
  );
}
