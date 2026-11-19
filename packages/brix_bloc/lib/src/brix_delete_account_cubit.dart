import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/account.dart';

/// Cubit for a delete account screen, built on brix [DeleteAccountFlow].
/// The state is the flow's own [CodeEntryState].
///
/// Code mode: [requestDeletion] sends the code (show the boxes once
/// `isCodeSent`), [confirm] deletes with the code the screen's boxes hold;
/// nothing deletes on its own. Other modes: [deleteWithoutCode].
class BrixDeleteAccountCubit extends Cubit<CodeEntryState> {
  BrixDeleteAccountCubit(this.flow) : super(flow.state) {
    _subscription = flow.changes.listen((code) {
      if (!isClosed) emit(code);
    });
  }

  final DeleteAccountFlow flow;
  late final StreamSubscription<CodeEntryState> _subscription;

  /// Digits in a code, for the boxes.
  int get otpLength => flow.otpLength;

  /// Sends the first code (code mode).
  Future<void> requestDeletion() => flow.requestDeletion();

  /// Deletes with [code].
  Future<void> confirm(String code) => flow.confirm(code);

  /// Confirm / password mode.
  Future<void> deleteWithoutCode({String? password}) =>
      flow.deleteWithoutCode(password: password);

  Future<void> resend() => flow.resend();

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await flow.dispose();
    return super.close();
  }
}

/// What a delete account screen shows while the first code is asked for.
extension BrixDeleteAccountCodeState on CodeEntryState {
  /// The first code is on its way (later sends are `isResending`).
  bool get isRequesting => isResending && !isCodeSent;
}
