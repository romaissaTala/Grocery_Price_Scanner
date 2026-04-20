import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String barcode;
  final String name;
  final String? brand;
  final String? imageUrl;
  final String? categoryId;
  final String? categoryName;
  final String? description;
  final NutritionInfo? nutrition;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  const Product({
    required this.id,
    required this.barcode,
    required this.name,
    this.brand,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    this.description,
    this.nutrition,
    required this.createdAt,
    required this.updatedAt,
  });
  
  @override
  List<Object?> get props => [
    id, barcode, name, brand, imageUrl, 
    categoryId, categoryName, description, nutrition
  ];
}

class NutritionInfo extends Equatable {
  final double? caloriesPer100g;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final double? fiberG;
  final double? sugarG;
  final double? sodiumMg;
  
  const NutritionInfo({
    this.caloriesPer100g,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.fiberG,
    this.sugarG,
    this.sodiumMg,
  });
  
  @override
  List<Object?> get props => [
    caloriesPer100g, proteinG, carbsG, fatG, fiberG, sugarG, sodiumMg
  ];
}