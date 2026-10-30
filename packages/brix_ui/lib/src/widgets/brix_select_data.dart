import 'package:flutter/widgets.dart';

import 'brix_option.dart';
import 'brix_select_style.dart';

/// Builds an app's own select field. brix keeps the rest: opening the menu
/// or sheet, the required check and telling the app what was chosen.
typedef BrixSelectBuilder<T> = Widget Function(
  BuildContext context,
  BrixSelectData<T> select,
);

/// Everything a [BrixSelectBuilder] needs to draw a select field.
class BrixSelectData<T> {
  const BrixSelectData({
    required this.label,
    required this.hint,
    required this.value,
    required this.selected,
    required this.options,
    required this.open,
    required this.errorText,
    required this.isRequired,
    required this.enabled,
    required this.style,
  });

  final String? label;
  final String hint;
  final T? value;

  /// The option of [value], or `null` when nothing is chosen.
  final BrixOption<T>? selected;

  final List<BrixOption<T>> options;

  /// Shows the options; `null` when the select is disabled.
  final VoidCallback? open;

  /// The validator's message or the app's `errorText`.
  final String? errorText;

  final bool isRequired;
  final bool enabled;
  final BrixSelectStyle style;
}
