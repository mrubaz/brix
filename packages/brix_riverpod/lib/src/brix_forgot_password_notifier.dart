import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_auth_form_notifier.dart';

/// Riverpod notifier for a "forgot password" screen, built on brix
/// [ForgotPasswordFlow]. Bind `formKey` and [identifierController], watch
/// `isSubmitting` for the button and call [submit]. The state is the
/// flow's own [AuthFormState].
///
/// Extend it and return the app's flow from [createFlow], like
/// `BrixLoginNotifier`.
abstract class BrixForgotPasswordNotifier
    extends BrixAuthFormNotifier<ForgotPasswordFlow, AuthFormState> {
  late TextEditingController identifierController;

  @override
  void initFields() {
    super.initFields();
    identifierController = TextEditingController();
  }

  @override
  AuthFormState initialState() => const AuthFormState();

  @override
  AuthFormState withSubmitting(AuthFormState current, bool isSubmitting) =>
      AuthFormState(isSubmitting: isSubmitting);

  /// Validates the form, then asks for the reset code or link.
  Future<void> submit() async {
    if (!validateForm()) return;
    await flow.submit(identifier: identifierController.text);
  }

  @override
  void disposeFields() {
    identifierController.dispose();
    super.disposeFields();
  }
}
