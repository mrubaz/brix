import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Every look, place and timing that used to be fixed can be changed.
Future<void> _pump(WidgetTester tester, Widget child, BrixTheme theme) async {
  BrixUi.navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: BrixUi.navigatorKey,
      theme: theme.toThemeData(),
      home: Scaffold(body: Center(child: child)),
    ),
  );
  // Theme changes animate (spinners never settle, so wait a fixed time).
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  tearDown(() {
    BrixDialog.dismiss();
    BrixToast.dismiss();
    BrixUi.navigatorKey = null;
  });

  group('loader', () {
    testWidgets('size and colour from the theme; own values win', (
      tester,
    ) async {
      final theme = BrixTheme.light(
        loader: const BrixLoaderStyle(radius: 16, color: Color(0xFF00AA00)),
      );
      await _pump(tester, const BrixLoader(), theme);
      var spinner = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(spinner.radius, 16);
      expect(spinner.color, const Color(0xFF00AA00));

      await _pump(tester, const BrixLoader(radius: 4), theme);
      spinner = tester.widget<CupertinoActivityIndicator>(
        find.byType(CupertinoActivityIndicator),
      );
      expect(spinner.radius, 4);
    });

    testWidgets('own spinner everywhere, also in loading buttons', (
      tester,
    ) async {
      final seen = <BrixLoaderData>[];
      final theme = BrixTheme.light(
        loaderBuilder: (context, loader) {
          seen.add(loader);
          return const Text('my spinner');
        },
      );
      await _pump(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrixLoader(),
            BrixButton(label: 'Save', isLoading: true, onPressed: () {}),
          ],
        ),
        theme,
      );
      expect(find.text('my spinner'), findsNWidgets(2));
      expect(find.byType(CupertinoActivityIndicator), findsNothing);
      // Inside a filled button it is told to use the text colour on primary.
      expect(seen.map((l) => l.color), contains(theme.colors.onPrimary));
    });

    test('style merge, lerp and theme', () {
      const a = BrixLoaderStyle(radius: 10);
      expect(a.merge(const BrixLoaderStyle(radius: 20)).radius, 20);
      expect(a.lerp(const BrixLoaderStyle(radius: 20), 0.5).radius, 15);
      expect(BrixTheme.light().copyWith(loader: a).loader, a);
    });
  });

  group('button timings', () {
    testWidgets('press and fade durations', (tester) async {
      await _pump(
        tester,
        const BrixButton(label: 'Go', onPressed: null),
        BrixTheme.light(
          button: const BrixButtonStyle(
            pressDuration: Duration(milliseconds: 50),
            fadeDuration: Duration(milliseconds: 400),
          ),
        ),
      );
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).duration,
        const Duration(milliseconds: 50),
      );
      expect(
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).duration,
        const Duration(milliseconds: 400),
      );
    });
  });

  group('text field', () {
    testWidgets('own required marker, or none', (tester) async {
      await _pump(
        tester,
        const BrixTextField(label: 'Email', isRequired: true),
        BrixTheme.light(
          textField: const BrixTextFieldStyle(
            requiredMarker: ' (required)',
            requiredMarkerStyle: TextStyle(color: Color(0xFF888888)),
          ),
        ),
      );
      expect(find.text('Email (required)'), findsOneWidget);

      await _pump(
        tester,
        const BrixTextField(label: 'Email', isRequired: true),
        BrixTheme.light(
          textField: const BrixTextFieldStyle(requiredMarker: ''),
        ),
      );
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('error text style and lines', (tester) async {
      await _pump(
        tester,
        const BrixTextField(errorText: 'Wrong'),
        BrixTheme.light(
          textField: const BrixTextFieldStyle(
            errorStyle: TextStyle(fontSize: 15),
            errorMaxLines: 1,
          ),
        ),
      );
      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(decoration.errorStyle?.fontSize, 15);
      expect(decoration.errorStyle?.color, const BrixColors.light().danger);
      expect(decoration.errorMaxLines, 1);
    });
  });

  group('dialog scrim', () {
    testWidgets('own scrim colour for warnings and dialogs', (tester) async {
      const clear = Color(0x00000000);
      await _pump(
        tester,
        const SizedBox(),
        BrixTheme.light(dialog: const BrixDialogStyle(scrimColor: clear)),
      );
      BrixDialog.warning('x');
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<ModalBarrier>(find.byType(ModalBarrier))
            .map((b) => b.color),
        contains(clear),
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      BrixDialog.show<void>(
        title: 'Hi',
        style: const BrixDialogStyle(scrimColor: Color(0x55FF0000)),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<ModalBarrier>(find.byType(ModalBarrier))
            .map((b) => b.color),
        contains(const Color(0x55FF0000)),
      );
    });
  });

  group('toast', () {
    testWidgets('centre position; the screen around it still works', (
      tester,
    ) async {
      var taps = 0;
      await _pump(
        tester,
        Align(
          alignment: Alignment.topLeft,
          child: TextButton(
            onPressed: () => taps++,
            child: const Text('Corner'),
          ),
        ),
        BrixTheme.light(
          toast: const BrixToastStyle(position: BrixToastPosition.center),
        ),
      );
      BrixToast.success('Middle');
      await tester.pumpAndSettle();
      final screen = tester.getSize(find.byType(Scaffold));
      expect(
        (tester.getCenter(find.text('Middle')).dy - screen.height / 2).abs(),
        lessThan(30),
      );
      await tester.tap(find.text('Corner'));
      expect(taps, 1);
      await tester.tap(find.text('Middle'));
      await tester.pumpAndSettle();
      expect(find.text('Middle'), findsNothing);
    });

    testWidgets('own in / out speed', (tester) async {
      await _pump(
        tester,
        const SizedBox(),
        BrixTheme.light(
          toast: const BrixToastStyle(
            animationDuration: Duration(milliseconds: 800),
          ),
        ),
      );
      BrixToast.success('Slow');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text('Slow'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, inExclusiveRange(0, 1));
    });
  });
}
