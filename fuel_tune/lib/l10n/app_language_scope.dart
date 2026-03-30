import 'package:flutter/widgets.dart';
import 'package:fuel_tune/l10n/app_language.dart';
import 'package:fuel_tune/l10n/language_controller.dart';
import 'package:fuel_tune/utils/number_utils.dart' as number_utils;

class AppLanguageScope extends InheritedNotifier<LanguageController> {
  const AppLanguageScope({
    super.key,
    required LanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static LanguageController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLanguageScope>();

    assert(scope != null, 'AppLanguageScope not found in context.');
    return scope!.notifier!;
  }
}

extension AppLanguageContext on BuildContext {
  LanguageController get languageController => AppLanguageScope.of(this);

  AppLanguage get appLanguage => languageController.language;

  bool get isEnglish => appLanguage == AppLanguage.english;

  String t({
    required String pt,
    required String en,
  }) {
    return isEnglish ? en : pt;
  }

  String formatNumberText(
    double value, {
    int decimalDigits = 2,
  }) {
    return number_utils.formatNumber(
      value,
      decimalDigits: decimalDigits,
      locale: appLanguage.localeTag,
    );
  }

  String formatCompactNumberText(double value) {
    return number_utils.formatCompactNumber(
      value,
      locale: appLanguage.localeTag,
    );
  }

  String formatTrimmedNumberText(
    double value, {
    int maxDecimalDigits = 2,
  }) {
    return number_utils.formatTrimmedNumber(
      value,
      maxDecimalDigits: maxDecimalDigits,
      locale: appLanguage.localeTag,
    );
  }

  String formatCurrencyText(double value) {
    return number_utils.formatCurrency(
      value,
      locale: appLanguage.localeTag,
    );
  }

  String formatDateTimeText(DateTime value) {
    return number_utils.formatDateTime(
      value,
      locale: appLanguage.localeTag,
    );
  }

  String formatStorageSizeText(int bytes) {
    return number_utils.formatStorageSize(
      bytes,
      locale: appLanguage.localeTag,
    );
  }
}
