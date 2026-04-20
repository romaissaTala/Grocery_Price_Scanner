import 'package:grocery_price_scanner/features/stores/domain/entities/store.dart';

import '../../domain/entities/price.dart';

class PriceModel extends Price {
  const PriceModel({
    required super.id,
    required super.productId,
    required super.store,
    required super.amount,
    required super.currency,
    required super.isOnSale,
    super.salePrice,
    required super.verifiedAt,
    required super.createdAt,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json, Store store) {
    // ✅ Handle null prices safely
    final priceValue = json['price'];
    final salePriceValue = json['sale_price'];

    return PriceModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      store: store,
      amount: priceValue != null ? (priceValue as num).toDouble() : 0.0,
      currency: json['currency'] as String? ?? 'DZD',
      isOnSale: json['is_on_sale'] as bool? ?? false,
      salePrice:
          salePriceValue != null ? (salePriceValue as num).toDouble() : null,
      verifiedAt: DateTime.parse(json['verified_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'amount': amount,
      'currency': currency,
      'is_on_sale': isOnSale,
      'sale_price': salePrice,
      'verified_at': verifiedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      // ✅ must include store so cache can reconstruct PriceModel
      'store': store.toJson(),
    };
  }
}
