import 'package:brix/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'otp_code_boxes.dart';

/// Base Riverpod notifier for a screen with code boxes (signup code,
/// password reset): the [boxes], the flow's [CodeEntryState] copied into
/// [S] through [withCodeEntry], [resend], boxes cleared on a rejected code,
/// and everything disposed with the provider.
///
/// Extra fields go in [initFields] and [disposeFields], like
/// `BrixAuthFormNotifier`.
abstract class BrixCodeEntryNotifier<F extends CodeEntryFlow, S>
    extends Notifier<S> {
  late F flow;
  late OtpCodeBoxes boxes;

  /// Makes the flow, usually from the app's own providers. Called on every
  /// build; the old flow is disposed first.
  @protected
  F createFlow();

  /// The state before anything happened, from the flow's first [code].
  @protected
  S initialState(CodeEntryState code);

  /// [current] with the flow's new [code] state.
  @protected
  S withCodeEntry(S current, CodeEntryState code);

  /// What the boxes do when the last digit is typed; null = nothing.
  @protected
  void Function()? get onCodeCompleted;

  @override
  S build() {
    flow = createFlow();
    initFields();
    boxes = OtpCodeBoxes(length: flow.otpLength, onCompleted: onCodeCompleted);
    var failedAttemptsSeen = flow.state.failedAttempts;
    final subscription = flow.changes.listen((code) {
      if (code.failedAttempts != failedAttemptsSeen) {
        failedAttemptsSeen = code.failedAttempts;
        boxes.clear();
      }
      state = withCodeEntry(state, code);
    });
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
      boxes.dispose();
      disposeFields();
    });
    return initialState(flow.state);
  }

  /// Makes the screen's extra fields. Runs on every build, before [boxes].
  @protected
  @mustCallSuper
  void initFields() {}

  /// Disposes what [initFields] made.
  @protected
  @mustCallSuper
  void disposeFields() {}

  /// Runs [start] once the provider is built (not inside build, where the
  /// state is not set yet).
  @protected
  void startAfterBuild(Future<void> Function() start) => Future.microtask(() {
    if (ref.mounted) start();
  });

  Future<void> resend() => flow.resend();
}
