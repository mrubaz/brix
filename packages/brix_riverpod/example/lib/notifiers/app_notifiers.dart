import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/widgets.dart';

import '../demo/demo_auth_provider.dart';
import '../providers.dart';

// Each notifier only says where its flow comes from. Everything else is in
// brix_riverpod.

class SessionNotifier extends BrixSessionNotifier<String> {
  @override
  SessionFlow<String> createFlow() => SessionFlow(
    auth: ref.read(backendProvider),
    store: ref.read(sessionStoreProvider),
    navigator: ref.read(navigatorProvider),
    feedback: ref.read(feedbackProvider),
  );
}

class LoginNotifier extends BrixLoginNotifier<String> {
  @override
  LoginFlow<String> createFlow() => LoginFlow(
    provider: ref.read(backendProvider),
    store: ref.read(sessionStoreProvider),
    navigator: ref.read(navigatorProvider),
    feedback: ref.read(feedbackProvider),
  );
}

/// Brix's signup notifier plus the app's own field (name) and body.
class SignupNotifier extends BrixSignupNotifier<DemoSignup, String> {
  late TextEditingController nameController;

  @override
  SignupFlow<DemoSignup, String> createFlow() => SignupFlow(
    provider: ref.read(backendProvider),
    store: ref.read(sessionStoreProvider),
    navigator: ref.read(navigatorProvider),
    feedback: ref.read(feedbackProvider),
  );

  @override
  void initFields() {
    super.initFields();
    nameController = TextEditingController();
  }

  @override
  void disposeFields() {
    nameController.dispose();
    super.disposeFields();
  }

  @override
  DemoSignup buildRequest({
    required String identifier,
    required String password,
  }) => DemoSignup(
    name: nameController.text.trim(),
    email: identifier,
    password: password,
  );
}

class OtpNotifier extends BrixOtpNotifier<String> {
  @override
  OtpVerificationFlow<String> createFlow() => OtpVerificationFlow(
    provider: ref.read(backendProvider),
    store: ref.read(sessionStoreProvider),
    navigator: ref.read(navigatorProvider),
    feedback: ref.read(feedbackProvider),
  );
}

class ForgotPasswordNotifier extends BrixForgotPasswordNotifier {
  @override
  ForgotPasswordFlow createFlow() => ForgotPasswordFlow(
    provider: ref.read(backendProvider),
    navigator: ref.read(navigatorProvider),
    feedback: ref.read(feedbackProvider),
  );
}

class ResetPasswordNotifier extends BrixResetPasswordNotifier {
  ResetPasswordNotifier(this.identifier);

  /// Where the code was sent (the family argument).
  final String identifier;

  @override
  ResetPasswordFlow createFlow() => ResetPasswordFlow(
    provider: ref.read(backendProvider),
    navigator: ref.read(navigatorProvider),
    feedback: ref.read(feedbackProvider),
    identifier: identifier,
    store: ref.read(sessionStoreProvider),
  );
}
