import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// One widget in the library: its brix_ui name, one line about it, and the
/// widget itself.
class LibrarySection extends StatelessWidget {
  const LibrarySection({
    super.key,
    required this.name,
    required this.about,
    required this.child,
  });

  /// The class name, e.g. `BrixButton`.
  final String name;
  final String about;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            name,
            style: brix.typography.body.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: brix.colors.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            about,
            style: brix.typography.body.copyWith(color: brix.colors.mutedText),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
