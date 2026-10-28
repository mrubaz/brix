import 'package:brix/account.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'brix_code_entry_controller.dart';

/// GetX controller for a delete account screen, built on brix
/// [DeleteAccountFlow]. Code mode: [requestDeletion] sends the code (show
/// the boxes once `isCodeSent`), [confirm] deletes; no auto submit for a
/// destructive action. Other modes: [deleteWithoutCode].
class BrixDeleteAccountController
    extends BrixCodeEntryController<DeleteAccountFlow> {
  BrixDeleteAccountController(super.flow);

  /// The first code is on its way (the resend loader is `isResending`).
  final isRequesting = false.obs;

  @override
  void Function()? get onCodeCompleted => null;

  @override
  void onInit() {
    super.onInit();
    ever<bool>(
      isResending,
      (busy) => isRequesting.value = busy && !isCodeSent.value,
    );
    ever<bool>(isCodeSent, (sent) {
      // The boxes are built on the next frame.
      if (sent) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!isClosed) boxes.focusNodes.first.requestFocus();
        });
      }
    });
  }

  /// Sends the first code (code mode).
  Future<void> requestDeletion() => flow.requestDeletion();

  /// Deletes with the typed code.
  Future<void> confirm() {
    FocusManager.instance.primaryFocus?.unfocus();
    return flow.confirm(boxes.code);
  }

  /// Confirm / password mode.
  Future<void> deleteWithoutCode({String? password}) =>
      flow.deleteWithoutCode(password: password);
}
