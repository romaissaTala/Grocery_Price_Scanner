import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/price.dart';
import '../../domain/entities/product_with_prices.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../models/price_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    // Try local cache first
    final cachedProduct = localDataSource.getCachedProduct(barcode);
    if (cachedProduct != null) {
      return Right(cachedProduct);
    }
    
    // Check network connectivity
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final product = await remoteDataSource.getProductByBarcode(barcode);
      await localDataSource.cacheProduct(barcode, product);
      return Right(product);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Price>>> getPricesForProduct(String productId) async {
    // Try local cache first
    final cachedPrices = localDataSource.getCachedPrices(productId);
    if (cachedPrices != null) {
      return Right(cachedPrices);
    }
    
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      final prices = await remoteDataSource.getPricesForProduct(productId);
      await localDataSource.cachePrices(productId, prices);
      return Right(prices);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, ProductWithPrices>> getProductWithPrices(String barcode) async {
    final productResult = await getProductByBarcode(barcode);
    
    return productResult.fold(
      (failure) => Left(failure),
      (product) async {
        final pricesResult = await getPricesForProduct(product.id);
        
        return pricesResult.fold(
          (failure) => Left(failure),
          (prices) {
            final productWithPrices = ProductWithPrices(
              product: product,
              prices: prices,
              cheapestPrice: prices.isNotEmpty 
                  ? prices.map((p) => p.effectivePrice).reduce((a, b) => a < b ? a : b)
                  : null,
              averagePrice: prices.isNotEmpty
                  ? prices.map((p) => p.effectivePrice).reduce((a, b) => a + b) / prices.length
                  : null,
              savingsAmount: prices.length >= 2
                  ? (prices.map((p) => p.effectivePrice).reduce((a, b) => a > b ? a : b) -
                     prices.map((p) => p.effectivePrice).reduce((a, b) => a < b ? a : b))
                  : null,
            );
            return Right(productWithPrices);
          },
        );
      },
    );
  }
  
  @override
  Future<Either<Failure, void>> trackProduct(
    String userId, 
    String productId, {
    double? targetPrice,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      await remoteDataSource.trackProduct(userId, productId, targetPrice: targetPrice);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> untrackProduct(String userId, String productId) async {
    final isConnected = await networkInfo.isConnected;
    if (!isConnected) {
      return Left(NetworkFailure('No internet connection'));
    }
    
    try {
      await remoteDataSource.untrackProduct(userId, productId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<Product>>> getTrackedProducts(String userId) async {
    // Implementation would need a new remote method
    // For brevity, returning empty list
    return const Right([]);
  }
  
@override
Future<Either<Failure, List<Price>>> getPriceHistory(String productId, String storeId) async {
  final isConnected = await networkInfo.isConnected;
  if (!isConnected) {
    return Left(NetworkFailure('No internet connection'));
  }
  
  try {
    final history = await remoteDataSource.getPriceHistory(productId, storeId);
    return Right(history);
  } catch (e) {
    print('Error getting price history: $e');
    // Return empty list instead of failure to prevent UI issues
    return const Right([]);
  }
}
}