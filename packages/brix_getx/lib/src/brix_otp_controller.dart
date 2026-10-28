import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_code_entry_controller.dart';

/// GetX controller for the signup code screen, built on brix
/// [OtpVerificationFlow]. The last digit submits on its own; a rejected
/// code clears the boxes.
class BrixOtpController<TUser>
    extends BrixCodeEntryController<OtpVerificationFlow<TUser>> {
  BrixOtpController(super.flow);

  @override
  void Function()? get onCodeCompleted => verify;

  @override
  void onReady() {
    super.onReady();
    flow.start();
  }

  /// Checks the code. Also runs on its own after the last digit.
  Future<void> verify() {
    FocusManager.instance.primaryFocus?.unfocus();
    return flow.verify(boxes.code);
  }

  /// Wrong email: back to signup.
  Future<void> changeIdentifier() => flow.changeIdentifier();
}
