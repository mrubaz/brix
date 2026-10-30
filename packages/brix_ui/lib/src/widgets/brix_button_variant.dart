/// Which kind of `BrixButton` it is. A class with `const` values, not an
/// enum: switch on it with a default case, so kinds added later never break
/// an app's own button builder.
///
/// ```dart
/// switch (button.variant) {
///   BrixButtonVariant.destructive => Colors.red,
///   _ => brandColor,
/// }
/// ```
class BrixButtonVariant {
  const BrixButtonVariant._(this.name);

  /// The main action, filled with `colors.primary`.
  static const filled = BrixButtonVariant._('filled');

  /// The quieter second action, outlined in `colors.primary`.
  static const outlined = BrixButtonVariant._('outlined');

  /// Delete, log out, filled with `colors.danger`.
  static const destructive = BrixButtonVariant._('destructive');

  final String name;

  @override
  String toString() => 'BrixButtonVariant.$name';
}
