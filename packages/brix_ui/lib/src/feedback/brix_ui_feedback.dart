import 'package:brix/auth.dart';

import '../widgets/brix_dialog.dart';
import '../widgets/brix_toast.dart';

/// A ready brix [AuthFeedback]: failures as the error dialog, warnings as
/// the warning dialog, success messages as a toast. Needs
/// `BrixUi.navigatorKey`.
///
/// ```dart
/// feedback: const BrixUiFeedback(),
/// ```
class BrixUiFeedback extends AuthFeedback {
  const BrixUiFeedback();

  /// The backend's messages; without any, brix's text for the failure type
  /// (e.g. no connection), so the dialog is never empty.
  @override
  void failure(Failure failure) => BrixDialog.error(failure.displayMessage);

  @override
  void warning(AuthWarning warning) => BrixDialog.warning(warning.message);

  /// Nothing is shown when the backend sent no message.
  @override
  void success(String? message) {
    if (message != null && message.trim().isNotEmpty) {
      BrixToast.success(message);
    }
  }
}
