import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dependencies.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/auth_page.dart';
import '../view_models/login_viewmodel.dart';

/// Email, password, remember me. The screen owns its fields and sends what
/// is typed to [LoginViewModel].
///
/// [identifier] fills the email after a signup or a password reset.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.identifier});

  final String? identifier;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  LoginViewModel get _viewModel => ref.read(loginProvider.notifier);

  @override
  void initState() {
    super.initState();
    _prefill(widget.identifier);
  }

  @override
  void didUpdateWidget(LoginScreen old) {
    super.didUpdateWidget(old);
    if (widget.identifier != old.identifier) _prefill(widget.identifier);
  }

  void _prefill(String? email) {
    if (email != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _viewModel.prefillIdentifier(email),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _viewModel.login();
  }

  @override
  Widget build(BuildContext context) {
    // Remembered details and a prefilled email arrive through the state.
    ref.listen(loginProvider, (_, state) {
      if (_email.text != state.identifier) _email.text = state.identifier;
      if (_password.text != state.password) _password.text = state.password;
    });
    final state = ref.watch(loginProvider);
    return AuthPage(
      title: 'Welcome back',
      subtitle: 'Log in to continue.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: _email,
                  onChanged: _viewModel.identifierChanged,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: _password,
                  onChanged: _viewModel.passwordChanged,
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _login(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Checkbox(
              value: state.rememberMe,
              onChanged: (_) => _viewModel.toggleRememberMe(),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _viewModel.toggleRememberMe,
                child: const Text(
                  'Remember me',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Flexible(
              child: TextButton(
                onPressed: () => context.go(Routes.forgotPassword),
                child: const Text(
                  'Forgot password?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        BrixButton(
          label: 'Log in',
          isLoading: state.isSubmitting,
          onPressed: _login,
        ),
        TextButton(
          onPressed: () => context.go(Routes.signup),
          child: const Text('No account? Sign up'),
        ),
        // Debug builds on the local test backend only; never in a release.
        if (Dependencies.devTools case final dev?) ...[
          const SizedBox(height: 16),
          Text(dev.loginHint, textAlign: TextAlign.center),
          TextButton(onPressed: dev.skipLogin, child: const Text('Skip login')),
          TextButton(
            onPressed: () async {
              await dev.resetLocalBackend();
              BrixToast.success('Local backend reset on this device.');
            },
            child: const Text('Reset local backend'),
          ),
        ],
      ],
    );
  }
}
