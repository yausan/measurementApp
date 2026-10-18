import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/project_model.dart';
import '../../core/theme.dart';
import 'project_view_model.dart';

class NewProjectScreen extends StatefulWidget {
  final ProjectViewModel viewModel;

  const NewProjectScreen({super.key, required this.viewModel});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _projectNumberController;
  final _titleController = TextEditingController();
  final _clientNameController = TextEditingController();
  final _clientCompanyController = TextEditingController();
  final _clientPhoneController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _siteAddressController = TextEditingController();
  final _technicianController = TextEditingController(text: 'Pooja Basoula (Field Tech)');
  DateTime _scheduledDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final randomNum = (100 + widget.viewModel.projects.length + 1).toString().padLeft(3, '0');
    _projectNumberController = TextEditingController(text: 'PRJ-2026-$randomNum');
  }

  @override
  void dispose() {
    _projectNumberController.dispose();
    _titleController.dispose();
    _clientNameController.dispose();
    _clientCompanyController.dispose();
    _clientPhoneController.dispose();
    _clientEmailController.dispose();
    _siteAddressController.dispose();
    _technicianController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentCyan,
              onPrimary: Colors.black,
              surface: AppTheme.surfaceSlate,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final project = ProjectModel(
      projectNumber: _projectNumberController.text.trim(),
      title: _titleController.text.trim(),
      clientName: _clientNameController.text.trim(),
      clientCompany: _clientCompanyController.text.trim(),
      clientPhone: _clientPhoneController.text.trim(),
      clientEmail: _clientEmailController.text.trim(),
      siteAddress: _siteAddressController.text.trim(),
      technicianName: _technicianController.text.trim().isEmpty
          ? 'Pooja Basoula (Field Tech)'
          : _technicianController.text.trim(),
      scheduledDate: _scheduledDate,
      status: ProjectStatus.inProgress,
      syncStatus: widget.viewModel.isOffline ? SyncStatus.offlineOnly : SyncStatus.pendingSync,
    );

    await widget.viewModel.createProject(project);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project ${project.projectNumber} created successfully in local database!'),
          backgroundColor: AppTheme.statusGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Site Project Intake'),
        actions: [
          TextButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check_rounded, color: AppTheme.accentCyan),
            label: const Text('Create', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSlate,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentAmber.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.assignment_outlined, color: AppTheme.accentAmber, size: 26),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Record project and customer information directly on site. Stored offline-first and synchronized when online.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Section: Project Info
              const Text('PROJECT METADATA',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentCyan, letterSpacing: 1.1)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Project ID *', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _projectNumberController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.tag_rounded, color: AppTheme.accentCyan),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Scheduled Date', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceSlate,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 18, color: AppTheme.accentCyan),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_scheduledDate),
                                  style: const TextStyle(fontSize: 13, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text('Project Title / Scope *', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Sippy Downs Commercial Glazing, Level 3 Fitout',
                  prefixIcon: Icon(Icons.business_center_outlined, color: AppTheme.accentCyan),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter project title' : null,
              ),
              const SizedBox(height: 24),

              // Section: Customer Info
              const Text('CUSTOMER & CLIENT DETAILS',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentCyan, letterSpacing: 1.1)),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Client / Contact Name *', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _clientNameController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Isuru',
                            prefixIcon: Icon(Icons.person_outline, color: AppTheme.accentCyan),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Enter contact name' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Company / Organisation', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _clientCompanyController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. UniSC Industry Partner',
                            prefixIcon: Icon(Icons.apartment_rounded, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Phone Number *', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _clientPhoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: '0400 123 456',
                            prefixIcon: Icon(Icons.phone_outlined, color: AppTheme.accentCyan),
                          ),
                          validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email Address', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _clientEmailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'client@company.com',
                            prefixIcon: Icon(Icons.email_outlined, color: Colors.white54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              const Text('Site Physical Address *', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _siteAddressController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Building B, Level 2, 90 Sippy Downs Dr, Sippy Downs QLD 4556',
                  prefixIcon: Icon(Icons.location_on_outlined, color: AppTheme.accentCyan),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Enter site address' : null,
              ),
              const SizedBox(height: 14),

              const Text('Field Technician Name *', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _technicianController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Pooja Basoula (Field Tech)',
                  prefixIcon: Icon(Icons.badge_outlined, color: AppTheme.accentCyan),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Create Site Project & Begin Field Work'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
