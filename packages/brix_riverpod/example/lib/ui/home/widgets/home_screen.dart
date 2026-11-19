import 'package:flutter/material.dart';

import '../../../config/dependencies.dart';
import '../../core/widgets/setup_steps.dart';
import '../../core/widgets/tab_page.dart';

/// Your app starts here. Replace it with your first screen.
///
/// While developing it lists what to do before the app goes live; a release
/// build never shows those steps.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final developing = Dependencies.devTools != null;
    return FutureBuilder(
      future: Dependencies.session.readSession(),
      builder: (context, snapshot) => TabPage(
        title: 'Welcome, ${snapshot.data?.user.name ?? ''}',
        subtitle: developing
            ? 'Your app runs. These steps make it yours.'
            : 'Your app starts here.',
        children: [if (developing) const SetupSteps()],
      ),
    );
  }
}
