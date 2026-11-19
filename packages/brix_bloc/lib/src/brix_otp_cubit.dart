import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/auth.dart';

/// Cubit for the signup code screen, built on brix [OtpVerificationFlow].
/// The state is the flow's own [CodeEntryState]. It starts at once.
///
/// The screen owns the code boxes: it calls [verify] with the typed code
/// (for example when the last digit is typed) and clears its boxes when
/// `failedAttempts` goes up.
class BrixOtpCubit<TUser> extends Cubit<CodeEntryState> {
  BrixOtpCubit(this.flow) : super(flow.state) {
    _subscription = flow.changes.listen((code) {
      if (!isClosed) emit(code);
    });
    flow.start();
  }

  final OtpVerificationFlow<TUser> flow;
  late final StreamSubscription<CodeEntryState> _subscription;

  /// Digits in a code, for the boxes.
  int get otpLength => flow.otpLength;

  /// Checks [code].
  Future<void> verify(String code) => flow.verify(code);

  Future<void> resend() => flow.resend();

  /// Wrong email: back to signup.
  Future<void> changeIdentifier() => flow.changeIdentifier();

  @override
  Future<void> close() async {
    // The flow first and at once: it stops its timers before anything waits.
    final disposing = flow.dispose();
    await _subscription.cancel();
    await disposing;
    return super.close();
  }
}
