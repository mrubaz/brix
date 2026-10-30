/// Every screen's address. Screens under another one (signup under login,
/// profile under home) get a back button to it.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/login/signup';
  static const otp = '/login/signup/code';
  static const forgotPassword = '/login/forgot-password';
  static const resetPassword = '/login/forgot-password/reset';
  static const home = '/home';
  static const profile = '/home/profile';
  static const changePassword = '/home/change-password';
  static const deleteAccount = '/home/delete-account';
}
