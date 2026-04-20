import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product.dart';
import '../entities/price.dart';
import '../entities/product_with_prices.dart';

abstract class ProductRepository {
  Future<Either<Failure, Product>> getProductByBarcode(String barcode);
  Future<Either<Failure, List<Price>>> getPricesForProduct(String productId);
  Future<Either<Failure, ProductWithPrices>> getProductWithPrices(String barcode);
  Future<Either<Failure, void>> trackProduct(String userId, String productId, {double? targetPrice});
  Future<Either<Failure, void>> untrackProduct(String userId, String productId);
  Future<Either<Failure, List<Product>>> getTrackedProducts(String userId);
  Future<Either<Failure, List<Price>>> getPriceHistory(String productId, String storeId);
}