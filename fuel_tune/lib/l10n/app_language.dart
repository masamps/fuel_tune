import 'package:flutter/material.dart';

enum AppLanguage {
  portuguese(code: 'pt', localeTag: 'pt_BR', locale: Locale('pt', 'BR')),
  english(code: 'en', localeTag: 'en_US', locale: Locale('en', 'US'));

  const AppLanguage({
    required this.code,
    required this.localeTag,
    required this.locale,
  });

  final String code;
  final String localeTag;
  final Locale locale;

  static AppLanguage fromCode(String? code) {
    return AppLanguage.values.firstWhere(
      (language) => language.code == code,
      orElse: () => AppLanguage.portuguese,
    );
  }
}
