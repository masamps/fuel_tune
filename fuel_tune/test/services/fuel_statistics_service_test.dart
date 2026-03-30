import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/models/fuel_record.dart';
import 'package:fuel_tune/services/fuel_statistics_service.dart';

void main() {
  group('FuelStatisticsService', () {
    test('returns empty summary when there are no records', () {
      final summary = FuelStatisticsService.summarize(const []);

      expect(summary.totalRecords, 0);
      expect(summary.averageConsumptionKmPerLiter, 0);
      expect(summary.totalAmountPaid, isNull);
    });

    test('calculates consumption and spending metrics', () {
      final summary = FuelStatisticsService.summarize([
        FuelRecord(
          distanceKm: 300,
          litersFilled: 25,
          averageConsumption: 12,
          fueledAt: DateTime.parse('2026-03-20T10:00:00.000'),
          amountPaid: 150,
        ),
        FuelRecord(
          distanceKm: 360,
          litersFilled: 30,
          averageConsumption: 12,
          fueledAt: DateTime.parse('2026-03-22T10:00:00.000'),
          amountPaid: 180,
        ),
      ]);

      expect(summary.totalRecords, 2);
      expect(summary.totalDistanceKm, 660);
      expect(summary.totalLitersFilled, 55);
      expect(summary.averageConsumptionKmPerLiter, 12);
      expect(summary.bestConsumptionKmPerLiter, 12);
      expect(summary.worstConsumptionKmPerLiter, 12);
      expect(summary.totalAmountPaid, 330);
      expect(summary.averageAmountPaid, 165);
      expect(summary.costPerKm, 0.5);
      expect(summary.recentRecords.first.distanceKm, 360);
    });

    test('ignores spending metrics when amount paid is absent', () {
      final summary = FuelStatisticsService.summarize([
        FuelRecord(
          distanceKm: 250,
          litersFilled: 20,
          averageConsumption: 12.5,
          fueledAt: DateTime.parse('2026-03-22T10:00:00.000'),
        ),
      ]);

      expect(summary.averageAmountPaid, isNull);
      expect(summary.totalAmountPaid, isNull);
      expect(summary.costPerKm, isNull);
      expect(summary.paidRecordsCount, 0);
    });
  });
}
