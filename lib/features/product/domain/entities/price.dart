import 'package:equatable/equatable.dart';
import '../../../stores/domain/entities/store.dart';

class Price extends Equatable {
  final String id;
  final String productId;
  final Store store;
  final double amount;
  final String currency;
  final bool isOnSale;
  final double? salePrice;
  final DateTime verifiedAt;
  final DateTime createdAt;
  
  const Price({
    required this.id,
    required this.productId,
    required this.store,
    required this.amount,
    required this.currency,
    required this.isOnSale,
    this.salePrice,
    required this.verifiedAt,
    required this.createdAt,
  });
  
  double get effectivePrice => isOnSale && salePrice != null ? salePrice! : amount;
  
  bool get hasDiscount => isOnSale && salePrice != null && salePrice! < amount;
  
  double get discountAmount => hasDiscount ? amount - salePrice! : 0;
  
  int get discountPercent => hasDiscount 
      ? ((discountAmount / amount) * 100).round() 
      : 0;
  
  @override
  List<Object?> get props => [
    id, productId, store, amount, currency, isOnSale, salePrice
  ];
}