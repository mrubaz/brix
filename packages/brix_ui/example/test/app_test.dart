import 'package:brix_ui/brix_ui.dart';
import 'package:brix_ui_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Like a user: sign in, alerts, dark mode, every brand.
void main() {
  setUp(() => BrixUi.navigatorKey = null);
  tearDown(() {
    BrixAlert.dismiss();
    BrixToast.dismiss();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1400);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BrixUiExampleApp());
    await settle(tester);
  }

  BrixTheme theme(WidgetTester tester) =>
      BrixTheme.of(tester.element(find.text('Sign in').first));

  testWidgets('empty sign in: field errors and a warning', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(BrixButton, 'Sign in'));
    await settle(tester);
    expect(find.text('This field is required.'), findsNWidgets(2));
    expect(find.text('Fill in your email and password.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await settle(tester);
  });

  testWidgets('sign in: loading, then a toast', (tester) async {
    await pumpApp(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'you@example.com'),
      'ada@brix.dev',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'Secret@123');
    await tester.tap(find.widgetWithText(BrixButton, 'Sign in'));
    await tester.pump();
    expect(
      tester.widget<BrixButton>(find.byType(BrixButton).first).isLoading,
      isTrue,
    );
    await tester.pump(const Duration(milliseconds: 1300));
    await settle(tester);
    expect(find.text('Signed in as ada@brix.dev'), findsOneWidget);
  });

  testWidgets('confirm delete returns a value → toast', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Delete photo'));
    await settle(tester);
    expect(find.text('Delete this photo?'), findsOneWidget);
    await tester.tap(find.widgetWithText(BrixButton, 'Delete'));
    await settle(tester);
    expect(find.text('Photo deleted'), findsOneWidget);
  });

  testWidgets('warning, error and toast buttons', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Error'));
    await settle(tester);
    expect(find.text('No internet connection.'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await settle(tester);

    await tester.tap(find.text('Toast'));
    await settle(tester);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('dark mode switches the theme, widgets stay', (tester) async {
    await pumpApp(tester);
    expect(theme(tester).brightness, Brightness.light);
    await tester.tap(find.byTooltip('Dark mode'));
    await settle(tester);
    expect(theme(tester).brightness, Brightness.dark);
    expect(find.byType(BrixTextField), findsNWidgets(2));
  });

  testWidgets('Forest: underline fields, bottom sheet alert', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Forest'));
    await settle(tester);
    expect(theme(tester).textField.border, BrixFieldBorder.underline);
    expect(find.text('SIGN IN'), findsOneWidget); // capital buttons

    await tester.tap(find.text('WARNING'));
    await settle(tester);
    final screen = tester.getSize(find.byType(Scaffold));
    expect(
      tester.getBottomLeft(find.text('OK')).dy,
      greaterThan(screen.height - 120),
    );
  });

  testWidgets('Sunset: own buttons, Urdu texts', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Sunset'));
    await settle(tester);
    // The app's own button widget: no brix Ink inside any BrixButton.
    expect(
      find.descendant(of: find.byType(BrixButton), matching: find.byType(Ink)),
      findsNothing,
    );

    await tester.tap(find.text('Warning'));
    await settle(tester);
    expect(find.text('توجہ کریں'), findsOneWidget);
    await tester.tap(find.text('ٹھیک ہے'));
    await settle(tester);
    expect(find.text('توجہ کریں'), findsNothing);
  });
}

// The loader on the screen spins forever, so pumpAndSettle never ends -
// pump long enough for routes, alerts and toasts to finish moving.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
