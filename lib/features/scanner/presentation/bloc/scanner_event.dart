import 'package:equatable/equatable.dart';

abstract class ScannerEvent extends Equatable {
  const ScannerEvent();
  
  @override
  List<Object?> get props => [];
}

class StartScanning extends ScannerEvent {}

class StopScanning extends ScannerEvent {}

class BarcodeDetected extends ScannerEvent {
  final String barcode;
  
  const BarcodeDetected(this.barcode);
  
  @override
  List<Object?> get props => [barcode];
}

// Renamed from SaveScanToHistory to SaveScanHistoryEvent
class SaveScanHistoryEvent extends ScannerEvent {
  final String barcode;
  final String userId;
  final String? productId;
  
  const SaveScanHistoryEvent({
    required this.barcode,
    required this.userId,
    this.productId,
  });
  
  @override
  List<Object?> get props => [barcode, userId, productId];
}

class ClearLastScan extends ScannerEvent {}
