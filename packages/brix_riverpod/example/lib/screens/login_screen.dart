import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../routes.dart';
import '../widgets/auth_page.dart';

/// Email, password, remember me. Only layout, the notifier does the rest.
///
/// [identifier] is the email passed by the navigator (after signup or a
/// reset); it fills the form.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.identifier});

  final String? identifier;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  void initState() {
    super.initState();
    final identifier = widget.identifier;
    if (identifier != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(loginProvider.notifier).prefillIdentifier(identifier),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final notifier = ref.read(loginProvider.notifier);
    return AuthPage(
      title: 'Welcome back',
      subtitle: 'Log in to continue.',
      children: [
        Form(
          key: notifier.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: notifier.identifierController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: notifier.passwordController,
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => notifier.login(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile.adaptive(
          value: state.rememberMe,
          onChanged: (_) => notifier.toggleRememberMe(),
          title: const Text('Remember me'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        const SizedBox(height: 8),
        BrixButton(
          label: 'Log in',
          isLoading: state.isSubmitting,
          onPressed: notifier.login,
        ),
        TextButton(
          onPressed: () =>
              Navigator.of(context).pushNamed(Routes.forgotPassword),
          child: const Text('Forgot password?'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(Routes.signup),
          child: const Text('No account? Sign up'),
        ),
        const SizedBox(height: 16),
        const Text(
          'Demo account: demo@brix.dev / Demo@1234',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
