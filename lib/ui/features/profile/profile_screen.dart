import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../projects/project_view_model.dart';

class ProfileScreen extends StatefulWidget {
  final ProjectViewModel viewModel;

  const ProfileScreen({super.key, required this.viewModel});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _companyController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    _nameController = TextEditingController(text: widget.viewModel.technicianName);
    _roleController = TextEditingController(text: widget.viewModel.technicianRole);
    _companyController = TextEditingController(text: widget.viewModel.companyName);
    _emailController = TextEditingController(text: widget.viewModel.technicianEmail);
    _phoneController = TextEditingController(text: widget.viewModel.technicianPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'OP';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.viewModel.updateProfile(
      name: _nameController.text.isEmpty ? 'Field Technician' : _nameController.text,
      role: _roleController.text.isEmpty ? 'Field Estimator' : _roleController.text,
      company: _companyController.text.isEmpty ? 'Building Solutions' : _companyController.text,
      email: _emailController.text,
      phone: _phoneController.text,
    );

    if (!mounted) return;
    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully! All future records will use your identity.'),
        backgroundColor: AppTheme.statusGreen,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetToDefaults() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceSlate,
        title: const Text('Reset Profile Defaults?'),
        content: const Text(
          'This will reset your local profile information to generic Field Operator defaults.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentAmber),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await widget.viewModel.updateProfile(
                name: 'Field Technician',
                role: 'Lead Field Estimator',
                company: 'UniSC Partner Building Solutions',
                email: '',
                phone: '',
              );
              _initControllers();
              setState(() {});
            },
            child: const Text('Reset', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentName = widget.viewModel.technicianName;
    final currentRole = widget.viewModel.technicianRole;
    final currentCompany = widget.viewModel.companyName;
    final deviceId = widget.viewModel.deviceId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technician Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: AppTheme.accentCyan),
              tooltip: 'Edit Profile',
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check_rounded, color: AppTheme.statusGreen),
              tooltip: 'Save Profile',
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar & Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: AppTheme.accentCyan,
                      child: Text(
                        _getInitials(currentName),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      currentName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentRole,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.accentCyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentCompany,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.phonelink_setup_rounded, size: 14, color: AppTheme.accentAmber),
                          const SizedBox(width: 6),
                          Text(
                            'HARDWARE ID: $deviceId',
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentAmber,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Mode toggle notification
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSlate,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isEditing ? Icons.info_outline : Icons.badge_outlined,
                      color: _isEditing ? AppTheme.accentAmber : AppTheme.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _isEditing
                            ? 'Editing profile: changes will update your signature on new projects, notes, and cloud synchronisation records.'
                            : 'This identity is stamped onto your on-site measurements, inspection notes, and Firestore cloud sync uploads.',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Form Fields
              _buildField(
                label: 'Full Name',
                controller: _nameController,
                icon: Icons.person_rounded,
                hint: 'e.g. John Smith',
                enabled: _isEditing,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter your name';
                  return null;
                },
              ),

              const SizedBox(height: 14),

              _buildField(
                label: 'Role / Job Title',
                controller: _roleController,
                icon: Icons.work_outline_rounded,
                hint: 'e.g. Senior Glazing Estimator / Site Lead',
                enabled: _isEditing,
              ),

              const SizedBox(height: 14),

              _buildField(
                label: 'Organization / Company',
                controller: _companyController,
                icon: Icons.business_rounded,
                hint: 'e.g. UniSC Partner Building Solutions',
                enabled: _isEditing,
              ),

              const SizedBox(height: 14),

              _buildField(
                label: 'Contact Email',
                controller: _emailController,
                icon: Icons.email_outlined,
                hint: 'e.g. estimator@example.com',
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              _buildField(
                label: 'Contact Phone',
                controller: _phoneController,
                icon: Icons.phone_outlined,
                hint: 'e.g. +61 400 000 000',
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 24),

              // Action Buttons
              if (_isEditing)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _initControllers();
                          setState(() => _isEditing = false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF64748B)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _saveProfile,
                        icon: const Icon(Icons.save_rounded, color: Colors.black),
                        label: const Text('Save Profile', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCyan,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _isEditing = true),
                        icon: const Icon(Icons.edit_rounded, color: AppTheme.accentCyan, size: 18),
                        label: const Text('Edit Identity', style: TextStyle(color: AppTheme.accentCyan)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppTheme.accentCyan),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: _resetToDefaults,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF475569)),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      ),
                      child: const Icon(Icons.restart_alt_rounded, color: Colors.white70),
                    ),
                  ],
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    required bool enabled,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white70,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: enabled ? AppTheme.accentCyan : const Color(0xFF64748B), size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            filled: true,
            fillColor: enabled ? const Color(0xFF1E293B) : const Color(0xFF161F2E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF334155)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF1E293B)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.accentCyan, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
