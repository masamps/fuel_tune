import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalPreferencesRepository', () {
    late LocalPreferencesRepository repository;

    setUp(() {
      repository = LocalPreferencesRepository();
      SharedPreferences.setMockInitialValues({});
    });

    test('loads light theme by default', () async {
      final themeMode = await repository.loadThemeMode();

      expect(themeMode, ThemeMode.light);
    });

    test('loads pro as disabled by default', () async {
      final isProUnlocked = await repository.loadIsProUnlocked();

      expect(isProUnlocked, isFalse);
    });

    test('persists pro status locally', () async {
      await repository.saveIsProUnlocked(true);

      final isProUnlocked = await repository.loadIsProUnlocked();

      expect(isProUnlocked, isTrue);
    });

    test('persists language code locally', () async {
      await repository.saveLanguageCode('en');

      final languageCode = await repository.loadLanguageCode();

      expect(languageCode, 'en');
    });
  });
}
