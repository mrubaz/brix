import 'package:flutter/material.dart';

import '../widgets/brix_dialog_data.dart';
import '../widgets/brix_dialog_style.dart';
import '../widgets/brix_button_data.dart';
import '../widgets/brix_button_style.dart';
import '../widgets/brix_loader_data.dart';
import '../widgets/brix_loader_style.dart';
import '../widgets/brix_select_data.dart';
import '../widgets/brix_select_style.dart';
import '../widgets/brix_sheet_data.dart';
import '../widgets/brix_sheet_style.dart';
import '../widgets/brix_text_field_data.dart';
import '../widgets/brix_text_field_style.dart';
import '../widgets/brix_toast_data.dart';
import '../widgets/brix_toast_style.dart';
import 'brix_colors.dart';
import 'brix_shape.dart';
import 'brix_typography.dart';
import 'brix_ui_icons.dart';
import 'brix_ui_texts.dart';

/// Everything brix widgets need to look right: [colors], [typography] and
/// [shape]. Lives in `ThemeData.extensions`, so `theme` / `darkTheme` /
/// `themeMode` switch it and Flutter animates the change.
///
/// ```dart
/// MaterialApp(
///   theme: BrixTheme.light(colors: BrixColors.light(primary: brand)).toThemeData(),
///   darkTheme: BrixTheme.dark(colors: BrixColors.dark(primary: brand)).toThemeData(),
/// )
/// ```
///
/// An app with its own `ThemeData` adds the theme to it instead:
/// `ThemeData(extensions: [BrixTheme.light()])`.
class BrixTheme extends ThemeExtension<BrixTheme> {
  BrixTheme.light({
    BrixColors? colors,
    BrixTypography? typography,
    this.shape = const BrixShape(),
    this.glass = false,
    this.texts = const BrixUiTexts(),
    this.icons = const BrixUiIcons(),
    this.button = const BrixButtonStyle(),
    this.buttonBuilder,
    this.textField = const BrixTextFieldStyle(),
    this.textFieldBuilder,
    this.dialog = const BrixDialogStyle(),
    this.dialogBuilder,
    this.toast = const BrixToastStyle(),
    this.toastBuilder,
    this.loader = const BrixLoaderStyle(),
    this.loaderBuilder,
    this.sheet = const BrixSheetStyle(),
    this.sheetBuilder,
    this.select = const BrixSelectStyle(),
    this.selectBuilder,
  }) : brightness = Brightness.light,
       colors = colors ?? const BrixColors.light(),
       typography = typography ?? BrixTypography();

  BrixTheme.dark({
    BrixColors? colors,
    BrixTypography? typography,
    this.shape = const BrixShape(),
    this.glass = false,
    this.texts = const BrixUiTexts(),
    this.icons = const BrixUiIcons(),
    this.button = const BrixButtonStyle(),
    this.buttonBuilder,
    this.textField = const BrixTextFieldStyle(),
    this.textFieldBuilder,
    this.dialog = const BrixDialogStyle(),
    this.dialogBuilder,
    this.toast = const BrixToastStyle(),
    this.toastBuilder,
    this.loader = const BrixLoaderStyle(),
    this.loaderBuilder,
    this.sheet = const BrixSheetStyle(),
    this.sheetBuilder,
    this.select = const BrixSelectStyle(),
    this.selectBuilder,
  }) : brightness = Brightness.dark,
       colors = colors ?? const BrixColors.dark(),
       typography = typography ?? BrixTypography();

  const BrixTheme._({
    required this.brightness,
    required this.colors,
    required this.typography,
    required this.shape,
    required this.glass,
    required this.texts,
    required this.icons,
    required this.button,
    required this.buttonBuilder,
    required this.textField,
    required this.textFieldBuilder,
    required this.dialog,
    required this.dialogBuilder,
    required this.toast,
    required this.toastBuilder,
    required this.loader,
    required this.loaderBuilder,
    required this.sheet,
    required this.sheetBuilder,
    required this.select,
    required this.selectBuilder,
  });

  /// Whether this is the light or the dark theme.
  final Brightness brightness;

  final BrixColors colors;
  final BrixTypography typography;
  final BrixShape shape;

  /// Frosted (blurred, see-through) dialogs and toasts instead of solid
  /// cards. Off by default: a solid card reads on any screen colour.
  final bool glass;

  /// Texts brix_ui shows on its own (OK, default dialog titles...).
  final BrixUiTexts texts;

  /// Icons brix_ui shows on its own (dialogs, toast, password button).
  final BrixUiIcons icons;

  /// How every `BrixButton` looks; a button's own `style` goes on top.
  final BrixButtonStyle button;

  /// Draws every `BrixButton` with the app's own widget; brix keeps the
  /// logic. A button's own `builder` wins.
  final BrixButtonBuilder? buttonBuilder;

  /// How every `BrixTextField` looks; a field's own `style` goes on top.
  final BrixTextFieldStyle textField;

  /// Draws every `BrixTextField` with the app's own widget; brix keeps the
  /// logic. A field's own `builder` wins.
  final BrixTextFieldBuilder? textFieldBuilder;

  /// How every `BrixDialog` looks; `BrixDialog.show(style: ...)` goes on top.
  final BrixDialogStyle dialog;

  /// Draws every dialog card with the app's own widget; brix keeps the
  /// dimmed screen, animation and returned value.
  final BrixDialogBuilder? dialogBuilder;

  /// How every `BrixToast` looks: position, duration, size, text.
  final BrixToastStyle toast;

  /// Draws every toast card with the app's own widget; brix keeps the
  /// timer, placing and swiping.
  final BrixToastBuilder? toastBuilder;

  /// Size and colour of every `BrixLoader`.
  final BrixLoaderStyle loader;

  /// Draws every spinner (also inside loading buttons) with the app's own
  /// widget.
  final BrixLoaderBuilder? loaderBuilder;

  /// How every `BrixSheet` looks; `BrixSheet.show(style: ...)` goes on top.
  final BrixSheetStyle sheet;

  /// Draws every sheet panel with the app's own widget; brix keeps the
  /// sliding, dragging and returned value.
  final BrixSheetBuilder? sheetBuilder;

  /// How the menus and sheets of every `BrixSelect` look. The field itself
  /// follows [textField].
  final BrixSelectStyle select;

  /// Draws every `BrixSelect` field with the app's own widget; brix keeps
  /// opening the options, the required check and the chosen value.
  final BrixSelectBuilder<Object?>? selectBuilder;

  /// The theme set in the app, or, without one, the brix defaults for the
  /// app's current brightness, so widgets work with no setup.
  static BrixTheme of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<BrixTheme>() ??
        (theme.brightness == Brightness.dark ? _defaultDark : _defaultLight);
  }

  static final BrixTheme _defaultLight = BrixTheme.light();
  static final BrixTheme _defaultDark = BrixTheme.dark();

  /// A Material theme with the same colours and font, so plain Flutter
  /// widgets (app bar, switches, scaffold) match brix widgets.
  ThemeData toThemeData() {
    return ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onPrimary,
        error: colors.danger,
        onError: colors.onPrimary,
        surface: colors.surface,
        onSurface: colors.text,
        outline: colors.border,
        scrim: colors.scrim,
      ),
      scaffoldBackgroundColor: colors.background,
      fontFamily: typography.body.fontFamily,
      extensions: [this],
    );
  }

  @override
  BrixTheme copyWith({
    BrixColors? colors,
    BrixTypography? typography,
    BrixShape? shape,
    bool? glass,
    BrixUiTexts? texts,
    BrixUiIcons? icons,
    BrixButtonStyle? button,
    BrixButtonBuilder? buttonBuilder,
    BrixTextFieldStyle? textField,
    BrixTextFieldBuilder? textFieldBuilder,
    BrixDialogStyle? dialog,
    BrixDialogBuilder? dialogBuilder,
    BrixToastStyle? toast,
    BrixToastBuilder? toastBuilder,
    BrixLoaderStyle? loader,
    BrixLoaderBuilder? loaderBuilder,
    BrixSheetStyle? sheet,
    BrixSheetBuilder? sheetBuilder,
    BrixSelectStyle? select,
    BrixSelectBuilder<Object?>? selectBuilder,
  }) {
    return BrixTheme._(
      brightness: brightness,
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      shape: shape ?? this.shape,
      glass: glass ?? this.glass,
      texts: texts ?? this.texts,
      icons: icons ?? this.icons,
      button: button ?? this.button,
      buttonBuilder: buttonBuilder ?? this.buttonBuilder,
      textField: textField ?? this.textField,
      textFieldBuilder: textFieldBuilder ?? this.textFieldBuilder,
      dialog: dialog ?? this.dialog,
      dialogBuilder: dialogBuilder ?? this.dialogBuilder,
      toast: toast ?? this.toast,
      toastBuilder: toastBuilder ?? this.toastBuilder,
      loader: loader ?? this.loader,
      loaderBuilder: loaderBuilder ?? this.loaderBuilder,
      sheet: sheet ?? this.sheet,
      sheetBuilder: sheetBuilder ?? this.sheetBuilder,
      select: select ?? this.select,
      selectBuilder: selectBuilder ?? this.selectBuilder,
    );
  }

  @override
  BrixTheme lerp(covariant BrixTheme? other, double t) {
    if (other == null) return this;
    return BrixTheme._(
      brightness: t < 0.5 ? brightness : other.brightness,
      colors: colors.lerp(other.colors, t),
      typography: typography.lerp(other.typography, t),
      shape: shape.lerp(other.shape, t),
      glass: t < 0.5 ? glass : other.glass,
      texts: t < 0.5 ? texts : other.texts,
      icons: t < 0.5 ? icons : other.icons,
      button: button.lerp(other.button, t),
      buttonBuilder: t < 0.5 ? buttonBuilder : other.buttonBuilder,
      textField: textField.lerp(other.textField, t),
      textFieldBuilder: t < 0.5 ? textFieldBuilder : other.textFieldBuilder,
      dialog: dialog.lerp(other.dialog, t),
      dialogBuilder: t < 0.5 ? dialogBuilder : other.dialogBuilder,
      toast: toast.lerp(other.toast, t),
      toastBuilder: t < 0.5 ? toastBuilder : other.toastBuilder,
      loader: loader.lerp(other.loader, t),
      loaderBuilder: t < 0.5 ? loaderBuilder : other.loaderBuilder,
      sheet: sheet.lerp(other.sheet, t),
      sheetBuilder: t < 0.5 ? sheetBuilder : other.sheetBuilder,
      select: select.lerp(other.select, t),
      selectBuilder: t < 0.5 ? selectBuilder : other.selectBuilder,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixTheme &&
      other.brightness == brightness &&
      other.colors == colors &&
      other.typography == typography &&
      other.shape == shape &&
      other.glass == glass &&
      other.texts == texts &&
      other.icons == icons &&
      other.button == button &&
      other.buttonBuilder == buttonBuilder &&
      other.textField == textField &&
      other.textFieldBuilder == textFieldBuilder &&
      other.dialog == dialog &&
      other.dialogBuilder == dialogBuilder &&
      other.toast == toast &&
      other.toastBuilder == toastBuilder &&
      other.loader == loader &&
      other.loaderBuilder == loaderBuilder &&
      other.sheet == sheet &&
      other.sheetBuilder == sheetBuilder &&
      other.select == select &&
      other.selectBuilder == selectBuilder;

  @override
  int get hashCode => Object.hashAll([
    brightness,
    colors,
    typography,
    shape,
    glass,
    texts,
    icons,
    button,
    buttonBuilder,
    textField,
    textFieldBuilder,
    dialog,
    dialogBuilder,
    toast,
    toastBuilder,
    loader,
    loaderBuilder,
    sheet,
    sheetBuilder,
    select,
    selectBuilder,
  ]);
}
