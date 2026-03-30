import 'fuel_record.dart';

class FuelStatisticsSummary {
  const FuelStatisticsSummary({
    required this.totalRecords,
    required this.totalDistanceKm,
    required this.totalLitersFilled,
    required this.averageConsumptionKmPerLiter,
    required this.bestConsumptionKmPerLiter,
    required this.worstConsumptionKmPerLiter,
    required this.averageAmountPaid,
    required this.totalAmountPaid,
    required this.costPerKm,
    required this.paidRecordsCount,
    required this.lastFueledAt,
    required this.recentRecords,
  });

  const FuelStatisticsSummary.empty()
      : totalRecords = 0,
        totalDistanceKm = 0,
        totalLitersFilled = 0,
        averageConsumptionKmPerLiter = 0,
        bestConsumptionKmPerLiter = 0,
        worstConsumptionKmPerLiter = 0,
        averageAmountPaid = null,
        totalAmountPaid = null,
        costPerKm = null,
        paidRecordsCount = 0,
        lastFueledAt = null,
        recentRecords = const [];

  final int totalRecords;
  final double totalDistanceKm;
  final double totalLitersFilled;
  final double averageConsumptionKmPerLiter;
  final double bestConsumptionKmPerLiter;
  final double worstConsumptionKmPerLiter;
  final double? averageAmountPaid;
  final double? totalAmountPaid;
  final double? costPerKm;
  final int paidRecordsCount;
  final DateTime? lastFueledAt;
  final List<FuelRecord> recentRecords;

  bool get hasRecords => totalRecords > 0;
  bool get hasAmountInsights => totalAmountPaid != null && paidRecordsCount > 0;
}
