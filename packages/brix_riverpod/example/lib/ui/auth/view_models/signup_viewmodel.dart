import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/signup_request.dart';
import '../../../domain/models/user.dart';

/// Signup: email and passwords come from [BrixSignupNotifier]; the app's
/// own fields (here the name) live here.
class SignupViewModel extends BrixSignupNotifier<SignupRequest, User> {
  late TextEditingController nameController;

  @override
  SignupFlow<SignupRequest, User> createFlow() => SignupFlow(
    provider: Dependencies.auth,
    store: Dependencies.session,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
  );

  @override
  void initFields() {
    super.initFields();
    nameController = TextEditingController();
  }

  @override
  void disposeFields() {
    nameController.dispose();
    super.disposeFields();
  }

  @override
  SignupRequest buildRequest({
    required String identifier,
    required String password,
  }) => SignupRequest(
    name: nameController.text.trim(),
    email: identifier,
    password: password,
  );
}

final signupProvider =
    NotifierProvider.autoDispose<SignupViewModel, BrixSignupState>(
      SignupViewModel.new,
    );
