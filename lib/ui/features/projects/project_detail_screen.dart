import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/measurement_item.dart';
import '../../../data/models/site_photo.dart';
import '../../../data/models/site_note.dart';
import '../../core/theme.dart';
import '../../core/widgets/sync_status_badge.dart';
import 'project_view_model.dart';
import '../measurements/measurement_entry_screen.dart';
import '../notes/note_entry_dialog.dart';
import '../photos/photo_entry_dialog.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  final ProjectViewModel viewModel;

  const ProjectDetailScreen({
    super.key,
    required this.projectId,
    required this.viewModel,
  });

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  ProjectModel? get _project => widget.viewModel.getProjectById(widget.projectId);

  Future<void> _openAddMeasurement() async {
    final result = await Navigator.of(context).push<MeasurementItem>(
      MaterialPageRoute(
        builder: (_) => MeasurementEntryScreen(projectId: widget.projectId),
      ),
    );

    if (result != null) {
      await widget.viewModel.addMeasurement(widget.projectId, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Measurement "${result.label}" recorded!'),
            backgroundColor: AppTheme.statusGreen,
          ),
        );
      }
    }
  }

  Future<void> _openAddNote() async {
    final result = await showDialog<SiteNote>(
      context: context,
      builder: (_) => NoteEntryDialog(projectId: widget.projectId),
    );

    if (result != null) {
      await widget.viewModel.addNote(widget.projectId, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site observation added.'),
            backgroundColor: AppTheme.statusGreen,
          ),
        );
      }
    }
  }

  Future<void> _openAddPhoto() async {
    final result = await showDialog<SitePhoto>(
      context: context,
      builder: (_) => PhotoEntryDialog(projectId: widget.projectId),
    );

    if (result != null) {
      await widget.viewModel.addPhoto(widget.projectId, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Site photo attached.'),
            backgroundColor: AppTheme.statusGreen,
          ),
        );
      }
    }
  }

  Future<void> _syncCurrentProject() async {
    final result = await widget.viewModel.syncSingleProject(widget.projectId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: result.success ? AppTheme.statusGreen : AppTheme.accentAmber,
        ),
      );
    }
  }

  void _showReportSummary() {
    final project = _project;
    if (project == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceSlate,
          title: Row(
            children: [
              const Icon(Icons.description_rounded, color: AppTheme.accentCyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Field Summary Report — ${project.projectNumber}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CLIENT: ${project.clientName} (${project.clientCompany})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('ADDRESS: ${project.siteAddress}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('DATE: ${DateFormat('yyyy-MM-dd HH:mm').format(project.scheduledDate)}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text('FIELD OPERATOR: Pooja Basoula (SCI701 Field Lead)',
                            style: const TextStyle(fontSize: 12, color: AppTheme.accentCyan)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('RECORDED MEASUREMENTS:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accentCyan)),
                  const SizedBox(height: 6),
                  ...project.measurements.map(
                    (m) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline, size: 14, color: AppTheme.statusGreen),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('${m.label} [${m.locationTag}]:',
                                style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          ),
                          Text(m.formattedValue,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  if (project.measurements.isEmpty)
                    const Text('No measurements recorded yet.',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
                  const Divider(height: 24, color: Color(0xFF475569)),
                  const Text('SITE OBSERVATIONS & HAZARDS:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.accentAmber)),
                  const SizedBox(height: 6),
                  ...project.notes.map(
                    (n) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text('• [${n.category.displayName}] ${n.content}',
                          style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ),
                  ),
                  if (project.notes.isEmpty)
                    const Text('No notes recorded.',
                        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white54)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final buffer = StringBuffer();
                buffer.writeln('==================================================');
                buffer.writeln('FIELD MEASUREMENT REPORT — ${project.projectNumber}');
                buffer.writeln('PROJECT: ${project.title}');
                buffer.writeln('CLIENT: ${project.clientName} (${project.clientCompany})');
                buffer.writeln('ADDRESS: ${project.siteAddress}');
                buffer.writeln('PHONE: ${project.clientPhone}');
                buffer.writeln('DATE: ${DateFormat('yyyy-MM-dd HH:mm').format(project.scheduledDate)}');
                buffer.writeln('OPERATOR: Pooja Basoula (SCI701 Field Tech Lead)');
                buffer.writeln('SYNC STATUS: ${project.syncStatus.name.toUpperCase()}');
                buffer.writeln('==================================================');
                buffer.writeln('RECORDED DIMENSIONS:');
                for (final m in project.measurements) {
                  buffer.writeln('- ${m.label} [${m.locationTag}]: ${m.formattedValue} (${m.type.displayName})${m.notes.isNotEmpty ? ' | Notes: ${m.notes}' : ''}');
                }
                buffer.writeln('--------------------------------------------------');
                buffer.writeln('SITE OBSERVATIONS & HAZARDS:');
                for (final n in project.notes) {
                  buffer.writeln('- [${n.category.displayName}] ${n.content} (by ${n.author})');
                }
                buffer.writeln('==================================================');

                Clipboard.setData(ClipboardData(text: buffer.toString()));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Field report copied to clipboard! Ready to email or paste.'),
                    backgroundColor: AppTheme.statusGreen,
                  ),
                );
              },
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Copy Field Report'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final project = _project;
        if (project == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Project Not Found')),
            body: const Center(child: Text('This project could not be found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(project.projectNumber),
            actions: [
              IconButton(
                tooltip: 'Sync with Office Backend',
                icon: const Icon(Icons.sync_rounded),
                onPressed: _syncCurrentProject,
              ),
              IconButton(
                tooltip: 'Field Summary Report',
                icon: const Icon(Icons.receipt_long_rounded),
                onPressed: _showReportSummary,
              ),
            ],
          ),
          body: Column(
            children: [
              // Project Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppTheme.primaryNavy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                project.title,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 14, color: AppTheme.accentCyan),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${project.clientName} ${project.clientCompany.isNotEmpty ? '• ${project.clientCompany}' : ''}',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SyncStatusBadge(status: project.syncStatus),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.accentAmber),
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.badge_outlined, size: 14, color: AppTheme.accentCyan),
                        const SizedBox(width: 4),
                        Text(
                          'Tech: ${project.technicianName}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                        ),
                        const Spacer(),
                        if (project.deviceId.isNotEmpty)
                          Text(
                            project.deviceId,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontFamily: 'monospace'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 14, color: AppTheme.statusGreen),
                        const SizedBox(width: 4),
                        Text(
                          project.clientPhone,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                        ),
                        const Spacer(),
                        if (project.lastSyncedAt != null)
                          Text(
                            'Synced: ${DateFormat('HH:mm, dd MMM').format(project.lastSyncedAt!)}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tab Bar
              Container(
                color: AppTheme.surfaceSlate,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppTheme.accentCyan,
                  labelColor: AppTheme.accentCyan,
                  unselectedLabelColor: Colors.white60,
                  tabs: [
                    Tab(
                      icon: const Icon(Icons.straighten_rounded, size: 18),
                      text: 'Dimensions (${project.measurements.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.notes_rounded, size: 18),
                      text: 'Site Notes (${project.notes.length})',
                    ),
                    Tab(
                      icon: const Icon(Icons.photo_camera_rounded, size: 18),
                      text: 'Photos (${project.photos.length})',
                    ),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMeasurementsList(project),
                    _buildNotesList(project),
                    _buildPhotosList(project),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppTheme.surfaceSlate,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openAddMeasurement,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add Measurement'),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filledTonal(
                  tooltip: 'Add Observation Note',
                  icon: const Icon(Icons.note_add_rounded, color: AppTheme.accentCyan),
                  onPressed: _openAddNote,
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Attach Site Photo',
                  icon: const Icon(Icons.add_a_photo_rounded, color: AppTheme.accentAmber),
                  onPressed: _openAddPhoto,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMeasurementsList(ProjectModel project) {
    if (project.measurements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.straighten_rounded, size: 64, color: Color(0xFF475569)),
            const SizedBox(height: 12),
            const Text('No Measurements Recorded Yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 6),
            const Text('Tap "Add Measurement" below to record openings & dimensions.',
                style: TextStyle(fontSize: 13, color: Colors.white38)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _openAddMeasurement,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Capture First Dimension'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: project.measurements.length,
      itemBuilder: (context, index) {
        final m = project.measurements[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.straighten_rounded, color: AppTheme.accentCyan, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.label,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(m.locationTag,
                                    style: const TextStyle(fontSize: 11, color: AppTheme.accentAmber)),
                              ),
                              const SizedBox(width: 8),
                              Text(m.type.displayName,
                                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Text(
                      m.formattedValue,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                    ),
                  ],
                ),
                if (m.notes.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tolerance / Notes: ${m.notes}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (m.isVerified) ...[
                          const Icon(Icons.verified_rounded, size: 14, color: AppTheme.statusGreen),
                          const SizedBox(width: 4),
                          const Text('Dual-Checked',
                              style: TextStyle(fontSize: 11, color: AppTheme.statusGreen)),
                        ],
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.white38),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppTheme.surfaceSlate,
                            title: const Text('Delete Measurement?'),
                            content: Text('Remove "${m.label}"?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.statusRed),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await widget.viewModel.deleteMeasurement(project.id, m.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotesList(ProjectModel project) {
    if (project.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_note_rounded, size: 64, color: Color(0xFF475569)),
            const SizedBox(height: 12),
            const Text('No Site Observations Yet',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 6),
            const Text('Add safety hazards, delivery constraints, or client instructions.',
                style: TextStyle(fontSize: 13, color: Colors.white38)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: project.notes.length,
      itemBuilder: (context, index) {
        final n = project.notes[index];
        final isHazard = n.category == NoteCategory.hazard;

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          color: isHazard ? const Color(0xFF3F1B1B) : AppTheme.surfaceSlate,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isHazard ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
                      size: 18,
                      color: isHazard ? AppTheme.statusRed : AppTheme.accentCyan,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      n.category.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isHazard ? AppTheme.statusRed : AppTheme.accentCyan,
                      ),
                    ),
                    if (n.isPinned) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.accentAmber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('PINNED',
                            style: TextStyle(fontSize: 9, color: AppTheme.accentAmber, fontWeight: FontWeight.bold)),
                      ),
                    ],
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
                      onPressed: () => widget.viewModel.deleteNote(project.id, n.id),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(n.content, style: const TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('By: ${n.author}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
                    Text(DateFormat('dd MMM, HH:mm').format(n.timestamp),
                        style: const TextStyle(fontSize: 11, color: Colors.white38)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotosList(ProjectModel project) {
    if (project.photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo_camera_rounded, size: 64, color: Color(0xFF475569)),
            const SizedBox(height: 12),
            const Text('No Site Photos Attached',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 6),
            const Text('Capture openings, floor rebates, or installation hazards.',
                style: TextStyle(fontSize: 13, color: Colors.white38)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: project.photos.length,
      itemBuilder: (context, index) {
        final p = project.photos[index];
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: const Color(0xFF0F172A),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.camera_alt_outlined, size: 48, color: AppTheme.accentCyan),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(p.tag, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white70),
                          onPressed: () => widget.viewModel.deletePhoto(project.id, p.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(p.timestamp),
                      style: const TextStyle(fontSize: 10, color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
