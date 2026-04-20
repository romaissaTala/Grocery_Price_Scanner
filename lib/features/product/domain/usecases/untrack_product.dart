import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/product_repository.dart';

class UntrackProduct {
  final ProductRepository repository;
  
  UntrackProduct(this.repository);
  
  Future<Either<Failure, void>> call(String userId, String productId) async {
    return await repository.untrackProduct(userId, productId);
  }
}