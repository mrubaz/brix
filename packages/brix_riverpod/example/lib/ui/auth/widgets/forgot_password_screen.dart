import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/auth_page.dart';
import '../view_models/forgot_password_viewmodel.dart';

/// Email for the reset code.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  ForgotPasswordViewModel get _viewModel =>
      ref.read(forgotPasswordProvider.notifier);

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _viewModel.submit();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);
    return AuthPage(
      title: 'Forgot password',
      subtitle: 'We send a code to reset it.',
      children: [
        Form(
          key: _formKey,
          child: BrixTextField(
            onChanged: _viewModel.identifierChanged,
            label: 'Email',
            isRequired: true,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            onSubmitted: (_) => _submit(),
          ),
        ),
        const SizedBox(height: 24),
        BrixButton(
          label: 'Send code',
          isLoading: state.isSubmitting,
          onPressed: _submit,
        ),
      ],
    );
  }
}
