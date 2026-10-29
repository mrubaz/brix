// Renders the example screen in three brands for the README / pub.dev:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there).
import 'dart:io';

import 'package:brix_ui/brix_ui.dart';
import 'package:brix_ui_example/brands.dart';
import 'package:brix_ui_example/gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = '../../doc/screenshots';
const _page = Color(0xFFE9ECF1);

Future<void> _loadFonts() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Process.runSync('which', ['flutter']).stdout.toString().trim())
          .resolveSymbolicLinksSync()
          .replaceAll('/bin/flutter', '');
  final dir = '$root/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, List<String> files) async {
    final loader = FontLoader(family);
    for (final file in files) {
      final bytes = File('$dir/$file').readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Roboto', [
    'Roboto-Regular.ttf',
    'Roboto-Medium.ttf',
    'Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['MaterialIcons-Regular.otf']);
}

Widget _screen(Brand brand, Brightness brightness) {
  final dark = brightness == Brightness.dark;
  return Column(
    children: [
      Theme(
        data: brand.theme(brightness).toThemeData(),
        child: Builder(
          builder: (context) => Container(
            width: 360,
            height: 760,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: context.brix.colors.background,
              borderRadius: BorderRadius.circular(34),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 24,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
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
      const SizedBox(height: 14),
      Text(
        '${brand.label}${dark ? ' – dark' : ''}',
        style: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF5B6270),
        ),
      ),
    ],
  );
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('example in three brands', (tester) async {
    const width = 3 * 360 + 2 * 32 + 72.0;
    const height = 880.0;
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(width * 2, height * 2);
    addTearDown(tester.view.reset);
    debugDisableShadows = false;
    try {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: RepaintBoundary(
            key: const Key('shot'),
            child: FittedBox(
              child: SizedBox(
                width: width,
                height: height,
                child: Material(
                  color: _page,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(36, 36, 36, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _screen(Brand.standard, Brightness.light),
                        const SizedBox(width: 32),
                        _screen(Brand.forest, Brightness.light),
                        const SizedBox(width: 32),
                        _screen(Brand.sunset, Brightness.dark),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await expectLater(
        find.byKey(const Key('shot')),
        matchesGoldenFile('$_out/example.png'),
      );
    } finally {
      debugDisableShadows = true;
    }
  });
}
