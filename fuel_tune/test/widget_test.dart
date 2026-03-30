import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fuel_tune/l10n/language_controller.dart';
import 'package:fuel_tune/main.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/theme/theme_controller.dart';
import 'package:flutter/cupertino.dart';

void main() {
  testWidgets('opens on the mixture flow and shows the main navigation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferencesRepository = LocalPreferencesRepository();
    final themeController = ThemeController(preferencesRepository);
    final languageController = LanguageController(preferencesRepository);

    await themeController.load();
    await languageController.load();

    await tester.pumpWidget(
      MyApp(
        themeController: themeController,
        languageController: languageController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mistura desejada'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.speedometer), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.settings), findsOneWidget);
  });

  testWidgets('shows English copy and the Pro tab when premium is enabled', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'language_code': 'en',
      'pro_unlocked': true,
    });
    final preferencesRepository = LocalPreferencesRepository();
    final themeController = ThemeController(preferencesRepository);
    final languageController = LanguageController(preferencesRepository);

    await themeController.load();
    await languageController.load();

    await tester.pumpWidget(
      MyApp(
        themeController: themeController,
        languageController: languageController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Target blend'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.speedometer), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.clock), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.star), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.settings), findsOneWidget);
  });
}
