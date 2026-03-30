import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/services/calculo_combustivel.dart';

void main() {
  group('FuelMixCalculator', () {
    test('calculates blend by liters', () {
      final result = FuelMixCalculator.calculateByLiters(
        totalLiters: 20,
        ethanolFraction: 0.75,
      );

      expect(result.ethanolLiters, 15);
      expect(result.gasolineLiters, 5);
      expect(result.totalLiters, 20);
    });

    test('calculates blend by value', () {
      final result = FuelMixCalculator.calculateByValue(
        totalAmount: 100,
        ethanolPrice: 4,
        gasolinePrice: 5,
        ethanolFraction: 0.5,
      );

      expect(result.ethanolLiters, 12.5);
      expect(result.gasolineLiters, 10);
      expect(result.totalLiters, 22.5);
    });
  });
}
