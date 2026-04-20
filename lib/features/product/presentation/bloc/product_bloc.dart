import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_price_scanner/core/errors/failures.dart';
import 'package:grocery_price_scanner/features/product/domain/repositories/product_repository.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_product_with_prices.dart';
import '../../domain/usecases/track_product.dart';
import '../../domain/usecases/untrack_product.dart';
import '../../domain/usecases/get_price_history.dart'; // ✅ Add this import
import 'product_event.dart';
import 'product_state.dart';

@injectable
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductWithPrices getProductWithPrices;
  final TrackProduct trackProduct;
  final UntrackProduct untrackProduct;
  final GetPriceHistory getPriceHistory;

  // ✅ FIX: Remove the extra 'required ProductRepository ProductRepository' parameter
  ProductBloc({
    required this.getProductWithPrices,
    required this.trackProduct,
    required this.untrackProduct,
    required this.getPriceHistory,
  }) : super(ProductInitial()) {
    on<LoadProductByBarcode>(_onLoadProductByBarcode);
    on<RefreshPrices>(_onRefreshPrices);
    on<ToggleTrackProduct>(_onToggleTrackProduct);
    on<LoadPriceHistory>(_onLoadPriceHistory);
  }
  Future<void> _onLoadPriceHistory(
    LoadPriceHistory event,
    Emitter<ProductState> emit,
  ) async {
    try {
      final result = await getPriceHistory(event.productId, event.storeId);

      result.fold(
        (failure) {
          print('Failed to load price history: ${failure.message}');
          emit(PriceHistoryLoaded(const []));
        },
        (history) {
          print('Price history loaded: ${history.length} items');
          emit(PriceHistoryLoaded(history));
        },
      );
    } catch (e) {
      print('Error loading price history: $e');
      emit(PriceHistoryLoaded(const []));
    }
  }

  Future<void> _onLoadProductByBarcode(
    LoadProductByBarcode event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      final result = await getProductWithPrices(event.barcode);

      result.fold(
        (failure) {
          if (failure is NotFoundFailure) {
            emit(ProductNotFound(event.barcode));
          } else {
            emit(ProductError(failure.message));
          }
        },
        (productWithPrices) {
          print('Product found: ${productWithPrices.product.name}');
          print('Prices count: ${productWithPrices.prices.length}');
          emit(ProductFound(
            product: productWithPrices.product,
            prices: productWithPrices.prices,
            cheapestPrice: productWithPrices.cheapestPrice ??
                productWithPrices.computedCheapestPrice,
            averagePrice: productWithPrices.averagePrice ??
                productWithPrices.computedAveragePrice,
            savingsAmount: productWithPrices.savingsAmount ??
                productWithPrices.computedSavingsAmount,
          ));
        },
      );
    } catch (e) {
      print('Unexpected error: $e');
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onRefreshPrices(
    RefreshPrices event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductFound) {
      final currentState = state as ProductFound;
      emit(currentState.copyWith(isLoadingPrices: true));

      final result = await getProductWithPrices(currentState.product.barcode);

      result.fold(
        (failure) {
          emit(currentState.copyWith(isLoadingPrices: false));
        },
        (productWithPrices) {
          emit(currentState.copyWith(
            prices: productWithPrices.prices,
            cheapestPrice: productWithPrices.cheapestPrice ??
                productWithPrices.computedCheapestPrice,
            averagePrice: productWithPrices.averagePrice ??
                productWithPrices.computedAveragePrice,
            savingsAmount: productWithPrices.savingsAmount ??
                productWithPrices.computedSavingsAmount,
            isLoadingPrices: false,
          ));
        },
      );
    }
  }

  Future<void> _onToggleTrackProduct(
    ToggleTrackProduct event,
    Emitter<ProductState> emit,
  ) async {
    if (state is ProductFound) {
      final currentState = state as ProductFound;

      final result = event.isTracking
          ? await untrackProduct(event.userId, event.productId)
          : await trackProduct(event.userId, event.productId,
              targetPrice: event.targetPrice);

      result.fold(
        (failure) {
          // Show error message
        },
        (_) {
          emit(currentState.copyWith(isTracking: !event.isTracking));
        },
      );
    }
  }
}
