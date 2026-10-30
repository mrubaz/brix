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

/// An app's own dialog card: tapping a button sends its value to brix.
Widget _ownAlert(BuildContext context, BrixDialogData dialog) {
  return Container(
    key: const Key('own-dialog'),
    color: dialog.accent,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('my ${dialog.title}'),
        for (final button in dialog.buttons)
          TextButton(
            onPressed: () => dialog.onPressed(button.value),
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
    BrixDialog.dismiss();
    BrixToast.dismiss();
    BrixUi.navigatorKey = null;
  });

  group('styles: merge, lerp, theme', () {
    test('dialog style', () {
      const a = BrixDialogStyle(maxWidth: 300, buttonsVertical: true);
      final b = a.merge(const BrixDialogStyle(maxWidth: 400));
      expect(b.maxWidth, 400);
      expect(b.buttonsVertical, isTrue);
      expect(a.lerp(b, 0.5).maxWidth, 350);
      final theme = BrixTheme.light().copyWith(dialog: a);
      expect(theme.dialog, a);
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

  group('dialog style', () {
    testWidgets('width, icon size, text alignment, title style', (
      tester,
    ) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          dialog: const BrixDialogStyle(
            maxWidth: 280,
            iconSize: 40,
            iconCircleSize: 70,
            textAlign: TextAlign.start,
            titleStyle: TextStyle(fontSize: 26),
          ),
        ),
      );
      BrixDialog.warning('Check this');
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
        BrixTheme.light(dialog: const BrixDialogStyle(showIcon: false)),
      );
      BrixDialog.error('Failed');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.error_outline_rounded), findsNothing);
      expect(find.text('Failed'), findsOneWidget);
    });

    testWidgets('buttons stacked when the style says so', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          dialog: const BrixDialogStyle(buttonsVertical: true, buttonGap: 20),
        ),
      );
      BrixDialog.show<int>(
        title: 'Pick',
        buttons: const [
          BrixDialogButton(label: 'A', value: 1),
          BrixDialogButton(label: 'B', value: 2),
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
        BrixTheme.light(dialog: const BrixDialogStyle(showIcon: false)),
      );
      BrixDialog.show<void>(
        title: 'Hi',
        icon: const BrixIcon(Icons.star),
        style: const BrixDialogStyle(showIcon: true),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('dialog placement', () {
    testWidgets('bottom alignment with a margin (sheet look)', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          dialog: const BrixDialogStyle(
            alignment: Alignment.bottomCenter,
            margin: EdgeInsets.fromLTRB(12, 0, 12, 30),
            transition: BrixDialogTransition.slideUp,
          ),
        ),
      );
      BrixDialog.warning('Low');
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
          dialog: const BrixDialogStyle(
            alignment: Alignment.topCenter,
            transition: BrixDialogTransition.slideDown,
          ),
        ),
      );
      BrixDialog.error('Top');
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.text('Something went wrong')).dy,
        lessThan(150),
      );
    });

    testWidgets('centre by default', (tester) async {
      await _pumpApp(tester, BrixTheme.light());
      BrixDialog.warning('Mid');
      await tester.pumpAndSettle();
      final screen = tester.getSize(find.byType(Scaffold));
      final message = tester.getCenter(find.text('Mid'));
      expect((message.dy - screen.height / 2).abs(), lessThan(80));
    });

    testWidgets('fade transition and its duration', (tester) async {
      await _pumpApp(
        tester,
        BrixTheme.light(
          dialog: const BrixDialogStyle(
            transition: BrixDialogTransition.fade,
            transitionDuration: Duration(milliseconds: 600),
          ),
        ),
      );
      final result = BrixDialog.show<int>(title: 'Slow');
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

    testWidgets('show(style:) moves one dialog', (tester) async {
      await _pumpApp(tester, BrixTheme.light());
      BrixDialog.show<void>(
        title: 'Here',
        style: const BrixDialogStyle(alignment: Alignment.topCenter),
      );
      await tester.pumpAndSettle();
      expect(tester.getTopLeft(find.text('Here')).dy, lessThan(150));
    });
  });

  group('dialog builder', () {
    testWidgets('own card; the tapped value still comes back', (tester) async {
      await _pumpApp(tester, BrixTheme.light(dialogBuilder: _ownAlert));
      final result = BrixDialog.show<bool>(
        title: 'Delete?',
        buttons: const [
          BrixDialogButton(label: 'No', value: false),
          BrixDialogButton.destructive(label: 'Yes', value: true),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own-dialog')), findsOneWidget);
      expect(find.text('my Delete?'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(find.byKey(const Key('own-dialog')), findsNothing);
    });

    testWidgets('warning in an own card: accent and OK close it', (
      tester,
    ) async {
      await _pumpApp(tester, BrixTheme.light(dialogBuilder: _ownAlert));
      BrixDialog.warning('Check');
      await tester.pumpAndSettle();
      final card = tester.widget<Container>(
        find.byKey(const Key('own-dialog')),
      );
      expect(card.color, const BrixColors.light().warning);
      expect(find.text('my Please check'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own-dialog')), findsNothing);
    });

    testWidgets('show(builder:) wins over the theme builder', (tester) async {
      await _pumpApp(tester, BrixTheme.light(dialogBuilder: _ownAlert));
      BrixDialog.show<void>(
        title: 'Hi',
        builder: (context, dialog) => const Text('one-off'),
      );
      await tester.pumpAndSettle();
      expect(find.text('one-off'), findsOneWidget);
      expect(find.byKey(const Key('own-dialog')), findsNothing);
    });

    testWidgets('own card still on the dimmed screen', (tester) async {
      await _pumpApp(tester, BrixTheme.light(dialogBuilder: _ownAlert));
      BrixDialog.error('x');
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
