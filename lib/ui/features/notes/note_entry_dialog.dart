import 'package:flutter/material.dart';
import '../../../data/models/site_note.dart';
import '../../core/theme.dart';

class NoteEntryDialog extends StatefulWidget {
  final String projectId;

  const NoteEntryDialog({super.key, required this.projectId});

  @override
  State<NoteEntryDialog> createState() => _NoteEntryDialogState();
}

class _NoteEntryDialogState extends State<NoteEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();
  NoteCategory _selectedCategory = NoteCategory.general;
  bool _isPinned = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final note = SiteNote(
      projectId: widget.projectId,
      content: _contentController.text.trim(),
      category: _selectedCategory,
      author: 'Pooja Basoula (Field Tech)',
      isPinned: _isPinned,
    );

    Navigator.of(context).pop(note);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceSlate,
      title: const Row(
        children: [
          Icon(Icons.edit_note_rounded, color: AppTheme.accentCyan),
          SizedBox(width: 8),
          Text('Add Site Observation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Category', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              DropdownButtonFormField<NoteCategory>(
                initialValue: _selectedCategory,
                dropdownColor: AppTheme.surfaceSlate,
                items: NoteCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.displayName, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (cat) {
                  if (cat != null) setState(() => _selectedCategory = cat);
                },
              ),
              const SizedBox(height: 16),
              const Text('Observation / Hazard Details *', style: TextStyle(fontSize: 12, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contentController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe site conditions, safety hazards, or specific client instructions...',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter note content';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isPinned,
                onChanged: (val) => setState(() => _isPinned = val),
                title: const Text('Pin to Top (Priority Alert)', style: TextStyle(fontSize: 13)),
                activeThumbColor: AppTheme.accentAmber,
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
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Save Note'),
        ),
      ],
    );
  }
}
