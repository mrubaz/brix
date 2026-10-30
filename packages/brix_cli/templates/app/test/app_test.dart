import 'dart:io';

import 'package:brix_app/dev/local_accounts_service.dart';
import 'package:brix_app/dev/local_backend.dart';
import 'package:brix_app/dev/local_box.dart';
import 'package:brix_app/main.dart';
import 'package:brix_storage/brix_storage.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// The whole app on the local backend, like a user.
void main() {
  late Directory dir;

  setUp(() {
    Get.testMode = true;
    dir = Directory.systemTemp.createTempSync('app_test');
    startWithLocalBackend(
      accounts: LocalAccountsService(
        LocalBox(File('${dir.path}/backend.json')),
      ),
      storage: BrixStorage(values: MemoryStore(), secrets: MemoryStore()),
    );
  });
  tearDown(() {
    BrixDialog.dismiss();
    BrixToast.dismiss();
    Get.reset();
    dir.deleteSync(recursive: true);
  });

  Future<void> start(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1200);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await settle(tester);
  }

  Future<void> logIn(WidgetTester tester, String email, String password) async {
    await enter(tester, 'Email', email);
    await enter(tester, 'Password', password);
    await tap(tester, find.widgetWithText(BrixButton, 'Log in'));
  }

  testWidgets('sign up, code, log in, log out, reset password', (tester) async {
    await start(tester);
    expect(find.textContaining('demo@brix.dev'), findsOneWidget); // dev hint

    await logIn(tester, 'demo@brix.dev', 'nope');
    expect(find.text('Wrong email or password.'), findsOneWidget);
    await tap(tester, find.text('OK'));

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
    await tester.enterText(find.byType(TextField).first, '123456');
    await settle(tester);

    await enter(tester, 'Password', 'Strong@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Log in'));
    expect(find.text('Hello Ada'), findsOneWidget);

    await tap(tester, find.text('Log out'));
    await tap(tester, find.text('Forgot password?'));
    await enter(tester, 'Email', 'ada@brix.dev');
    await tap(tester, find.widgetWithText(BrixButton, 'Send code'));
    await tester.enterText(find.byType(TextField).first, '123456');
    await enter(tester, 'New password', 'Newer@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Save password'));

    await logIn(tester, 'ada@brix.dev', 'Newer@123');
    expect(find.text('Hello Ada'), findsOneWidget);
  });

  testWidgets('profile, change password, delete account', (tester) async {
    await start(tester);
    await logIn(tester, 'demo@brix.dev', 'Demo@1234');
    expect(find.text('Hello Demo'), findsOneWidget);

    // Profile: change the name.
    await tap(tester, find.text('Profile'));
    expect(find.text('demo@brix.dev'), findsOneWidget);
    await enter(tester, 'Name', 'Grace');
    await tap(tester, find.widgetWithText(BrixButton, 'Save'));
    expect(find.text('Profile saved.'), findsOneWidget);
    // The success toast covers the top bar until it hides.
    await tester.pump(BrixToast.defaultDuration);
    await settle(tester);
    await tap(tester, find.byType(BackButton));

    // Change password: wrong current one first.
    await tap(tester, find.text('Change password'));
    await enter(tester, 'Current password', 'nope');
    await enter(tester, 'New password', 'Fresh@123');
    await enter(tester, 'Confirm new password', 'Fresh@123');
    await tap(tester, find.widgetWithText(BrixButton, 'Change password').last);
    expect(find.text('The current password is wrong.'), findsOneWidget);
    await tap(tester, find.text('OK'));
    await enter(tester, 'Current password', 'Demo@1234');
    await tap(tester, find.widgetWithText(BrixButton, 'Change password').last);
    expect(find.text('Password changed.'), findsOneWidget);

    // Delete account with the code.
    await tap(tester, find.text('Delete account'));
    await tap(tester, find.text('Send me a code'));
    for (var i = 0; i < 6; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
      await tester.pump();
    }
    await tap(tester, find.text('Delete my account'));
    expect(find.widgetWithText(BrixButton, 'Log in'), findsOneWidget);

    // Gone on this device, also with the new password.
    await logIn(tester, 'demo@brix.dev', 'Fresh@123');
    expect(find.text('Wrong email or password.'), findsOneWidget);
    await tap(tester, find.text('OK'));

    // Reset brings the demo account back, on this device only.
    await tap(tester, find.text('Reset local backend'));
    await logIn(tester, 'demo@brix.dev', 'Demo@1234');
    expect(find.text('Hello Demo'), findsOneWidget);
  });

  testWidgets('skip login opens home as the test user', (tester) async {
    await start(tester);
    await tap(tester, find.text('Skip login'));
    expect(find.text('Hello Demo'), findsOneWidget);
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

// Local calls take 600 ms; dialogs, toasts and routes need time too.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 200));
  }
}
