import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../../domain/entities/price.dart';

class PriceHistoryChart extends StatefulWidget {
  final String productId;
  final String storeId;

  const PriceHistoryChart({
    super.key,
    required this.productId,
    required this.storeId,
  });

  @override
  State<PriceHistoryChart> createState() => _PriceHistoryChartState();
}

class _PriceHistoryChartState extends State<PriceHistoryChart> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Load price history
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ProductBloc>().add(
          LoadPriceHistory(widget.productId, widget.storeId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Show loading only while actually loading
        if (state is ProductLoading) {
          return _buildLoadingState(context);
        }
        
        if (state is PriceHistoryLoaded) {
          _isLoading = false;
          if (state.history.isEmpty) {
            return _buildEmptyState(context);
          }
          return _ChartView(history: state.history);
        }
        
        // Default state - show loading
        return _buildLoadingState(context);
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.08), 
          width: 0.5,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.08), 
          width: 0.5,
        ),
      ),
      child: Center(
        child: Text(
          'No price history available',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.4), 
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _ChartView extends StatelessWidget {
  final List<Price> history;

  const _ChartView({required this.history});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty || history.length < 2) {
      return _buildEmptyState(context);
    }

    try {
      final prices = history.take(7).map((p) => p.effectivePrice).toList();
      if (prices.length < 2) return _buildEmptyState(context);

      final maxPrice = prices.reduce((a, b) => a > b ? a : b);
      final minPrice = prices.reduce((a, b) => a < b ? a : b);
      final range = maxPrice - minPrice;

      return Container(
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withOpacity(0.08), 
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Last ${prices.length} prices',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface.withOpacity(0.45),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Price trend',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurface.withOpacity(0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: CustomPaint(
                size: Size.infinite,
                painter: _LineChartPainter(
                  prices: prices,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  range: range,
                  lineColor: colorScheme.primary,
                  dotColor: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Error building chart: $e');
      return _buildEmptyState(context);
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No price history available',
          style: TextStyle(
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> prices;
  final double minPrice;
  final double maxPrice;
  final double range;
  final Color lineColor;
  final Color dotColor;

  const _LineChartPainter({
    required this.prices,
    required this.minPrice,
    required this.maxPrice,
    required this.range,
    required this.lineColor,
    required this.dotColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (prices.length < 2) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final step = size.width / (prices.length - 1);

    for (int i = 0; i < prices.length; i++) {
      final x = step * i;
      final y = range > 0
          ? (size.height * (1.0 - (prices[i] - minPrice) / range))
              .clamp(0.0, size.height)
          : size.height / 2;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.prices != prices || old.lineColor != lineColor;
}