import 'package:brix/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brix_forgot_password_state.dart';

/// Riverpod notifier for a "forgot password" screen, built on brix
/// [ForgotPasswordFlow]: send what is typed with [identifierChanged], check
/// the form, then call [submit].
abstract class BrixForgotPasswordNotifier
    extends Notifier<BrixForgotPasswordState> {
  late ForgotPasswordFlow flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  ForgotPasswordFlow createFlow();

  @override
  BrixForgotPasswordState build() {
    flow = createFlow();
    final subscription = flow.changes.listen((form) {
      if (ref.mounted) state = state.copyWith(isSubmitting: form.isSubmitting);
    });
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    return const BrixForgotPasswordState();
  }

  void identifierChanged(String value) {
    if (ref.mounted) state = state.copyWith(identifier: value);
  }

  /// Asks for the reset code or link.
  Future<void> submit() => flow.submit(identifier: state.identifier);
}
