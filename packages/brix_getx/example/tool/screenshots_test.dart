// Renders brix_getx's README / pub.dev screenshots from this demo app:
//
//   flutter test tool/screenshots_test.dart --update-goldens
//
// Not part of `flutter test` (only `test/` runs there).
import 'dart:io';

import 'package:brix_getx_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _out = '../../doc/screenshots';

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

Future<void> _settle(WidgetTester tester, {int steps = 10}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}

Future<void> _enter(WidgetTester tester, String label, String text) async {
  await tester.enterText(find.widgetWithText(TextFormField, label), text);
  await tester.pump();
}

Future<void> _shoot(WidgetTester tester, String name) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await _settle(tester, steps: 25); // snackbars gone
  await expectLater(
    find.byType(BrixExampleApp),
    matchesGoldenFile('$_out/$name.png'),
  );
}

void main() {
  setUpAll(_loadFonts);

  testWidgets('login, signup checklist, code boxes', (tester) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const BrixExampleApp());
    await _settle(tester);
    await _enter(tester, 'Email', 'demo@brix.dev');
    await _enter(tester, 'Password', 'Demo@1234');
    await _shoot(tester, 'login');

    await tester.tap(find.text('No account? Sign up'));
    await _settle(tester);
    await _enter(tester, 'Name', 'Ada');
    await _enter(tester, 'Email', 'ada@brix.dev');
    await _enter(tester, 'Password', 'Strong12');
    await _shoot(tester, 'signup_password_rules');

    await _enter(tester, 'Password', 'Strong@123');
    await _enter(tester, 'Confirm password', 'Strong@123');
    final signUp = find.widgetWithText(FilledButton, 'Sign up');
    await tester.ensureVisible(signUp);
    await tester.tap(signUp);
    await _settle(tester);
    for (var i = 0; i < 3; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      await tester.pump();
    }
    await _shoot(tester, 'code_boxes');
  });
}
