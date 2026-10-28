/// One requirement of a [PasswordPolicy], for a live checklist on screen.
///
/// Not an enum on purpose: apps `switch` with a default case (or just show
/// [labelFor]), so rules added to brix later never break them.
class PasswordRule {
  const PasswordRule._(this.name, this._label);

  /// Stable id, e.g. for logs or tests.
  final String name;
  final String _label;

  static const minLength = PasswordRule._(
    'minLength',
    'At least {n} characters',
  );
  static const uppercase = PasswordRule._(
    'uppercase',
    'One capital letter (A-Z)',
  );
  static const lowercase = PasswordRule._(
    'lowercase',
    'One small letter (a-z)',
  );
  static const digit = PasswordRule._('digit', 'One number (0-9)');
  static const symbol = PasswordRule._(
    'symbol',
    'One special character (e.g. @ # _ -)',
  );

  static const values = [minLength, uppercase, lowercase, digit, symbol];

  /// Default English text for a checklist, with [policy]'s numbers filled in.
  String labelFor(PasswordPolicy policy) =>
      _label.replaceAll('{n}', '${policy.minLength}');

  @override
  String toString() => 'PasswordRule($name)';
}

/// What a new password must contain (signup, reset, change password).
///
/// Never applied on login: accounts made under an older, weaker policy must
/// still be able to log in.
class PasswordPolicy {
  const PasswordPolicy({
    this.minLength = 8,
    this.requireUppercase = true,
    this.requireLowercase = true,
    this.requireDigit = true,
    this.requireSymbol = true,
  }) : assert(minLength > 0, 'minLength must be positive');

  final int minLength;
  final bool requireUppercase;
  final bool requireLowercase;
  final bool requireDigit;

  /// Anything that is not a letter, digit or space counts (`@`, `_`, `-`…).
  final bool requireSymbol;

  static final _uppercase = RegExp(r'[A-Z]');
  static final _lowercase = RegExp(r'[a-z]');
  static final _digit = RegExp(r'\d');
  static final _symbol = RegExp(r'[^A-Za-z0-9\s]');

  /// Every rule this policy uses, in checklist order.
  List<PasswordRule> get rules => [
    PasswordRule.minLength,
    if (requireUppercase) PasswordRule.uppercase,
    if (requireLowercase) PasswordRule.lowercase,
    if (requireDigit) PasswordRule.digit,
    if (requireSymbol) PasswordRule.symbol,
  ];

  /// The rules [password] does not meet yet; empty when it is allowed.
  List<PasswordRule> unmetRules(String password) => [
    for (final rule in rules)
      if (!_meets(rule, password)) rule,
  ];

  bool allows(String password) => unmetRules(password).isEmpty;

  bool _meets(PasswordRule rule, String password) => switch (rule) {
    PasswordRule.minLength => password.length >= minLength,
    PasswordRule.uppercase => _uppercase.hasMatch(password),
    PasswordRule.lowercase => _lowercase.hasMatch(password),
    PasswordRule.digit => _digit.hasMatch(password),
    PasswordRule.symbol => _symbol.hasMatch(password),
    _ => true,
  };
}
