import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';

import 'brix_auth_form_notifier.dart';
import 'brix_login_state.dart';

/// Riverpod notifier for a login screen, built on brix [LoginFlow].
///
/// Extend it, return the app's flow from [createFlow] and declare the
/// provider:
///
/// ```dart
/// class LoginNotifier extends BrixLoginNotifier<AppUser> {
///   @override
///   LoginFlow<AppUser> createFlow() => ref.read(authProvider).loginFlow();
/// }
///
/// final loginProvider =
///     NotifierProvider.autoDispose<LoginNotifier, BrixLoginState>(
///       LoginNotifier.new,
///     );
/// ```
///
/// Bind `formKey`, [identifierController] and [passwordController] in the
/// view, watch the state for the loader and toggles, and call [login].
abstract class BrixLoginNotifier<TUser>
    extends BrixAuthFormNotifier<LoginFlow<TUser>, BrixLoginState> {
  late TextEditingController identifierController;
  late TextEditingController passwordController;

  @override
  void initFields() {
    super.initFields();
    identifierController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  BrixLoginState build() {
    final initial = super.build();
    _fillRemembered();
    return initial;
  }

  @override
  BrixLoginState initialState() => const BrixLoginState();

  @override
  BrixLoginState withSubmitting(BrixLoginState current, bool isSubmitting) =>
      current.copyWith(isSubmitting: isSubmitting);

  Future<void> _fillRemembered() async {
    final saved = await flow.loadRemembered();
    if (saved == null || !ref.mounted) return;
    identifierController.text = saved.identifier;
    passwordController.text = saved.password;
    state = state.copyWith(rememberMe: true);
  }

  /// Fills the email, e.g. back from a reset or a verified signup. The
  /// password is filled only when "remember me" holds this account's.
  Future<void> prefillIdentifier(String identifier) async {
    identifierController.text = identifier;
    final saved = await flow.loadRemembered();
    if (!ref.mounted) return;
    if (saved != null && saved.identifier == identifier) {
      passwordController.text = saved.password;
      state = state.copyWith(rememberMe: true);
    } else {
      passwordController.clear();
    }
  }

  void togglePasswordVisibility() =>
      state = state.copyWith(obscurePassword: !state.obscurePassword);

  void toggleRememberMe() =>
      state = state.copyWith(rememberMe: !state.rememberMe);

  /// Validates the form, then logs in. Double taps are ignored by the flow.
  Future<void> login() async {
    if (!validateForm()) return;
    await flow.submit(
      identifier: identifierController.text,
      password: passwordController.text,
      rememberMe: state.rememberMe,
    );
  }

  @override
  void disposeFields() {
    identifierController.dispose();
    passwordController.dispose();
    super.disposeFields();
  }
}
