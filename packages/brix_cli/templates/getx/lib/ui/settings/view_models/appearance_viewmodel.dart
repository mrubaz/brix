import 'package:brix_storage/brix_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Light, dark or the phone's setting, kept on the device. One for the whole
/// app (the app's `MaterialApp` follows [mode]).
class AppearanceViewModel extends GetxController {
  AppearanceViewModel(this._storage);

  final BrixStorage _storage;

  static const _key = 'appearance';

  final mode = ThemeMode.system.obs;

  /// Reads the saved choice; call once at start.
  Future<void> load() async {
    final saved = await _storage.read(_key);
    mode.value = ThemeMode.values.firstWhere(
      (value) => value.name == saved,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> select(ThemeMode value) async {
    mode.value = value;
    await _storage.write(_key, value.name);
  }
}
