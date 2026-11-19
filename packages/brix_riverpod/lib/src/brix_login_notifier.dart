import 'package:brix/auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'brix_login_state.dart';

/// Riverpod notifier for a login screen, built on brix [LoginFlow]. It holds
/// no Flutter objects: the screen owns its fields, sends what is typed
/// ([identifierChanged], [passwordChanged]), checks its form, then calls
/// [login].
///
/// ```dart
/// class LoginNotifier extends BrixLoginNotifier<User> {
///   @override
///   LoginFlow<User> createFlow() => LoginFlow(...);
/// }
///
/// final loginProvider =
///     NotifierProvider.autoDispose<LoginNotifier, BrixLoginState>(
///       LoginNotifier.new,
///     );
/// ```
///
/// Saved "remember me" details arrive in the state on start; the screen puts
/// them in its fields (for example with `ref.listen`).
abstract class BrixLoginNotifier<TUser> extends Notifier<BrixLoginState> {
  late LoginFlow<TUser> flow;

  /// Makes the flow, usually from the app's own providers. Called on every
  /// build; the old flow is disposed first.
  @protected
  LoginFlow<TUser> createFlow();

  @override
  BrixLoginState build() {
    flow = createFlow();
    final subscription = flow.changes.listen(
      (form) => _set(state.copyWith(isSubmitting: form.isSubmitting)),
    );
    ref.onDispose(() {
      subscription.cancel();
      flow.dispose();
    });
    _fillRemembered();
    return const BrixLoginState();
  }

  void _set(BrixLoginState next) {
    if (ref.mounted) state = next;
  }

  Future<void> _fillRemembered() async {
    final saved = await flow.loadRemembered();
    if (saved == null || !ref.mounted) return;
    _set(
      state.copyWith(
        identifier: saved.identifier,
        password: saved.password,
        rememberMe: true,
      ),
    );
  }

  void identifierChanged(String value) =>
      _set(state.copyWith(identifier: value));

  void passwordChanged(String value) => _set(state.copyWith(password: value));

  void togglePasswordVisibility() =>
      _set(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleRememberMe() =>
      _set(state.copyWith(rememberMe: !state.rememberMe));

  /// Fills the email, e.g. back from a reset or a verified signup. The
  /// password is filled only when "remember me" holds this account's.
  Future<void> prefillIdentifier(String identifier) async {
    final saved = await flow.loadRemembered();
    if (!ref.mounted) return;
    if (saved != null && saved.identifier == identifier) {
      _set(
        state.copyWith(
          identifier: identifier,
          password: saved.password,
          rememberMe: true,
        ),
      );
    } else {
      _set(state.copyWith(identifier: identifier, password: ''));
    }
  }

  /// Logs in with what is typed. Check the form first; double taps are
  /// ignored by the flow.
  Future<void> login() => flow.submit(
    identifier: state.identifier,
    password: state.password,
    rememberMe: state.rememberMe,
  );
}
