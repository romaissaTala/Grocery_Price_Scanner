import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.barcode,
    required super.name,
    super.brand,
    super.imageUrl,
    super.categoryId,
    super.categoryName,
    super.description,
    super.nutrition,
    required super.createdAt,
    required super.updatedAt,
  });
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Safely handle category data
    String? categoryName;
    if (json['categories'] != null) {
      if (json['categories'] is Map<String, dynamic>) {
        categoryName = json['categories']['name'] as String?;
      } else if (json['categories'] is List && json['categories'].isNotEmpty) {
        categoryName = json['categories'][0]['name'] as String?;
      }
    }

    return ProductModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      imageUrl: json['image_url'] as String?,
      categoryId: json['category_id'] as String?,
      categoryName: categoryName,
      description: json['description'] as String?,
      nutrition: json['calories_per_100g'] != null
          ? NutritionInfo(
              caloriesPer100g: (json['calories_per_100g'] as num?)?.toDouble(),
              proteinG: (json['protein_g'] as num?)?.toDouble(),
              carbsG: (json['carbs_g'] as num?)?.toDouble(),
              fatG: (json['fat_g'] as num?)?.toDouble(),
              fiberG: (json['fiber_g'] as num?)?.toDouble(),
              sugarG: (json['sugar_g'] as num?)?.toDouble(),
              sodiumMg: (json['sodium_mg'] as num?)?.toDouble(),
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'name': name,
      'brand': brand,
      'image_url': imageUrl,
      'category_id': categoryId,
      'description': description,
      'calories_per_100g': nutrition?.caloriesPer100g,
      'protein_g': nutrition?.proteinG,
      'carbs_g': nutrition?.carbsG,
      'fat_g': nutrition?.fatG,
      'fiber_g': nutrition?.fiberG,
      'sugar_g': nutrition?.sugarG,
      'sodium_mg': nutrition?.sodiumMg,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
