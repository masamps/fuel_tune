import 'package:flutter_test/flutter_test.dart';
import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';
import 'package:fuel_tune/services/pro_access_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ProAccessService', () {
    late LocalPreferencesRepository preferencesRepository;
    late ProAccessService service;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      preferencesRepository = LocalPreferencesRepository();
      service = ProAccessService(
        preferencesRepository: preferencesRepository,
      );
    });

    test('redeems the full discount coupon and unlocks Pro', () async {
      final result = await service.redeemCoupon(
        FuelTunePlan.fullUnlockCouponCode,
      );

      expect(result.status, ProCouponRedemptionStatus.success);
      expect(
        result.discountPercent,
        FuelTunePlan.fullUnlockCouponDiscountPercent,
      );
      expect(result.discountedPrice, 0);
      expect(await preferencesRepository.loadIsProUnlocked(), isTrue);
    });

    test('applies the upzero15 coupon without unlocking Pro', () async {
      final result = await service.redeemCoupon('upzero15');

      expect(result.status, ProCouponRedemptionStatus.discountApplied);
      expect(
        result.discountPercent,
        FuelTunePlan.roundedDiscountPercentForPriceInCents(
          FuelTunePlan.partialDiscountCouponFinalPriceInCents,
        ),
      );
      expect(
        result.discountedPrice,
        FuelTunePlan.priceFromCents(
          FuelTunePlan.partialDiscountCouponFinalPriceInCents,
        ),
      );
      expect(await preferencesRepository.loadIsProUnlocked(), isFalse);
    });

    test('rejects invalid coupon codes', () async {
      final result = await service.redeemCoupon('123456');

      expect(result.status, ProCouponRedemptionStatus.invalid);
      expect(await preferencesRepository.loadIsProUnlocked(), isFalse);
    });

    test('normalizes coupon spacing before validation', () async {
      final result = await service.redeemCoupon(' 110927 ');

      expect(result.status, ProCouponRedemptionStatus.success);
      expect(result.normalizedCode, FuelTunePlan.fullUnlockCouponCode);
    });
  });
}
