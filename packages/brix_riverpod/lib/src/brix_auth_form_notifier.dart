import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Base Riverpod notifier for a brix auth form: [formKey], the flow made by
/// [createFlow], its busy state copied into [S] through [withSubmitting],
/// and the flow disposed with the provider.
///
/// Text fields are made in [initFields] and disposed in [disposeFields],
/// not as `final` fields: Riverpod can keep the same notifier across a
/// rebuild, and the old fields are disposed with the old flow.
abstract class BrixAuthFormNotifier<F extends FormFlow, S> extends Notifier<S> {
  late F flow;

  final formKey = GlobalKey<FormState>();

  /// Makes the flow, usually from the app's own providers
  /// (`ref.read(authProvider).loginFlow()`). Called on every build; the
  /// old flow is disposed first.
  @protected
  F createFlow();

  /// The state before anything happened. [flow] is ready here.
  @protected
  S initialState();

  /// [current] with the flow's busy state set to [isSubmitting].
  @protected
  S withSubmitting(S current, bool isSubmitting);

  @override
  S build() {
    flow = createFlow();
    initFields();
    final subscription = flow.changes.listen(
      (form) => state = withSubmitting(state, form.isSubmitting),
    );
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
      disposeFields();
    });
    return initialState();
  }

  /// Makes the screen's text fields. Runs on every build, after [flow].
  @protected
  @mustCallSuper
  void initFields() {}

  /// Disposes what [initFields] made. Runs when the provider is disposed
  /// or rebuilt.
  @protected
  @mustCallSuper
  void disposeFields() {}

  /// Hides the keyboard and runs the form validators.
  @protected
  bool validateForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    return formKey.currentState?.validate() ?? false;
  }
}
