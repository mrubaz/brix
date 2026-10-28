import 'package:brix/auth.dart';
import 'package:test/test.dart';

void main() {
  const policy = PasswordPolicy();

  test('default: 8 characters, capital, small, number, special', () {
    expect(policy.rules, [
      PasswordRule.minLength,
      PasswordRule.uppercase,
      PasswordRule.lowercase,
      PasswordRule.digit,
      PasswordRule.symbol,
    ]);
  });

  test('a strong password meets every rule', () {
    expect(policy.unmetRules('Asdf@_1234'), isEmpty);
    expect(policy.allows('Asdf@_1234'), isTrue);
  });

  test('each missing part is reported', () {
    expect(policy.unmetRules(''), policy.rules);
    expect(policy.unmetRules('Asdf@_1'), [PasswordRule.minLength]);
    expect(policy.unmetRules('asdf@_1234'), [PasswordRule.uppercase]);
    expect(policy.unmetRules('ASDF@_1234'), [PasswordRule.lowercase]);
    expect(policy.unmetRules('Asdf@_abcd'), [PasswordRule.digit]);
    expect(policy.unmetRules('Asdf12345'), [PasswordRule.symbol]);
  });

  test('a space is not a special character', () {
    expect(policy.unmetRules('Asdf 12345'), [PasswordRule.symbol]);
  });

  test('switched off rules are not checked', () {
    const lengthOnly = PasswordPolicy(
      minLength: 6,
      requireUppercase: false,
      requireLowercase: false,
      requireDigit: false,
      requireSymbol: false,
    );

    expect(lengthOnly.rules, [PasswordRule.minLength]);
    expect(lengthOnly.allows('abcdef'), isTrue);
    expect(lengthOnly.allows('abcde'), isFalse);
  });

  test('each rule has a default label, length filled from the policy', () {
    expect(PasswordRule.minLength.labelFor(policy), 'At least 8 characters');
    expect(
      PasswordRule.minLength.labelFor(const PasswordPolicy(minLength: 12)),
      'At least 12 characters',
    );
    for (final rule in PasswordRule.values) {
      expect(rule.labelFor(policy), isNotEmpty, reason: rule.name);
    }
  });
}
