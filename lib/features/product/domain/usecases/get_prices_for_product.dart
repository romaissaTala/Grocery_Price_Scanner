import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/price.dart';
import '../repositories/product_repository.dart';

class GetPricesForProduct {
  final ProductRepository repository;
  
  GetPricesForProduct(this.repository);
  
  Future<Either<Failure, List<Price>>> call(String productId) async {
    return await repository.getPricesForProduct(productId);
  }
}