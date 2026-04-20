import 'package:grocery_price_scanner/features/history/domain/entities/scan_history_entry.dart';

class ScanHistoryModel extends ScanHistoryEntry {
  const ScanHistoryModel({
    this.id,
    required super.userId,
    super.productId,
    required super.barcode,
    super.productName,
    super.productImageUrl,
    required super.scannedAt,
    required super.isBatch,
    required super.folderName,
    super.notes,
  });

  final String? id;

  factory ScanHistoryModel.fromJson(Map<String, dynamic> json) {
    return ScanHistoryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productId: json['product_id'] as String?,
      barcode: json['barcode'] as String,
      productName: json['product_name'] as String?,
      productImageUrl: json['product_image_url'] as String?,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      isBatch: json['is_batch'] as bool? ?? false,
      folderName: json['folder_name'] as String? ?? 'General',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'user_id': userId,
      'barcode': barcode,
      'scanned_at': scannedAt.toIso8601String(),
      'is_batch': isBatch,
      'folder_name': folderName,
    };

    // ✅ Only add optional fields if they are not null
    if (productId != null) json['product_id'] = productId;
    if (productName != null) json['product_name'] = productName;
    if (productImageUrl != null) json['product_image_url'] = productImageUrl;
    if (notes != null) json['notes'] = notes;

    // ✅ IMPORTANT: DO NOT include 'id' at all - let Supabase generate it!
    // The database will auto-generate a UUID because of DEFAULT uuid_generate_v4()

    return json;
  }
}
