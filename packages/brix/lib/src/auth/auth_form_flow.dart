import 'package:meta/meta.dart';

import '../core/brix_flow.dart';
import '../core/failure.dart';
import 'auth_feedback.dart';
import 'auth_provider.dart';

/// State of a form screen (login, forgot password, signup, change
/// password…).
class AuthFormState {
  const AuthFormState({this.isSubmitting = false});

  /// A call is running; the button should show a loader.
  final bool isSubmitting;
}

/// Base of the form flows: one call at a time, busy state while it runs,
/// and thrown errors shown as a failure instead of crashing.
abstract class FormFlow extends BrixFlow<AuthFormState> {
  FormFlow({required this.feedback}) : super(const AuthFormState());

  /// For subclasses: the alerts.
  final AuthFeedback feedback;

  /// Turns a thrown error into a [Failure] (the backend adapter's mapping).
  Failure mapError(Object error, StackTrace stackTrace);

  /// Runs [action] unless one is already running (double tap) or the flow
  /// is disposed. Errors thrown by [action] go through [mapError] to
  /// [AuthFeedback.failure].
  @protected
  Future<void> run(Future<void> Function() action) async {
    if (isDisposed || state.isSubmitting) return;
    emit(const AuthFormState(isSubmitting: true));
    try {
      await action();
    } catch (error, stackTrace) {
      feedback.failure(mapError(error, stackTrace));
    } finally {
      emit(const AuthFormState());
    }
  }
}

/// A [FormFlow] talking to an [AuthProvider].
abstract class AuthFormFlow<TUser> extends FormFlow {
  AuthFormFlow({required this.provider, required super.feedback});

  /// For subclasses: the backend.
  final AuthProvider<dynamic, TUser> provider;

  @override
  Failure mapError(Object error, StackTrace stackTrace) =>
      provider.mapError(error, stackTrace);
}
