import 'package:brix_getx/brix_getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Live list of the password rules; texts come from brix
/// (`rule.labelFor(policy)`).
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({super.key, required this.tracker});

  final PasswordRulesTracker tracker;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Obx(() {
      final unmet = tracker.unmet.toSet();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final rule in tracker.rules)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(
                    unmet.contains(rule)
                        ? Icons.radio_button_unchecked
                        : Icons.check_circle,
                    size: 16,
                    color: unmet.contains(rule)
                        ? colors.outline
                        : colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(rule.labelFor(tracker.policy))),
                ],
              ),
            ),
        ],
      );
    });
  }
}
