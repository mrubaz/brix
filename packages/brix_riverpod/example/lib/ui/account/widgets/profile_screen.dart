import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/profile_update.dart';
import '../../core/widgets/auth_page.dart';
import '../view_models/profile_viewmodel.dart';

/// Name (editable) and email (read only), loaded from the backend.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  ProfileViewModel get _viewModel => ref.read(profileProvider.notifier);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      _viewModel.save(ProfileUpdate(name: _name.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fill the form when the user first arrives; later reloads (a save, an
    // avatar) keep what is being typed.
    ref.listen(profileProvider, (before, now) {
      if (before?.user == null && now.user != null) _name.text = now.user!.name;
    });
    final state = ref.watch(profileProvider);
    return AuthPage(
      title: 'Profile',
      subtitle: 'Your name is shown in the app.',
      children: [
        if (state.isLoading && state.user == null)
          const Padding(padding: EdgeInsets.all(32), child: BrixLoader())
        else if (state.loadFailed)
          BrixButton.outlined(label: 'Try again', onPressed: _viewModel.load)
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
                    textStyle: TextStyle(color: context.brix.colors.mutedText),
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
    );
  }
}
