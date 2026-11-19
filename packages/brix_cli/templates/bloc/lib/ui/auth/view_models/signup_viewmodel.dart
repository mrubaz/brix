import 'package:brix_bloc/brix_bloc.dart';

import '../../../domain/models/signup_request.dart';
import '../../../domain/models/user.dart';

/// Signup: email and passwords come from [BrixSignupCubit]; the app's own
/// values (here the name) live here.
class SignupViewModel extends BrixSignupCubit<SignupRequest, User> {
  SignupViewModel(super.flow);

  String _name = '';

  void nameChanged(String value) => _name = value;

  @override
  SignupRequest buildRequest({
    required String identifier,
    required String password,
  }) =>
      SignupRequest(name: _name.trim(), email: identifier, password: password);
}
