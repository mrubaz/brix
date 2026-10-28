import 'package:brix_getx_example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The whole demo, like a user: sign up, verify, log in, log out, reset.
void main() {
  testWidgets('sign up → code → log in → log out → reset password', (
    tester,
  ) async {
    await tester.pumpWidget(const BrixExampleApp());
    await settle(tester);
    expect(find.text('Log in'), findsWidgets);

    // Wrong password: the backend's message.
    await enter(tester, 'Email', 'demo@brix.dev');
    await enter(tester, 'Password', 'nope');
    await tap(tester, find.widgetWithText(FilledButton, 'Log in'));
    expect(find.text('Wrong email or password.'), findsOneWidget);

    // Sign up a new account; a weak password is stopped by brix.
    await tap(tester, find.text('No account? Sign up'));
    await enter(tester, 'Name', 'Ada');
    await enter(tester, 'Email', 'ada@brix.dev');
    await enter(tester, 'Password', 'weak');
    await enter(tester, 'Confirm password', 'weak');
    await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
    expect(find.text('The password does not meet all the rules.'), findsOne);

    await enter(tester, 'Password', 'Strong@123');
    await enter(tester, 'Confirm password', 'Strong@123');
    await tap(tester, find.widgetWithText(FilledButton, 'Sign up'));
    expect(find.text('Check your email'), findsOneWidget);
    expect(find.text('Code sent to ad•••@brix.dev'), findsOneWidget);

    // Typing the last digit verifies at once and opens login, email filled.
    await tester.enterText(find.byType(TextField).first, '123456');
    await settle(tester);
    expect(find.text('Email verified. Please log in.'), findsOneWidget);
    expect(find.text('ada@brix.dev'), findsOneWidget);

    await enter(tester, 'Password', 'Strong@123');
    await tap(tester, find.widgetWithText(FilledButton, 'Log in'));
    expect(find.text('You are logged in.'), findsOneWidget);

    await tap(tester, find.text('Log out'));
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);

    // Forgot → code + new password → back to login with the email.
    await tap(tester, find.text('Forgot password?'));
    await enter(tester, 'Email', 'ada@brix.dev');
    await tap(tester, find.widgetWithText(FilledButton, 'Send code'));
    expect(find.text('New password'), findsWidgets);

    await tester.enterText(find.byType(TextField).first, '123456');
    await enter(tester, 'New password', 'Newer@123');
    await tap(tester, find.widgetWithText(FilledButton, 'Save password'));
    expect(find.text('Password changed. Please log in.'), findsOneWidget);
    expect(find.text('ada@brix.dev'), findsOneWidget);

    await enter(tester, 'Password', 'Newer@123');
    await tap(tester, find.widgetWithText(FilledButton, 'Log in'));
    expect(find.text('You are logged in.'), findsOneWidget);

    await tap(tester, find.text('Log out'));
  });
}

Future<void> enter(WidgetTester tester, String label, String text) async {
  await tester.enterText(find.widgetWithText(TextFormField, label), text);
  await tester.pump();
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await settle(tester);
}

// Demo calls take 600 ms; snackbars and route animations need time too.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}
