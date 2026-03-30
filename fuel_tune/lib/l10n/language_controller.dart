import 'package:flutter/material.dart';
import 'package:fuel_tune/l10n/app_language.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';

class LanguageController extends ChangeNotifier {
  LanguageController(this._preferencesRepository);

  final LocalPreferencesRepository _preferencesRepository;

  AppLanguage _language = AppLanguage.portuguese;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  Future<void> load() async {
    final savedCode = await _preferencesRepository.loadLanguageCode();
    _language = AppLanguage.fromCode(savedCode);
  }

  Future<void> updateLanguage(AppLanguage language) async {
    if (_language == language) {
      return;
    }

    _language = language;
    notifyListeners();
    await _preferencesRepository.saveLanguageCode(language.code);
  }
}
