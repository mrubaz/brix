import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:brix/auth.dart';

import 'brix_login_state.dart';

/// Cubit for a login screen, built on brix [LoginFlow]. It holds no Flutter
/// objects: the screen sends what is typed ([identifierChanged],
/// [passwordChanged]), checks its form, then calls [login].
///
/// ```dart
/// BlocProvider(
///   create: (_) => BrixLoginCubit<User>(LoginFlow(...)),
///   child: const LoginScreen(),
/// )
/// ```
///
/// Saved "remember me" details are loaded into the state on start; the
/// screen puts them in its fields (for example with a `BlocListener`).
class BrixLoginCubit<TUser> extends Cubit<BrixLoginState> {
  BrixLoginCubit(this.flow) : super(const BrixLoginState()) {
    _subscription = flow.changes.listen(
      (form) => _emit(state.copyWith(isSubmitting: form.isSubmitting)),
    );
    _fillRemembered();
  }

  final LoginFlow<TUser> flow;
  late final StreamSubscription<AuthFormState> _subscription;

  void _emit(BrixLoginState next) {
    if (!isClosed) emit(next);
  }

  Future<void> _fillRemembered() async {
    final saved = await flow.loadRemembered();
    if (saved == null) return;
    _emit(
      state.copyWith(
        identifier: saved.identifier,
        password: saved.password,
        rememberMe: true,
      ),
    );
  }

  void identifierChanged(String value) =>
      _emit(state.copyWith(identifier: value));

  void passwordChanged(String value) => _emit(state.copyWith(password: value));

  void togglePasswordVisibility() =>
      _emit(state.copyWith(obscurePassword: !state.obscurePassword));

  void toggleRememberMe() =>
      _emit(state.copyWith(rememberMe: !state.rememberMe));

  /// Fills the email, e.g. back from a reset or a verified signup. The
  /// password is filled only when "remember me" holds this account's.
  Future<void> prefillIdentifier(String identifier) async {
    final saved = await flow.loadRemembered();
    if (saved != null && saved.identifier == identifier) {
      _emit(
        state.copyWith(
          identifier: identifier,
          password: saved.password,
          rememberMe: true,
        ),
      );
    } else {
      _emit(state.copyWith(identifier: identifier, password: ''));
    }
  }

  /// Logs in with what is typed. Check the form first; double taps are
  /// ignored by the flow.
  Future<void> login() => flow.submit(
    identifier: state.identifier,
    password: state.password,
    rememberMe: state.rememberMe,
  );

  @override
  Future<void> close() async {
    await _subscription.cancel();
    await flow.dispose();
    return super.close();
  }
}
