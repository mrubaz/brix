import 'package:brix_getx/brix_getx.dart';

import '../../../domain/models/user.dart';

/// Login: email, password, remember me, all in [BrixLoginController].
/// Add your own state here.
class LoginViewModel extends BrixLoginController<User> {
  LoginViewModel(super.flow);
}
