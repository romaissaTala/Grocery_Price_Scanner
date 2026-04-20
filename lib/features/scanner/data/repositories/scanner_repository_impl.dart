import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_local_datasource.dart';


class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerLocalDataSource localDataSource;
  
  ScannerRepositoryImpl({required this.localDataSource});
  
  @override
  Future<Either<Failure, void>> saveScanResult(ScanResult result, String userId) async {
    try {
      await localDataSource.saveScanResult(result, userId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ScanResult>>> getRecentScans(String userId, {int limit = 20}) async {
    try {
      final scans = await localDataSource.getRecentScans(userId, limit: limit);
      return Right(scans);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}