import 'package:brix/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Riverpod notifier for a delete account screen, built on brix
/// [DeleteAccountFlow]. The state is the flow's own [CodeEntryState].
///
/// Code mode: [requestDeletion] sends the code (show the boxes once
/// `isCodeSent`), [confirm] deletes with the code the screen's boxes hold;
/// nothing deletes on its own. Other modes: [deleteWithoutCode].
abstract class BrixDeleteAccountNotifier extends Notifier<CodeEntryState> {
  late DeleteAccountFlow flow;

  /// Makes the flow, usually from the app's own providers.
  @protected
  DeleteAccountFlow createFlow();

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
    return flow.state;
  }

  /// Sends the first code (code mode).
  Future<void> requestDeletion() => flow.requestDeletion();

  /// Deletes with [code].
  Future<void> confirm(String code) => flow.confirm(code);

  /// Confirm / password mode.
  Future<void> deleteWithoutCode({String? password}) =>
      flow.deleteWithoutCode(password: password);

  Future<void> resend() => flow.resend();
}

/// What a delete account screen shows while the first code is asked for.
extension BrixDeleteAccountCodeState on CodeEntryState {
  /// The first code is on its way (later sends are `isResending`).
  bool get isRequesting => isResending && !isCodeSent;
}
