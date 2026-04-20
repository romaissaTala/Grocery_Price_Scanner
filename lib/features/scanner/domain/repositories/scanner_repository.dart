import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/scan_result.dart';

abstract class ScannerRepository {
  Future<Either<Failure, void>> saveScanResult(ScanResult result, String userId);
  Future<Either<Failure, List<ScanResult>>> getRecentScans(String userId, {int limit = 20});
}