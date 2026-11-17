import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_code_entry_notifier.dart';

/// Riverpod notifier for the signup code screen, built on brix
/// [OtpVerificationFlow]. The last digit submits on its own; a rejected
/// code clears the boxes. The state is the flow's own [CodeEntryState].
///
/// Extend it and return the app's flow from [createFlow], like
/// `BrixLoginNotifier`.
abstract class BrixOtpNotifier<TUser>
    extends BrixCodeEntryNotifier<OtpVerificationFlow<TUser>, CodeEntryState> {
  @override
  CodeEntryState build() {
    final initial = super.build();
    startAfterBuild(flow.start);
    return initial;
  }

  @override
  CodeEntryState initialState(CodeEntryState code) => code;

  @override
  CodeEntryState withCodeEntry(CodeEntryState current, CodeEntryState code) =>
      code;

  @override
  void Function()? get onCodeCompleted => verify;

  /// Checks the code. Also runs on its own after the last digit.
  Future<void> verify() {
    FocusManager.instance.primaryFocus?.unfocus();
    return flow.verify(boxes.code);
  }

  /// Wrong email: back to signup.
  Future<void> changeIdentifier() => flow.changeIdentifier();
}
