import 'package:flutter/material.dart';

import 'brix_icon.dart';

/// Every icon brix_ui shows on its own. Material icons by default; pass
/// your own (`BrixIcon(CupertinoIcons....)`, `BrixIcon.custom(svg)`).
class BrixUiIcons {
  const BrixUiIcons({
    this.warning = const BrixIcon(Icons.warning_amber_rounded),
    this.error = const BrixIcon(Icons.error_outline_rounded),
    this.success = const BrixIcon(Icons.check_circle_rounded),
    this.showPassword = const BrixIcon(Icons.visibility_outlined),
    this.hidePassword = const BrixIcon(Icons.visibility_off_outlined),
  });

  /// `BrixAlert.warning`.
  final BrixIcon warning;

  /// `BrixAlert.error`.
  final BrixIcon error;

  /// `BrixToast.success`.
  final BrixIcon success;

  /// Password field button, while the text is hidden.
  final BrixIcon showPassword;

  /// Password field button, while the text is shown.
  final BrixIcon hidePassword;

  BrixUiIcons copyWith({
    BrixIcon? warning,
    BrixIcon? error,
    BrixIcon? success,
    BrixIcon? showPassword,
    BrixIcon? hidePassword,
  }) {
    return BrixUiIcons(
      warning: warning ?? this.warning,
      error: error ?? this.error,
      success: success ?? this.success,
      showPassword: showPassword ?? this.showPassword,
      hidePassword: hidePassword ?? this.hidePassword,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is BrixUiIcons &&
      other.warning == warning &&
      other.error == error &&
      other.success == success &&
      other.showPassword == showPassword &&
      other.hidePassword == hidePassword;

  @override
  int get hashCode =>
      Object.hash(warning, error, success, showPassword, hidePassword);
}
