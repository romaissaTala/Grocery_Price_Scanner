import '../../domain/entities/store.dart';

class StoreModel extends Store {
  const StoreModel({
    required super.id,
    required super.name,
    super.logoUrl,
    super.website,
    super.city,
    super.address,
    super.phone,
    super.isActive,
    super.createdAt,
  });

  factory StoreModel.fromJson(Map<String, dynamic> json) {
    return StoreModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'website': website,
      'city': city,
      'address': address, // This should work since address is inherited
      'phone': phone, // This should work since phone is inherited
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
