import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/price.dart';
import '../../domain/entities/product_with_prices.dart';

abstract class ProductState extends Equatable {
  const ProductState();
  
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductFound extends ProductState {
  final Product product;
  final List<Price> prices;
  final double? cheapestPrice;
  final double? averagePrice;
  final double? savingsAmount;
  final bool isLoadingPrices;
  final bool isTracking;
  
  const ProductFound({
    required this.product,
    required this.prices,
    this.cheapestPrice,
    this.averagePrice,
    this.savingsAmount,
    this.isLoadingPrices = false,
    this.isTracking = false,
  });
  
  ProductFound copyWith({
    Product? product,
    List<Price>? prices,
    double? cheapestPrice,
    double? averagePrice,
    double? savingsAmount,
    bool? isLoadingPrices,
    bool? isTracking,
  }) {
    return ProductFound(
      product: product ?? this.product,
      prices: prices ?? this.prices,
      cheapestPrice: cheapestPrice ?? this.cheapestPrice,
      averagePrice: averagePrice ?? this.averagePrice,
      savingsAmount: savingsAmount ?? this.savingsAmount,
      isLoadingPrices: isLoadingPrices ?? this.isLoadingPrices,
      isTracking: isTracking ?? this.isTracking,
    );
  }
  
  @override
  List<Object?> get props => [
    product, prices, cheapestPrice, averagePrice, savingsAmount, isLoadingPrices, isTracking
  ];
}

class ProductNotFound extends ProductState {
  final String barcode;
  
  const ProductNotFound(this.barcode);
  
  @override
  List<Object?> get props => [barcode];
}

class ProductError extends ProductState {
  final String message;
  
  const ProductError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class PriceHistoryLoaded extends ProductState {
  final List<Price> history;
  
  const PriceHistoryLoaded(this.history);
  
  @override
  List<Object?> get props => [history];
}