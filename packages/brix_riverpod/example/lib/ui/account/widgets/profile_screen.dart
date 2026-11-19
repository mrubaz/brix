import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/auth_page.dart';
import '../view_models/profile_viewmodel.dart';

/// Name (editable) and email (read only), loaded from the backend.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final profile = ref.read(profileProvider.notifier);
    return AuthPage(
      title: 'Profile',
      subtitle: 'Your name is shown in the app.',
      children: [
        if (state.isLoading)
          const Padding(padding: EdgeInsets.all(32), child: BrixLoader())
        else if (state.loadFailed)
          BrixButton.outlined(label: 'Try again', onPressed: profile.load)
        else
          Form(
            key: profile.formKey,
            child: Column(
              children: [
                BrixTextField(
                  controller: profile.nameController,
                  label: 'Name',
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => profile.save(),
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
                  onPressed: profile.save,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
