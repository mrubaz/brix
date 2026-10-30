import 'package:flutter/widgets.dart';

import 'brix_theme.dart';

/// `context.brix.colors.primary`, short for [BrixTheme.of].
extension BrixThemeContext on BuildContext {
  BrixTheme get brix => BrixTheme.of(this);
}
