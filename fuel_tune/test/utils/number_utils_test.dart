import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/utils/number_utils.dart';

void main() {
  group('parseFlexibleDouble', () {
    test('accepts Brazilian decimal comma', () {
      expect(parseFlexibleDouble('5,79'), 5.79);
    });

    test('accepts mixed thousands and decimals in pt-BR', () {
      expect(parseFlexibleDouble('1.234,56'), 1234.56);
    });

    test('treats isolated dot groups as thousands separators', () {
      expect(parseFlexibleDouble('1.234'), 1234);
      expect(parseFlexibleDouble('12.345.678'), 12345678);
    });

    test('keeps dot as decimal separator when format is plain decimal', () {
      expect(parseFlexibleDouble('12.34'), 12.34);
    });
  });

  group('fuelBlendLabel', () {
    test('preserves decimal precision for custom blends', () {
      expect(
        fuelBlendLabel(
          presetLabel: 'Personalizada',
          isCustom: true,
          customPercentage: 62.5,
        ),
        'E62,5',
      );
    });

    test('keeps integer custom blends clean', () {
      expect(
        fuelBlendLabel(
          presetLabel: 'Personalizada',
          isCustom: true,
          customPercentage: 70,
        ),
        'E70',
      );
    });
  });
}
