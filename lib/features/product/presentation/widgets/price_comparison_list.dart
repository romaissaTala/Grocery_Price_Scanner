import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/price.dart';

class PriceComparisonList extends StatelessWidget {
  final List<Price> prices;

  const PriceComparisonList({super.key, required this.prices});

  @override
  Widget build(BuildContext context) {
    print('PriceComparisonList building with ${prices.length} prices');
    if (prices.isEmpty) {
      return Center(
        child: Text('No price data available',
            style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
      );
    }

    double cheapestPrice = double.infinity;
    for (final price in prices) {
      if (price.effectivePrice < cheapestPrice) {
        cheapestPrice = price.effectivePrice;
      }
    }

    return Column(
      children: prices.asMap().entries.map((entry) {
        return _PriceTile(
          price: entry.value,
          isCheapest: entry.value.effectivePrice == cheapestPrice,
          animationDelay: (entry.key * 60).ms,
        );
      }).toList(),
    );
  }
}

class _PriceTile extends StatelessWidget {
  final Price price;
  final bool isCheapest;
  final Duration animationDelay;

  const _PriceTile({
    required this.price,
    required this.isCheapest,
    required this.animationDelay,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Semantic colors that work in both themes
    final cheapColor =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    final cardBg =
        isCheapest ? cheapColor.withOpacity(0.08) : colorScheme.surface;
    final cardBorder = isCheapest
        ? cheapColor.withOpacity(0.4)
        : colorScheme.onSurface.withOpacity(0.08);
    final storeName =
        price.store.name.isNotEmpty ? price.store.name : 'Unknown';
    final firstLetter = storeName.substring(0, 1).toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder, width: isCheapest ? 1.5 : 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Store avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Store name + sale badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                      if (price.isOnSale) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'ON SALE',
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Price + BEST badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${price.effectivePrice.toStringAsFixed(0)} DA',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            // ✅ Green for cheapest, normal text for others
                            color:
                                isCheapest ? cheapColor : colorScheme.onSurface,
                          ),
                        ),
                        if (isCheapest) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: cheapColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BEST',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (price.isOnSale && price.salePrice != null)
                      Text(
                        '${price.amount.toStringAsFixed(0)} DA',
                        style: TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: colorScheme.onSurface.withOpacity(0.35),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(delay: animationDelay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, curve: Curves.easeOut);
  }
}
