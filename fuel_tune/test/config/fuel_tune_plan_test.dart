import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';

void main() {
  group('FuelTunePlan', () {
    test('allows saving while free history limit is not reached', () {
      final canSave = FuelTunePlan.canSaveRecord(
        isProUnlocked: false,
        currentRecordsCount: 4,
      );

      expect(canSave, isTrue);
    });

    test('blocks saving when free history limit is reached', () {
      final canSave = FuelTunePlan.canSaveRecord(
        isProUnlocked: false,
        currentRecordsCount: 5,
      );

      expect(canSave, isFalse);
    });

    test('always allows saving for pro users', () {
      final canSave = FuelTunePlan.canSaveRecord(
        isProUnlocked: true,
        currentRecordsCount: 999,
      );

      expect(canSave, isTrue);
    });
  });
}
