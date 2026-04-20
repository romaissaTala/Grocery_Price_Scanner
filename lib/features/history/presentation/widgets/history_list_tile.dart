import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/scan_history_entry.dart';

class HistoryListTile extends StatelessWidget {
  final ScanHistoryEntry entry;
  final VoidCallback onDelete;
  
  const HistoryListTile({
    super.key,
    required this.entry,
    required this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(isDark ? 0.1 : 0.08),
          width: 0.5,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: entry.productImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    entry.productImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _HistoryInitial(
                      barcode: entry.barcode,
                      colorScheme: colorScheme,
                    ),
                  ),
                )
              : _HistoryInitial(
                  barcode: entry.barcode,
                  colorScheme: colorScheme,
                ),
        ),
        title: Text(
          entry.productName ?? 'Unknown Product',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Barcode: ${entry.barcode}',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(entry.scannedAt),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: colorScheme.error.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colorScheme.error,
              size: 20,
            ),
            onPressed: onDelete,
            padding: const EdgeInsets.all(8),
          ),
        ),
        onTap: () {
          if (entry.productId != null) {
            // Navigate to product details
            // context.push('/product/${entry.barcode}');
          }
        },
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _HistoryInitial extends StatelessWidget {
  final String barcode;
  final ColorScheme colorScheme;
  
  const _HistoryInitial({
    required this.barcode,
    required this.colorScheme,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.qr_code_scanner_rounded,
        size: 28,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}