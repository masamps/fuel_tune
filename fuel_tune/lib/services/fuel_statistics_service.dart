import 'dart:math' as math;

import 'package:fuel_tune/models/fuel_record.dart';
import 'package:fuel_tune/models/fuel_statistics_summary.dart';

class FuelStatisticsService {
  const FuelStatisticsService._();

  static FuelStatisticsSummary summarize(List<FuelRecord> records) {
    if (records.isEmpty) {
      return const FuelStatisticsSummary.empty();
    }

    final sortedRecords = List<FuelRecord>.from(records)
      ..sort((a, b) => b.fueledAt.compareTo(a.fueledAt));

    var totalDistanceKm = 0.0;
    var totalLitersFilled = 0.0;
    var bestConsumptionKmPerLiter = 0.0;
    var worstConsumptionKmPerLiter = double.infinity;

    for (final record in sortedRecords) {
      totalDistanceKm += record.distanceKm;
      totalLitersFilled += record.litersFilled;
      bestConsumptionKmPerLiter =
          math.max(bestConsumptionKmPerLiter, record.averageConsumption);
      worstConsumptionKmPerLiter =
          math.min(worstConsumptionKmPerLiter, record.averageConsumption);
    }

    final paidRecords =
        sortedRecords.where((record) => record.amountPaid != null).toList();

    double? totalAmountPaid;
    double? averageAmountPaid;
    double? costPerKm;

    if (paidRecords.isNotEmpty) {
      final paidDistanceKm = paidRecords.fold<double>(
        0,
        (sum, record) => sum + record.distanceKm,
      );
      totalAmountPaid = paidRecords.fold<double>(
        0,
        (sum, record) => sum + (record.amountPaid ?? 0),
      );
      averageAmountPaid = totalAmountPaid / paidRecords.length;

      if (paidDistanceKm > 0) {
        costPerKm = totalAmountPaid / paidDistanceKm;
      }
    }

    return FuelStatisticsSummary(
      totalRecords: sortedRecords.length,
      totalDistanceKm: totalDistanceKm,
      totalLitersFilled: totalLitersFilled,
      averageConsumptionKmPerLiter:
          totalLitersFilled > 0 ? totalDistanceKm / totalLitersFilled : 0,
      bestConsumptionKmPerLiter: bestConsumptionKmPerLiter,
      worstConsumptionKmPerLiter: worstConsumptionKmPerLiter == double.infinity
          ? 0
          : worstConsumptionKmPerLiter,
      averageAmountPaid: averageAmountPaid,
      totalAmountPaid: totalAmountPaid,
      costPerKm: costPerKm,
      paidRecordsCount: paidRecords.length,
      lastFueledAt: sortedRecords.first.fueledAt,
      recentRecords: sortedRecords.take(3).toList(),
    );
  }
}
