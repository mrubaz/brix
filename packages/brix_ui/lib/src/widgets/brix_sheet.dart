import 'package:flutter/material.dart';

import '../overlay/brix_ui.dart';
import '../theme/brix_theme.dart';
import '../theme/brix_theme_context.dart';
import 'brix_sheet_data.dart';
import 'brix_sheet_height.dart';
import 'brix_sheet_style.dart';

/// A panel that slides up from the bottom, like an iOS sheet: a grabber, an
/// optional title and any content (a list, a form, a few buttons). Drag it
/// down or tap outside to close it.
///
/// ```dart
/// final colour = await BrixSheet.show<String>(
///   title: 'Pick a colour',
///   builder: (context) => Column(children: [
///     ListTile(
///       title: const Text('Blue'),
///       onTap: () => BrixSheet.close(context, 'blue'),
///     ),
///   ]),
/// );
/// ```
///
/// Its look comes from `BrixTheme.sheet`; draw a completely own panel with
/// `BrixTheme.sheetBuilder`.
class BrixSheet extends StatelessWidget {
  const BrixSheet({
    super.key,
    this.title,
    required this.child,
    required this.onClose,
    this.height = BrixSheetHeight.content,
    this.style,
    this.builder,
  });

  final String? title;
  final Widget child;

  /// Closes the sheet with a value.
  final void Function([Object? value]) onClose;

  final BrixSheetHeight height;

  /// This sheet's look, on top of `BrixTheme.sheet`.
  final BrixSheetStyle? style;

  /// Draws this sheet instead of brix (wins over `BrixTheme.sheetBuilder`).
  final BrixSheetBuilder? builder;

  /// Opens a sheet with what [builder] makes and returns the value it was
  /// closed with (`null` when dragged down or tapped outside).
  static Future<T?> show<T>({
    BuildContext? context,
    required WidgetBuilder builder,
    String? title,
    BrixSheetHeight height = BrixSheetHeight.content,
    bool dismissible = true,
    BrixSheetStyle? style,
    BrixSheetBuilder? sheetBuilder,
  }) {
    final host = BrixUi.contextOf(context);
    final brix = BrixTheme.of(host);
    final look = brix.sheet.merge(style);
    return showModalBottomSheet<T>(
      context: host,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: dismissible,
      enableDrag: dismissible,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: look.scrimColor ?? brix.colors.scrim,
      constraints: BoxConstraints(maxWidth: look.maxWidth ?? 640),
      builder: (sheetContext) => BrixSheet(
        title: title,
        height: height,
        style: style,
        builder: sheetBuilder,
        onClose: ([value]) => Navigator.of(sheetContext).pop(value as T?),
        child: Builder(builder: builder),
      ),
    );
  }

  /// Closes the sheet that holds [context] and returns [value] from
  /// [show].
  static void close<T>(BuildContext context, [T? value]) =>
      Navigator.of(context).pop(value);

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final look = brix.sheet.merge(style);
    final custom = builder ?? brix.sheetBuilder;
    if (custom != null) {
      return custom(
        context,
        BrixSheetData(title: title, child: child, close: onClose, style: look),
      );
    }

    final screen = MediaQuery.sizeOf(context).height;
    final radius = Radius.circular(look.radius ?? brix.shape.radius + 6);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (look.showGrabber ?? true)
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 6, bottom: 4),
              width: 36,
              height: 5,
              decoration: BoxDecoration(
                color: look.grabberColor ?? brix.colors.border,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: brix.typography.title
                  .copyWith(fontSize: 17, color: brix.colors.text)
                  .merge(look.titleStyle),
            ),
          ),
        Flexible(
          child: SingleChildScrollView(
            padding: look.padding ?? const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: child,
          ),
        ),
      ],
    );

    return Semantics(
      scopesRoute: true,
      namesRoute: title != null,
      label: title,
      explicitChildNodes: true,
      child: Container(
        width: double.infinity,
        height: switch (height) {
          BrixSheetHeight.half => screen * 0.5,
          BrixSheetHeight.full => screen * 0.92,
          _ => null,
        },
        constraints: BoxConstraints(maxHeight: screen * 0.92),
        decoration: BoxDecoration(
          color: look.backgroundColor ?? brix.colors.surface,
          borderRadius: BorderRadius.vertical(top: radius),
        ),
        child: SafeArea(
          top: false,
          child: Material(type: MaterialType.transparency, child: body),
        ),
      ),
    );
  }
}
