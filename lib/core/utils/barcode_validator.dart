import '../constants/app_constants.dart';
import '../errors/failures.dart';

class BarcodeValidator {
  static ValidationFailure? validate(String barcode) {
    if (barcode.isEmpty) {
      return const ValidationFailure('Barcode cannot be empty');
    }
    
    if (barcode.length < AppConstants.minBarcodeLength ||
        barcode.length > AppConstants.maxBarcodeLength) {
      return ValidationFailure(
        'Barcode must be between ${AppConstants.minBarcodeLength} and ${AppConstants.maxBarcodeLength} characters',
      );
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(barcode)) {
      return const ValidationFailure('Barcode must contain only numbers');
    }
    
    return null;
  }
  
  static String format(String barcode) {
    // Remove any non-digit characters
    return barcode.replaceAll(RegExp(r'[^0-9]'), '');
  }
}