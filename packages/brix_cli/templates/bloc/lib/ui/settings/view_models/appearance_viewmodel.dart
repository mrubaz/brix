import 'package:brix_storage/brix_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Light, dark or the phone's setting, kept on the device. One for the whole
/// app (the app's `MaterialApp` follows it).
class AppearanceViewModel extends Cubit<ThemeMode> {
  AppearanceViewModel(this._storage) : super(ThemeMode.system) {
    _load();
  }

  final BrixStorage _storage;

  static const _key = 'appearance';

  Future<void> _load() async {
    final saved = await _storage.read(_key);
    if (isClosed) return;
    emit(
      ThemeMode.values.firstWhere(
        (value) => value.name == saved,
        orElse: () => ThemeMode.system,
      ),
    );
  }

  Future<void> select(ThemeMode value) async {
    emit(value);
    await _storage.write(_key, value.name);
  }
}
