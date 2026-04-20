import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/store_model.dart';


class StoreRemoteDataSource {
  final SupabaseClient _supabase;
  
  StoreRemoteDataSource(this._supabase);
  
  Future<List<StoreModel>> getStores() async {
    try {
      final response = await _supabase
          .from('stores')
          .select('*')
          .order('name');
      
      return response.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get stores: $e');
    }
  }
  
  Future<StoreModel> getStoreById(String storeId) async {
    try {
      final response = await _supabase
          .from('stores')
          .select('*')
          .eq('id', storeId)
          .single();
      
      return StoreModel.fromJson(response);
    } catch (e) {
      throw ServerException('Failed to get store: $e');
    }
  }
  
  Future<List<StoreModel>> getStoresByCity(String city) async {
    try {
      final response = await _supabase
          .from('stores')
          .select('*')
          .eq('city', city)
          .eq('is_active', true)
          .order('name');
      
      return response.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException('Failed to get stores by city: $e');
    }
  }
      
  // Add this method
  Future<void> updatePrice({
    required String productId,
    required String storeId,
    required double price,
    bool isOnSale = false,
    double? salePrice,
  }) async {
    try {
      await _supabase.from('prices').upsert({
        'product_id': productId,
        'store_id': storeId,
        'price': price,
        'currency': 'DZD',
        'is_on_sale': isOnSale,
        'sale_price': salePrice,
        'verified_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException('Failed to update price: $e');
    }
  }
}