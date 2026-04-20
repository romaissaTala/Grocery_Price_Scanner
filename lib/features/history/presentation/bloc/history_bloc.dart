import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:grocery_price_scanner/features/history/domain/usecases/add_history_entry.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/clear_history.dart';
import '../../domain/usecases/delete_history_entry.dart';
import '../../domain/usecases/get_history.dart';
import '../../domain/usecases/search_history.dart';
import 'history_event.dart';
import 'history_state.dart';



class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistory getHistory;
  final SearchHistory searchHistory;
  final DeleteHistoryEntry deleteHistoryEntry;
  final ClearHistory clearHistory;
  final AddHistoryEntry addHistoryEntry;
  HistoryBloc({
    required this.getHistory,
    required this.searchHistory,
    required this.deleteHistoryEntry,
    required this.clearHistory,
    required this.addHistoryEntry,
  }) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SearchHistoryEvent>(_onSearchHistory);
    on<DeleteHistoryEntryEvent>(_onDeleteHistoryEntry);
    on<ClearHistoryEvent>(_onClearHistory);
    on<AddHistoryEntryEvent>(_onAddHistoryEntry);
  }
  
  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    
    final result = await getHistory(event.userId, limit: event.limit);
    
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (entries) => emit(HistoryLoaded(entries: entries)),
    );
  }
  
  Future<void> _onSearchHistory(
    SearchHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    
    final result = await searchHistory(event.userId, event.query);
    
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (entries) => emit(HistoryLoaded(entries: entries, isSearching: true)),
    );
  }
  
  Future<void> _onDeleteHistoryEntry(
    DeleteHistoryEntryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await deleteHistoryEntry(event.entryId);
    
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) {
        if (state is HistoryLoaded) {
          final currentState = state as HistoryLoaded;
          final updatedEntries = currentState.entries
              .where((e) => e.id != event.entryId)
              .toList();
          emit(HistoryLoaded(entries: updatedEntries));
        }
      },
    );
  }
  
  Future<void> _onClearHistory(
    ClearHistoryEvent event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await clearHistory(event.userId);
    
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => emit(HistoryLoaded(entries: [])),
    );
  }

  Future<void> _onAddHistoryEntry(
  AddHistoryEntryEvent event,
  Emitter<HistoryState> emit,
) async {
  final result = await addHistoryEntry(event.entry);
  
  result.fold(
    (failure) => print('Failed to add history entry: ${failure.message}'),
    (_) {
      // Refresh history after adding
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        final updatedEntries = [event.entry, ...currentState.entries];
        emit(HistoryLoaded(entries: updatedEntries));
      }
    },
  );
}
}