import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_keys.dart';
import 'demo/demo_auth_provider.dart';
import 'demo/demo_navigator.dart';
import 'demo/demo_session_store.dart';
import 'notifiers/app_notifiers.dart';

// The app's four adapters, shared by every flow.

final backendProvider = Provider((ref) => DemoAuthProvider());

final sessionStoreProvider = Provider((ref) => DemoSessionStore());

final navigatorProvider = Provider(
  (ref) => DemoNavigator(
    navigatorKey: AppKeys.navigator,
    // Login is already open under this screen: fill its email.
    prefillLogin: (identifier) =>
        ref.read(loginProvider.notifier).prefillIdentifier(identifier),
  ),
);

/// brix_ui's dialogs and toasts (needs `BrixUi.navigatorKey`).
final feedbackProvider = Provider<AuthFeedback>(
  (ref) => const BrixUiFeedback(),
);

// One provider per screen. Auto dispose: the notifier and its flow go
// away when the screen closes.

final sessionProvider =
    NotifierProvider.autoDispose<SessionNotifier, SessionState>(
      SessionNotifier.new,
    );

final loginProvider =
    NotifierProvider.autoDispose<LoginNotifier, BrixLoginState>(
      LoginNotifier.new,
    );

final signupProvider =
    NotifierProvider.autoDispose<SignupNotifier, BrixSignupState>(
      SignupNotifier.new,
    );

final otpProvider = NotifierProvider.autoDispose<OtpNotifier, CodeEntryState>(
  OtpNotifier.new,
);

final forgotPasswordProvider =
    NotifierProvider.autoDispose<ForgotPasswordNotifier, AuthFormState>(
      ForgotPasswordNotifier.new,
    );

/// One per email the code was sent to.
final resetPasswordProvider = NotifierProvider.autoDispose
    .family<ResetPasswordNotifier, BrixResetPasswordState, String>(
      ResetPasswordNotifier.new,
    );
