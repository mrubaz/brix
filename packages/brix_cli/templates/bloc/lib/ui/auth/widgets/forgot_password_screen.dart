import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/widgets/auth_page.dart';

/// Email for the reset code.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  BrixForgotPasswordCubit get _cubit => context.read<BrixForgotPasswordCubit>();

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) _cubit.submit();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrixForgotPasswordCubit, BrixForgotPasswordState>(
      builder: (context, state) => AuthPage(
        title: 'Forgot password',
        subtitle: 'We send a code to reset it.',
        children: [
          Form(
            key: _formKey,
            child: BrixTextField(
              onChanged: _cubit.identifierChanged,
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
      ),
    );
  }
}
