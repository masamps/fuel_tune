import 'package:flutter/material.dart';

import '../repositories/local_preferences_repository.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._preferencesRepository);

  final LocalPreferencesRepository _preferencesRepository;

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    _themeMode = await _preferencesRepository.loadThemeMode();
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();
    await _preferencesRepository.saveThemeMode(mode);
  }
}
