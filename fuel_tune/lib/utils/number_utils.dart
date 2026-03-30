import 'package:intl/intl.dart';

double? parseFlexibleDouble(String input) {
  var normalized = input.trim();

  if (normalized.isEmpty) {
    return null;
  }

  normalized =
      normalized.replaceAll('R\$', '').replaceAll('%', '').replaceAll(' ', '');

  final lastComma = normalized.lastIndexOf(',');
  final lastDot = normalized.lastIndexOf('.');

  if (lastComma >= 0 && lastDot >= 0) {
    if (lastComma > lastDot) {
      normalized = normalized.replaceAll('.', '').replaceAll(',', '.');
    } else {
      normalized = normalized.replaceAll(',', '');
    }
  } else if (lastComma >= 0) {
    normalized = normalized.replaceAll(',', '.');
  } else if (_looksLikeThousandsSeparatedValue(normalized)) {
    normalized = normalized.replaceAll('.', '');
  }

  return double.tryParse(normalized);
}

String formatNumber(
  double value, {
  int decimalDigits = 2,
  String locale = 'pt_BR',
}) {
  final formatter = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = decimalDigits
    ..maximumFractionDigits = decimalDigits;
  return formatter.format(value);
}

String formatCompactNumber(
  double value, {
  String locale = 'pt_BR',
}) {
  return NumberFormat.decimalPattern(locale).format(value);
}

String formatTrimmedNumber(
  double value, {
  int maxDecimalDigits = 2,
  String locale = 'pt_BR',
}) {
  final formatter = NumberFormat.decimalPattern(locale)
    ..minimumFractionDigits = 0
    ..maximumFractionDigits = maxDecimalDigits;
  return formatter.format(value);
}

String formatCurrency(
  double value, {
  String locale = 'pt_BR',
}) {
  final formatter = NumberFormat.currency(
    locale: locale,
    symbol: 'R\$',
    decimalDigits: 2,
  );
  return formatter.format(value);
}

String formatDateTime(
  DateTime value, {
  String locale = 'pt_BR',
}) {
  final formatter = DateFormat(
    locale == 'en_US' ? 'MM/dd/yyyy HH:mm' : 'dd/MM/yyyy HH:mm',
    locale,
  );
  return formatter.format(value);
}

String formatStorageSize(
  int bytes, {
  String locale = 'pt_BR',
}) {
  if (bytes < 1024) {
    return '$bytes B';
  }

  if (bytes < 1024 * 1024) {
    return '${formatNumber(bytes / 1024, locale: locale)} KB';
  }

  return '${formatNumber(bytes / (1024 * 1024), locale: locale)} MB';
}

String fuelBlendLabel({
  required String presetLabel,
  required bool isCustom,
  double? customPercentage,
}) {
  if (!isCustom || customPercentage == null) {
    return presetLabel;
  }

  return 'E${formatTrimmedNumber(customPercentage)}';
}

bool _looksLikeThousandsSeparatedValue(String value) {
  final parts = value.split('.');

  if (parts.length < 2) {
    return false;
  }

  if (parts.first.isEmpty || parts.any((part) => part.isEmpty)) {
    return false;
  }

  return parts.skip(1).every((part) => part.length == 3);
}
