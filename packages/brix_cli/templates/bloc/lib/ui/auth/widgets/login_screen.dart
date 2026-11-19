import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/user.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/auth_page.dart';

/// Email, password, remember me. The screen owns its fields and sends what
/// is typed to [BrixLoginCubit].
///
/// [identifier] fills the email after a signup or a password reset.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.identifier});

  final String? identifier;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  BrixLoginCubit<User> get _cubit => context.read<BrixLoginCubit<User>>();

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
        (_) => _cubit.prefillIdentifier(email),
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
    if (_formKey.currentState?.validate() ?? false) _cubit.login();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BrixLoginCubit<User>, BrixLoginState>(
      // Remembered details and a prefilled email arrive through the state.
      listener: (context, state) {
        if (_email.text != state.identifier) _email.text = state.identifier;
        if (_password.text != state.password) _password.text = state.password;
      },
      builder: (context, state) => AuthPage(
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
                    onChanged: _cubit.identifierChanged,
                    label: 'Email',
                    isRequired: true,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  BrixTextField(
                    controller: _password,
                    onChanged: _cubit.passwordChanged,
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
                onChanged: (_) => _cubit.toggleRememberMe(),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: _cubit.toggleRememberMe,
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
            TextButton(
              onPressed: dev.skipLogin,
              child: const Text('Skip login'),
            ),
            TextButton(
              onPressed: () async {
                await dev.resetLocalBackend();
                BrixToast.success('Local backend reset on this device.');
              },
              child: const Text('Reset local backend'),
            ),
          ],
        ],
      ),
    );
  }
}
