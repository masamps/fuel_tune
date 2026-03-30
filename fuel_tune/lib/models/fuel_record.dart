import '../utils/number_utils.dart';

class FuelRecord {
  const FuelRecord({
    required this.distanceKm,
    required this.litersFilled,
    required this.averageConsumption,
    required this.fueledAt,
    this.notes = '',
    this.amountPaid,
  });

  final double distanceKm;
  final double litersFilled;
  final double averageConsumption;
  final DateTime fueledAt;
  final String notes;
  final double? amountPaid;

  Map<String, dynamic> toJson() {
    return {
      'km_percorrido': distanceKm,
      'litros': litersFilled,
      'media_consumo': averageConsumption,
      'observacao': notes,
      'dt_abastecimento': fueledAt.toIso8601String(),
      'valor_pago': amountPaid,
    };
  }

  factory FuelRecord.fromJson(Map<String, dynamic> json) {
    return FuelRecord(
      distanceKm: _readDouble(json['km_percorrido']),
      litersFilled: _readDouble(json['litros']),
      averageConsumption: _readDouble(json['media_consumo']),
      fueledAt:
          DateTime.tryParse((json['dt_abastecimento'] as String?) ?? '') ??
              DateTime.now(),
      notes: (json['observacao'] as String?) ?? '',
      amountPaid: _readNullableDouble(json['valor_pago']),
    );
  }

  static double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return parseFlexibleDouble(value) ?? 0;
    }

    return 0;
  }

  static double? _readNullableDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return parseFlexibleDouble(value);
    }

    return null;
  }
}
