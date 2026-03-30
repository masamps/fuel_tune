import 'package:fuel_tune/config/fuel_tune_plan.dart';
import 'package:fuel_tune/repositories/local_preferences_repository.dart';

enum ProCouponRedemptionStatus {
  success,
  alreadyUnlocked,
  discountApplied,
  invalid,
}

class ProCouponRedemptionResult {
  const ProCouponRedemptionResult({
    required this.status,
    required this.normalizedCode,
    this.discountPercent = 0,
    this.discountedPrice = FuelTunePlan.proPriceInCents / 100,
  });

  final ProCouponRedemptionStatus status;
  final String normalizedCode;
  final int discountPercent;
  final double discountedPrice;

  bool get isSuccess =>
      status == ProCouponRedemptionStatus.success ||
      status == ProCouponRedemptionStatus.alreadyUnlocked;

  bool get hasDiscount =>
      status == ProCouponRedemptionStatus.success ||
      status == ProCouponRedemptionStatus.alreadyUnlocked ||
      status == ProCouponRedemptionStatus.discountApplied;

  bool get unlocksPro =>
      discountPercent >= FuelTunePlan.fullUnlockCouponDiscountPercent;
}

class ProAccessService {
  ProAccessService({LocalPreferencesRepository? preferencesRepository})
      : _preferencesRepository =
            preferencesRepository ?? LocalPreferencesRepository();

  final LocalPreferencesRepository _preferencesRepository;

  Future<void> unlockPro() async {
    await _preferencesRepository.saveIsProUnlocked(true);
  }

  Future<ProCouponRedemptionResult> redeemCoupon(String rawCode) async {
    final normalizedCode = normalizeCoupon(rawCode);
    final discountedPriceInCents = _couponPricesInCents[normalizedCode];

    if (discountedPriceInCents == null) {
      return ProCouponRedemptionResult(
        status: ProCouponRedemptionStatus.invalid,
        normalizedCode: normalizedCode,
        discountedPrice: FuelTunePlan.proPrice,
      );
    }

    final discountedPrice = FuelTunePlan.priceFromCents(discountedPriceInCents);
    final discountPercent = FuelTunePlan.roundedDiscountPercentForPriceInCents(
      discountedPriceInCents,
    );

    if (discountedPriceInCents > 0) {
      return ProCouponRedemptionResult(
        status: ProCouponRedemptionStatus.discountApplied,
        normalizedCode: normalizedCode,
        discountPercent: discountPercent,
        discountedPrice: discountedPrice,
      );
    }

    final isProUnlocked = await _preferencesRepository.loadIsProUnlocked();

    if (!isProUnlocked) {
      await unlockPro();
    }

    return ProCouponRedemptionResult(
      status: isProUnlocked
          ? ProCouponRedemptionStatus.alreadyUnlocked
          : ProCouponRedemptionStatus.success,
      normalizedCode: normalizedCode,
      discountPercent: discountPercent,
      discountedPrice: discountedPrice,
    );
  }

  static String normalizeCoupon(String rawCode) {
    return rawCode.replaceAll(RegExp(r'\s+'), '').trim().toUpperCase();
  }

  static const Map<String, int> _couponPricesInCents = {
    FuelTunePlan.fullUnlockCouponCode: 0,
    FuelTunePlan.partialDiscountCouponCode:
        FuelTunePlan.partialDiscountCouponFinalPriceInCents,
  };
}
