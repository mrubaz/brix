import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _texts = BrixUiTexts(
  ok: 'ٹھیک ہے',
  warningTitle: 'دیکھیں',
  errorTitle: 'خرابی',
  showPassword: 'دکھائیں',
  hidePassword: 'چھپائیں',
  requiredField: 'ضروری ہے',
);

const _icons = BrixUiIcons(
  warning: BrixIcon(Icons.info),
  error: BrixIcon(Icons.close),
  success: BrixIcon(Icons.thumb_up),
  showPassword: BrixIcon(Icons.lock_open),
  hidePassword: BrixIcon(Icons.lock),
);

final _custom = BrixTheme.light(texts: _texts, icons: _icons);

Future<void> _pumpApp(WidgetTester tester, Widget body) async {
  BrixUi.navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: BrixUi.navigatorKey,
      theme: _custom.toThemeData(),
      home: Scaffold(body: body),
    ),
  );
}

void main() {
  tearDown(() {
    BrixAlert.dismiss();
    BrixToast.dismiss();
    BrixUi.navigatorKey = null;
  });

  group('defaults', () {
    test('English texts and Material icons', () {
      const texts = BrixUiTexts();
      expect(texts.ok, 'OK');
      expect(texts.requiredField, 'This field is required.');
      expect(BrixTheme.light().texts, texts);
      expect(BrixTheme.dark().icons, const BrixUiIcons());
    });

    test('copyWith changes only the given value', () {
      final texts = const BrixUiTexts().copyWith(ok: 'Fine');
      expect(texts.ok, 'Fine');
      expect(texts.errorTitle, const BrixUiTexts().errorTitle);

      const tick = BrixIcon(Icons.done);
      final icons = const BrixUiIcons().copyWith(success: tick);
      expect(icons.success, tick);
      expect(icons.error, const BrixUiIcons().error);
    });

    test('theme copyWith and lerp carry texts and icons', () {
      final theme = BrixTheme.light().copyWith(texts: _texts, icons: _icons);
      expect(theme.texts, _texts);
      expect(theme.icons, _icons);
      expect(BrixTheme.light().lerp(theme, 0.4).texts, const BrixUiTexts());
      expect(BrixTheme.light().lerp(theme, 0.6).texts, _texts);
      expect(theme == BrixTheme.light(), isFalse);
    });
  });

  group('BrixIcon', () {
    testWidgets('IconData gets the colour and size', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: const BrixIcon(Icons.star)
              .build(color: const Color(0xFF00FF00), size: 40),
        ),
      );
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, const Color(0xFF00FF00));
      expect(icon.size, 40);
    });

    testWidgets('custom widget reads colour and size from IconTheme', (
      tester,
    ) async {
      late IconThemeData seen;
      final icon = BrixIcon.custom(
        Builder(
          builder: (context) {
            seen = IconTheme.of(context);
            return const SizedBox();
          },
        ),
      );
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: icon.build(color: const Color(0xFF0000FF), size: 32),
          ),
        ),
      );
      expect(seen.color, const Color(0xFF0000FF));
      expect(seen.size, 32);
      expect(
        tester.getSize(find.byType(SizedBox).first),
        const Size.square(32),
      );
    });
  });

  group('widgets use the theme texts and icons', () {
    testWidgets('warning alert', (tester) async {
      await _pumpApp(tester, const SizedBox());
      BrixAlert.warning('x');
      await tester.pumpAndSettle();
      expect(find.text('دیکھیں'), findsOneWidget);
      expect(find.text('ٹھیک ہے'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('error alert', (tester) async {
      await _pumpApp(tester, const SizedBox());
      BrixAlert.error('x');
      await tester.pumpAndSettle();
      expect(find.text('خرابی'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('show() default OK button', (tester) async {
      await _pumpApp(tester, const SizedBox());
      BrixAlert.show<void>(title: 'Hi');
      await tester.pumpAndSettle();
      expect(find.text('ٹھیک ہے'), findsOneWidget);
    });

    testWidgets('show() with an own icon', (tester) async {
      await _pumpApp(tester, const SizedBox());
      BrixAlert.show<void>(title: 'Hi', icon: const BrixIcon(Icons.delete));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('toast', (tester) async {
      await _pumpApp(tester, const SizedBox());
      BrixToast.success('Saved');
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
    });

    testWidgets('password button', (tester) async {
      await _pumpApp(tester, const BrixTextField(isPassword: true));
      expect(find.byTooltip('دکھائیں'), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      await tester.tap(find.byTooltip('دکھائیں'));
      await tester.pump();
      expect(find.byTooltip('چھپائیں'), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('required message; own message still wins', (tester) async {
      final form = GlobalKey<FormState>();
      await _pumpApp(
        tester,
        Form(
          key: form,
          child: const Column(
            children: [
              BrixTextField(isRequired: true),
              BrixTextField(isRequired: true, requiredMessage: 'Need it'),
            ],
          ),
        ),
      );
      form.currentState!.validate();
      await tester.pump();
      expect(find.text('ضروری ہے'), findsOneWidget);
      expect(find.text('Need it'), findsOneWidget);
    });
  });
}
