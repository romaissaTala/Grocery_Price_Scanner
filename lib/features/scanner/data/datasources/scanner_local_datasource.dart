import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/scan_result.dart';


class ScannerLocalDataSource {
  static const String scanHistoryBox = 'scan_history_local';
  
  ScannerLocalDataSource() {
    _init();
  }
  
  Future<void> _init() async {
    if (!Hive.isBoxOpen(scanHistoryBox)) {
      await Hive.openBox<dynamic>(scanHistoryBox);
    }
  }
  
  Box<dynamic> get _scanBox => Hive.box<dynamic>(scanHistoryBox);
  
  Future<void> saveScanResult(ScanResult result, String userId) async {
    try {
      final key = '${userId}_scans';
      List<dynamic> scans = _scanBox.get(key) ?? [];
      scans.insert(0, result.toJson());
      if (scans.length > 100) scans = scans.sublist(0, 100);
      await _scanBox.put(key, scans);
    } catch (e) {
      print('Failed to save scan result: $e');
    }
  }
  
  Future<List<ScanResult>> getRecentScans(String userId, {int limit = 20}) async {
    try {
      final key = '${userId}_scans';
      final scans = _scanBox.get(key) ?? [];
      return scans
          .take(limit)
          .map((item) => ScanResult.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Failed to get recent scans: $e');
      return [];
    }
  }
}