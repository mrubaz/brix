import 'package:flutter/cupertino.dart';

import '../theme/brix_theme_context.dart';
import 'brix_loader_data.dart';

/// The iOS-style spinner, centred, in the theme's quiet text colour.
///
/// Its size and colour come from `BrixTheme.loader`; draw an own spinner
/// for the whole app with `BrixTheme.loaderBuilder` (loading buttons use it
/// too).
///
/// ```dart
/// if (isLoading) const BrixLoader()
/// ```
class BrixLoader extends StatelessWidget {
  const BrixLoader({super.key, this.radius, this.color});

  /// Size of the spinner; default `loader.radius`, else 10 (iOS).
  final double? radius;

  /// Default: `loader.color`, else `colors.mutedText`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final data = BrixLoaderData(
      radius: radius ?? brix.loader.radius ?? 10,
      color: color ?? brix.loader.color ?? brix.colors.mutedText,
    );
    final builder = brix.loaderBuilder;
    return Center(
      child: builder != null
          ? builder(context, data)
          : CupertinoActivityIndicator(radius: data.radius, color: data.color),
    );
  }
}
