import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/scan_history_model.dart';

class HistoryRemoteDataSource {
  final SupabaseClient _supabase;

  HistoryRemoteDataSource(this._supabase);
  Future<List<ScanHistoryModel>> getHistory(String userId,
      {int limit = 50}) async {
    try {
      final response = await _supabase
          .from('scan_history')
          .select('*')
          .eq('user_id', userId)
          .order('scanned_at', ascending: false)
          .limit(limit);

      return response.map((json) => ScanHistoryModel.fromJson(json)).toList();
    } catch (e) {
      print('Failed to get history: $e');
      // ✅ Return empty list instead of throwing
      return [];
    }
  }

  Future<void> addHistoryEntry(ScanHistoryModel entry) async {
    try {
      print('Attempting to insert: ${entry.toJson()}');

      final response = await _supabase
          .from('scan_history')
          .insert(entry.toJson())
          .select(); // This returns the inserted row

      print('Insert successful: $response');
    } catch (e) {
      print('Detailed error: $e');
      throw ServerException('Failed to add history entry: $e');
    }
  }

  Future<void> deleteHistoryEntry(String entryId) async {
    try {
      await _supabase.from('scan_history').delete().eq('id', entryId);
    } catch (e) {
      throw ServerException('Failed to delete history entry: $e');
    }
  }

  Future<void> clearHistory(String userId) async {
    try {
      await _supabase.from('scan_history').delete().eq('user_id', userId);
    } catch (e) {
      throw ServerException('Failed to clear history: $e');
    }
  }

  Future<List<ScanHistoryModel>> searchHistory(
      String userId, String query) async {
    try {
      final response = await _supabase
          .from('scan_history')
          .select('*')
          .eq('user_id', userId)
          .or('barcode.ilike.%$query%,product_name.ilike.%$query%')
          .order('scanned_at', ascending: false);

      return response.map((json) => ScanHistoryModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to search history: $e');
    }
  }
}
