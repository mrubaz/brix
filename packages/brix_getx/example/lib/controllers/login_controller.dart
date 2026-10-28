import 'package:brix_getx/brix_getx.dart';
import 'package:get/get.dart';

/// Brix's login controller plus one app detail: the email passed by the
/// navigator (after signup or a reset) fills the form.
class LoginController extends BrixLoginController<String> {
  LoginController(super.flow);

  @override
  void onReady() {
    super.onReady();
    final identifier = Get.arguments;
    if (identifier is String) prefillIdentifier(identifier);
  }
}
