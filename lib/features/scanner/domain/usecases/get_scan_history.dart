import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_result.dart';
import '../repositories/scanner_repository.dart';

class GetScanHistory {
  final ScannerRepository repository;
  
  GetScanHistory(this.repository);
  
  Future<Either<Failure, List<ScanResult>>> call(String userId, {int limit = 20}) async {
    return await repository.getRecentScans(userId, limit: limit);
  }
}