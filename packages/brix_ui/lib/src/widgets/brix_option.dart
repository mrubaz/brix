import '../theme/brix_icon.dart';

/// One choice in a `BrixSelect`: the [value] the app gets and the [label]
/// people see.
class BrixOption<T> {
  const BrixOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;

  /// Shown before the label in the menu and the sheet.
  final BrixIcon? icon;
}
