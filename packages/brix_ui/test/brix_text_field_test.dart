import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final _theme = BrixTheme.light(
  colors: const BrixColors.light(
    primary: Color(0xFF000011),
    danger: Color(0xFF000022),
    border: Color(0xFF000033),
  ),
);

Future<void> _pump(WidgetTester tester, Widget child, {BrixTheme? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: (theme ?? _theme).toThemeData(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

InputDecoration _decoration(WidgetTester tester, [int index = 0]) => tester
    .widgetList<TextField>(find.byType(TextField))
    .elementAt(index)
    .decoration!;

TextField _textField(WidgetTester tester, [int index = 0]) =>
    tester.widgetList<TextField>(find.byType(TextField)).elementAt(index);

Color _borderColor(InputBorder? border) =>
    (border! as OutlineInputBorder).borderSide.color;

void main() {
  testWidgets('label above, * only when required', (tester) async {
    await _pump(tester, const BrixTextField(label: 'Email', isRequired: true));
    expect(find.text('Email *'), findsOneWidget);

    await _pump(tester, const BrixTextField(label: 'Email'));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Email *'), findsNothing);
  });

  testWidgets('screen readers hear the label with the field', (tester) async {
    final semantics = tester.ensureSemantics();
    await _pump(tester, const BrixTextField(label: 'Email'));
    expect(
      tester.getSemantics(find.byType(TextField)),
      isSemantics(label: 'Email', isTextField: true),
    );
    semantics.dispose();
  });

  testWidgets('typing calls onChanged; text is not changed', (tester) async {
    final controller = TextEditingController();
    final changes = <String>[];
    await _pump(
      tester,
      BrixTextField(controller: controller, onChanged: changes.add),
    );
    await tester.enterText(find.byType(TextField), ' a b ');
    expect(controller.text, ' a b ');
    expect(changes, [' a b ']);
  });

  group('password', () {
    testWidgets('hidden, eye button shows and hides it', (tester) async {
      await _pump(tester, const BrixTextField(isPassword: true));
      expect(_textField(tester).obscureText, isTrue);
      expect(_textField(tester).autocorrect, isFalse);
      expect(_textField(tester).enableSuggestions, isFalse);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(_textField(tester).obscureText, isFalse);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(_textField(tester).obscureText, isTrue);
    });

    testWidgets('value is never trimmed', (tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        BrixTextField(controller: controller, isPassword: true),
      );
      await tester.enterText(find.byType(TextField), '  pass  ');
      expect(controller.text, '  pass  ');
    });

    testWidgets('eye button replaces suffixIcon', (tester) async {
      await _pump(
        tester,
        const BrixTextField(isPassword: true, suffixIcon: Icon(Icons.star)),
      );
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byTooltip('Show password'), findsOneWidget);
    });
  });

  group('validation', () {
    Future<FormState> pumpForm(WidgetTester tester, Widget field) async {
      final key = GlobalKey<FormState>();
      await _pump(tester, Form(key: key, child: field));
      return key.currentState!;
    }

    testWidgets('required + empty shows the default message', (tester) async {
      final form = await pumpForm(
        tester,
        const BrixTextField(isRequired: true),
      );
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);
      expect(
        _borderColor(_decoration(tester).errorBorder),
        _theme.colors.danger,
      );
    });

    testWidgets('spaces only count as empty, but not for passwords', (
      tester,
    ) async {
      var form = await pumpForm(
        tester,
        const BrixTextField(isRequired: true, requiredMessage: 'Needed'),
      );
      await tester.enterText(find.byType(TextField), '   ');
      expect(form.validate(), isFalse);

      form = await pumpForm(
        tester,
        const BrixTextField(isRequired: true, isPassword: true),
      );
      await tester.enterText(find.byType(TextField), '   ');
      expect(form.validate(), isTrue);
    });

    testWidgets('not required: no check', (tester) async {
      final form = await pumpForm(tester, const BrixTextField());
      expect(form.validate(), isTrue);
    });

    testWidgets('own validator wins over the empty check', (tester) async {
      final form = await pumpForm(
        tester,
        BrixTextField(
          isRequired: true,
          validator: (value) => value == 'ok' ? null : 'Type ok',
        ),
      );
      expect(form.validate(), isFalse);
      await tester.pump();
      expect(find.text('Type ok'), findsOneWidget);
      expect(find.text('This field is required.'), findsNothing);

      await tester.enterText(find.byType(TextField), 'ok');
      expect(form.validate(), isTrue);
    });

    testWidgets('errorText from outside is shown', (tester) async {
      await _pump(tester, const BrixTextField(errorText: 'Email taken'));
      expect(find.text('Email taken'), findsOneWidget);
    });
  });

  group('keyboard', () {
    testWidgets('Next moves to the next field', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            BrixTextField(textInputAction: TextInputAction.next),
            BrixTextField(),
          ],
        ),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(_textField(tester, 1).focusNode!.hasFocus, isTrue);
    });

    testWidgets('Done (default) closes the keyboard and submits', (
      tester,
    ) async {
      final submitted = <String>[];
      await _pump(tester, BrixTextField(onSubmitted: submitted.add));
      expect(_textField(tester).textInputAction, TextInputAction.done);

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'hi');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      expect(submitted, ['hi']);
      expect(_textField(tester).focusNode!.hasFocus, isFalse);
    });

    testWidgets('multi-line defaults to a new line action', (tester) async {
      await _pump(tester, const BrixTextField(maxLines: 4));
      expect(_textField(tester).textInputAction, TextInputAction.newline);
    });

    testWidgets('tap outside closes the keyboard', (tester) async {
      await _pump(tester, const BrixTextField());
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(_textField(tester).focusNode!.hasFocus, isTrue);

      await tester.tapAt(const Offset(400, 500));
      await tester.pump();
      expect(_textField(tester).focusNode!.hasFocus, isFalse);
    });

    testWidgets('autofill hints are passed on', (tester) async {
      await _pump(
        tester,
        const BrixTextField(autofillHints: [AutofillHints.email]),
      );
      expect(_textField(tester).autofillHints, [AutofillHints.email]);
    });

    testWidgets('formatters and max length apply', (tester) async {
      final controller = TextEditingController();
      await _pump(
        tester,
        BrixTextField(
          controller: controller,
          maxLength: 3,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      );
      await tester.enterText(find.byType(TextField), 'a12345');
      expect(controller.text, '123');
    });
  });

  group('look', () {
    testWidgets('border, focus and fill come from the theme', (tester) async {
      await _pump(tester, const BrixTextField());
      final decoration = _decoration(tester);
      expect(_borderColor(decoration.enabledBorder), _theme.colors.border);
      expect(_borderColor(decoration.focusedBorder), _theme.colors.primary);
      expect(decoration.fillColor, _theme.colors.surface);
    });

    testWidgets('read-only: no focus colour, background fill', (tester) async {
      var taps = 0;
      await _pump(tester, BrixTextField(readOnly: true, onTap: () => taps++));
      final decoration = _decoration(tester);
      expect(_borderColor(decoration.focusedBorder), _theme.colors.border);
      expect(decoration.fillColor, _theme.colors.background);
      await tester.tap(find.byType(TextField));
      expect(taps, 1);
    });

    testWidgets('height is at least the theme field height', (tester) async {
      await _pump(
        tester,
        const BrixTextField(),
        theme: BrixTheme.light(shape: const BrixShape(fieldHeight: 60)),
      );
      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(60),
      );
    });

    testWidgets('follows the dark theme with no widget change', (tester) async {
      await _pump(tester, const BrixTextField(), theme: BrixTheme.dark());
      expect(_decoration(tester).fillColor, const BrixColors.dark().surface);
    });

    testWidgets('disabled: cannot type, quiet text', (tester) async {
      await _pump(tester, const BrixTextField(enabled: false));
      expect(_textField(tester).enabled, isFalse);
      expect(_textField(tester).style?.color, _theme.colors.mutedText);
    });
  });

  testWidgets('own focus node is used and not disposed', (tester) async {
    final node = FocusNode();
    await _pump(tester, BrixTextField(focusNode: node));
    await tester.tap(find.byType(TextField));
    expect(node.hasFocus, isTrue);
    await tester.pumpWidget(const SizedBox());
    node.addListener(() {}); // throws if it was disposed
    node.dispose();
  });
}
