import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/product_repository.dart';

class TrackProduct {
  final ProductRepository repository;
  
  TrackProduct(this.repository);
  
  Future<Either<Failure, void>> call(String userId, String productId, {double? targetPrice}) async {
    return await repository.trackProduct(userId, productId, targetPrice: targetPrice);
  }
}