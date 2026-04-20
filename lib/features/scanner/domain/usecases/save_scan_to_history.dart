import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_result.dart';
import '../repositories/scanner_repository.dart';

class SaveScanToHistory {
  final ScannerRepository repository;
  
  SaveScanToHistory(this.repository);
  
  Future<Either<Failure, void>> call(ScanResult result, String userId) async {
    return await repository.saveScanResult(result, userId);
  }
}