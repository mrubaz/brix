import 'package:flutter/widgets.dart';

/// The app's logo: brix's brick mark (two rows of bricks on a brick orange
/// square). Replace this widget with your own logo, for example
/// `Image.asset('assets/logo.png', width: size)`, and every screen that
/// shows it follows.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 28});

  /// Width and height in points.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Drawn on a 28 point grid, like the logo on the brix website.
    final unit = size / 28;
    Widget brick(double left, double top, double width) => Positioned(
      left: left * unit,
      top: top * unit,
      width: width * unit,
      height: 6 * unit,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(1.6 * unit),
        ),
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8 * unit),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE4572E), Color(0xFFB8361A)],
          ),
        ),
        child: Stack(
          children: [brick(6, 7, 16), brick(6, 15, 7), brick(15, 15, 7)],
        ),
      ),
    );
  }
}
