import 'package:grocery_price_scanner/features/stores/data/models/store_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/product_model.dart';
import '../models/price_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabase;

  ProductRemoteDataSource(this._supabase);

  Future<ProductModel> getProductByBarcode(String barcode) async {
    try {
      final response = await _supabase
          .from('products')
          .select('*, categories!inner(name)')
          .eq('barcode', barcode)
          .single();

      return ProductModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to get product: $e');
    }
  }

  Future<List<PriceModel>> getPricesForProduct(String productId) async {
    try {
      final pricesResponse = await _supabase
          .from('prices')
          .select('*, stores(*)')
          .eq('product_id', productId);

      final List<PriceModel> prices = [];

      for (final priceData in pricesResponse) {
        // Skip if price is null
        if (priceData['price'] == null) {
          print('Skipping price with null value for product $productId');
          continue;
        }

        final storeData = priceData['stores'] as Map<String, dynamic>;
        final store = StoreModel.fromJson(storeData);
        prices.add(PriceModel.fromJson(priceData, store));
      }

      prices.sort((a, b) => a.effectivePrice.compareTo(b.effectivePrice));
      return prices;
    } catch (e) {
      print('Failed to get prices: $e');
      return [];
    }
  }

  Future<void> trackProduct(String userId, String productId,
      {double? targetPrice}) async {
    try {
      await _supabase.from('tracked_products').upsert({
        'user_id': userId,
        'product_id': productId,
        'target_price': targetPrice,
      });
    } catch (e) {
      throw ServerException('Failed to track product: $e');
    }
  }

  Future<void> untrackProduct(String userId, String productId) async {
    try {
      await _supabase
          .from('tracked_products')
          .delete()
          .match({'user_id': userId, 'product_id': productId});
    } catch (e) {
      throw ServerException('Failed to untrack product: $e');
    }
  }

  Future<List<PriceModel>> getPriceHistory(
      String productId, String storeId) async {
    try {
      final response = await _supabase
          .from('price_history')
          .select('*, stores(*)')
          .eq('product_id', productId)
          .eq('store_id', storeId)
          .order('recorded_at', ascending: false)
          .limit(30);

      final List<PriceModel> history = [];

      for (final priceData in response) {
        final storeData = priceData['stores'] as Map<String, dynamic>;
        final store = StoreModel.fromJson(storeData);
        history.add(PriceModel.fromJson({
          ...priceData,
          'price': priceData['price'],
          'verified_at': priceData['recorded_at'],
          'created_at': priceData['recorded_at'],
        }, store));
      }

      return history;
    } catch (e) {
      print('Failed to get price history: $e');
      return []; // Return empty list instead of throwing
    }
  }
}
