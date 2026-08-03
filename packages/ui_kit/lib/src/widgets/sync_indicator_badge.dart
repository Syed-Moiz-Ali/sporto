import 'package:flutter/material.dart';
import 'glass_container.dart';

class SyncIndicatorBadge extends StatelessWidget {
  final bool isConnected;
  final bool isSyncing;
  final int pendingItemsCount;

  const SyncIndicatorBadge({
    super.key,
    required this.isConnected,
    this.isSyncing = false,
    this.pendingItemsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final statusColor = isConnected
        ? (isSyncing ? colorScheme.secondary : colorScheme.primary)
        : Colors.orangeAccent;

    final label = isConnected
        ? (isSyncing
            ? 'Syncing...'
            : 'Online & Synced')
        : 'Offline ($pendingItemsCount Pending)';

    return GlassContainer(
      borderRadius: 20,
      blur: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      backgroundColor: statusColor.withValues(alpha: 0.15),
      borderColor: statusColor.withValues(alpha: 0.4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
