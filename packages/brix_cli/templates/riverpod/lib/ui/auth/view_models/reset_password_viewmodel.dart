import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';

/// Code and new password for [identifier], the email the code went to.
class ResetPasswordViewModel extends BrixResetPasswordNotifier {
  ResetPasswordViewModel(this.identifier);

  final String identifier;

  @override
  ResetPasswordFlow createFlow() => ResetPasswordFlow(
    provider: Dependencies.auth,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
    identifier: identifier,
    store: Dependencies.session,
  );
}

/// One per email.
final resetPasswordProvider = NotifierProvider.autoDispose
    .family<ResetPasswordViewModel, BrixResetPasswordState, String>(
      ResetPasswordViewModel.new,
    );
