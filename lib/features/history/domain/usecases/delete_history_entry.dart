import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryEntry {
  final HistoryRepository repository;
  
  DeleteHistoryEntry(this.repository);
  
  Future<Either<Failure, void>> call(String entryId) async {
    return await repository.deleteHistoryEntry(entryId);
  }
}