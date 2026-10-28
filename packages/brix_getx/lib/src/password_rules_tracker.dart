import 'package:brix/auth.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Keeps [unmet] in sync with what is typed in [field], for a live
/// checklist under a new password field.
class PasswordRulesTracker {
  PasswordRulesTracker({required this.policy, required this.field})
    : unmet = RxList<PasswordRule>(policy.unmetRules(field.text)) {
    field.addListener(_update);
  }

  final PasswordPolicy policy;
  final TextEditingController field;

  /// Rules the typed password does not meet yet; empty = allowed.
  final RxList<PasswordRule> unmet;

  /// Every rule of the policy, in checklist order.
  List<PasswordRule> get rules => policy.rules;

  bool get isMet => unmet.isEmpty;

  void _update() => unmet.assignAll(policy.unmetRules(field.text));

  /// Call before disposing [field].
  void dispose() => field.removeListener(_update);
}
