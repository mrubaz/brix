import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';

/// Current, new and confirm password.
class ChangePasswordViewModel extends BrixChangePasswordNotifier {
  @override
  ChangePasswordFlow createFlow() => ChangePasswordFlow(
    account: Dependencies.account,
    store: Dependencies.session,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
  );
}

final changePasswordProvider =
    NotifierProvider.autoDispose<
      ChangePasswordViewModel,
      BrixChangePasswordState
    >(ChangePasswordViewModel.new);
