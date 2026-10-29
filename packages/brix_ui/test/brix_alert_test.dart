import 'package:brix/auth.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _theme = BrixTheme.light(
  colors: const BrixColors.light(
    warning: Color(0xFF000011),
    danger: Color(0xFF000022),
    success: Color(0xFF000033),
    scrim: Color(0x44000044),
  ),
);

/// An app with a navigator key and a screen with a counter button, to see
/// whether taps reach the screen under an alert.
Future<void> _pumpApp(
  WidgetTester tester, {
  BrixTheme? theme,
  VoidCallback? onScreenTap,
}) async {
  BrixUi.navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: BrixUi.navigatorKey,
      theme: (theme ?? _theme).toThemeData(),
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: onScreenTap,
            child: const Text('Screen button'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() {
    BrixAlert.dismiss();
    BrixToast.dismiss();
    BrixUi.navigatorKey = null;
  });

  group('BrixAlert.show', () {
    testWidgets('returns the tapped button value', (tester) async {
      await _pumpApp(tester);
      final result = BrixAlert.show<bool>(
        title: 'Delete this photo?',
        message: 'This cannot be undone.',
        buttons: const [
          BrixAlertButton(label: 'Cancel', value: false),
          BrixAlertButton.destructive(label: 'Delete', value: true),
        ],
      );
      await tester.pumpAndSettle();
      expect(find.text('Delete this photo?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(await result, isTrue);
      expect(find.text('Delete this photo?'), findsNothing);
    });

    testWidgets('no buttons given: one OK, returns null', (tester) async {
      await _pumpApp(tester);
      final result = BrixAlert.show<String>(title: 'Done');
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(await result, isNull);
    });

    testWidgets('dims the screen with the theme scrim', (tester) async {
      await _pumpApp(tester);
      BrixAlert.show<void>(title: 'Hi');
      await tester.pumpAndSettle();
      final barriers = tester.widgetList<ModalBarrier>(
        find.byType(ModalBarrier),
      );
      expect(barriers.map((b) => b.color), contains(_theme.colors.scrim));
    });

    testWidgets('tapping outside closes only when dismissible', (tester) async {
      await _pumpApp(tester);
      BrixAlert.show<void>(title: 'Stay');
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      final result = BrixAlert.show<int>(title: 'Go', dismissible: true);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.text('Go'), findsNothing);
      expect(await result, isNull);
    });

    testWidgets('two buttons side by side, three stacked', (tester) async {
      await _pumpApp(tester);
      BrixAlert.show<int>(
        title: 'Pick',
        buttons: const [
          BrixAlertButton(label: 'A', value: 1),
          BrixAlertButton.primary(label: 'B', value: 2),
        ],
      );
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('A')).dy,
        tester.getCenter(find.text('B')).dy,
      );
      await tester.tap(find.text('A'));
      await tester.pumpAndSettle();

      BrixAlert.show<int>(
        title: 'Pick',
        buttons: const [
          BrixAlertButton(label: 'A', value: 1),
          BrixAlertButton(label: 'B', value: 2),
          BrixAlertButton(label: 'C', value: 3),
        ],
      );
      await tester.pumpAndSettle();
      expect(
        tester.getCenter(find.text('B')).dy,
        greaterThan(tester.getCenter(find.text('A')).dy),
      );
    });

    testWidgets('own content is shown', (tester) async {
      await _pumpApp(tester);
      BrixAlert.show<void>(title: 'Note', content: const Text('Extra'));
      await tester.pumpAndSettle();
      expect(find.text('Extra'), findsOneWidget);
    });

    testWidgets('works with a context and no navigator key', (tester) async {
      late BuildContext screen;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              screen = context;
              return const SizedBox();
            },
          ),
        ),
      );
      BrixAlert.show<void>(context: screen, title: 'Hello');
      await tester.pumpAndSettle();
      expect(find.text('Hello'), findsOneWidget);
    });

    test('no context and no navigator key: clear error', () {
      expect(
        () => BrixAlert.show<void>(title: 'x'),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('BrixUi.navigatorKey'),
          ),
        ),
      );
    });
  });

  group('BrixAlert.warning / error', () {
    testWidgets('warning: default title, warning colour, OK closes', (
      tester,
    ) async {
      await _pumpApp(tester);
      BrixAlert.warning('Enter your email.');
      await tester.pumpAndSettle();

      expect(find.text('Please check'), findsOneWidget);
      expect(find.text('Enter your email.'), findsOneWidget);
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.warning_amber_rounded),
      );
      expect(icon.color, _theme.colors.warning);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your email.'), findsNothing);
    });

    testWidgets('error: default title, danger colour, own title', (
      tester,
    ) async {
      await _pumpApp(tester);
      BrixAlert.error('Server down');
      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.error_outline_rounded),
      );
      expect(icon.color, _theme.colors.danger);

      BrixAlert.error('Try later', title: 'Oops');
      await tester.pumpAndSettle();
      expect(find.text('Oops'), findsOneWidget);
    });

    testWidgets('a new alert replaces the open one', (tester) async {
      await _pumpApp(tester);
      BrixAlert.warning('First');
      await tester.pumpAndSettle();
      BrixAlert.error('Second');
      await tester.pumpAndSettle();
      expect(find.text('First'), findsNothing);
      expect(find.text('Second'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsNothing);
    });

    testWidgets('blocks taps on the screen below', (tester) async {
      var taps = 0;
      await _pumpApp(tester, onScreenTap: () => taps++);
      BrixAlert.warning('Wait');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Screen button'), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('stays on top while the screen below changes', (tester) async {
      await _pumpApp(tester);
      BrixAlert.error('Saved failed');
      BrixUi.navigatorKey!.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Text('Next screen')),
      );
      await tester.pumpAndSettle();
      expect(find.text('Next screen'), findsOneWidget);
      expect(find.text('Saved failed'), findsOneWidget);
    });

    testWidgets('long message scrolls instead of overflowing', (tester) async {
      await _pumpApp(tester);
      BrixAlert.error(List.filled(80, 'A very long line of text.').join('\n'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('dark theme: card uses the dark surface', (tester) async {
      await _pumpApp(tester, theme: BrixTheme.dark());
      BrixAlert.warning('Dark');
      await tester.pumpAndSettle();
      final card = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration! as BoxDecoration).color ==
                    const BrixColors.dark().surface,
          );
      expect(card, isNotEmpty);
    });

    testWidgets('glass theme: frosted card', (tester) async {
      await _pumpApp(tester, theme: BrixTheme.light(glass: true));
      BrixAlert.warning('Glass');
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('solid by default: no blur', (tester) async {
      await _pumpApp(tester);
      BrixAlert.warning('Solid');
      await tester.pumpAndSettle();
      expect(find.byType(BackdropFilter), findsNothing);
    });
  });

  group('BrixToast', () {
    testWidgets('shows at the top and hides by itself', (tester) async {
      await _pumpApp(tester);
      BrixToast.success('Profile saved');
      await tester.pumpAndSettle();
      expect(find.text('Profile saved'), findsOneWidget);
      expect(tester.getTopLeft(find.text('Profile saved')).dy, lessThan(100));
      final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_rounded));
      expect(icon.color, _theme.colors.success);

      await tester.pump(BrixToast.defaultDuration);
      await tester.pumpAndSettle();
      expect(find.text('Profile saved'), findsNothing);
    });

    testWidgets('own duration and title', (tester) async {
      await _pumpApp(tester);
      BrixToast.success(
        'All good',
        title: 'Saved',
        duration: const Duration(seconds: 1),
      );
      await tester.pumpAndSettle();
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('All good'), findsNothing);
    });

    testWidgets('tap hides it early', (tester) async {
      await _pumpApp(tester);
      BrixToast.success('Tap me');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tap me'));
      await tester.pumpAndSettle();
      expect(find.text('Tap me'), findsNothing);
    });

    testWidgets('swipe up hides it early', (tester) async {
      await _pumpApp(tester);
      BrixToast.success('Swipe me');
      await tester.pumpAndSettle();
      await tester.fling(find.text('Swipe me'), const Offset(0, -100), 800);
      await tester.pumpAndSettle();
      expect(find.text('Swipe me'), findsNothing);
    });

    testWidgets('a new toast replaces the open one and keeps its time', (
      tester,
    ) async {
      await _pumpApp(tester);
      BrixToast.success('One');
      await tester.pump(const Duration(seconds: 2));
      BrixToast.success('Two');
      await tester.pumpAndSettle();
      expect(find.text('One'), findsNothing);
      expect(find.text('Two'), findsOneWidget);

      // The first toast's timer must not close the second one.
      await tester.pump(const Duration(seconds: 1, milliseconds: 500));
      expect(find.text('Two'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Two'), findsNothing);
    });

    testWidgets('does not block the screen', (tester) async {
      var taps = 0;
      await _pumpApp(tester, onScreenTap: () => taps++);
      BrixToast.success('Saved');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Screen button'));
      expect(taps, 1);
    });

    testWidgets('announced to screen readers', (tester) async {
      final semantics = tester.ensureSemantics();
      await _pumpApp(tester);
      BrixToast.success('Saved');
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(BrixToast)),
        isSemantics(isLiveRegion: true),
      );
      semantics.dispose();
    });
  });

  group('BrixUiFeedback', () {
    const feedback = BrixUiFeedback();

    testWidgets('failure with backend messages shows them', (tester) async {
      await _pumpApp(tester);
      feedback.failure(
        ValidationFailure(messages: ['Email taken', 'Phone invalid']),
      );
      await tester.pumpAndSettle();
      expect(find.text('Email taken\nPhone invalid'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('failure without messages shows the brix default', (
      tester,
    ) async {
      await _pumpApp(tester);
      final failure = NetworkFailure();
      feedback.failure(failure);
      await tester.pumpAndSettle();
      expect(find.text(failure.defaultMessage), findsOneWidget);
    });

    testWidgets('warning shows its brix text', (tester) async {
      await _pumpApp(tester);
      feedback.warning(AuthWarning.otpIncomplete);
      await tester.pumpAndSettle();
      expect(find.text(AuthWarning.otpIncomplete.message), findsOneWidget);
      expect(find.text('Please check'), findsOneWidget);
    });

    testWidgets('success shows a toast; nothing when no message', (
      tester,
    ) async {
      await _pumpApp(tester);
      feedback.success(null);
      feedback.success('  ');
      await tester.pumpAndSettle();
      expect(find.byType(BrixToast), findsNothing);

      feedback.success('Logged in');
      await tester.pumpAndSettle();
      expect(find.text('Logged in'), findsOneWidget);
    });
  });
}
