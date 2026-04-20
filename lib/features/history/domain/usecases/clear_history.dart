import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/history_repository.dart';

class ClearHistory {
  final HistoryRepository repository;
  
  ClearHistory(this.repository);
  
  Future<Either<Failure, void>> call(String userId) async {
    return await repository.clearHistory(userId);
  }
}