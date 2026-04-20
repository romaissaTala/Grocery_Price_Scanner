import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/store_repository.dart';

class UpdatePriceParams {
  final String productId;
  final String storeId;
  final double price;
  final bool isOnSale;
  final double? salePrice;

  const UpdatePriceParams({
    required this.productId,
    required this.storeId,
    required this.price,
    this.isOnSale = false,
    this.salePrice,
  });
}

class UpdatePrice {
  final StoreRepository _repository;
  UpdatePrice(this._repository);

  Future<Either<Failure, void>> call(UpdatePriceParams params) {
    return _repository.updatePrice(
      productId: params.productId,
      storeId: params.storeId,
      price: params.price,
      isOnSale: params.isOnSale,
      salePrice: params.salePrice,
    );
  }
}