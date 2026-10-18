import 'package:flutter/material.dart';
import '../../../data/models/site_photo.dart';
import '../../core/theme.dart';

class PhotoEntryDialog extends StatefulWidget {
  final String projectId;

  const PhotoEntryDialog({super.key, required this.projectId});

  @override
  State<PhotoEntryDialog> createState() => _PhotoEntryDialogState();
}

class _PhotoEntryDialogState extends State<PhotoEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedTag = 'Structural Opening';
  int _selectedGraphicIdx = 0;

  final List<String> _tags = [
    'Structural Opening',
    'Window Rebate',
    'Facade Alignment',
    'Safety Hazard',
    'Access / Ingress',
  ];

  final List<IconData> _sampleIcons = [
    Icons.window_rounded,
    Icons.door_front_door_rounded,
    Icons.domain_rounded,
    Icons.roofing_rounded,
    Icons.construction_rounded,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final photo = SitePhoto(
      projectId: widget.projectId,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      imagePath: 'simulated://camera_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      tag: _selectedTag,
    );

    Navigator.of(context).pop(photo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceSlate,
      title: const Row(
        children: [
          Icon(Icons.camera_alt_rounded, color: AppTheme.accentCyan),
          SizedBox(width: 8),
          Text('Attach Site Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Camera viewfinder simulator box
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(_sampleIcons[_selectedGraphicIdx], size: 54, color: AppTheme.accentCyan.withValues(alpha: 0.6)),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.statusGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.statusGreen),
                        ),
                        child: const Text('CAMERA READY', style: TextStyle(fontSize: 10, color: AppTheme.statusGreen)),
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      child: Text('Field Photo Capture (High Resolution)',
                          style: TextStyle(fontSize: 11, color: Colors.white60)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              const Text('Photo Subject / Label *', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. North Curtain Wall Anchor Bolts',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a title for the photo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              const Text('Tag / Category', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedTag,
                dropdownColor: AppTheme.surfaceSlate,
                items: _tags.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Text(t, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (t) {
                  if (t != null) {
                    setState(() {
                      _selectedTag = t;
                      _selectedGraphicIdx = _tags.indexOf(t) % _sampleIcons.length;
                    });
                  }
                },
              ),
              const SizedBox(height: 14),

              const Text('Description / Reference Notes', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Verified structural steel tolerance with plumb line',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add_photo_alternate_rounded, size: 18),
          label: const Text('Attach Photo'),
        ),
      ],
    );
  }
}
