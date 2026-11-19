import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';

/// Asks for the reset code.
class ForgotPasswordViewModel extends BrixForgotPasswordNotifier {
  @override
  ForgotPasswordFlow createFlow() => ForgotPasswordFlow(
    provider: Dependencies.auth,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
  );
}

final forgotPasswordProvider =
    NotifierProvider.autoDispose<
      ForgotPasswordViewModel,
      BrixForgotPasswordState
    >(ForgotPasswordViewModel.new);
