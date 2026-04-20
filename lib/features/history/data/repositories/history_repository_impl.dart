import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/scan_history_entry.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/history_remote_datasource.dart';
import '../models/scan_history_model.dart';


class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  
  HistoryRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });
  
@override
Future<Either<Failure, List<ScanHistoryModel>>> getHistory(String userId, {int limit = 50}) async {
  final isConnected = await networkInfo.isConnected;
  if (!isConnected) {
    return Left(NetworkFailure('No internet connection'));
  }
  
  try {
    final history = await remoteDataSource.getHistory(userId, limit: limit);
    return Right(history);
  } catch (e) {
    print('Error getting history: $e');
    return const Right([]);
  }
}

@override
Future<Either<Failure, void>> addHistoryEntry(ScanHistoryModel entry) async {
  final isConnected = await networkInfo.isConnected;
  if (!isConnected) {
    return Left(NetworkFailure('No internet connection'));
  }
  
  try {
    await remoteDataSource.addHistoryEntry(entry);
    return const Right(null);
  } catch (e) {
    return Left(ServerFailure(e.toString()));
  }
}
  @override
  Future<Either<Failure, void>> deleteHistoryEntry(String entryId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      await remoteDataSource.deleteHistoryEntry(entryId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> clearHistory(String userId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      await remoteDataSource.clearHistory(userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<ScanHistoryModel>>> searchHistory(String userId, String query) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final results = await remoteDataSource.searchHistory(userId, query);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}