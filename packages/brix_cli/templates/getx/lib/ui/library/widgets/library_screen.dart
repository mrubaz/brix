import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/tab_page.dart';
import 'library_section.dart';

/// Every brix_ui widget in your theme, with its name. Change
/// `lib/ui/core/themes/theme.dart` and see them all change here. Remove this
/// tab when you no longer need it.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const _countries = [
    BrixOption(value: 'pk', label: 'Pakistan'),
    BrixOption(value: 'ae', label: 'United Arab Emirates'),
    BrixOption(value: 'gb', label: 'United Kingdom'),
    BrixOption(value: 'us', label: 'United States'),
  ];

  static const _cities = [
    BrixOption(value: 'lhr', label: 'Lahore'),
    BrixOption(value: 'khi', label: 'Karachi'),
    BrixOption(value: 'isb', label: 'Islamabad'),
    BrixOption(value: 'dxb', label: 'Dubai'),
    BrixOption(value: 'lon', label: 'London'),
  ];

  String? _country = 'pk';

  @override
  Widget build(BuildContext context) {
    return TabPage(
      title: 'Library',
      subtitle: 'Every brix_ui widget, in your theme.',
      children: [
        LibrarySection(
          name: 'BrixButton',
          about: 'Filled, outlined and destructive, with a loading state.',
          child: Column(
            children: [
              BrixButton(label: 'Continue', onPressed: () {}),
              const SizedBox(height: 10),
              BrixButton.outlined(label: 'Cancel', onPressed: () {}),
              const SizedBox(height: 10),
              BrixButton.destructive(label: 'Delete', onPressed: () {}),
            ],
          ),
        ),
        const LibrarySection(
          name: 'BrixTextField',
          about: 'Label, required marker, password eye and errors.',
          child: BrixTextField(
            label: 'Email',
            hint: 'you@example.com',
            isRequired: true,
          ),
        ),
        LibrarySection(
          name: 'BrixSelect',
          about: 'A menu for a few options, a sheet for many.',
          child: BrixSelect<String>(
            label: 'Country',
            options: _countries,
            value: _country,
            onChanged: (value) => setState(() => _country = value),
          ),
        ),
        const LibrarySection(
          name: 'BrixSearchField',
          about: 'Type to search; a name not in the list is kept too.',
          child: BrixSearchField<String>(label: 'City', options: _cities),
        ),
        const LibrarySection(
          name: 'BrixCard',
          about: 'A surface in your theme, with an optional accent.',
          child: BrixCard(child: Text('A card holds any content.')),
        ),
        LibrarySection(
          name: 'BrixSheet',
          about: 'A bottom sheet in three heights.',
          child: BrixButton.outlined(
            label: 'Open a sheet',
            onPressed: () => BrixSheet.show<void>(
              context: context,
              title: 'A sheet',
              builder: (_) => const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Text('Short forms and choices go here.'),
              ),
            ),
          ),
        ),
        LibrarySection(
          name: 'BrixDialog',
          about: 'Errors, warnings and questions on a dim background.',
          child: BrixButton.outlined(
            label: 'Open a dialog',
            onPressed: () => BrixDialog.show<void>(
              context: context,
              title: 'A dialog',
              message: 'It reads on any screen.',
            ),
          ),
        ),
        LibrarySection(
          name: 'BrixToast',
          about: 'A short success message at the top.',
          child: BrixButton.outlined(
            label: 'Show a toast',
            onPressed: () => BrixToast.success('Saved.', context: context),
          ),
        ),
        const LibrarySection(
          name: 'BrixLoader',
          about: 'The iOS style spinner, in any size.',
          child: SizedBox(height: 40, child: BrixLoader(radius: 12)),
        ),
      ],
    );
  }
}
