import 'package:equatable/equatable.dart';

class ScanHistoryEntry extends Equatable {
  final String? id;
  final String userId;
  final String? productId;
  final String barcode;
  final String? productName;
  final String? productImageUrl;
  final DateTime scannedAt;
  final bool isBatch;
  final String folderName;
  final String? notes;
  
  const ScanHistoryEntry({
   this.id,
    required this.userId,
    this.productId,
    required this.barcode,
    this.productName,
    this.productImageUrl,
    required this.scannedAt,
    required this.isBatch,
    required this.folderName,
    this.notes,
  });
  
  @override
  List<Object?> get props => [
    id, userId, productId, barcode, productName, 
    productImageUrl, scannedAt, isBatch, folderName
  ];
}