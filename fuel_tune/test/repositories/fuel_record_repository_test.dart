import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/models/fuel_record.dart';
import 'package:fuel_tune/repositories/fuel_record_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FuelRecordRepository', () {
    late FuelRecordRepository repository;

    setUp(() {
      repository = FuelRecordRepository();
    });

    test('returns empty list when persisted JSON is invalid', () async {
      SharedPreferences.setMockInitialValues({
        'abastecimentos': '{invalid-json',
      });

      final records = await repository.loadRecords();

      expect(records, isEmpty);
    });

    test('can save a record even when previous payload was invalid', () async {
      SharedPreferences.setMockInitialValues({
        'abastecimentos': '{invalid-json',
      });

      await repository.saveRecord(
        FuelRecord(
          distanceKm: 100,
          litersFilled: 10,
          averageConsumption: 10,
          fueledAt: DateTime.parse('2026-03-20T10:00:00.000'),
        ),
      );

      final records = await repository.loadRecords();

      expect(records, hasLength(1));
      expect(records.first.distanceKm, 100);
    });

    test('sorts records from newest to oldest', () async {
      SharedPreferences.setMockInitialValues({});

      await repository.saveRecords([
        FuelRecord(
          distanceKm: 100,
          litersFilled: 10,
          averageConsumption: 10,
          fueledAt: DateTime.parse('2026-03-19T10:00:00.000'),
        ),
        FuelRecord(
          distanceKm: 200,
          litersFilled: 20,
          averageConsumption: 10,
          fueledAt: DateTime.parse('2026-03-20T10:00:00.000'),
        ),
      ]);

      final records = await repository.loadRecords();

      expect(records.first.distanceKm, 200);
      expect(records.last.distanceKm, 100);
    });
  });
}
