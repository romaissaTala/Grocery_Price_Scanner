import 'package:equatable/equatable.dart';
import 'package:grocery_price_scanner/features/history/data/models/scan_history_model.dart';
import 'package:grocery_price_scanner/features/history/domain/entities/scan_history_entry.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadHistory extends HistoryEvent {
  final String userId;
  final int limit;
  
  const LoadHistory({required this.userId, this.limit = 50});
  
  @override
  List<Object?> get props => [userId, limit];
}

class SearchHistoryEvent extends HistoryEvent {
  final String userId;
  final String query;
  
  const SearchHistoryEvent({required this.userId, required this.query});
  
  @override
  List<Object?> get props => [userId, query];
}

class DeleteHistoryEntryEvent extends HistoryEvent {
  final String entryId;
  
  const DeleteHistoryEntryEvent(this.entryId);
  
  @override
  List<Object?> get props => [entryId];
}

class ClearHistoryEvent extends HistoryEvent {
  final String userId;
  
  const ClearHistoryEvent(this.userId);
  
  @override
  List<Object?> get props => [userId];
}

// Add this new event
class AddHistoryEntryEvent extends HistoryEvent {
  final ScanHistoryModel entry; // Changed from ScanHistoryEntry to ScanHistoryModel
  
  const AddHistoryEntryEvent(this.entry);
  
  @override
  List<Object?> get props => [entry];
}