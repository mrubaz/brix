import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget that saves the [BrixTheme] it reads.
Future<BrixTheme> _themeIn(
  WidgetTester tester, {
  ThemeData? theme,
  ThemeData? darkTheme,
  ThemeMode themeMode = ThemeMode.system,
}) async {
  late BrixTheme read;
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: Builder(
        builder: (context) {
          read = context.brix;
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pumpAndSettle(); // theme changes animate
  return read;
}

void main() {
  group('BrixColors', () {
    test('light and dark have different defaults', () {
      const light = BrixColors.light();
      const dark = BrixColors.dark();
      expect(light.background, isNot(dark.background));
      expect(light.text, isNot(dark.text));
      expect(light == dark, isFalse);
    });

    test('override changes only the given colour', () {
      const brand = Color(0xFF1D629D);
      const colors = BrixColors.light(primary: brand);
      expect(colors.primary, brand);
      expect(colors.surface, const BrixColors.light().surface);
    });

    test('copyWith keeps the other colours', () {
      const dark = BrixColors.dark();
      final copy = dark.copyWith(danger: const Color(0xFF000001));
      expect(copy.danger, const Color(0xFF000001));
      expect(copy.background, dark.background);
      expect(copy.copyWith(danger: dark.danger), dark);
    });

    test('lerp blends from one to the other', () {
      const light = BrixColors.light();
      const dark = BrixColors.dark();
      expect(light.lerp(dark, 0), light);
      expect(light.lerp(dark, 1), dark);
      expect(
        light.lerp(dark, 0.5).background,
        Color.lerp(light.background, dark.background, 0.5),
      );
    });
  });

  group('BrixTypography', () {
    test('fontFamily goes on every style', () {
      final typography = BrixTypography(fontFamily: 'Inter');
      for (final style in [
        typography.title,
        typography.body,
        typography.label,
        typography.button,
        typography.caption,
      ]) {
        expect(style.fontFamily, 'Inter');
      }
    });

    test('a style with its own font keeps it', () {
      final typography = BrixTypography(
        fontFamily: 'Inter',
        title: const TextStyle(fontFamily: 'Serif', fontSize: 30),
      );
      expect(typography.title.fontFamily, 'Serif');
      expect(typography.title.fontSize, 30);
      expect(typography.body.fontFamily, 'Inter');
    });

    test('styles carry no colour (colours come from BrixColors)', () {
      final typography = BrixTypography();
      expect(typography.body.color, isNull);
      expect(typography.title.color, isNull);
    });

    test('copyWith and lerp', () {
      final a = BrixTypography();
      final b = a.copyWith(body: const TextStyle(fontSize: 20));
      expect(b.body.fontSize, 20);
      expect(b.title, a.title);
      expect(a.lerp(b, 0.5).body.fontSize, 18);
      expect(BrixTypography(), BrixTypography());
    });
  });

  group('BrixShape', () {
    test('defaults meet the 44 pt touch target', () {
      const shape = BrixShape();
      expect(shape.buttonHeight, greaterThanOrEqualTo(44));
      expect(shape.fieldHeight, greaterThanOrEqualTo(44));
    });

    test('copyWith and lerp', () {
      const a = BrixShape();
      final b = a.copyWith(radius: 20);
      expect(b.radius, 20);
      expect(b.buttonHeight, a.buttonHeight);
      expect(a.lerp(b, 0.5).radius, 16);
      expect(b.copyWith(radius: 12), a);
    });
  });

  group('BrixTheme', () {
    test('light and dark use their own colours and brightness', () {
      final light = BrixTheme.light();
      final dark = BrixTheme.dark();
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.colors, const BrixColors.light());
      expect(dark.colors, const BrixColors.dark());
    });

    test('toThemeData matches the tokens and carries the theme', () {
      final brix = BrixTheme.dark(
        colors: const BrixColors.dark(primary: Color(0xFF123456)),
        typography: BrixTypography(fontFamily: 'Inter'),
      );
      final data = brix.toThemeData();
      expect(data.brightness, Brightness.dark);
      expect(data.colorScheme.primary, const Color(0xFF123456));
      expect(data.colorScheme.error, brix.colors.danger);
      expect(data.scaffoldBackgroundColor, brix.colors.background);
      expect(data.textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(data.extension<BrixTheme>(), brix);
    });

    test('glass is off by default, copyWith and lerp carry it', () {
      expect(BrixTheme.light().glass, isFalse);
      final glass = BrixTheme.light().copyWith(glass: true);
      expect(glass.glass, isTrue);
      expect(glass == BrixTheme.light(), isFalse);
      expect(BrixTheme.light().lerp(glass, 0.6).glass, isTrue);
    });

    test('copyWith keeps brightness', () {
      final dark = BrixTheme.dark();
      final copy = dark.copyWith(shape: const BrixShape(radius: 4));
      expect(copy.brightness, Brightness.dark);
      expect(copy.shape.radius, 4);
      expect(copy.colors, dark.colors);
    });

    test('lerp blends tokens and switches brightness half way', () {
      final light = BrixTheme.light();
      final dark = BrixTheme.dark();
      expect(light.lerp(null, 0.5), light);
      expect(light.lerp(dark, 0.4).brightness, Brightness.light);
      expect(light.lerp(dark, 0.6).brightness, Brightness.dark);
      expect(light.lerp(dark, 1), dark);
    });

    testWidgets('context.brix reads the app theme', (tester) async {
      final brix = BrixTheme.light(
        colors: const BrixColors.light(primary: Color(0xFF00FF00)),
      );
      final read = await _themeIn(tester, theme: brix.toThemeData());
      expect(read, brix);
    });

    testWidgets('dark mode picks the dark brix theme', (tester) async {
      final read = await _themeIn(
        tester,
        theme: BrixTheme.light().toThemeData(),
        darkTheme: BrixTheme.dark().toThemeData(),
        themeMode: ThemeMode.dark,
      );
      expect(read.brightness, Brightness.dark);
    });

    testWidgets('own ThemeData with the extension works', (tester) async {
      final brix = BrixTheme.light(shape: const BrixShape(radius: 2));
      final read = await _themeIn(tester, theme: ThemeData(extensions: [brix]));
      expect(read.shape.radius, 2);
    });

    testWidgets('no setup: defaults follow the app brightness', (tester) async {
      expect((await _themeIn(tester)).colors, const BrixColors.light());
      final dark = await _themeIn(
        tester,
        theme: ThemeData(brightness: Brightness.dark),
      );
      expect(dark.colors, const BrixColors.dark());
    });
  });
}
