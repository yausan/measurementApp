import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets/sync_status_badge.dart';
import '../projects/project_view_model.dart';
import '../projects/project_detail_screen.dart';
import '../projects/new_project_screen.dart';

class DashboardScreen extends StatelessWidget {
  final ProjectViewModel viewModel;
  final VoidCallback onNavigateToTools;

  const DashboardScreen({
    super.key,
    required this.viewModel,
    required this.onNavigateToTools,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final projects = viewModel.projects;
        final isOffline = viewModel.isOffline;

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.architecture_rounded, color: AppTheme.accentCyan),
                SizedBox(width: 10),
                Text('Site Measurement Ops', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Sync with Central Office',
                icon: viewModel.isSyncing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentCyan),
                      )
                    : const Icon(Icons.sync_rounded),
                onPressed: viewModel.isSyncing ? null : () => viewModel.syncAll(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Field Operator & Partner Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppTheme.accentCyan,
                            radius: 18,
                            child: Text('PB',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pooja Basoula — Field Tech Lead',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                                Text('SCI701 Project 4 • On-site Measurement System',
                                    style: TextStyle(fontSize: 11, color: AppTheme.accentCyan)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentAmber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ISURU PARTNER',
                                style: TextStyle(
                                    fontSize: 10, color: AppTheme.accentAmber, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Offline-first field data collection eliminating manual paper recording and transcription errors.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Offline Mode Simulation Control Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isOffline ? const Color(0xFF3F2714) : const Color(0xFF11221F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: isOffline ? AppTheme.accentAmber : AppTheme.statusGreen),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isOffline ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                        color: isOffline ? AppTheme.accentAmber : AppTheme.statusGreen,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isOffline ? 'OFFLINE MODE SIMULATOR (Active)' : 'ONLINE (Office Cloud Connected)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isOffline ? AppTheme.accentAmber : AppTheme.statusGreen,
                              ),
                            ),
                            Text(
                              isOffline
                                  ? 'Field changes are recorded safely in local database.'
                                  : 'Real-time synchronization enabled.',
                              style: const TextStyle(fontSize: 11, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: !isOffline,
                        activeThumbColor: AppTheme.statusGreen,
                        inactiveThumbColor: AppTheme.accentAmber,
                        onChanged: (_) => viewModel.toggleSimulatedOffline(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Grid
                Row(
                  children: [
                    _buildStatCard(
                      label: 'Total Projects',
                      value: '${viewModel.totalProjectsCount}',
                      icon: Icons.folder_open_rounded,
                      color: AppTheme.accentCyan,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      label: 'Measurements',
                      value: '${viewModel.totalMeasurementsCount}',
                      icon: Icons.straighten_rounded,
                      color: const Color(0xFF38BDF8),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildStatCard(
                      label: 'Pending Sync',
                      value: '${viewModel.pendingSyncCount}',
                      icon: Icons.cloud_upload_outlined,
                      color: AppTheme.accentAmber,
                    ),
                    const SizedBox(width: 10),
                    _buildStatCard(
                      label: 'Office Synced',
                      value: '${viewModel.syncedCount}',
                      icon: Icons.cloud_done_rounded,
                      color: AppTheme.statusGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quick Action Bar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => NewProjectScreen(viewModel: viewModel),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('New Site Intake'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onNavigateToTools,
                        icon: const Icon(Icons.crop_free_rounded, color: AppTheme.accentAmber),
                        label: const Text('Digital Inclinometer',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Sync Result Message if present
                if (viewModel.lastSyncResult != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: viewModel.lastSyncResult!.success
                          ? AppTheme.statusGreen.withValues(alpha: 0.12)
                          : AppTheme.accentAmber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: viewModel.lastSyncResult!.success ? AppTheme.statusGreen : AppTheme.accentAmber,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          viewModel.lastSyncResult!.success ? Icons.check_circle_rounded : Icons.info_outline,
                          color: viewModel.lastSyncResult!.success ? AppTheme.statusGreen : AppTheme.accentAmber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            viewModel.lastSyncResult!.message,
                            style: const TextStyle(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Active Site Projects
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ACTIVE SITE PROJECTS',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentCyan, letterSpacing: 1.1)),
                    Text('${projects.length} recorded',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 10),

                ...projects.take(4).map((p) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      title: Text(
                        p.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('${p.projectNumber} • ${p.clientName} (${p.clientCompany})',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text('${p.measurements.length} dims',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.accentCyan)),
                              const SizedBox(width: 8),
                              Text('${p.notes.length} notes',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.accentAmber)),
                              const Spacer(),
                              SyncStatusBadge(status: p.syncStatus, compact: true),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProjectDetailScreen(
                              projectId: p.id,
                              viewModel: viewModel,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceSlate,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                Icon(icon, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
