import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/fuel_record.dart';

class FuelRecordRepository {
  static const _storageKey = 'abastecimentos';

  Future<SharedPreferences> get _prefs async {
    return SharedPreferences.getInstance();
  }

  Future<List<FuelRecord>> loadRecords() async {
    final prefs = await _prefs;
    final recordsJson = prefs.getString(_storageKey);

    if (recordsJson == null || recordsJson.isEmpty) {
      return [];
    }

    try {
      final decoded = json.decode(recordsJson);

      if (decoded is! List) {
        return [];
      }

      final records = decoded
          .whereType<Map>()
          .map((item) => FuelRecord.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      records.sort((a, b) => b.fueledAt.compareTo(a.fueledAt));
      return records;
    } on FormatException {
      return [];
    } on TypeError {
      return [];
    }
  }

  Future<void> saveRecord(FuelRecord record) async {
    final records = await loadRecords();
    records.add(record);
    records.sort((a, b) => b.fueledAt.compareTo(a.fueledAt));
    await saveRecords(records);
  }

  Future<void> saveRecords(List<FuelRecord> records) async {
    final prefs = await _prefs;
    final payload = records.map((record) => record.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(payload));
  }

  Future<void> clearRecords() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
  }
}
