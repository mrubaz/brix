import 'dart:async';

import 'package:brix/auth.dart';
import 'package:get/get.dart';

import 'otp_code_boxes.dart';

/// Base GetX controller for a screen with code boxes (signup code, password
/// reset): the [boxes], the flow's state as Rx, [resend], boxes cleared on
/// a rejected code, and everything disposed on close.
abstract class BrixCodeEntryController<F extends CodeEntryFlow>
    extends GetxController {
  BrixCodeEntryController(this.flow);

  final F flow;

  late final OtpCodeBoxes boxes;

  final isSubmitting = false.obs;
  final isResending = false.obs;

  /// Seconds left before "resend" works again; 0 = it works now.
  final resendSeconds = 0.obs;

  /// Where the code was sent, partly hidden (`ru•••@gmail.com`).
  final maskedIdentifier = ''.obs;

  /// A code has been sent (false until the user asks for the first one on
  /// screens like delete account).
  final isCodeSent = false.obs;

  StreamSubscription<CodeEntryState>? _stateSubscription;
  int _failedAttemptsSeen = 0;

  /// What the boxes do when the last digit is typed; null = nothing.
  void Function()? get onCodeCompleted;

  @override
  void onInit() {
    super.onInit();
    boxes = OtpCodeBoxes(length: flow.otpLength, onCompleted: onCodeCompleted);
    _apply(flow.state);
    _stateSubscription = flow.changes.listen(_apply);
  }

  void _apply(CodeEntryState state) {
    isSubmitting.value = state.isSubmitting;
    isResending.value = state.isResending;
    resendSeconds.value = state.resendIn.inSeconds;
    maskedIdentifier.value = state.maskedIdentifier;
    isCodeSent.value = state.isCodeSent;
    if (state.failedAttempts != _failedAttemptsSeen) {
      _failedAttemptsSeen = state.failedAttempts;
      boxes.clear();
    }
  }

  Future<void> resend() => flow.resend();

  @override
  void onClose() {
    _stateSubscription?.cancel();
    flow.dispose();
    boxes.dispose();
    super.onClose();
  }
}
