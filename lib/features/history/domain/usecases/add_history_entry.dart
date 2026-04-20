import 'package:fpdart/fpdart.dart';
import 'package:grocery_price_scanner/features/history/data/models/scan_history_model.dart';
import '../../../../core/errors/failures.dart';

import '../repositories/history_repository.dart';

class AddHistoryEntry {
  final HistoryRepository repository;
  
  AddHistoryEntry(this.repository);
  
  Future<Either<Failure, void>> call(ScanHistoryModel entry) async { // Changed parameter type
    return await repository.addHistoryEntry(entry);
  }
}