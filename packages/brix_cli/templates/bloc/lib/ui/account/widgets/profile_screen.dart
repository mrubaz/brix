import 'package:brix_bloc/brix_bloc.dart';
import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/models/profile_update.dart';
import '../../../domain/models/user.dart';
import '../../core/widgets/auth_page.dart';

/// Name (editable) and email (read only), loaded from the backend.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  BrixProfileCubit<User, ProfileUpdate> get _cubit =>
      context.read<BrixProfileCubit<User, ProfileUpdate>>();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _cubit.save(ProfileUpdate(name: _name.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<
      BrixProfileCubit<User, ProfileUpdate>,
      ProfileState<User>
    >(
      // Fill the form when the user first arrives; later reloads (a save,
      // an avatar) keep what is being typed.
      listenWhen: (before, now) => before.user == null && now.user != null,
      listener: (context, state) => _name.text = state.user!.name,
      builder: (context, state) => AuthPage(
        title: 'Profile',
        subtitle: 'Your name is shown in the app.',
        children: [
          if (state.isLoading && state.user == null)
            const Padding(padding: EdgeInsets.all(32), child: BrixLoader())
          else if (state.loadFailed)
            BrixButton.outlined(label: 'Try again', onPressed: _cubit.load)
          else
            Form(
              key: _formKey,
              child: Column(
                children: [
                  BrixTextField(
                    controller: _name,
                    label: 'Name',
                    isRequired: true,
                    textCapitalization: TextCapitalization.words,
                    onSubmitted: (_) => _save(),
                  ),
                  const SizedBox(height: 16),
                  BrixTextField(
                    initialValue: state.user?.email,
                    label: 'Email',
                    readOnly: true,
                    style: BrixTextFieldStyle(
                      fillColor: context.brix.colors.surface,
                      textStyle: TextStyle(
                        color: context.brix.colors.mutedText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BrixButton(
                    label: 'Save',
                    isLoading: state.isSaving,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
