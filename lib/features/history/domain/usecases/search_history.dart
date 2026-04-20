import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_history_entry.dart';
import '../repositories/history_repository.dart';

class SearchHistory {
  final HistoryRepository repository;
  
  SearchHistory(this.repository);
  
  Future<Either<Failure, List<ScanHistoryEntry>>> call(String userId, String query) async {
    return await repository.searchHistory(userId, query);
  }
}