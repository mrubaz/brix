import 'package:flutter/widgets.dart';

/// The navigator key the demo navigator and brix_ui's dialogs use to open
/// screens without a `BuildContext`.
abstract final class AppKeys {
  static final navigator = GlobalKey<NavigatorState>();
}
