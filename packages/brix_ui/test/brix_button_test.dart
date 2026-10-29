import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _light = BrixTheme.light(
  colors: const BrixColors.light(
    primary: Color(0xFF000011),
    secondary: Color(0xFF000022),
    danger: Color(0xFF000033),
    onPrimary: Color(0xFF000044),
  ),
);

Future<void> _pump(WidgetTester tester, Widget child, {BrixTheme? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: (theme ?? _light).toThemeData(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
}

BoxDecoration _decoration(WidgetTester tester) {
  final ink = tester.widget<Ink>(find.byType(Ink));
  return ink.decoration! as BoxDecoration;
}

void main() {
  group('BrixButton', () {
    testWidgets('tap runs onPressed with a haptic', (tester) async {
      final haptics = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            haptics.add(call.arguments as String);
          }
          return null;
        },
      );
      var taps = 0;
      await _pump(tester, BrixButton(label: 'Save', onPressed: () => taps++));

      await tester.tap(find.text('Save'));
      expect(taps, 1);
      expect(haptics, ['HapticFeedbackType.lightImpact']);
    });

    testWidgets('no haptic when turned off', (tester) async {
      final haptics = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          haptics.add(call);
          return null;
        },
      );
      await _pump(
        tester,
        BrixButton(label: 'Save', haptics: false, onPressed: () {}),
      );
      await tester.tap(find.text('Save'));
      expect(
        haptics.where((c) => c.method == 'HapticFeedback.vibrate'),
        isEmpty,
      );
    });

    testWidgets('loading shows a spinner and ignores taps', (tester) async {
      var taps = 0;
      await _pump(
        tester,
        BrixButton(label: 'Save', isLoading: true, onPressed: () => taps++),
      );

      expect(find.text('Save'), findsNothing);
      expect(find.byType(CupertinoActivityIndicator), findsOneWidget);
      await tester.tap(find.byType(BrixButton));
      expect(taps, 0);
      // Still fully visible – only a disabled button fades.
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        1,
      );
    });

    testWidgets('loading keeps the button size', (tester) async {
      await _pump(tester, BrixButton(label: 'Save', onPressed: () {}));
      final idle = tester.getSize(find.byType(BrixButton));
      await _pump(
        tester,
        BrixButton(label: 'Save', isLoading: true, onPressed: () {}),
      );
      expect(tester.getSize(find.byType(BrixButton)), idle);
    });

    testWidgets('onPressed null disables and fades it', (tester) async {
      await _pump(tester, const BrixButton(label: 'Save', onPressed: null));
      await tester.pumpAndSettle();
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
        0.4,
      );
      expect(
        tester.getSemantics(find.byType(BrixButton)),
        isSemantics(isButton: true, isEnabled: false, hasEnabledState: true),
      );
    });

    testWidgets('filled uses primary, gradient adds secondary', (tester) async {
      await _pump(tester, BrixButton(label: 'Go', onPressed: () {}));
      expect(_decoration(tester).color, _light.colors.primary);
      final label = tester.widget<Text>(find.text('Go'));
      expect(label.style?.color, _light.colors.onPrimary);

      await _pump(
        tester,
        BrixButton(label: 'Go', gradient: true, onPressed: () {}),
      );
      final gradient = _decoration(tester).gradient! as LinearGradient;
      expect(gradient.colors, [_light.colors.primary, _light.colors.secondary]);
    });

    testWidgets('outlined has a primary border and no fill', (tester) async {
      await _pump(tester, BrixButton.outlined(label: 'Back', onPressed: () {}));
      final decoration = _decoration(tester);
      expect(decoration.color, isNull);
      expect((decoration.border! as Border).top.color, _light.colors.primary);
      expect(
        tester.widget<Text>(find.text('Back')).style?.color,
        _light.colors.primary,
      );
    });

    testWidgets('destructive uses danger', (tester) async {
      await _pump(
        tester,
        BrixButton.destructive(label: 'Delete', onPressed: () {}),
      );
      expect(_decoration(tester).color, _light.colors.danger);
    });

    testWidgets('follows the dark theme with no widget change', (tester) async {
      await _pump(
        tester,
        BrixButton(label: 'Go', onPressed: () {}),
        theme: BrixTheme.dark(),
      );
      expect(_decoration(tester).color, const BrixColors.dark().primary);
    });

    testWidgets('size comes from the theme', (tester) async {
      final theme = BrixTheme.light(shape: const BrixShape(buttonHeight: 60));
      await _pump(
        tester,
        BrixButton(label: 'Go', expand: false, onPressed: () {}),
        theme: theme,
      );
      final size = tester.getSize(find.byType(BrixButton));
      expect(size.height, 60);
      expect(size.width, lessThan(800)); // fits the label

      await _pump(tester, BrixButton(label: 'Go', onPressed: () {}));
      expect(tester.getSize(find.byType(BrixButton)).width, 800);
    });

    testWidgets('label is shown as written, with an icon', (tester) async {
      await _pump(
        tester,
        BrixButton(label: 'Log in', icon: Icons.login, onPressed: () {}),
      );
      expect(find.text('Log in'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('press shrinks it and starting to load releases it', (
      tester,
    ) async {
      var loading = false;
      late StateSetter setOuter;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            setOuter = setState;
            return BrixButton(
              label: 'Save',
              isLoading: loading,
              onPressed: () {},
            );
          },
        ),
      );
      double scale() =>
          tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale;

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(BrixButton)),
      );
      await tester.pump(const Duration(milliseconds: 200));
      expect(scale(), 0.97);

      setOuter(() => loading = true);
      await tester.pump();
      expect(scale(), 1);
      await gesture.up();
    });
  });

  group('BrixLoader', () {
    testWidgets('uses the muted text colour by default', (tester) async {
      await _pump(tester, const BrixLoader());
      final spinner = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(spinner.color, _light.colors.mutedText);
      expect(spinner.radius, 10);
    });

    testWidgets('takes its own colour and size', (tester) async {
      await _pump(
        tester,
        const BrixLoader(radius: 20, color: Color(0xFF00FF00)),
      );
      final spinner = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(spinner.color, const Color(0xFF00FF00));
      expect(spinner.radius, 20);
    });
  });
}
