import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// Your look, in one place. Change colours, font, shape, texts or icons and
/// every brix_ui widget follows. See https://pub.dev/packages/brix_ui.
///
/// The defaults follow Apple's design: grouped white fields on a light grey
/// background, a blue tint, round corners.
abstract final class AppTheme {
  static const _brand = Color(0xFF007AFF);

  static const _field = BrixTextFieldStyle(
    border: BrixFieldBorder.none,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
  );

  static final light = BrixTheme.light(
    colors: const BrixColors.light(primary: _brand),
    textField: _field,
  ).toThemeData().copyWith(appBarTheme: _appBar(const Color(0xFFF2F2F7)));

  static final dark = BrixTheme.dark(
    colors: const BrixColors.dark(primary: Color(0xFF0A84FF)),
    textField: _field,
  ).toThemeData().copyWith(appBarTheme: _appBar(Colors.black));

  static AppBarTheme _appBar(Color background) => AppBarTheme(
    backgroundColor: background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}
