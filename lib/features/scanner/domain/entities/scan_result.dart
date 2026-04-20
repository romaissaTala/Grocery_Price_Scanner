import 'package:equatable/equatable.dart';

class ScanResult extends Equatable {
  final String barcode;
  final String? rawValue;
  final DateTime timestamp;
  final ScanResultType type;
  
  const ScanResult({
    required this.barcode,
    this.rawValue,
    required this.timestamp,
    this.type = ScanResultType.single,
  });
  
  // Add fromJson factory
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      barcode: json['barcode'] as String,
      rawValue: json['rawValue'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: ScanResultType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => ScanResultType.single,
      ),
    );
  }
  
  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'rawValue': rawValue,
      'timestamp': timestamp.toIso8601String(),
      'type': type.toString(),
    };
  }
  
  @override
  List<Object?> get props => [barcode, rawValue, timestamp, type];
}

enum ScanResultType {
  single,
  batch,
}