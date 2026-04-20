import 'package:equatable/equatable.dart';

abstract class StoreEvent extends Equatable {
  const StoreEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadStores extends StoreEvent {}

class LoadStoresByCity extends StoreEvent {
  final String city;
  
  const LoadStoresByCity(this.city);
  
  @override
  List<Object?> get props => [city];
}