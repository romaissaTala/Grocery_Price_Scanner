import 'package:fpdart/fpdart.dart';
import 'package:grocery_price_scanner/features/stores/domain/entities/store.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/store_repository.dart';

class GetStores {
  final StoreRepository repository;
  
  GetStores(this.repository);
  
  Future<Either<Failure, List<Store>>> call() async {
    return await repository.getStores();
  }
}