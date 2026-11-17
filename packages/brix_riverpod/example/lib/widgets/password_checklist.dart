import 'package:brix_riverpod/brix_riverpod.dart';
import 'package:flutter/material.dart';

/// Live list of the password rules; texts come from brix
/// (`rule.labelFor(policy)`). [unmet] comes from the screen's state.
class PasswordChecklist extends StatelessWidget {
  const PasswordChecklist({
    super.key,
    required this.policy,
    required this.unmet,
  });

  final PasswordPolicy policy;
  final List<PasswordRule> unmet;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final open = unmet.toSet();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final rule in policy.rules)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Icon(
                  open.contains(rule)
                      ? Icons.radio_button_unchecked
                      : Icons.check_circle,
                  size: 16,
                  color: open.contains(rule) ? colors.outline : colors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(rule.labelFor(policy))),
              ],
            ),
          ),
      ],
    );
  }
}
