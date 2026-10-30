import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(WidgetTester tester, Widget child, {BrixTheme? theme}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: (theme ?? BrixTheme.light()).toThemeData(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

InputDecoration _decoration(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

/// An app's own field: a plain TextFormField wired with brix's data.
Widget _ownField(BuildContext context, BrixTextFieldData field) {
  return Column(
    key: const Key('own'),
    children: [
      if (field.label != null) Text('my ${field.label}'),
      TextFormField(
        controller: field.controller,
        focusNode: field.focusNode,
        obscureText: field.obscureText,
        validator: field.validator,
        textInputAction: field.textInputAction,
        onEditingComplete: field.onEditingComplete,
        onTapOutside: field.onTapOutside,
        onFieldSubmitted: field.onSubmitted,
        autocorrect: field.autocorrect,
      ),
      if (field.toggleObscured != null)
        TextButton(
          onPressed: field.toggleObscured,
          child: Text(field.obscureText ? 'show' : 'hide'),
        ),
    ],
  );
}

void main() {
  group('BrixTextFieldStyle', () {
    test('merge: set values of the other win, text styles combine', () {
      const theme = BrixTextFieldStyle(
        border: BrixFieldBorder.underline,
        radius: 20,
        textStyle: TextStyle(fontSize: 18),
      );
      final merged = theme.merge(
        const BrixTextFieldStyle(
          radius: 4,
          textStyle: TextStyle(letterSpacing: 1),
        ),
      );
      expect(merged.border, BrixFieldBorder.underline);
      expect(merged.radius, 4);
      expect(merged.textStyle?.fontSize, 18);
      expect(merged.textStyle?.letterSpacing, 1);
      expect(theme.merge(null), theme);
    });

    test('lerp blends numbers and switches choices half way', () {
      const a = BrixTextFieldStyle(radius: 10, border: BrixFieldBorder.outline);
      const b = BrixTextFieldStyle(
        radius: 20,
        border: BrixFieldBorder.underline,
      );
      expect(a.lerp(b, 0.5).radius, 15);
      expect(a.lerp(b, 0.4).border, BrixFieldBorder.outline);
      expect(a.lerp(b, 0.6).border, BrixFieldBorder.underline);
    });

    test('theme carries it', () {
      const style = BrixTextFieldStyle(labelInside: true);
      final theme = BrixTheme.dark().copyWith(textField: style);
      expect(theme.textField, style);
      expect(theme == BrixTheme.dark(), isFalse);
      expect(BrixTheme.dark().lerp(theme, 1).textField.labelInside, isTrue);
    });
  });

  group('theme style', () {
    testWidgets('underline: line border, no fill', (tester) async {
      await _pump(
        tester,
        const BrixTextField(),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(
            border: BrixFieldBorder.underline,
          ),
        ),
      );
      final decoration = _decoration(tester);
      expect(decoration.enabledBorder, isA<UnderlineInputBorder>());
      expect(decoration.focusedBorder, isA<UnderlineInputBorder>());
      expect(decoration.filled, isFalse);
    });

    testWidgets('none: no edge, still filled', (tester) async {
      await _pump(
        tester,
        const BrixTextField(),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(
            border: BrixFieldBorder.none,
            fillColor: Color(0xFFEEEEEE),
          ),
        ),
      );
      final decoration = _decoration(tester);
      expect(
        (decoration.enabledBorder! as OutlineInputBorder).borderSide,
        BorderSide.none,
      );
      expect(decoration.filled, isTrue);
      expect(decoration.fillColor, const Color(0xFFEEEEEE));
    });

    testWidgets('radius, widths, padding and height', (tester) async {
      await _pump(
        tester,
        const BrixTextField(),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(
            radius: 24,
            borderWidth: 2,
            focusedBorderWidth: 4,
            contentPadding: EdgeInsets.all(20),
            height: 64,
          ),
        ),
      );
      final decoration = _decoration(tester);
      final enabled = decoration.enabledBorder! as OutlineInputBorder;
      expect(enabled.borderRadius, BorderRadius.circular(24));
      expect(enabled.borderSide.width, 2);
      expect(
        (decoration.focusedBorder! as OutlineInputBorder).borderSide.width,
        4,
      );
      expect(decoration.contentPadding, const EdgeInsets.all(20));
      expect(
        tester.getSize(find.byType(TextField)).height,
        greaterThanOrEqualTo(64),
      );
    });

    testWidgets('label inside the field, * kept', (tester) async {
      await _pump(
        tester,
        const BrixTextField(label: 'Email', isRequired: true),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(labelInside: true),
        ),
      );
      expect(_decoration(tester).label, isNotNull);
      expect(find.text('Email *'), findsOneWidget);
      // Only one label, none above the field.
      expect(find.byType(Column), findsNothing);
    });

    testWidgets('label gap and text styles', (tester) async {
      await _pump(
        tester,
        BrixTextField(
          label: 'Name',
          hint: 'Your name',
          controller: TextEditingController(),
        ),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(
            labelGap: 20,
            textStyle: TextStyle(letterSpacing: 2),
            labelStyle: TextStyle(fontSize: 18),
            hintStyle: TextStyle(fontStyle: FontStyle.italic),
          ),
        ),
      );
      expect(
        tester.getTopLeft(find.byType(TextField)).dy -
            tester.getBottomLeft(find.text('Name')).dy,
        20,
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.letterSpacing, 2);
      expect(field.style?.color, const BrixColors.light().text);
      expect(field.decoration?.hintStyle?.fontStyle, FontStyle.italic);
      final label = tester.widget<Text>(find.text('Name'));
      expect(label.style?.fontSize, 18);
    });
  });

  testWidgets('a field\'s own style wins over the theme', (tester) async {
    await _pump(
      tester,
      const BrixTextField(style: BrixTextFieldStyle(radius: 2)),
      theme: BrixTheme.light(
        textField: const BrixTextFieldStyle(radius: 30, borderWidth: 3),
      ),
    );
    final border = _decoration(tester).enabledBorder! as OutlineInputBorder;
    expect(border.borderRadius, BorderRadius.circular(2));
    expect(border.borderSide.width, 3);
  });

  testWidgets('initialValue works without a controller', (tester) async {
    await _pump(tester, const BrixTextField(initialValue: 'Ada'));
    expect(find.text('Ada'), findsOneWidget);
  });

  group('builder', () {
    testWidgets('theme builder draws every field', (tester) async {
      await _pump(
        tester,
        const BrixTextField(label: 'Email'),
        theme: BrixTheme.light(textFieldBuilder: _ownField),
      );
      expect(find.byKey(const Key('own')), findsOneWidget);
      expect(find.text('my Email'), findsOneWidget);
    });

    testWidgets('brix\'s required check runs in the own field', (tester) async {
      final form = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(key: form, child: const BrixTextField(isRequired: true)),
        theme: BrixTheme.light(textFieldBuilder: _ownField),
      );
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);
    });

    testWidgets('password show / hide is kept by brix', (tester) async {
      await _pump(
        tester,
        const BrixTextField(isPassword: true),
        theme: BrixTheme.light(textFieldBuilder: _ownField),
      );
      TextField field() => tester.widget<TextField>(find.byType(TextField));
      expect(field().obscureText, isTrue);
      expect(field().autocorrect, isFalse);
      await tester.tap(find.text('show'));
      await tester.pump();
      expect(field().obscureText, isFalse);
      expect(find.text('hide'), findsOneWidget);
    });

    testWidgets('Next moves to the next field', (tester) async {
      await _pump(
        tester,
        const Column(
          children: [
            BrixTextField(textInputAction: TextInputAction.next),
            BrixTextField(),
          ],
        ),
        theme: BrixTheme.light(textFieldBuilder: _ownField),
      );
      await tester.tap(find.byType(TextField).first);
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();
      expect(
        tester
            .widgetList<TextField>(find.byType(TextField))
            .last
            .focusNode!
            .hasFocus,
        isTrue,
      );
    });

    testWidgets('own controller is used; made one keeps initialValue', (
      tester,
    ) async {
      late BrixTextFieldData seen;
      final controller = TextEditingController(text: 'mine');
      await _pump(
        tester,
        BrixTextField(
          controller: controller,
          builder: (context, field) {
            seen = field;
            return const SizedBox();
          },
        ),
      );
      expect(seen.controller, same(controller));

      await _pump(
        tester,
        BrixTextField(
          initialValue: 'start',
          builder: (context, field) {
            seen = field;
            return const SizedBox();
          },
        ),
      );
      expect(seen.controller.text, 'start');
    });

    testWidgets('builder gets the merged style and the field settings', (
      tester,
    ) async {
      late BrixTextFieldData seen;
      await _pump(
        tester,
        BrixTextField(
          label: 'Bio',
          hint: 'A few words',
          maxLines: 4,
          errorText: 'Too short',
          style: const BrixTextFieldStyle(radius: 3),
          builder: (context, field) {
            seen = field;
            return const SizedBox();
          },
        ),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(
            border: BrixFieldBorder.underline,
          ),
        ),
      );
      expect(seen.label, 'Bio');
      expect(seen.hint, 'A few words');
      expect(seen.maxLines, 4);
      expect(seen.textInputAction, TextInputAction.newline);
      expect(seen.errorText, 'Too short');
      expect(seen.style.border, BrixFieldBorder.underline);
      expect(seen.style.radius, 3);
      expect(seen.toggleObscured, isNull);
    });

    testWidgets('a field\'s own builder wins over the theme builder', (
      tester,
    ) async {
      await _pump(
        tester,
        BrixTextField(builder: (context, field) => const Text('mine')),
        theme: BrixTheme.light(textFieldBuilder: _ownField),
      );
      expect(find.text('mine'), findsOneWidget);
      expect(find.byKey(const Key('own')), findsNothing);
    });
  });
}
