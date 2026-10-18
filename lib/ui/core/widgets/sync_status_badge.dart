import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../theme.dart';

class SyncStatusBadge extends StatelessWidget {
  final SyncStatus status;
  final bool compact;

  const SyncStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    switch (status) {
      case SyncStatus.synced:
        bg = AppTheme.statusGreen.withValues(alpha: 0.15);
        fg = AppTheme.statusGreen;
        icon = Icons.cloud_done_rounded;
        label = 'Synced to Office';
        break;
      case SyncStatus.pendingSync:
        bg = AppTheme.accentAmber.withValues(alpha: 0.18);
        fg = AppTheme.accentAmber;
        icon = Icons.cloud_upload_outlined;
        label = 'Pending Sync';
        break;
      case SyncStatus.offlineOnly:
        bg = Colors.blueGrey.withValues(alpha: 0.25);
        fg = const Color(0xFF94A3B8);
        icon = Icons.cloud_off_rounded;
        label = 'Saved Locally (Offline)';
        break;
      case SyncStatus.syncing:
        bg = AppTheme.accentCyan.withValues(alpha: 0.2);
        fg = AppTheme.accentCyan;
        icon = Icons.sync_rounded;
        label = 'Syncing...';
        break;
      case SyncStatus.error:
        bg = AppTheme.statusRed.withValues(alpha: 0.2);
        fg = AppTheme.statusRed;
        icon = Icons.error_outline_rounded;
        label = 'Sync Conflict';
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
            Text(
              status == SyncStatus.synced
                  ? 'Synced'
                  : status == SyncStatus.pendingSync
                      ? 'Pending'
                      : 'Offline',
              style: TextStyle(
                color: fg,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: fg.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectStatusBadge extends StatelessWidget {
  final ProjectStatus status;

  const ProjectStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case ProjectStatus.draft:
        color = Colors.grey;
        break;
      case ProjectStatus.inProgress:
        color = AppTheme.accentCyan;
        break;
      case ProjectStatus.pendingSync:
        color = AppTheme.accentAmber;
        break;
      case ProjectStatus.synced:
        color = AppTheme.statusGreen;
        break;
      case ProjectStatus.completed:
        color = const Color(0xFF38BDF8);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
