
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price.dart';
import '../repositories/product_repository.dart';

class GetPriceHistory {
  final ProductRepository repository;
  
  GetPriceHistory(this.repository);
  
  Future<Either<Failure, List<Price>>> call(String productId, String storeId) async {
    return await repository.getPriceHistory(productId, storeId);
  }
}