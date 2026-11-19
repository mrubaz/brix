import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';

/// Login: email, password, remember me, all in [BrixLoginNotifier].
/// Add your own state here.
class LoginViewModel extends BrixLoginNotifier<User> {
  @override
  LoginFlow<User> createFlow() => LoginFlow(
    provider: Dependencies.auth,
    store: Dependencies.session,
    navigator: Dependencies.navigator,
    feedback: Dependencies.feedback,
  );
}

final loginProvider =
    NotifierProvider.autoDispose<LoginViewModel, BrixLoginState>(
      LoginViewModel.new,
    );
