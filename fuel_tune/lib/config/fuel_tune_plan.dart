import 'dart:math' as math;

abstract final class FuelTunePlan {
  static const int freeHistoryLimit = 5;
  static const String proName = 'Fuel Tune Pro';
  static const int proPriceInCents = 1990;
  static const String fullUnlockCouponCode = '110927';
  static const String partialDiscountCouponCode = 'UPZERO15';
  static const int partialDiscountCouponFinalPriceInCents = 1515;
  static const int fullUnlockCouponDiscountPercent = 100;

  static double get proPrice => proPriceInCents / 100;

  static bool canSaveRecord({
    required bool isProUnlocked,
    required int currentRecordsCount,
  }) {
    return isProUnlocked || currentRecordsCount < freeHistoryLimit;
  }

  static int remainingFreeHistorySlots(int currentRecordsCount) {
    return math.max(freeHistoryLimit - currentRecordsCount, 0);
  }

  static bool hasReachedFreeHistoryLimit(int currentRecordsCount) {
    return currentRecordsCount >= freeHistoryLimit;
  }

  static double discountedProPrice(int discountPercent) {
    final safePercent = math.max(0, math.min(discountPercent, 100));
    final discountedCents =
        ((proPriceInCents * (100 - safePercent)) / 100).round();

    return discountedCents / 100;
  }

  static double priceFromCents(int priceInCents) {
    return priceInCents / 100;
  }

  static int roundedDiscountPercentForPriceInCents(int discountedPriceInCents) {
    final safePrice =
        math.max(0, math.min(discountedPriceInCents, proPriceInCents));
    final discountFraction = (proPriceInCents - safePrice) / proPriceInCents;

    return (discountFraction * 100).round();
  }
}
