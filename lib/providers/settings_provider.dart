import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/services/hive_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, ThemeMode>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<ThemeMode> {
  final Box _settingsBox = HiveService.settingsBox;
  static const String _themeKey = 'themeMode';

  SettingsNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  void _loadTheme() {
    final themeIndex = _settingsBox.get(_themeKey, defaultValue: ThemeMode.dark.index);
    state = ThemeMode.values[themeIndex];
  }

  Future<void> toggleTheme() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await _settingsBox.put(_themeKey, state.index);
  }
}