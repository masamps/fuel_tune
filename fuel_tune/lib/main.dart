import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fuel_tune/l10n/app_language.dart';
import 'package:fuel_tune/l10n/app_language_scope.dart';
import 'package:fuel_tune/l10n/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/theme/app_theme.dart';
import 'package:fuel_tune/theme/theme_controller.dart';

import 'screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferencesRepository = LocalPreferencesRepository();
  final themeController = ThemeController(preferencesRepository);
  final languageController = LanguageController(preferencesRepository);
  await themeController.load();
  await languageController.load();

  runApp(
    MyApp(
      themeController: themeController,
      languageController: languageController,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.themeController,
    required this.languageController,
  });

  final ThemeController themeController;
  final LanguageController languageController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([themeController, languageController]),
      builder: (context, _) {
        return AppLanguageScope(
          controller: languageController,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode,
            locale: languageController.locale,
            supportedLocales:
                AppLanguage.values.map((language) => language.locale).toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Home(
              themeController: themeController,
              languageController: languageController,
            ),
          ),
        );
      },
    );
  }
}
