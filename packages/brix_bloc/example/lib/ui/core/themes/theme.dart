import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// Your look, in one place. Change colours, font, shape, texts or icons and
/// every brix_ui widget follows. See https://pub.dev/packages/brix_ui.
///
/// The defaults are brix's own brand: brick orange on white, warm off-white
/// fields with a soft border, round corners. Put your brand colours here.
abstract final class AppTheme {
  /// Fields: a soft border that turns brick orange while typing, so they
  /// read on a white page.
  static const _field = BrixTextFieldStyle(
    border: BrixFieldBorder.outline,
    borderWidth: 1,
    focusedBorderWidth: 1.5,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
  );

  static final light = BrixTheme.light(
    colors: const BrixColors.light(
      primary: Color(0xFFE4572E),
      secondary: Color(0xFFB8361A),
      background: Color(0xFFFFFFFF),
      surface: Color(0xFFFBF9F7),
      border: Color(0xFFE9E2DC),
    ),
    textField: _field,
  ).toThemeData().copyWith(appBarTheme: _appBar(const Color(0xFFFFFFFF)));

  static final dark = BrixTheme.dark(
    colors: const BrixColors.dark(
      primary: Color(0xFFFF7A4D),
      secondary: Color(0xFFD9481F),
      background: Color(0xFF0B0908),
      surface: Color(0xFF1D1815),
      border: Color(0xFF2E2622),
    ),
    textField: _field,
  ).toThemeData().copyWith(appBarTheme: _appBar(const Color(0xFF0B0908)));

  static AppBarTheme _appBar(Color background) => AppBarTheme(
    backgroundColor: background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
  );
}
