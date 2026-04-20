import 'package:hive_flutter/hive_flutter.dart';
import '../../../stores/data/models/store_model.dart';
import '../models/product_model.dart';
import '../models/price_model.dart';

class ProductLocalDataSource {
  static const String productBox = 'products_cache';
  static const String priceBox = 'prices_cache';

  ProductLocalDataSource() {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen(productBox)) {
      await Hive.openBox<dynamic>(productBox);
    }
    if (!Hive.isBoxOpen(priceBox)) {
      await Hive.openBox<dynamic>(priceBox);
    }
  }

  Box<dynamic> get _productBox => Hive.box<dynamic>(productBox);
  Box<dynamic> get _priceBox => Hive.box<dynamic>(priceBox);

  ProductModel? getCachedProduct(String barcode) {
    try {
      final data = _productBox.get(barcode);
      if (data == null) return null;

      // ✅ FIX: Hive returns Map<dynamic, dynamic>, not Map<String, dynamic>
      // Must use Map.from() to safely convert before passing to fromJson
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        return ProductModel.fromJson(map);
      }

      return null;
    } catch (e) {
      print('Failed to get cached product: $e');
      // ✅ Delete corrupted entry so it doesn't keep failing
      _productBox.delete(barcode);
      return null;
    }
  }

  Future<void> cacheProduct(String barcode, ProductModel product) async {
    try {
      await _productBox.put(barcode, product.toJson());
    } catch (e) {
      print('Failed to cache product: $e');
    }
  }

  List<PriceModel>? getCachedPrices(String productId) {
    try {
      final data = _priceBox.get(productId);
      if (data == null) return null;
      if (data is! List || data.isEmpty) return null;

      return data.map((item) {
        // ✅ FIX: each item is also Map<dynamic, dynamic> from Hive
        final priceMap = Map<String, dynamic>.from(item as Map);

        // ✅ FIX: nested 'store' map also needs conversion
        final storeRaw = priceMap['store'] ?? priceMap['stores'];
        if (storeRaw == null) return null;
        final storeMap = Map<String, dynamic>.from(storeRaw as Map);

        final store = StoreModel.fromJson(storeMap);
        return PriceModel.fromJson(priceMap, store);
      }).whereType<PriceModel>().toList();
    } catch (e) {
      print('Failed to get cached prices: $e');
      // ✅ Delete corrupted entry
      _priceBox.delete(productId);
      return null;
    }
  }

  Future<void> cachePrices(String productId, List<PriceModel> prices) async {
    try {
      // ✅ Store with consistent 'store' key (not 'stores' like Supabase uses)
      final pricesJson = prices.map((p) {
        final json = p.toJson();
        // Ensure the store is stored under 'store' key for consistency
        json['store'] = p.store.toJson();
        return json;
      }).toList();
      await _priceBox.put(productId, pricesJson);
    } catch (e) {
      print('Failed to cache prices: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      await _productBox.clear();
      await _priceBox.clear();
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }
}