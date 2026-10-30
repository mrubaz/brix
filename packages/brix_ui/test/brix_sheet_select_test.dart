import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  BrixTheme? theme,
}) async {
  BrixUi.navigatorKey = GlobalKey<NavigatorState>();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(400, 800);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: BrixUi.navigatorKey,
      theme: (theme ?? BrixTheme.light()).toThemeData(),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    ),
  );
}

const _few = [
  BrixOption(value: 'pk', label: 'Pakistan'),
  BrixOption(value: 'gb', label: 'United Kingdom'),
  BrixOption(value: 'ae', label: 'United Arab Emirates'),
];

final _many = [
  for (var i = 1; i <= 10; i++) BrixOption(value: i, label: 'Option $i'),
];

void main() {
  tearDown(() => BrixUi.navigatorKey = null);

  group('BrixSheet', () {
    testWidgets('opens with a title, closes with a value', (tester) async {
      await _pump(tester, const SizedBox());
      final result = BrixSheet.show<String>(
        title: 'Pick one',
        builder: (context) => TextButton(
          onPressed: () => BrixSheet.close(context, 'blue'),
          child: const Text('Blue'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pick one'), findsOneWidget);

      await tester.tap(find.text('Blue'));
      await tester.pumpAndSettle();
      expect(await result, 'blue');
      expect(find.text('Pick one'), findsNothing);
    });

    testWidgets('tap outside closes it with null', (tester) async {
      await _pump(tester, const SizedBox());
      final result = BrixSheet.show<int>(
        builder: (context) => const Text('Content'),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
      expect(find.text('Content'), findsNothing);
      expect(await result, isNull);
    });

    testWidgets('drag down closes it', (tester) async {
      await _pump(tester, const SizedBox());
      BrixSheet.show<void>(
        builder: (context) => const SizedBox(height: 200, child: Text('Drag')),
      );
      await tester.pumpAndSettle();
      await tester.fling(find.text('Drag'), const Offset(0, 400), 1500);
      await tester.pumpAndSettle();
      expect(find.text('Drag'), findsNothing);
    });

    testWidgets('not dismissible: stays until closed in code', (tester) async {
      await _pump(tester, const SizedBox());
      BrixSheet.show<void>(
        dismissible: false,
        builder: (context) => const Text('Stay'),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(200, 40));
      await tester.pumpAndSettle();
      expect(find.text('Stay'), findsOneWidget);
    });

    testWidgets('grabber shown by default, hidden by the style', (
      tester,
    ) async {
      await _pump(tester, const SizedBox());
      BrixSheet.show<void>(builder: (context) => const Text('A'));
      await tester.pumpAndSettle();
      final grabber = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.constraints?.maxWidth == 36 &&
            w.constraints?.maxHeight == 5,
      );
      expect(grabber, findsOneWidget);
      Navigator.of(tester.element(find.text('A'))).pop();
      await tester.pumpAndSettle();

      BrixSheet.show<void>(
        style: const BrixSheetStyle(showGrabber: false),
        builder: (context) => const Text('B'),
      );
      await tester.pumpAndSettle();
      expect(grabber, findsNothing);
    });

    testWidgets('heights: half and full', (tester) async {
      await _pump(tester, const SizedBox());
      BrixSheet.show<void>(
        height: BrixSheetHeight.half,
        builder: (context) => const Text('Half'),
      );
      await tester.pumpAndSettle();
      final half = tester.getSize(find.byType(BrixSheet)).height;
      expect(half, closeTo(400, 30));
      Navigator.of(tester.element(find.text('Half'))).pop();
      await tester.pumpAndSettle();

      BrixSheet.show<void>(
        height: BrixSheetHeight.full,
        builder: (context) => const Text('Full'),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(BrixSheet)).height, greaterThan(650));
    });

    testWidgets('theme colour, radius and scrim', (tester) async {
      await _pump(
        tester,
        const SizedBox(),
        theme: BrixTheme.light(
          sheet: const BrixSheetStyle(
            backgroundColor: Color(0xFF112233),
            radius: 30,
            scrimColor: Color(0x22000000),
          ),
        ),
      );
      BrixSheet.show<void>(builder: (context) => const Text('A'));
      await tester.pumpAndSettle();
      final panel = tester
          .widgetList<Container>(find.byType(Container))
          .firstWhere(
            (c) =>
                c.decoration is BoxDecoration &&
                (c.decoration! as BoxDecoration).color ==
                    const Color(0xFF112233),
          );
      expect(
        (panel.decoration! as BoxDecoration).borderRadius,
        const BorderRadius.vertical(top: Radius.circular(30)),
      );
      expect(
        tester
            .widgetList<ModalBarrier>(find.byType(ModalBarrier))
            .map((b) => b.color),
        contains(const Color(0x22000000)),
      );
    });

    testWidgets('own panel from the builder; closing still works', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(),
        theme: BrixTheme.light(
          sheetBuilder: (context, sheet) => ColoredBox(
            key: const Key('own'),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('my ${sheet.title}'),
                sheet.child,
                TextButton(
                  onPressed: () => sheet.close(7),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
      final result = BrixSheet.show<int>(
        title: 'Title',
        builder: (context) => const Text('Body'),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('own')), findsOneWidget);
      expect(find.text('my Title'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(await result, 7);
    });

    test('style merge and lerp', () {
      const a = BrixSheetStyle(radius: 10, showGrabber: true);
      final b = a.merge(const BrixSheetStyle(radius: 20));
      expect(b.radius, 20);
      expect(b.showGrabber, isTrue);
      expect(a.lerp(b, 0.5).radius, 15);
      expect(BrixTheme.light().copyWith(sheet: a).sheet, a);
    });
  });

  group('BrixSelect', () {
    testWidgets('shows the hint, then the chosen option (menu)', (
      tester,
    ) async {
      String? chosen;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => BrixSelect<String>(
            label: 'Country',
            options: _few,
            value: chosen,
            onChanged: (value) => setState(() => chosen = value),
          ),
        ),
      );
      expect(find.text('Choose'), findsOneWidget);

      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNWidgets(3));

      await tester.tap(find.text('United Kingdom'));
      await tester.pumpAndSettle();
      expect(chosen, 'gb');
      expect(find.text('United Kingdom'), findsOneWidget);
      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('the chosen option has a tick in the menu', (tester) async {
      await _pump(
        tester,
        BrixSelect<String>(options: _few, value: 'pk', onChanged: (_) {}),
      );
      await tester.tap(find.text('Pakistan'));
      await tester.pumpAndSettle();
      final row = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Pakistan'),
      );
      expect(row.trailingIcon, isNotNull);
      final other = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'United Kingdom'),
      );
      expect(other.trailingIcon, isNull);
    });

    testWidgets('many options open a sheet; picking closes it', (tester) async {
      int? chosen;
      await _pump(
        tester,
        BrixSelect<int>(
          label: 'Number',
          options: _many,
          onChanged: (value) => chosen = value,
        ),
      );
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      expect(find.byType(BrixSheet), findsOneWidget);
      expect(find.text('Number'), findsNWidgets(2)); // label + sheet title

      await tester.tap(find.text('Option 3'));
      await tester.pumpAndSettle();
      expect(chosen, 3);
      expect(find.byType(BrixSheet), findsNothing);
      expect(find.text('Option 3'), findsOneWidget);
    });

    testWidgets('mode forces a sheet for a few options', (tester) async {
      await _pump(
        tester,
        BrixSelect<String>(
          options: _few,
          mode: BrixSelectMode.sheet,
          sheetTitle: 'Where?',
          onChanged: (_) {},
        ),
      );
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      expect(find.text('Where?'), findsOneWidget);
      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('required: form check with the theme text', (tester) async {
      final form = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(
          key: form,
          child: BrixSelect<String>(
            label: 'Country',
            isRequired: true,
            options: _few,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Country *'), findsOneWidget);
      expect(form.currentState!.validate(), isFalse);
      await tester.pump();
      expect(find.text('This field is required.'), findsOneWidget);

      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pakistan'));
      await tester.pumpAndSettle();
      expect(form.currentState!.validate(), isTrue);
    });

    testWidgets('a new value from the app shows in the field', (tester) async {
      var value = 'pk';
      late StateSetter set;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) {
            set = setState;
            return BrixSelect<String>(
              options: _few,
              value: value,
              onChanged: (_) {},
            );
          },
        ),
      );
      expect(find.text('Pakistan'), findsOneWidget);
      set(() => value = 'ae');
      await tester.pumpAndSettle();
      expect(find.text('United Arab Emirates'), findsOneWidget);
    });

    testWidgets('disabled does not open', (tester) async {
      await _pump(
        tester,
        BrixSelect<String>(options: _few, enabled: false, onChanged: (_) {}),
      );
      await tester.tap(find.text('Choose'));
      await tester.pumpAndSettle();
      expect(find.byType(MenuItemButton), findsNothing);
    });

    testWidgets('field follows the text field style', (tester) async {
      await _pump(
        tester,
        BrixSelect<String>(options: _few, onChanged: (_) {}),
        theme: BrixTheme.light(
          textField: const BrixTextFieldStyle(
            border: BrixFieldBorder.underline,
          ),
        ),
      );
      final decorator = tester.widget<InputDecorator>(
        find.byType(InputDecorator),
      );
      expect(decorator.decoration.enabledBorder, isA<UnderlineInputBorder>());
    });

    testWidgets('own field from the builder; brix still opens and picks', (
      tester,
    ) async {
      String? chosen;
      await _pump(
        tester,
        BrixSelect<String>(
          options: _few,
          onChanged: (value) => chosen = value,
          builder: (context, select) => TextButton(
            onPressed: select.open,
            child: Text(select.selected?.label ?? 'Pick a country'),
          ),
        ),
      );
      await tester.tap(find.text('Pick a country'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pakistan'));
      await tester.pumpAndSettle();
      expect(chosen, 'pk');
      expect(find.widgetWithText(TextButton, 'Pakistan'), findsOneWidget);
    });

    testWidgets('theme select builder works for any type', (tester) async {
      await _pump(
        tester,
        BrixSelect<int>(options: _many, value: 2, onChanged: (_) {}),
        theme: BrixTheme.light(
          selectBuilder: (context, select) =>
              Text('theme: ${select.selected?.label}'),
        ),
      );
      expect(find.text('theme: Option 2'), findsOneWidget);
    });

    test('style merge and lerp; texts and icons', () {
      const a = BrixSelectStyle(menuRadius: 10);
      expect(a.merge(const BrixSelectStyle(menuRadius: 20)).menuRadius, 20);
      expect(a.lerp(const BrixSelectStyle(menuRadius: 20), 0.5).menuRadius, 15);
      expect(const BrixUiTexts().selectHint, 'Choose');
      expect(const BrixUiIcons().selected.icon, Icons.check_rounded);
    });
  });
}
