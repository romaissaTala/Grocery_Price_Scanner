import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../widgets/product_header_card.dart';
import '../widgets/price_comparison_list.dart';
import '../widgets/price_history_chart.dart';
import '../widgets/flip_card.dart';
import '../widgets/shimmer_price_list.dart';
import '../widgets/nutrition_card.dart';

class ProductResultPage extends StatelessWidget {
  final String barcode;

  const ProductResultPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    print('ProductResultPage received barcode: $barcode');
    return BlocProvider(
      create: (_) {
        print('Creating ProductBloc for barcode: $barcode'); // Add this
        return sl<ProductBloc>()..add(LoadProductByBarcode(barcode));
      },
      child: const _ProductResultView(),
    );
  }
}

// In _ProductResultView — REMOVE the Scaffold wrapper entirely
class _ProductResultView extends StatelessWidget {
  const _ProductResultView();

  @override
  Widget build(BuildContext context) {
    // ✅ No Scaffold here — the sheet container is already the background
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return Center(
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        }
        if (state is ProductNotFound) return const _NotFoundView();
        if (state is ProductError) return _ErrorView(message: state.message);
        if (state is ProductFound) {
          try {
            return FoundView(state: state);
          } catch (e) {
            return _ErrorView(message: e.toString());
          }
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class FoundView extends StatelessWidget {
  final ProductFound state;
  // ✅ Accept the sheet's scroll controller
  final ScrollController? scrollController;

  const FoundView({super.key, required this.state, this.scrollController});

  @override
  Widget build(BuildContext context) {
    if (state.prices.isEmpty && state.isLoadingPrices) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading prices...'),
          ],
        ),
      );
    }

    final product = state.product;
    final prices = state.prices;
    final cheapestPrice = state.cheapestPrice;
    final savingsAmount = state.savingsAmount;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cheapColor =
        isDark ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);
    print('Building FoundView with ${prices.length} prices');
    return ListView(
      // ✅ KEY: use the sheet's scroll controller, not a new one
      controller: scrollController,
      // ✅ ClampingScrollPhysics works correctly inside DraggableScrollableSheet
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.zero,
      children: [
        // ── Product image header ─────────────────────────────
        Stack(
          children: [
            // Image
            SizedBox(
              height: 220,
              width: double.infinity,
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: colorScheme.surface,
                        child: Icon(Icons.image_not_supported,
                            size: 64,
                            color: colorScheme.onSurface.withOpacity(0.2)),
                      ),
                    )
                  : Container(
                      color: colorScheme.surface,
                      child: Icon(Icons.inventory_2_outlined,
                          size: 64,
                          color: colorScheme.onSurface.withOpacity(0.2)),
                    ),
            ),
            // Gradient overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.25),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.4, 0.7, 1.0],
                  ),
                ),
              ),
            ),
            // Product name + brand over image
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null)
                    Text(
                      product.brand!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (cheapestPrice != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: cheapColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cheapColor.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified, color: cheapColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'From ${cheapestPrice.toStringAsFixed(0)} DA',
                            style: TextStyle(
                              color: cheapColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Bookmark button
            Positioned(
              top: 8,
              right: 8,
              child: SafeArea(
                child: IconButton(
                  icon: Icon(
                    state.isTracking ? Icons.bookmark : Icons.bookmark_border,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
            ),
          ],
        ),

        // ── Savings banner ───────────────────────────────────
        if (savingsAmount != null && savingsAmount > 0)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: cheapColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.savings_outlined,
                    color: Colors.white, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('You can save up to',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 12)),
                      Text(
                        '${savingsAmount.toStringAsFixed(0)} DA',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Shop Smart',
                    style: TextStyle(
                      color: cheapColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 150.ms),

        // ── Price Comparison ─────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.compare_arrows,
                      color: colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Price Comparison',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.isLoadingPrices)
                const ShimmerPriceList()
              else if (prices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: colorScheme.onSurface.withOpacity(0.08)),
                  ),
                  child: Center(
                    child: Text(
                      'No price data available for this product',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.45)),
                    ),
                  ),
                )
          //    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
              else
                PriceComparisonList(prices: prices)
                    .animate()
                    .fadeIn(duration: 400.ms),
            ],
          ),
        ),

        // ── Price History ────────────────────────────────────
        if (prices.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.timeline, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Price History',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                //+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                // PriceHistoryChart(
                //   productId: product.id,
                //   storeId: prices.first.store.id,
                // ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),

        // ── Nutrition ────────────────────────────────────────
        if (product.nutrition != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.set_meal, color: colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Nutrition Information',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FlipCard(nutrition: product.nutrition!),
              ],
            ).animate().fadeIn(delay: 300.ms),
          ),

        const SizedBox(height: 80),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Looking up product...'),
        ],
      ),
    );
  }
}

class _NotFoundView extends StatelessWidget {
  const _NotFoundView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 72, color: Colors.white38),
          const SizedBox(height: 16),
          const Text(
            'Product Not Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'This barcode is not in our database yet.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan Another'),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
}
