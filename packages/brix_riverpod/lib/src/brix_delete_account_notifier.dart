import 'package:brix/account.dart';
import 'package:flutter/widgets.dart';

import 'brix_code_entry_notifier.dart';

/// Riverpod notifier for a delete account screen, built on brix
/// [DeleteAccountFlow]. The state is the flow's own [CodeEntryState].
///
/// Code mode: [requestDeletion] sends the code (show the boxes once
/// `isCodeSent`, the first box gets focus), [confirm] deletes; no auto
/// submit for a destructive action. Other modes: [deleteWithoutCode].
///
/// Extend it and return the app's flow from [createFlow], like
/// `BrixLoginNotifier`.
abstract class BrixDeleteAccountNotifier
    extends BrixCodeEntryNotifier<DeleteAccountFlow, CodeEntryState> {
  @override
  CodeEntryState initialState(CodeEntryState code) => code;

  @override
  CodeEntryState withCodeEntry(CodeEntryState current, CodeEntryState code) {
    if (!current.isCodeSent && code.isCodeSent) _focusFirstBox();
    return code;
  }

  /// The boxes are built on the next frame.
  void _focusFirstBox() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (ref.mounted) boxes.focusNodes.first.requestFocus();
  });

  @override
  void Function()? get onCodeCompleted => null;

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

/// What a delete account screen shows while the first code is asked for.
extension BrixDeleteAccountCodeState on CodeEntryState {
  /// The first code is on its way (later sends are `isResending`).
  bool get isRequesting => isResending && !isCodeSent;
}
