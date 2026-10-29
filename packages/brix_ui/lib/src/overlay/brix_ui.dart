import 'package:flutter/widgets.dart';

/// App-wide setup for alerts and toasts shown without a `BuildContext`
/// (e.g. from a controller).
///
/// ```dart
/// MaterialApp(navigatorKey: BrixUi.navigatorKey ??= GlobalKey())
/// // GetX: BrixUi.navigatorKey = Get.key;
/// ```
abstract final class BrixUi {
  /// The app's navigator key. Not needed when every call passes a
  /// `context`.
  static GlobalKey<NavigatorState>? navigatorKey;

  /// The top overlay: from [context] when given, else from [navigatorKey].
  static OverlayState overlayOf(BuildContext? context) {
    final overlay = context != null
        ? Overlay.of(context, rootOverlay: true)
        : navigatorKey?.currentState?.overlay;
    if (overlay == null) {
      throw StateError(
        'brix_ui: pass a context, or set BrixUi.navigatorKey to the '
        "MaterialApp's navigatorKey (GetX: Get.key) before showing an alert "
        'or a toast.',
      );
    }
    return overlay;
  }

  /// A context under the app's navigator: [context] when given, else
  /// [navigatorKey]'s.
  static BuildContext contextOf(BuildContext? context) {
    final found = context ?? navigatorKey?.currentContext;
    if (found == null) {
      throw StateError(
        'brix_ui: pass a context, or set BrixUi.navigatorKey to the '
        "MaterialApp's navigatorKey (GetX: Get.key) before showing an alert.",
      );
    }
    return found;
  }
}
