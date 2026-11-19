import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';

/// Light, dark or the phone's setting, kept on the device. One for the whole
/// app (the app's `MaterialApp` watches it).
class AppearanceViewModel extends Notifier<ThemeMode> {
  static const _key = 'appearance';

  @override
  ThemeMode build() {
    _load();
    return ThemeMode.system;
  }

  Future<void> _load() async {
    final saved = await Dependencies.storage.read(_key);
    if (!ref.mounted) return;
    state = ThemeMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> select(ThemeMode value) async {
    state = value;
    await Dependencies.storage.write(_key, value.name);
  }
}

final appearanceProvider = NotifierProvider<AppearanceViewModel, ThemeMode>(
  AppearanceViewModel.new,
);
