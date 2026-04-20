import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_price_scanner/features/scanner/domain/entities/scan_result.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/save_scan_to_history.dart';
import 'scanner_event.dart';
import 'scanner_state.dart';


class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final SaveScanToHistory saveScanToHistory;
  
  ScannerBloc({
    required this.saveScanToHistory,
  }) : super(ScannerInitial()) {
    on<StartScanning>(_onStartScanning);
    on<StopScanning>(_onStopScanning);
    on<BarcodeDetected>(_onBarcodeDetected);
    on<SaveScanHistoryEvent>(_onSaveScanHistory); // Updated event name
    on<ClearLastScan>(_onClearLastScan);
    
  }
  
  Future<void> _onStartScanning(
    StartScanning event,
    Emitter<ScannerState> emit,
  ) async {
    emit(const ScannerActive());
  }
  
  Future<void> _onStopScanning(
    StopScanning event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerInitial());
  }
  
  Future<void> _onBarcodeDetected(
    BarcodeDetected event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is ScannerActive) {
      final currentState = state as ScannerActive;
      emit(ScannerProcessing(event.barcode));
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      emit(ScannerActive(
        isTorchOn: currentState.isTorchOn,
        lastScannedBarcode: event.barcode,
      ));
    }
  }
  
  Future<void> _onSaveScanHistory(
    SaveScanHistoryEvent event,
    Emitter<ScannerState> emit,
  ) async {
    // Create ScanResult entity
    final scanResult = ScanResult(
      barcode: event.barcode,
      rawValue: event.barcode,
      timestamp: DateTime.now(),
      type: ScanResultType.single,
    );
    
    // Call the use case
    final result = await saveScanToHistory(scanResult, event.userId);
    
    result.fold(
      (failure) => emit(ScannerError(failure.message)),
      (_) {
        if (state is ScannerActive) {
          emit((state as ScannerActive).copyWith(lastScannedBarcode: null));
        }
      },
    );
  }
  
  Future<void> _onClearLastScan(
    ClearLastScan event,
    Emitter<ScannerState> emit,
  ) async {
    if (state is ScannerActive) {
      emit((state as ScannerActive).copyWith(lastScannedBarcode: null));
    }
  }
}