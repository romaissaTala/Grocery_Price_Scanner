import 'package:equatable/equatable.dart';
import 'package:grocery_price_scanner/features/stores/domain/entities/store.dart';


abstract class StoreState extends Equatable {
  const StoreState();
  
  @override
  List<Object?> get props => [];
}

class StoreInitial extends StoreState {}

class StoreLoading extends StoreState {}

class StoreLoaded extends StoreState {
  final List<Store> stores;
  
  const StoreLoaded(this.stores);
  
  @override
  List<Object?> get props => [stores];
}

class StoreError extends StoreState {
  final String message;
  
  const StoreError(this.message);
  
  @override
  List<Object?> get props => [message];
}