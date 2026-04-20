import 'package:fpdart/fpdart.dart';
import 'package:grocery_price_scanner/features/history/data/models/scan_history_model.dart';
import '../../../../core/errors/failures.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<ScanHistoryModel>>> getHistory(String userId, {int limit = 50});
  Future<Either<Failure, void>> addHistoryEntry(ScanHistoryModel entry); // Changed parameter type
  Future<Either<Failure, void>> deleteHistoryEntry(String entryId);
  Future<Either<Failure, void>> clearHistory(String userId);
  Future<Either<Failure, List<ScanHistoryModel>>> searchHistory(String userId, String query);
}