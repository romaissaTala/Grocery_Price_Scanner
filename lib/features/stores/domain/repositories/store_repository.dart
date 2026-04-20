import 'package:fpdart/fpdart.dart';
import 'package:grocery_price_scanner/features/stores/domain/entities/store.dart';
import '../../../../core/errors/failures.dart';


abstract class StoreRepository {
  Future<Either<Failure, List<Store>>> getStores();
  Future<Either<Failure, Store>> getStoreById(String storeId);
  Future<Either<Failure, List<Store>>> getStoresByCity(String city);
  
  // Add this method
  Future<Either<Failure, void>> updatePrice({
    required String productId,
    required String storeId,
    required double price,
    bool isOnSale = false,
    double? salePrice,
  });
}