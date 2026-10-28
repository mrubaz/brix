import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/widgets.dart';

import '../demo/demo_auth_provider.dart';

/// Brix's signup controller plus the app's own field (name) and body.
class SignupController extends BrixSignupController<DemoSignup, String> {
  SignupController(super.flow);

  final nameController = TextEditingController();

  @override
  DemoSignup buildRequest({
    required String identifier,
    required String password,
  }) => DemoSignup(
    name: nameController.text.trim(),
    email: identifier,
    password: password,
  );

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }
}
