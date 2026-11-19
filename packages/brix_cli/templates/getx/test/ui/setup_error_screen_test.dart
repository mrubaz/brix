import 'package:brix_app/ui/core/widgets/setup_steps.dart';
import 'package:brix_app/ui/setup/widgets/setup_error_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('a release without an API shows the problem and the steps', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 900);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const SetupErrorScreen(message: 'Set API_URL.'));

    expect(find.text('The app is not set up'), findsOneWidget);
    expect(find.text('Set API_URL.'), findsOneWidget);
    for (final step in SetupSteps.steps.take(2)) {
      expect(find.text(step.title), findsOneWidget);
    }
    // The page scrolls to the last step.
    await tester.scrollUntilVisible(
      find.text(SetupSteps.steps.last.title),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text(SetupSteps.steps.last.title), findsOneWidget);
  });
}
