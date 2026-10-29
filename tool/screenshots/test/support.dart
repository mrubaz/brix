import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const pageColor = Color(0xFFE9ECF1);
const mono = 'SFMono';
const symbols = 'AppleSymbols';

/// Roboto + Material icons from the Flutter SDK, SF Mono from macOS.
Future<void> loadFonts() async {
  final root =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Process.runSync('which', ['flutter']).stdout.toString().trim())
          .resolveSymbolicLinksSync()
          .replaceAll('/bin/flutter', '');
  final sdkFonts = '$root/bin/cache/artifacts/material_fonts';

  Future<void> load(String family, List<String> paths) async {
    final loader = FontLoader(family);
    for (final path in paths) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
  }

  await load('Roboto', [
    '$sdkFonts/Roboto-Regular.ttf',
    '$sdkFonts/Roboto-Medium.ttf',
    '$sdkFonts/Roboto-Bold.ttf',
  ]);
  await load('MaterialIcons', ['$sdkFonts/MaterialIcons-Regular.otf']);
  await load(mono, ['/System/Library/Fonts/SFNSMono.ttf']);
  // ▰ and arrows are not in SF Mono / Roboto.
  await load(symbols, ['/System/Library/Fonts/Apple Symbols.ttf']);
}

/// Pumps [child] on a [size] page, painted at 2x so thin lines stay sharp,
/// and saves it as [path].
Future<void> shoot(
  WidgetTester tester,
  String path,
  Widget child, {
  required Size size,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size * 2;
  addTearDown(tester.view.reset);
  debugDisableShadows = false;
  try {
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: const Key('shot'),
          child: FittedBox(
            child: SizedBox.fromSize(
              size: size,
              child: Material(
                color: pageColor,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Align(alignment: Alignment.topCenter, child: child),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(find.byKey(const Key('shot')), matchesGoldenFile(path));
  } finally {
    debugDisableShadows = true;
  }
}

/// A dark terminal window that shows [lines] with their ANSI colours.
class Terminal extends StatelessWidget {
  const Terminal({super.key, required this.title, required this.lines});

  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: const Color(0xFF2D2D2D),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                for (final color in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ]) ...[
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 13,
                    color: Color(0xFFB0B0B0),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final line in lines)
                  Text.rich(
                    TextSpan(children: ansiSpans(line)),
                    softWrap: false,
                    style: const TextStyle(
                      fontFamily: mono,
                      fontFamilyFallback: [symbols],
                      fontSize: 13,
                      height: 1.45,
                      color: Color(0xFFD4D4D4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _fg = {
  30: Color(0xFF000000),
  31: Color(0xFFF14C4C),
  32: Color(0xFF23D18B),
  33: Color(0xFFF5F543),
  34: Color(0xFF3B8EEA),
  90: Color(0xFF8A8A8A),
  97: Color(0xFFFFFFFF),
};

const _bg = {
  41: Color(0xFFCD3131),
  42: Color(0xFF0DBC79),
  43: Color(0xFFE5E510),
  44: Color(0xFF2472C8),
  100: Color(0xFF666666),
};

/// Turns one line with ANSI colour codes into styled spans.
List<TextSpan> ansiSpans(String line) {
  final spans = <TextSpan>[];
  final pattern = RegExp('\x1B\\[([0-9;]*)m');
  var style = const TextStyle();
  var start = 0;
  for (final match in pattern.allMatches(line)) {
    if (match.start > start) {
      spans.add(
        TextSpan(text: line.substring(start, match.start), style: style),
      );
    }
    final codes = match.group(1)!.split(';').map(int.tryParse).toList();
    for (var i = 0; i < codes.length; i++) {
      final code = codes[i] ?? 0;
      if (code == 0) {
        style = const TextStyle();
      } else if (code == 1) {
        style = style.copyWith(fontWeight: FontWeight.w700);
      } else if (code == 38 && i + 2 < codes.length && codes[i + 1] == 5) {
        style = style.copyWith(color: _xterm(codes[i + 2]!));
        i += 2;
      } else if (_fg.containsKey(code)) {
        style = style.copyWith(color: _fg[code]);
      } else if (_bg.containsKey(code)) {
        style = style.copyWith(backgroundColor: _bg[code]);
      }
    }
    start = match.end;
  }
  if (start < line.length) {
    spans.add(TextSpan(text: line.substring(start), style: style));
  }
  return spans;
}

/// The xterm 256-colour cube (16–231).
Color _xterm(int n) {
  if (n < 16 || n > 231) return const Color(0xFFD4D4D4);
  final i = n - 16;
  int level(int v) => v == 0 ? 0 : 55 + v * 40;
  return Color.fromARGB(255, level(i ~/ 36), level((i ~/ 6) % 6), level(i % 6));
}
