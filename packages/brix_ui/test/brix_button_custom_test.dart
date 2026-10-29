import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {BrixTheme? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: (theme ?? BrixTheme.light()).toThemeData(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) =>
    tester.widget<Ink>(find.byType(Ink)).decoration! as BoxDecoration;

double _radius(WidgetTester tester) =>
    (_decoration(tester).borderRadius! as BorderRadius).topLeft.x;

/// Records haptic calls.
List<String> _haptics(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'HapticFeedback.vibrate') calls.add('vibrate');
      return null;
    },
  );
  return calls;
}

/// An app's own button, drawn from [BrixButtonData].
Widget _ownButton(BuildContext context, BrixButtonData button) {
  return GestureDetector(
    onTap: button.onPressed,
    child: Container(
      key: const Key('own'),
      color: button.variant == BrixButtonVariant.destructive
          ? Colors.red
          : Colors.black,
      child: Text(button.isLoading ? 'busy' : button.label),
    ),
  );
}

void main() {
  group('BrixButtonStyle', () {
    test('merge: set values of the other win, the rest stay', () {
      const theme = BrixButtonStyle(radius: 30, height: 60, upperCase: true);
      final merged = theme.merge(const BrixButtonStyle(radius: 4));
      expect(merged.radius, 4);
      expect(merged.height, 60);
      expect(merged.upperCase, isTrue);
      expect(theme.merge(null), theme);
    });

    test('merge combines text styles', () {
      const a = BrixButtonStyle(textStyle: TextStyle(fontSize: 18));
      final b = a.merge(
        const BrixButtonStyle(textStyle: TextStyle(letterSpacing: 2)),
      );
      expect(b.textStyle?.fontSize, 18);
      expect(b.textStyle?.letterSpacing, 2);
    });

    test('lerp blends numbers and flips flags half way', () {
      const a = BrixButtonStyle(radius: 10, upperCase: false);
      const b = BrixButtonStyle(radius: 20, upperCase: true);
      expect(a.lerp(b, 0.5).radius, 15);
      expect(a.lerp(b, 0.4).upperCase, isFalse);
      expect(a.lerp(b, 0.6).upperCase, isTrue);
      // One side unset: no blending, it switches half way.
      expect(const BrixButtonStyle().lerp(b, 0.4).radius, isNull);
      expect(const BrixButtonStyle().lerp(b, 0.6).radius, 20);
    });

    test('theme copyWith, lerp and equality carry it', () {
      const style = BrixButtonStyle(radius: 30);
      final theme = BrixTheme.light().copyWith(button: style);
      expect(theme.button, style);
      expect(theme == BrixTheme.light(), isFalse);
      expect(BrixTheme.light().lerp(theme, 1).button.radius, 30);
    });
  });

  group('theme style', () {
    testWidgets('size, radius, padding and capitals for every button', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixButton(label: 'Save', onPressed: () {}),
        theme: BrixTheme.light(
          button: const BrixButtonStyle(
            height: 60,
            radius: 30,
            upperCase: true,
            padding: EdgeInsets.symmetric(horizontal: 40),
          ),
        ),
      );
      expect(tester.getSize(find.byType(BrixButton)).height, 60);
      expect(_radius(tester), 30);
      expect(find.text('SAVE'), findsOneWidget);
      expect(
        tester.widget<Padding>(find.byType(Padding).last).padding,
        const EdgeInsets.symmetric(horizontal: 40),
      );
    });

    testWidgets('text style merges over the typography', (tester) async {
      await _pump(
        tester,
        BrixButton(label: 'Go', onPressed: () {}),
        theme: BrixTheme.light(
          button: const BrixButtonStyle(
            textStyle: TextStyle(letterSpacing: 1.5),
          ),
        ),
      );
      final style = tester.widget<Text>(find.text('Go')).style!;
      expect(style.letterSpacing, 1.5);
      expect(style.fontSize, BrixTypography().button.fontSize);
      expect(style.color, const BrixColors.light().onPrimary);
    });

    testWidgets('gradient for every filled button, not for others', (
      tester,
    ) async {
      final theme = BrixTheme.light(
        button: const BrixButtonStyle(gradient: true),
      );
      await _pump(
        tester,
        BrixButton(label: 'Go', onPressed: () {}),
        theme: theme,
      );
      expect(_decoration(tester).gradient, isNotNull);

      await _pump(
        tester,
        BrixButton(label: 'Go', gradient: false, onPressed: () {}),
        theme: theme,
      );
      expect(_decoration(tester).gradient, isNull);

      await _pump(
        tester,
        BrixButton.destructive(label: 'Delete', onPressed: () {}),
        theme: theme,
      );
      expect(_decoration(tester).gradient, isNull);
    });

    testWidgets('icon size and gap', (tester) async {
      await _pump(
        tester,
        BrixButton(label: 'Go', icon: Icons.star, onPressed: () {}),
        theme: BrixTheme.light(
          button: const BrixButtonStyle(iconSize: 28, iconGap: 14),
        ),
      );
      expect(tester.widget<Icon>(find.byIcon(Icons.star)).size, 28);
      expect(
        tester.getTopLeft(find.text('Go')).dx -
            tester.getTopRight(find.byIcon(Icons.star)).dx,
        14,
      );
    });

    testWidgets('pressed scale and disabled opacity', (tester) async {
      final theme = BrixTheme.light(
        button: const BrixButtonStyle(pressedScale: 0.9, disabledOpacity: 0.2),
      );
      await _pump(
        tester,
        BrixButton(label: 'Go', onPressed: () {}),
        theme: theme,
      );
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(BrixButton)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        0.9,
      );
      await gesture.up();

      await _pump(
        tester,
        const BrixButton(label: 'Go', onPressed: null),
        theme: theme,
      );
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0.2,
      );
    });

    testWidgets('outline width', (tester) async {
      await _pump(
        tester,
        BrixButton.outlined(label: 'Back', onPressed: () {}),
        theme: BrixTheme.light(button: const BrixButtonStyle(borderWidth: 3)),
      );
      expect((_decoration(tester).border! as Border).top.width, 3);
    });

    testWidgets('haptics off in the theme, on for one button', (tester) async {
      final calls = _haptics(tester);
      final theme = BrixTheme.light(
        button: const BrixButtonStyle(haptics: false),
      );
      await _pump(
        tester,
        BrixButton(label: 'Go', onPressed: () {}),
        theme: theme,
      );
      await tester.tap(find.text('Go'));
      expect(calls, isEmpty);

      await _pump(
        tester,
        BrixButton(label: 'Go', haptics: true, onPressed: () {}),
        theme: theme,
      );
      await tester.tap(find.text('Go'));
      expect(calls, hasLength(1));
    });
  });

  testWidgets('a button\'s own style wins over the theme', (tester) async {
    await _pump(
      tester,
      BrixButton(
        label: 'Go',
        style: const BrixButtonStyle(radius: 2),
        onPressed: () {},
      ),
      theme: BrixTheme.light(
        button: const BrixButtonStyle(radius: 30, height: 60),
      ),
    );
    expect(_radius(tester), 2);
    expect(tester.getSize(find.byType(BrixButton)).height, 60);
  });

  group('builder', () {
    testWidgets('theme builder draws every button; brix keeps the logic', (
      tester,
    ) async {
      final calls = _haptics(tester);
      var taps = 0;
      final theme = BrixTheme.light(buttonBuilder: _ownButton);
      await _pump(
        tester,
        BrixButton(label: 'Save', onPressed: () => taps++),
        theme: theme,
      );
      expect(find.byKey(const Key('own')), findsOneWidget);
      expect(find.byType(Ink), findsNothing);

      await tester.tap(find.text('Save'));
      expect(taps, 1);
      expect(calls, hasLength(1)); // brix's haptic still runs
    });

    testWidgets('loading: builder gets no onPressed, so taps do nothing', (
      tester,
    ) async {
      var taps = 0;
      late BrixButtonData seen;
      await _pump(
        tester,
        BrixButton(
          label: 'Save',
          isLoading: true,
          onPressed: () => taps++,
          builder: (context, button) {
            seen = button;
            return _ownButton(context, button);
          },
        ),
      );
      expect(find.text('busy'), findsOneWidget);
      await tester.tap(find.byKey(const Key('own')));
      expect(taps, 0);
      expect(seen.onPressed, isNull);
      expect(seen.isEnabled, isTrue);
      expect(seen.isLoading, isTrue);
    });

    testWidgets('builder gets variant, icon, merged style and capitals', (
      tester,
    ) async {
      late BrixButtonData seen;
      await _pump(
        tester,
        BrixButton.destructive(
          label: 'Delete',
          icon: Icons.delete,
          expand: false,
          style: const BrixButtonStyle(height: 40),
          builder: (context, button) {
            seen = button;
            return const SizedBox();
          },
          onPressed: null,
        ),
        theme: BrixTheme.light(
          button: const BrixButtonStyle(upperCase: true, radius: 30),
        ),
      );
      expect(seen.variant, BrixButtonVariant.destructive);
      expect(seen.icon, Icons.delete);
      expect(seen.label, 'DELETE');
      expect(seen.style.radius, 30);
      expect(seen.style.height, 40);
      expect(seen.isEnabled, isFalse);
      expect(seen.expand, isFalse);
    });

    testWidgets('builder is told when a filled button uses a gradient', (
      tester,
    ) async {
      late BrixButtonData seen;
      await _pump(
        tester,
        BrixButton(
          label: 'Go',
          gradient: true,
          onPressed: () {},
          builder: (context, button) {
            seen = button;
            return const SizedBox();
          },
        ),
      );
      expect(seen.style.gradient, isTrue);
    });

    testWidgets('a button\'s own builder wins over the theme builder', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixButton(
          label: 'Go',
          onPressed: () {},
          builder: (context, button) => const Text('mine'),
        ),
        theme: BrixTheme.light(buttonBuilder: _ownButton),
      );
      expect(find.text('mine'), findsOneWidget);
      expect(find.byKey(const Key('own')), findsNothing);
    });

    testWidgets('alerts use the app\'s button builder too', (tester) async {
      BrixUi.navigatorKey = GlobalKey<NavigatorState>();
      addTearDown(() {
        BrixAlert.dismiss();
        BrixUi.navigatorKey = null;
      });
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: BrixUi.navigatorKey,
          theme: BrixTheme.light(buttonBuilder: _ownButton).toThemeData(),
          home: const SizedBox(),
        ),
      );
      BrixAlert.warning('Check');
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own')), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Check'), findsNothing);
    });
  });

  test('variant names', () {
    expect(BrixButtonVariant.filled.name, 'filled');
    expect(BrixButtonVariant.outlined.toString(), 'BrixButtonVariant.outlined');
  });
}
