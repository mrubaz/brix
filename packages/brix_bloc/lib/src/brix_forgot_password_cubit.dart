import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/auth.dart';

import 'brix_forgot_password_state.dart';

/// Cubit for a "forgot password" screen, built on brix
/// [ForgotPasswordFlow]: send what is typed with [identifierChanged], check
/// the form, then call [submit].
class BrixForgotPasswordCubit extends Cubit<BrixForgotPasswordState> {
  BrixForgotPasswordCubit(this.flow) : super(const BrixForgotPasswordState()) {
    _subscription = flow.changes.listen((form) {
      if (!isClosed) emit(state.copyWith(isSubmitting: form.isSubmitting));
    });
  }

  final ForgotPasswordFlow flow;
  late final StreamSubscription<AuthFormState> _subscription;

  void identifierChanged(String value) {
    if (!isClosed) emit(state.copyWith(identifier: value));
  }

  /// Asks for the reset code or link.
  Future<void> submit() => flow.submit(identifier: state.identifier);

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await flow.dispose();
    return super.close();
  }
}
