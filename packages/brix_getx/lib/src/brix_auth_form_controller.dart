import 'dart:async';

import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Base GetX controller for a brix auth form: [formKey], [isSubmitting]
/// mirrored from the flow, and the flow disposed with the controller.
abstract class BrixAuthFormController<F extends FormFlow>
    extends GetxController {
  BrixAuthFormController(this.flow);

  final F flow;

  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  StreamSubscription<AuthFormState>? _stateSubscription;

  @override
  void onInit() {
    super.onInit();
    _stateSubscription = flow.changes.listen(
      (state) => isSubmitting.value = state.isSubmitting,
    );
  }

  /// Hides the keyboard and runs the form validators.
  @protected
  bool validateForm() {
    FocusManager.instance.primaryFocus?.unfocus();
    return formKey.currentState?.validate() ?? false;
  }

  @override
  void onClose() {
    _stateSubscription?.cancel();
    flow.dispose();
    super.onClose();
  }
}
