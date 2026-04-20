import 'package:equatable/equatable.dart';

class Store extends Equatable {
  final String id;
  final String name;
  final String? logoUrl;
  final String? website;
  final String? city;
  final String? address;
  final String? phone;
  final bool isActive;
  final DateTime? createdAt;
  
  const Store({
    required this.id,
    required this.name,
    this.logoUrl,
    this.website,
    this.city,
    this.address,
    this.phone,
    this.isActive = true,
    this.createdAt,
  });
  
  /// Factory method to create a Store from JSON
  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
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
  
  /// Convert Store to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'website': website,
      'city': city,
      'address': address,
      'phone': phone,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
  
  /// Create a copy of Store with updated fields
  Store copyWith({
    String? id,
    String? name,
    String? logoUrl,
    String? website,
    String? city,
    String? address,
    String? phone,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Store(
      id: id ?? this.id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      city: city ?? this.city,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  
  @override
  List<Object?> get props => [
    id, 
    name, 
    logoUrl, 
    website, 
    city, 
    address,
    phone,
    isActive, 
    createdAt
  ];
}