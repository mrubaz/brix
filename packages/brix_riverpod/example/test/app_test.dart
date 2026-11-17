import 'package:brix_riverpod_example/main.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The whole demo, like a user: sign up, verify, log in, log out, reset.
void main() {
  tearDown(() {
    BrixDialog.dismiss();
    BrixToast.dismiss();
  });

  testWidgets('sign up, code, log in, log out, reset password', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1200);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: BrixExampleApp()));
    await settle(tester);
    expect(find.text('Welcome back'), findsOneWidget);

    // Wrong password: the backend's message in brix_ui's error dialog.
    await enter(tester, 'Email', 'demo@brix.dev');
    await enter(tester, 'Password', 'nope');
    await tap(tester, find.widgetWithText(BrixButton, 'Log in'));
    expect(find.text('Wrong email or password.'), findsOneWidget);
    await tap(tester, find.text('OK'));

    // Sign up a new account; a weak password is stopped by brix.
    await tap(tester, find.text('No account? Sign up'));
    await enter(tester, 'Name', 'Ada');
    await enter(tester, 'Email', 'ada@brix.dev');
    await enter(tester, 'Password', 'weak');
    await enter(tester, 'Confirm password', 'weak');
    await tap(tester, find.widgetWithText(BrixButton, 'Sign up'));
    expect(find.text('The password does not meet all the rules.'), findsOne);
    await tap(tester, find.text('OK'));

    await enter(tester, 'Password', 'Strong@123');
    await enter(tester, 'Confirm password', 'Strong@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Sign up'));
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.text('Code sent to ad•••@brix.dev'), findsOneWidget);

    // Typing the last digit verifies at once and opens login, email filled.
    await tester.enterText(find.byType(TextField).first, '123456');
    await settle(tester);
    expect(find.text('Email verified. Please log in.'), findsOneWidget);
    expect(find.text('ada@brix.dev'), findsOneWidget);

    await enter(tester, 'Password', 'Strong@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Log in'));
    expect(find.text('You are logged in.'), findsOneWidget);

    await tap(tester, find.widgetWithText(BrixButton, 'Log out'));
    expect(find.widgetWithText(BrixButton, 'Log in'), findsOneWidget);

    // Forgot, then code + new password, then back to login with the email.
    await tap(tester, find.text('Forgot password?'));
    await enter(tester, 'Email', 'ada@brix.dev');
    await tap(tester, find.widgetWithText(BrixButton, 'Send code'));
    expect(find.text('New password'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '123456');
    await enter(tester, 'New password', 'Newer@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Save password'));
    expect(find.text('Password changed. Please log in.'), findsOneWidget);
    expect(find.text('ada@brix.dev'), findsOneWidget);

    await enter(tester, 'Password', 'Newer@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Log in'));
    expect(find.text('You are logged in.'), findsOneWidget);

    await tap(tester, find.widgetWithText(BrixButton, 'Log out'));
  });
}

/// Types into the [BrixTextField] with this [label].
Future<void> enter(WidgetTester tester, String label, String text) async {
  final field = find.descendant(
    of: find.byWidgetPredicate((w) => w is BrixTextField && w.label == label),
    matching: find.byType(TextField),
  );
  await tester.ensureVisible(field.last);
  await tester.enterText(field.last, text);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.tap(finder.first);
  await settle(tester);
}

// Demo calls take 600 ms; dialogs, toasts and routes need time too.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}
