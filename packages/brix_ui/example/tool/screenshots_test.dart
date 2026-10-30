// Renders the example screen in three brands for the README / pub.dev:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there). macOS only.
import 'package:brix_ui/brix_ui.dart';
import 'package:brix_ui_example/brands.dart';
import 'package:brix_ui_example/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../tool/screenshot_kit/iphone.dart';

const _out = '../../doc/screenshots';

Widget _phone(Brand brand, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final theme = brand.theme(brightness);
  return Captioned(
    caption: dark ? '${brand.label}, dark' : brand.label,
    child: IPhone(
      dark: dark,
      child: Theme(
        data: iosTheme(
          theme
              .copyWith(typography: BrixTypography(fontFamily: sfPro))
              .toThemeData(),
        ),
        child: Builder(
          builder: (context) => Material(
            color: context.brix.colors.background,
            child: GalleryScreen(
              brand: brand,
              dark: dark,
              onBrand: (_) {},
              onDark: (_) {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(loadAppleFonts);

  testWidgets('example in three brands', (tester) async {
    await shootRow(tester, '$_out/example.png', [
      _phone(Brand.standard, Brightness.light),
      _phone(Brand.forest, Brightness.light),
      _phone(Brand.sunset, Brightness.dark),
    ]);
  });
}
