/// Every screen's address. Screens under another one (signup under login,
/// profile under settings) get a back button to it.
abstract final class Routes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/login/signup';
  static const otp = '/login/signup/code';
  static const forgotPassword = '/login/forgot-password';
  static const resetPassword = '/login/forgot-password/reset';

  // The three tabs of the bottom bar.
  static const home = '/home';
  static const library = '/library';
  static const settings = '/settings';

  static const profile = '/settings/profile';
  static const changePassword = '/settings/change-password';
  static const deleteAccount = '/settings/delete-account';
  static const appearance = '/settings/appearance';
  static const about = '/settings/about';
}
