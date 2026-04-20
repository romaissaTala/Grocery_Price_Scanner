import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadProductByBarcode extends ProductEvent {
  final String barcode;
  
  const LoadProductByBarcode(this.barcode);
  
  @override
  List<Object?> get props => [barcode];
}

class RefreshPrices extends ProductEvent {
  final String productId;
  
  const RefreshPrices(this.productId);
  
  @override
  List<Object?> get props => [productId];
}

class ToggleTrackProduct extends ProductEvent {
  final String userId;
  final String productId;
  final bool isTracking;
  final double? targetPrice;
  
  const ToggleTrackProduct({
    required this.userId,
    required this.productId,
    required this.isTracking,
    this.targetPrice,
  });
  
  @override
  List<Object?> get props => [userId, productId, isTracking, targetPrice];
}

class LoadPriceHistory extends ProductEvent {
  final String productId;
  final String storeId;
  
  const LoadPriceHistory(this.productId, this.storeId);
  
  @override
  List<Object?> get props => [productId, storeId];
}