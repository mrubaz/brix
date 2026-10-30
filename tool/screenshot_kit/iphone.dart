// Shared by the screenshot tests: Apple fonts, an iPhone frame and a page
// that saves several phones side by side as one sharp PNG.
//
// Imported by path from each package's screenshot test (macOS only).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const sfPro = 'SF Pro';
const sfMono = 'SF Mono';
const pageColor = Color(0xFFF2F2F7);
const captionColor = Color(0xFF6E6E73);

/// SF Pro, SF Mono and Apple Symbols from macOS, Material icons from the
/// Flutter SDK.
Future<void> loadAppleFonts() async {
  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      loader.addFont(
        Future.value(ByteData.sublistView(File(path).readAsBytesSync())),
      );
    }
    await loader.load();
  }

  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(
        Process.runSync('which', ['flutter']).stdout.toString().trim(),
      ).resolveSymbolicLinksSync().replaceAll('/bin/flutter', '');
  await load(sfPro, ['/System/Library/Fonts/SFNS.ttf']);
  await load(sfMono, ['/System/Library/Fonts/SFNSMono.ttf']);
  await load('Apple Symbols', ['/System/Library/Fonts/Apple Symbols.ttf']);
  await load('MaterialIcons', [
    '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
  ]);
}

/// [theme] for an iPhone: iOS behaviour (back chevron, centred titles,
/// page slides) and SF Pro everywhere.
ThemeData iosTheme(ThemeData theme) => theme.copyWith(
  platform: TargetPlatform.iOS,
  textTheme: theme.textTheme.apply(fontFamily: sfPro),
  primaryTextTheme: theme.primaryTextTheme.apply(fontFamily: sfPro),
);

/// An iPhone 15 (393 × 852 points) showing [child] with the status bar,
/// Dynamic Island and home indicator. [dark] picks the status bar colour.
class IPhone extends StatelessWidget {
  const IPhone({super.key, required this.child, this.dark = false});

  static const size = Size(393, 852);
  static const _bezel = 12.0;

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final ink = dark ? Colors.white : Colors.black;
    return Container(
      width: size.width + _bezel * 2,
      height: size.height + _bezel * 2,
      padding: const EdgeInsets.all(_bezel),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(64),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 40,
            offset: Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(52),
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            padding: const EdgeInsets.only(top: 59, bottom: 34),
            viewPadding: const EdgeInsets.only(top: 59, bottom: 34),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: child),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 54,
                child: IgnorePointer(child: _StatusBar(ink: ink)),
              ),
              Positioned(
                top: 11,
                left: (size.width - 126) / 2,
                child: Container(
                  width: 126,
                  height: 37,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: (size.width - 140) / 2,
                child: Container(
                  width: 140,
                  height: 5,
                  decoration: BoxDecoration(
                    color: ink,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.ink});

  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(52, 18, 34, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '9:41',
            style: TextStyle(
              fontFamily: sfPro,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: ink,
              decoration: TextDecoration.none,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: CustomPaint(
              size: const Size(76, 13),
              painter: _StatusIcons(ink),
            ),
          ),
        ],
      ),
    );
  }
}

/// Signal bars, Wi-Fi and battery, drawn like iOS does.
class _StatusIcons extends CustomPainter {
  _StatusIcons(this.ink);

  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = ink;
    // Signal: four bars.
    for (var i = 0; i < 4; i++) {
      final h = 4.0 + i * 2.6;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * 4.6, 12 - h, 3, h),
          const Radius.circular(1),
        ),
        fill,
      );
    }
    // Wi-Fi: three arcs and a dot.
    final wifi = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const center = Offset(31, 12);
    for (final r in [3.5, 7.0, 10.5]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -2.35,
        1.57,
        false,
        wifi,
      );
    }
    // Battery.
    final outline = Paint()
      ..color = ink.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(47, 0.5, 25, 12),
      const Radius.circular(3.5),
    );
    canvas.drawRRect(body, outline);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(49, 2.5, 21, 8),
        const Radius.circular(2),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(73.5, 4.5, 1.6, 4),
        const Radius.circular(1),
      ),
      Paint()..color = ink.withValues(alpha: 0.4),
    );
  }

  @override
  bool shouldRepaint(_StatusIcons old) => old.ink != ink;
}

/// One phone (or any widget) with its caption under it.
class Captioned extends StatelessWidget {
  const Captioned({super.key, required this.caption, required this.child});

  final String caption;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(height: 22),
        Text(
          caption,
          style: const TextStyle(
            fontFamily: sfPro,
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: captionColor,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }
}

/// Lays [items] out in a row on a light grey page and saves `[path]` at 2x,
/// so thin lines and text stay sharp.
Future<void> shootRow(
  WidgetTester tester,
  String path,
  List<Widget> items, {
  double gap = 56,
  double padding = 64,
  Size? size,
  Future<void> Function()? prepare,
}) async {
  final width =
      size?.width ??
      padding * 2 +
          items.length * (IPhone.size.width + 24) +
          (items.length - 1) * gap;
  final height = size?.height ?? padding * 2 + IPhone.size.height + 24 + 52;
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width * 2, height * 2);
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  try {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: const Key('shot'),
          child: FittedBox(
            child: SizedBox(
              width: width,
              height: height,
              child: ColoredBox(
                color: pageColor,
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) SizedBox(width: gap),
                        items[i],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    // E.g. tap something to open a menu before the picture is taken.
    if (prepare != null) {
      await prepare();
      await tester.pump(const Duration(milliseconds: 600));
    }
    await expectLater(find.byKey(const Key('shot')), matchesGoldenFile(path));
  } finally {
    debugDisableShadows = true;
  }
}
