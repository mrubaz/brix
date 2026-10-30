import 'package:brix_ui/brix_ui.dart';
import 'package:flutter/material.dart';

/// One row in a [SettingsGroup]: a coloured icon, a label and a chevron.
class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// Background of the icon tile; default `colors.primary`.
  final Color? iconColor;

  /// Red label, for actions like deleting the account.
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final brix = context.brix;
    final tile = destructive
        ? brix.colors.danger
        : iconColor ?? brix.colors.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: tile,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: brix.typography.body.copyWith(
                  fontSize: 17,
                  color: destructive ? brix.colors.danger : brix.colors.text,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: brix.colors.mutedText.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
