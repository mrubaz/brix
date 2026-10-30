import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/widgets.dart';

import '../../../domain/models/signup_request.dart';
import '../../../domain/models/user.dart';

/// Signup: email and passwords come from [BrixSignupController]; the
/// app's own fields (here the name) live here.
class SignupViewModel extends BrixSignupController<SignupRequest, User> {
  SignupViewModel(super.flow);

  final nameController = TextEditingController();

  @override
  SignupRequest buildRequest({
    required String identifier,
    required String password,
  }) => SignupRequest(
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
