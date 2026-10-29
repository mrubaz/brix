import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

import 'brands.dart';

/// Brand and dark mode switches on top, then every widget.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({
    super.key,
    required this.brand,
    required this.dark,
    required this.onBrand,
    required this.onDark,
  });

  final Brand brand;
  final bool dark;
  final ValueChanged<Brand> onBrand;
  final ValueChanged<bool> onDark;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _signingIn = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      BrixAlert.warning('Fill in your email and password.');
      return;
    }
    setState(() => _signingIn = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _signingIn = false);
    BrixToast.success('Signed in as ${_email.text}');
  }

  Future<void> _confirmDelete() async {
    final delete = await BrixAlert.show<bool>(
      title: 'Delete this photo?',
      message: 'This cannot be undone.',
      icon: const BrixIcon(Icons.delete_outline),
      accent: context.brix.colors.danger,
      buttons: const [
        BrixAlertButton(label: 'Cancel', value: false),
        BrixAlertButton.destructive(label: 'Delete', value: true),
      ],
    );
    if (delete ?? false) BrixToast.success('Photo deleted');
  }

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    Text heading(String text) => Text(
      text,
      style: brix.typography.title.copyWith(color: brix.colors.text),
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<Brand>(
                    segments: [
                      for (final brand in Brand.values)
                        ButtonSegment(value: brand, label: Text(brand.label)),
                    ],
                    selected: {widget.brand},
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: brix.colors.primary,
                      selectedForegroundColor: brix.colors.onPrimary,
                      foregroundColor: brix.colors.text,
                      side: BorderSide(color: brix.colors.border),
                    ),
                    onSelectionChanged: (selection) =>
                        widget.onBrand(selection.first),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: widget.dark ? 'Light mode' : 'Dark mode',
                  icon: Icon(widget.dark ? Icons.light_mode : Icons.dark_mode),
                  onPressed: () => widget.onDark(!widget.dark),
                ),
              ],
            ),
            const SizedBox(height: 28),
            heading('Sign in'),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: AutofillGroup(
                child: Column(
                  children: [
                    BrixTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@example.com',
                      isRequired: true,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    BrixTextField(
                      controller: _password,
                      label: 'Password',
                      isRequired: true,
                      isPassword: true,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _signIn(),
                    ),
                    const SizedBox(height: 20),
                    BrixButton(
                      label: 'Sign in',
                      isLoading: _signingIn,
                      onPressed: _signIn,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            heading('Buttons'),
            const SizedBox(height: 16),
            BrixButton.outlined(label: 'Back', onPressed: () {}),
            const SizedBox(height: 12),
            BrixButton.destructive(
              label: 'Delete photo',
              icon: Icons.delete_outline,
              onPressed: _confirmDelete,
            ),
            const SizedBox(height: 12),
            const BrixButton(label: 'Disabled', onPressed: null),
            const SizedBox(height: 32),
            heading('Alerts and toasts'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                BrixButton.outlined(
                  label: 'Warning',
                  expand: false,
                  onPressed: () => BrixAlert.warning('Check your input.'),
                ),
                BrixButton.outlined(
                  label: 'Error',
                  expand: false,
                  onPressed: () => BrixAlert.error('No internet connection.'),
                ),
                BrixButton.outlined(
                  label: 'Toast',
                  expand: false,
                  onPressed: () => BrixToast.success('Saved'),
                ),
              ],
            ),
            const SizedBox(height: 32),
            heading('Loader'),
            const SizedBox(height: 16),
            const BrixLoader(),
          ],
        ),
      ),
    );
  }
}
