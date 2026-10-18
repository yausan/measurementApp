import 'package:flutter/material.dart';
import '../../../data/models/project_model.dart';
import '../../core/theme.dart';
import '../../core/widgets/sync_status_badge.dart';
import 'project_view_model.dart';
import 'project_detail_screen.dart';
import 'new_project_screen.dart';

class ProjectListScreen extends StatelessWidget {
  final ProjectViewModel viewModel;

  const ProjectListScreen({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final projects = viewModel.filteredProjects;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Site Project Records'),
            actions: [
              IconButton(
                tooltip: 'Sync Projects',
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
          body: Column(
            children: [
              // Search & Filter header
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: viewModel.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search by Project ID, Client (Isuru), Address...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.accentCyan),
                        suffixIcon: viewModel.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => viewModel.setSearchQuery(''),
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Projects'),
                            selected: viewModel.statusFilter == null,
                            onSelected: (_) => viewModel.setStatusFilter(null),
                            selectedColor: AppTheme.accentCyan,
                            labelStyle: TextStyle(
                              color: viewModel.statusFilter == null ? Colors.black : Colors.white70,
                              fontWeight: viewModel.statusFilter == null ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ...ProjectStatus.values.map((status) {
                            final isSelected = viewModel.statusFilter == status;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(status.displayName),
                                selected: isSelected,
                                onSelected: (_) => viewModel.setStatusFilter(isSelected ? null : status),
                                selectedColor: AppTheme.accentCyan,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Project List
              Expanded(
                child: projects.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search_off_rounded, size: 56, color: Color(0xFF475569)),
                            const SizedBox(height: 12),
                            const Text('No Projects Found',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                            const SizedBox(height: 6),
                            const Text('Try adjusting your search query or status filter.',
                                style: TextStyle(fontSize: 13, color: Colors.white38)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: projects.length,
                        itemBuilder: (context, index) {
                          final project = projects[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProjectDetailScreen(
                                      projectId: project.id,
                                      viewModel: viewModel,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          project.projectNumber,
                                          style: const TextStyle(
                                            color: AppTheme.accentCyan,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ProjectStatusBadge(status: project.status),
                                        const Spacer(),
                                        SyncStatusBadge(status: project.syncStatus, compact: true),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      project.title,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.person, size: 14, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${project.clientName} ${project.clientCompany.isNotEmpty ? '• ${project.clientCompany}' : ''}',
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.place_outlined, size: 14, color: AppTheme.accentAmber),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            project.siteAddress,
                                            style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Divider(height: 18, color: Color(0xFF334155)),
                                    Row(
                                      children: [
                                        _buildMetricChip(
                                          icon: Icons.straighten_rounded,
                                          count: project.measurements.length,
                                          label: 'Dimensions',
                                          color: AppTheme.accentCyan,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildMetricChip(
                                          icon: Icons.edit_note_rounded,
                                          count: project.notes.length,
                                          label: 'Notes',
                                          color: AppTheme.accentAmber,
                                        ),
                                        const SizedBox(width: 12),
                                        _buildMetricChip(
                                          icon: Icons.camera_alt_rounded,
                                          count: project.photos.length,
                                          label: 'Photos',
                                          color: Colors.lightGreenAccent,
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white38),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppTheme.accentCyan,
            foregroundColor: Colors.black,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewProjectScreen(viewModel: viewModel),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Project', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          '$count $label',
          style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
