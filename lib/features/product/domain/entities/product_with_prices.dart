import 'package:equatable/equatable.dart';
import 'price.dart';
import 'product.dart';


class ProductWithPrices extends Equatable {
  final Product product;
  final List<Price> prices;
  final double? cheapestPrice;
  final double? averagePrice;
  final double? savingsAmount;
  
  const ProductWithPrices({
    required this.product,
    required this.prices,
    this.cheapestPrice,
    this.averagePrice,
    this.savingsAmount,
  });

  Price? get cheapest {
    if (prices.isEmpty) return null;
    return prices.reduce((a, b) =>
        a.effectivePrice < b.effectivePrice ? a : b);
  }

  double? get savingsVsMax {
    if (prices.length < 2) return null;
    final min = cheapest!.effectivePrice;
    final max = prices.map((p) => p.effectivePrice).reduce((a, b) => a > b ? a : b);
    return max - min;
  }
  
  // Computed properties
  double get computedCheapestPrice {
    if (prices.isEmpty) return 0;
    return prices.map((p) => p.effectivePrice).reduce((a, b) => a < b ? a : b);
  }
  
  double get computedAveragePrice {
    if (prices.isEmpty) return 0;
    return prices.map((p) => p.effectivePrice).reduce((a, b) => a + b) / prices.length;
  }
  
  double get computedSavingsAmount {
    if (prices.length < 2) return 0;
    final sorted = [...prices]..sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
    return sorted.last.effectivePrice - sorted.first.effectivePrice;
  }

  @override
  List<Object?> get props => [
    product, 
    prices, 
    cheapestPrice, 
    averagePrice, 
    savingsAmount
  ];
}