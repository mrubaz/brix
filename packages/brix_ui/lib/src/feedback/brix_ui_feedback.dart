import 'package:brix/auth.dart';

import '../widgets/brix_alert.dart';
import '../widgets/brix_toast.dart';

/// A ready brix [AuthFeedback]: failures as the error alert, warnings as
/// the warning alert, success messages as a toast. Needs
/// `BrixUi.navigatorKey`.
///
/// ```dart
/// feedback: const BrixUiFeedback(),
/// ```
class BrixUiFeedback extends AuthFeedback {
  const BrixUiFeedback();

  /// The backend's messages; without any, brix's text for the failure type
  /// (e.g. no connection), so the alert is never empty.
  @override
  void failure(Failure failure) => BrixAlert.error(failure.displayMessage);

  @override
  void warning(AuthWarning warning) => BrixAlert.warning(warning.message);

  /// Nothing is shown when the backend sent no message.
  @override
  void success(String? message) {
    if (message != null && message.trim().isNotEmpty) {
      BrixToast.success(message);
    }
  }
}
