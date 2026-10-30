import 'package:flutter/widgets.dart';

import 'brix_sheet_style.dart';

/// Builds an app's own sheet panel. brix keeps the rest: sliding up,
/// dragging down to close, the dimmed screen and the returned value.
typedef BrixSheetBuilder = Widget Function(
  BuildContext context,
  BrixSheetData sheet,
);

/// Everything a [BrixSheetBuilder] needs to draw a sheet.
class BrixSheetData {
  const BrixSheetData({
    required this.title,
    required this.child,
    required this.close,
    required this.style,
  });

  final String? title;

  /// The content the app passed to `BrixSheet.show`.
  final Widget child;

  /// Closes the sheet; `BrixSheet.show` returns [value].
  final void Function([Object? value]) close;

  /// The theme's sheet style with the sheet's own on top.
  final BrixSheetStyle style;
}
