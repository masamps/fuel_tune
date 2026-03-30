import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferencesRepository {
  static const _themeModeKey = 'theme_mode';
  static const _proUnlockedKey = 'pro_unlocked';
  static const _languageCodeKey = 'language_code';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<ThemeMode> loadThemeMode() async {
    final prefs = await _prefs;
    final savedTheme = prefs.getString(_themeModeKey);

    switch (savedTheme) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
      default:
        return ThemeMode.light;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await _prefs;
    final value = mode == ThemeMode.dark ? 'dark' : 'light';
    await prefs.setString(_themeModeKey, value);
  }

  Future<bool> loadIsProUnlocked() async {
    final prefs = await _prefs;
    return prefs.getBool(_proUnlockedKey) ?? false;
  }

  Future<void> saveIsProUnlocked(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_proUnlockedKey, value);
  }

  Future<String?> loadLanguageCode() async {
    final prefs = await _prefs;
    return prefs.getString(_languageCodeKey);
  }

  Future<void> saveLanguageCode(String code) async {
    final prefs = await _prefs;
    await prefs.setString(_languageCodeKey, code);
  }

  Future<int> calculateStorageUsageInBytes() async {
    final prefs = await _prefs;
    var totalSize = 0;

    for (final key in prefs.getKeys()) {
      final value = prefs.get(key);
      if (value != null) {
        totalSize += utf8.encode(value.toString()).length;
      }
    }

    return totalSize;
  }
}
