import 'package:equatable/equatable.dart';

abstract class ScannerState extends Equatable {
  const ScannerState();
  
  @override
  List<Object?> get props => [];
}

class ScannerInitial extends ScannerState {}

class ScannerActive extends ScannerState {
  final bool isTorchOn;
  final String? lastScannedBarcode;
  
  const ScannerActive({
    this.isTorchOn = false,
    this.lastScannedBarcode,
  });
  
  ScannerActive copyWith({
    bool? isTorchOn,
    String? lastScannedBarcode,
  }) {
    return ScannerActive(
      isTorchOn: isTorchOn ?? this.isTorchOn,
      lastScannedBarcode: lastScannedBarcode ?? this.lastScannedBarcode,
    );
  }
  
  @override
  List<Object?> get props => [isTorchOn, lastScannedBarcode];
}

class ScannerProcessing extends ScannerState {
  final String barcode;
  
  const ScannerProcessing(this.barcode);
  
  @override
  List<Object?> get props => [barcode];
}

class ScannerError extends ScannerState {
  final String message;
  
  const ScannerError(this.message);
  
  @override
  List<Object?> get props => [message];
}