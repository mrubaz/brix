/// A button in a `BrixAlert`: its [label] and the [value] `BrixAlert.show`
/// returns when it is tapped.
///
/// - `BrixAlertButton`, outlined, the quiet choice (Cancel).
/// - `BrixAlertButton.primary`, filled, the main choice.
/// - `BrixAlertButton.destructive`, filled red (Delete, Log out).
class BrixAlertButton<T> {
  const BrixAlertButton({required this.label, this.value})
    : isPrimary = false,
      isDestructive = false;

  const BrixAlertButton.primary({required this.label, this.value})
    : isPrimary = true,
      isDestructive = false;

  const BrixAlertButton.destructive({required this.label, this.value})
    : isPrimary = false,
      isDestructive = true;

  final String label;
  final T? value;
  final bool isPrimary;
  final bool isDestructive;
}
