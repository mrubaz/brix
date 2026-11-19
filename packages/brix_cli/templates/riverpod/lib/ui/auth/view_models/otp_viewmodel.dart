import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';

/// The code after signup; the email comes from the session store.
class OtpViewModel extends BrixOtpNotifier<User> {
  @override
  OtpVerificationFlow<User> createFlow() => OtpVerificationFlow(
    provider: Dependencies.auth,
    store: Dependencies.session,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
  );
}

final otpProvider = NotifierProvider.autoDispose<OtpViewModel, CodeEntryState>(
  OtpViewModel.new,
);
