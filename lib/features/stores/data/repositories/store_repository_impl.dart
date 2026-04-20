import 'package:fpdart/fpdart.dart';
import 'package:grocery_price_scanner/features/stores/domain/entities/store.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/store_repository.dart';
import '../datasources/store_remote_datasource.dart';


class StoreRepositoryImpl implements StoreRepository {
  final StoreRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StoreRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Store>>> getStores() async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final stores = await remoteDataSource.getStores();
      // Fix: Convert List<StoreModel> to List<Store>
      return Right(stores.cast<Store>());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Store>> getStoreById(String storeId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final store = await remoteDataSource.getStoreById(storeId);
      // Fix: StoreModel can be directly returned as Store
      return Right(store as Store);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Store>>> getStoresByCity(String city) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      final stores = await remoteDataSource.getStoresByCity(city);
      // Fix: Convert List<StoreModel> to List<Store>
      return Right(stores.cast<Store>());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePrice({
    required String productId,
    required String storeId,
    required double price,
    bool isOnSale = false,
    double? salePrice,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }

    try {
      await remoteDataSource.updatePrice(
        productId: productId,
        storeId: storeId,
        price: price,
        isOnSale: isOnSale,
        salePrice: salePrice,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
