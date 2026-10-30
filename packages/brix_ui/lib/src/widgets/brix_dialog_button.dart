/// A button in a `BrixDialog`: its [label] and the [value] `BrixDialog.show`
/// returns when it is tapped.
///
/// - `BrixDialogButton`, outlined, the quiet choice (Cancel).
/// - `BrixDialogButton.primary`, filled, the main choice.
/// - `BrixDialogButton.destructive`, filled red (Delete, Log out).
class BrixDialogButton<T> {
  const BrixDialogButton({required this.label, this.value})
    : isPrimary = false,
      isDestructive = false;

  const BrixDialogButton.primary({required this.label, this.value})
    : isPrimary = true,
      isDestructive = false;

  const BrixDialogButton.destructive({required this.label, this.value})
    : isPrimary = false,
      isDestructive = true;

  final String label;
  final T? value;
  final bool isPrimary;
  final bool isDestructive;
}
