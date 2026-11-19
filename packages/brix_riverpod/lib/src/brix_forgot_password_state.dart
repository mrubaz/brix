import 'package:equatable/equatable.dart';

/// What a "forgot password" screen shows: the typed email and the loader.
class BrixForgotPasswordState extends Equatable {
  const BrixForgotPasswordState({
    this.identifier = '',
    this.isSubmitting = false,
  });

  final String identifier;
  final bool isSubmitting;

  BrixForgotPasswordState copyWith({String? identifier, bool? isSubmitting}) =>
      BrixForgotPasswordState(
        identifier: identifier ?? this.identifier,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  @override
  List<Object?> get props => [identifier, isSubmitting];
}
