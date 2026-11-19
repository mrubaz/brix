import 'package:brix/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier for the signup code screen, built on brix
/// [OtpVerificationFlow]. The state is the flow's own [CodeEntryState]; it
/// starts right after the build.
///
/// The screen owns the code boxes: it calls [verify] with the typed code
/// (for example when the last digit is typed) and clears its boxes when
/// `failedAttempts` goes up.
abstract class BrixOtpNotifier<TUser> extends Notifier<CodeEntryState> {
  late OtpVerificationFlow<TUser> flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  OtpVerificationFlow<TUser> createFlow();

  /// Digits in a code, for the boxes.
  int get otpLength => flow.otpLength;

  @override
  CodeEntryState build() {
    flow = createFlow();
    final subscription = flow.changes.listen((code) {
      if (ref.mounted) state = code;
    });
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    // Inside build the state is not set yet; start right after it.
    Future.microtask(() {
      if (ref.mounted) flow.start();
    });
    return flow.state;
  }

  /// Checks [code].
  Future<void> verify(String code) => flow.verify(code);

  Future<void> resend() => flow.resend();

  /// Wrong email: back to signup.
  Future<void> changeIdentifier() => flow.changeIdentifier();
}
