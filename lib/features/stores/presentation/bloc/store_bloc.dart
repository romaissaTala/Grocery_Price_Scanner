import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_price_scanner/features/stores/domain/usecases/get_stores.dart';
import 'package:injectable/injectable.dart';
import 'store_event.dart';
import 'store_state.dart';


class StoreBloc extends Bloc<StoreEvent, StoreState> {
  final GetStores getStores;
  
  StoreBloc({required this.getStores}) : super(StoreInitial()) {
    on<LoadStores>(_onLoadStores);
  }
  
  Future<void> _onLoadStores(
    LoadStores event,
    Emitter<StoreState> emit,
  ) async {
    emit(StoreLoading());
    
    final result = await getStores();
    
    result.fold(
      (failure) => emit(StoreError(failure.message)),
      (stores) => emit(StoreLoaded(stores)),
    );
  }
}