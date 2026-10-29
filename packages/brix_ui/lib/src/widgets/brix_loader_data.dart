import 'package:flutter/widgets.dart';

/// Draws every `BrixLoader` – also the spinner inside a loading
/// `BrixButton` – with the app's own widget (a Lottie, a branded
/// spinner…).
typedef BrixLoaderBuilder = Widget Function(
  BuildContext context,
  BrixLoaderData loader,
);

/// What a [BrixLoaderBuilder] gets.
class BrixLoaderData {
  const BrixLoaderData({required this.radius, required this.color});

  /// Half the size the spinner should take.
  final double radius;

  /// The colour it should use (e.g. `onPrimary` inside a filled button).
  final Color color;
}
