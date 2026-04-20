import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_history_entry.dart';
import '../repositories/history_repository.dart';

class GetHistory {
  final HistoryRepository repository;
  
  GetHistory(this.repository);
  
  Future<Either<Failure, List<ScanHistoryEntry>>> call(String userId, {int limit = 50}) async {
    return await repository.getHistory(userId, limit: limit);
  }
}