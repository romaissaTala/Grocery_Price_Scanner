import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/history_bloc.dart';
import '../bloc/history_event.dart';
import '../bloc/history_state.dart';
import '../widgets/history_list_tile.dart';
import '../widgets/history_search_bar.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String defaultUserId = '68d8e4a0-983a-4bc6-8a17-caadd83682eb';
    return BlocProvider(
      create: (_) =>
          sl<HistoryBloc>()..add(const LoadHistory(userId: defaultUserId)),
      child: const _HistoryView(),
    );
  }
}

class _HistoryView extends StatefulWidget {
  const _HistoryView();

  @override
  State<_HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<_HistoryView> {
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? HistorySearchBar(
                onSearch: (query) {
                  context.read<HistoryBloc>().add(
                        query.isNotEmpty
                            ? SearchHistoryEvent(
                                userId: '68d8e4a0-983a-4bc6-8a17-caadd83682eb',
                                query: query)
                            : const LoadHistory(
                                userId: '68d8e4a0-983a-4bc6-8a17-caadd83682eb'),
                      );
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Scan History',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  BlocBuilder<HistoryBloc, HistoryState>(
                    builder: (context, state) {
                      if (state is HistoryLoaded) {
                        return Text(
                          '${state.entries.length} products scanned',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: colorScheme.onSurface.withOpacity(0.5),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
        actions: [
          _AppBarIconButton(
            icon: _isSearching ? Icons.close_rounded : Icons.search_rounded,
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  context.read<HistoryBloc>().add(const LoadHistory(
                      userId: '68d8e4a0-983a-4bc6-8a17-caadd83682eb'));
                }
              });
            },
          ),
          _AppBarIconButton(
            icon: Icons.delete_outline_rounded,
            onTap: () => _showClearDialog(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }
          if (state is HistoryError) {
            return _buildError(context, state.message);
          }
          if (state is HistoryLoaded) {
            if (state.entries.isEmpty) return _buildEmptyState(context);
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: state.entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                return HistoryListTile(
                  entry: state.entries[index],
                  onDelete: () => context.read<HistoryBloc>().add(
                        DeleteHistoryEntryEvent(state.entries[index].id ?? ""),
                      ),
                )
                    .animate(delay: Duration(milliseconds: index * 50))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No scans yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan your first barcode to get started',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to scanner
              },
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Start Scanning'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: colorScheme.error.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<HistoryBloc>().add(
                    const LoadHistory(
                        userId: '68d8e4a0-983a-4bc6-8a17-caadd83682eb'),
                  );
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Clear History'),
        content: const Text(
            'Are you sure you want to clear all scan history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryBloc>().add(
                  ClearHistoryEvent('68d8e4a0-983a-4bc6-8a17-caadd83682eb'));
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}
