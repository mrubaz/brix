import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/widgets/auth_page.dart';
import '../view_models/profile_viewmodel.dart';

/// Name (editable) and email (read only).
class ProfileScreen extends GetView<ProfileViewModel> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthPage(
      title: 'Profile',
      subtitle: 'Your name is shown in the app.',
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return const Padding(
              padding: EdgeInsets.all(32),
              child: BrixLoader(),
            );
          }
          if (controller.loadFailed.value) {
            return BrixButton.outlined(
              label: 'Try again',
              onPressed: controller.load,
            );
          }
          return Form(
            key: controller.formKey,
            child: Column(
              children: [
                BrixTextField(
                  controller: controller.nameController,
                  label: 'Name',
                  isRequired: true,
                  textCapitalization: TextCapitalization.words,
                  onSubmitted: (_) => controller.save(),
                ),
                const SizedBox(height: 16),
                BrixTextField(
                  initialValue: controller.user.value?.email,
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
                  isLoading: controller.isSaving.value,
                  onPressed: controller.save,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
