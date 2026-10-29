import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester, BrixTheme theme) async {
  BrixUi.navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: BrixUi.navigatorKey,
      theme: theme.toThemeData(),
      home: const Scaffold(body: SizedBox.expand()),
    ),
  );
}

/// An app's own alert card: tapping a button sends its value to brix.
Widget _ownAlert(BuildContext context, BrixAlertData alert) {
  return Container(
    key: const Key('own-alert'),
    color: alert.accent,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('my ${alert.title}'),
        for (final button in alert.buttons)
          TextButton(
            onPressed: () => alert.onPressed(button.value),
            child: Text(button.label),
          ),
      ],
    ),
  );
}

/// An app's own toast card with a close button.
Widget _ownToast(BuildContext context, BrixToastData toast) {
  return Row(
    key: const Key('own-toast'),
    children: [
      Expanded(child: Text('my ${toast.message}')),
      TextButton(onPressed: toast.dismiss, child: const Text('close')),
    ],
  );
}

void main() {
  tearDown(() {
    BrixAlert.dismiss();
    BrixToast.dismiss();
    BrixUi.navigatorKey = null;
  });

  group('styles: merge, lerp, theme', () {
    test('alert style', () {
      const a = BrixAlertStyle(maxWidth: 300, buttonsVertical: true);
      final b = a.merge(const BrixAlertStyle(maxWidth: 400));
      expect(b.maxWidth, 400);
      expect(b.buttonsVertical, isTrue);
      expect(a.lerp(b, 0.5).maxWidth, 350);
      final theme = BrixTheme.light().copyWith(alert: a);
      expect(theme.alert, a);
      expect(theme == BrixTheme.light(), isFalse);
    });

    test('toast style', () {
      const a = BrixToastStyle(
        position: BrixToastPosition.bottom,
        duration: Duration(seconds: 5),
      );
      final b = a.merge(const BrixToastStyle(maxWidth: 300));
      expect(b.position, BrixToastPosition.bottom);
      expect(b.maxWidth, 300);
      expect(a.lerp(const BrixToastStyle(), 0.4).position, isNotNull);
      expect(BrixTheme.dark().copyWith(toast: a).toast, a);
    });
  });

  group('alert style', () {
    testWidgets('width, icon size, text alignment, title style', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          alert: const BrixAlertStyle(
            maxWidth: 280,
            iconSize: 40,
            iconCircleSize: 70,
            textAlign: TextAlign.start,
            titleStyle: TextStyle(fontSize: 26),
          ),
        ),
      );
      BrixAlert.warning('Check this');
      await tester.pumpAndSettle();

      expect(
        tester
            .getSize(
              find
                  .ancestor(
                    of: find.text('Please check'),
                    matching: find.byType(ConstrainedBox),
                  )
                  .first,
            )
            .width,
        lessThanOrEqualTo(280),
      );
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.warning_amber_rounded),
      );
      expect(icon.size, 40);
      final title = tester.widget<Text>(find.text('Please check'));
      expect(title.textAlign, TextAlign.start);
      expect(title.style?.fontSize, 26);
    });

    testWidgets('icon can be hidden', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(alert: const BrixAlertStyle(showIcon: false)),
      );
      BrixAlert.error('Failed');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('buttons stacked when the style says so', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          alert: const BrixAlertStyle(buttonsVertical: true, buttonGap: 20),
        ),
      );
      BrixAlert.show<int>(
        title: 'Pick',
        buttons: const [
          BrixAlertButton(label: 'A', value: 1),
          BrixAlertButton(label: 'B', value: 2),
        ],
      );
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.widgetWithText(BrixButton, 'B')).dy -
            tester.getBottomLeft(find.widgetWithText(BrixButton, 'A')).dy,
        20,
      );
    });

    testWidgets('show(style:) wins over the theme', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(alert: const BrixAlertStyle(showIcon: false)),
      );
      BrixAlert.show<void>(
        title: 'Hi',
        icon: const BrixIcon(Icons.star),
        style: const BrixAlertStyle(showIcon: true),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('alert placement', () {
    testWidgets('bottom alignment with a margin (sheet look)', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          alert: const BrixAlertStyle(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.fromLTRB(12, 0, 12, 30),
            transition: BrixAlertTransition.slideUp,
          ),
        ),
      );
      BrixAlert.warning('Low');
      await tester.pumpAndSettle();
      final screen = tester.getSize(find.byType(Scaffold));
      final ok = tester.getRect(find.widgetWithText(BrixButton, 'OK'));
      // Card bottom padding is 20, the margin 30.
      expect(screen.height - ok.bottom, 50);
      expect(find.byType(SlideTransition), findsWidgets);
    });

    testWidgets('top alignment (banner look)', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          alert: const BrixAlertStyle(
            alignment: Alignment.topCenter,
            transition: BrixAlertTransition.slideDown,
          ),
        ),
      );
      BrixAlert.error('Top');
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Something went wrong')).dy,
        lessThan(150),
      );
    });

    testWidgets('centre by default', (tester) async {
      await _pumpApp(tester, BrixTheme.light());
      BrixAlert.warning('Mid');
      await tester.pumpAndSettle();
      final screen = tester.getSize(find.byType(Scaffold));
      final message = tester.getCenter(find.text('Mid'));
      expect((message.dy - screen.height / 2).abs(), lessThan(80));
    });

    testWidgets('fade transition and its duration', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          alert: const BrixAlertStyle(
            transition: BrixAlertTransition.fade,
            transitionDuration: Duration(milliseconds: 600),
          ),
        ),
      );
      final result = BrixAlert.show<int>(title: 'Slow');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      final fade = tester.widget<FadeTransition>(
        find
            .ancestor(
              of: find.text('Slow'),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, inExclusiveRange(0, 1)); // still animating
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('show(style:) moves one alert', (tester) async {
      await _pumpApp(tester, BrixTheme.light());
      BrixAlert.show<void>(
        title: 'Here',
        style: const BrixAlertStyle(alignment: Alignment.topCenter),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Here')).dy, lessThan(150));
    });
  });

  group('alert builder', () {
    testWidgets('own card; the tapped value still comes back', (tester) async {
      await _pumpApp(tester, BrixTheme.light(alertBuilder: _ownAlert));
      final result = BrixAlert.show<bool>(
        title: 'Delete?',
        buttons: const [
          BrixAlertButton(label: 'No', value: false),
          BrixAlertButton.destructive(label: 'Yes', value: true),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own-alert')), findsOneWidget);
      expect(find.text('my Delete?'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(find.byKey(const Key('own-alert')), findsNothing);
    });

    testWidgets('warning in an own card: accent and OK close it', (
      tester,
    ) async {
      await _pumpApp(tester, BrixTheme.light(alertBuilder: _ownAlert));
      BrixAlert.warning('Check');
      await tester.pumpAndSettle();
      final card = tester.widget<Container>(find.byKey(const Key('own-alert')));
      expect(card.color, const BrixColors.light().warning);
      expect(find.text('my Please check'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own-alert')), findsNothing);
    });

    testWidgets('show(builder:) wins over the theme builder', (tester) async {
      await _pumpApp(tester, BrixTheme.light(alertBuilder: _ownAlert));
      BrixAlert.show<void>(
        title: 'Hi',
        builder: (context, alert) => const Text('one-off'),
      );
      await tester.pumpAndSettle();
      expect(find.text('one-off'), findsOneWidget);
      expect(find.byKey(const Key('own-alert')), findsNothing);
    });

    testWidgets('own card still on the dimmed screen', (tester) async {
      await _pumpApp(tester, BrixTheme.light(alertBuilder: _ownAlert));
      BrixAlert.error('x');
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<ModalBarrier>(find.byType(ModalBarrier))
            .map((b) => b.color),
        contains(const BrixColors.light().scrim),
      );
    });
  });

  group('toast style', () {
    testWidgets('bottom position, swipe down hides it', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          toast: const BrixToastStyle(position: BrixToastPosition.bottom),
        ),
      );
      BrixToast.success('Saved');
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Saved')).dy, greaterThan(400));

      await tester.fling(find.text('Saved'), const Offset(0, 100), 800);
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('theme duration; the call still wins', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          toast: const BrixToastStyle(duration: Duration(seconds: 1)),
        ),
      );
      BrixToast.success('Quick');
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Quick'), findsNothing);

      BrixToast.success('Long', duration: const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Long'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Long'), findsNothing);
    });

    testWidgets('max width, margin, icon size and message style', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          toast: const BrixToastStyle(
            maxWidth: 300,
            margin: EdgeInsets.fromLTRB(16, 40, 16, 8),
            iconSize: 32,
            messageStyle: TextStyle(fontSize: 20),
          ),
        ),
      );
      BrixToast.success('Styled');
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(BrixToast)).width, 300);
      expect(tester.getTopLeft(find.byType(BrixToast)).dy, 40);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.check_circle_rounded)).size,
        32,
      );
      expect(tester.widget<Text>(find.text('Styled')).style?.fontSize, 20);
    });
  });

  group('toast builder', () {
    testWidgets('own card; brix keeps the timer', (tester) async {
      await _pumpApp(tester, BrixTheme.light(toastBuilder: _ownToast));
      BrixToast.success('Saved');
      await tester.pumpAndSettle();
      expect(find.text('my Saved'), findsOneWidget);
      await tester.pump(BrixToast.defaultDuration);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own-toast')), findsNothing);
    });

    testWidgets('dismiss from the own card hides it', (tester) async {
      await _pumpApp(tester, BrixTheme.light(toastBuilder: _ownToast));
      BrixToast.success('Saved');
      await tester.pumpAndSettle();
      await tester.tap(find.text('close'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own-toast')), findsNothing);
    });

    testWidgets('builder gets icon, accent and style', (tester) async {
      late BrixToastData seen;
      await _pumpApp(
        tester,
        BrixTheme.light(
          toast: const BrixToastStyle(iconSize: 30),
          toastBuilder: (context, toast) {
            seen = toast;
            return const SizedBox(height: 10);
          },
        ),
      );
      BrixToast.success('Hi', title: 'Done');
      await tester.pumpAndSettle();
      expect(seen.title, 'Done');
      expect(seen.accent, const BrixColors.light().success);
      expect(seen.icon, const BrixUiIcons().success);
      expect(seen.style.iconSize, 30);
    });
  });
}
