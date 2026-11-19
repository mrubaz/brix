import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../config/dependencies.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/auth_page.dart';
import '../view_models/login_viewmodel.dart';

/// Email, password, remember me. Only layout, the view model does the rest.
///
/// [identifier] fills the email after a signup or a password reset.
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
    if (widget.identifier case final email?) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => ref.read(loginProvider.notifier).prefillIdentifier(email),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    final login = ref.read(loginProvider.notifier);
    return AuthPage(
      title: 'Welcome back',
      subtitle: 'Log in to continue.',
      children: [
        Form(
          key: login.formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                BrixTextField(
                  controller: login.identifierController,
                  label: 'Email',
                  isRequired: true,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  controller: login.passwordController,
                  label: 'Password',
                  isRequired: true,
                  isPassword: true,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => login.login(),
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
              onChanged: (_) => login.toggleRememberMe(),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: login.toggleRememberMe,
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
          onPressed: login.login,
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
