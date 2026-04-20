import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/product_with_prices.dart';
import '../repositories/product_repository.dart';

class GetProductWithPrices {
  final ProductRepository repository;
  
  GetProductWithPrices(this.repository);
  
  Future<Either<Failure, ProductWithPrices>> call(String barcode) async {
    return await repository.getProductWithPrices(barcode);
  }
}