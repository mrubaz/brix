import 'dart:async';

import 'package:meta/meta.dart';

import '../core/brix_flow.dart';
import '../core/failure.dart';
import '../core/result.dart';
import 'auth_feedback.dart';
import 'auth_provider.dart';
import 'auth_warning.dart';
import 'identifier_mask.dart';
import 'otp_purpose.dart';
import 'resend_cooldown.dart';

/// State of a screen where the user types an emailed code (signup code,
/// password reset).
class CodeEntryState {
  const CodeEntryState({
    this.identifier,
    this.isSubmitting = false,
    this.isResending = false,
    this.resendIn = Duration.zero,
    this.failedAttempts = 0,
    this.isCodeSent = true,
  });

  /// Where the code was sent; null until known.
  final String? identifier;
  final bool isSubmitting;
  final bool isResending;

  /// Time left before a new code may be asked for.
  final Duration resendIn;

  /// Goes up after every rejected code, so the screen can clear the boxes.
  final int failedAttempts;

  /// A code has been sent. False only where the user asks for the first
  /// one on the screen itself (e.g. delete account).
  final bool isCodeSent;

  bool get canResend =>
      identifier != null && !isResending && resendIn == Duration.zero;

  /// [identifier] with most of it hidden, for the screen's text.
  String get maskedIdentifier =>
      identifier == null ? '' : maskIdentifier(identifier!);

  CodeEntryState copyWith({
    String? identifier,
    bool? isSubmitting,
    bool? isResending,
    Duration? resendIn,
    int? failedAttempts,
    bool? isCodeSent,
  }) => CodeEntryState(
    identifier: identifier ?? this.identifier,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    isResending: isResending ?? this.isResending,
    resendIn: resendIn ?? this.resendIn,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    isCodeSent: isCodeSent ?? this.isCodeSent,
  );
}

/// Base of the code screens: one submit at a time, a rejected code counted
/// in [CodeEntryState.failedAttempts], "resend" after a [ResendCooldown], and the
/// countdown stopped on [dispose]. Subclasses say how long a code is, how a
/// code is sent and how errors map.
abstract class CodeEntryFlow extends BrixFlow<CodeEntryState> {
  CodeEntryFlow({
    required this.feedback,
    required Duration resendCooldown,
    String? identifier,
    bool codeSent = true,
  }) : super(
         CodeEntryState(identifier: _clean(identifier), isCodeSent: codeSent),
       ) {
    _cooldown = ResendCooldown(
      duration: resendCooldown,
      onTick: (left) => emit(state.copyWith(resendIn: left)),
    );
  }

  final AuthFeedback feedback;
  late final ResendCooldown _cooldown;

  static String? _clean(String? identifier) {
    final trimmed = identifier?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  /// Digits in a code.
  int get otpLength;

  /// Sends a (new) code to [identifier].
  Future<Result<void>> sendCode(String identifier);

  /// Turns a thrown error into a [Failure] (the backend adapter's mapping).
  Failure mapError(Object error, StackTrace stackTrace);

  /// For subclasses: the identifier became known (e.g. read from storage).
  @protected
  void setIdentifier(String identifier) =>
      emit(state.copyWith(identifier: identifier.trim()));

  /// For subclasses: a code was just sent, start the wait.
  @protected
  void startCooldown() => _cooldown.start();

  /// For subclasses: warns and returns false when [code] has the wrong
  /// number of digits.
  @protected
  bool checkCodeLength(String code) {
    if (code.length == otpLength) return true;
    feedback.warning(AuthWarning.otpIncomplete);
    return false;
  }

  /// For subclasses: runs [action] unless a submit is running. A thrown
  /// error is shown and counts as a rejected code.
  @protected
  Future<void> submitOnce(Future<void> Function() action) async {
    if (isDisposed || state.isSubmitting) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      await action();
    } catch (error, stackTrace) {
      feedback.failure(mapError(error, stackTrace));
      markFailed();
    } finally {
      emit(state.copyWith(isSubmitting: false));
    }
  }

  /// For subclasses: the backend rejected the code.
  @protected
  void markFailed() =>
      emit(state.copyWith(failedAttempts: state.failedAttempts + 1));

  /// Asks for a (new) code. Ignored during the cooldown or while a request
  /// is running.
  Future<void> resend() async {
    final identifier = state.identifier;
    if (isDisposed || identifier == null || !state.canResend) return;
    emit(state.copyWith(isResending: true));
    try {
      final result = await sendCode(identifier);
      switch (result) {
        case Success(:final message):
          feedback.success(message);
          emit(state.copyWith(isCodeSent: true));
          startCooldown();
        case Failed(:final failure):
          feedback.failure(failure);
      }
    } catch (error, stackTrace) {
      feedback.failure(mapError(error, stackTrace));
    } finally {
      emit(state.copyWith(isResending: false));
    }
  }

  @override
  Future<void> dispose() {
    _cooldown.cancel();
    return super.dispose();
  }
}

/// A [CodeEntryFlow] whose codes come from an [AuthProvider] (signup code,
/// password reset).
abstract class AuthCodeEntryFlow<TUser> extends CodeEntryFlow {
  AuthCodeEntryFlow({
    required this.provider,
    required super.feedback,
    required this.purpose,
    required super.resendCooldown,
    super.identifier,
  });

  final AuthProvider<dynamic, TUser> provider;
  final OtpPurpose purpose;

  @override
  int get otpLength => provider.capabilities.otpLength;

  @override
  Future<Result<void>> sendCode(String identifier) =>
      provider.resendOtp(identifier: identifier, purpose: purpose);

  @override
  Failure mapError(Object error, StackTrace stackTrace) =>
      provider.mapError(error, stackTrace);
}
