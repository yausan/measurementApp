import 'package:flutter/material.dart';
import '../../../data/models/measurement_item.dart';
import '../../core/theme.dart';

class MeasurementEntryScreen extends StatefulWidget {
  final String projectId;
  final MeasurementItem? existingItem;

  const MeasurementEntryScreen({
    super.key,
    required this.projectId,
    this.existingItem,
  });

  @override
  State<MeasurementEntryScreen> createState() => _MeasurementEntryScreenState();
}

class _MeasurementEntryScreenState extends State<MeasurementEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _labelController;
  late TextEditingController _valueController;
  late TextEditingController _notesController;
  late TextEditingController _customLocationController;

  late MeasurementType _selectedType;
  late MeasurementUnit _selectedUnit;
  late String _selectedLocation;
  bool _isVerified = true;

  final List<String> _commonLocations = [
    'North Facade L2',
    'South Facade',
    'Boardroom 204',
    'Main Foyer',
    'Suite 401',
    'Central Atrium',
    'Living Room',
    'Kitchen Bench',
    'Balcony Deck',
    'Custom...',
  ];

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _labelController = TextEditingController(text: item?.label ?? '');
    _valueController = TextEditingController(text: item != null ? item.value.toString() : '');
    _notesController = TextEditingController(text: item?.notes ?? '');
    _customLocationController = TextEditingController();

    _selectedType = item?.type ?? MeasurementType.length;
    _selectedUnit = item?.unit ?? MeasurementUnit.mm;
    _selectedLocation = item?.locationTag ?? _commonLocations.first;
    _isVerified = item?.isVerified ?? true;

    if (!_commonLocations.contains(_selectedLocation)) {
      _customLocationController.text = _selectedLocation;
      _selectedLocation = 'Custom...';
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    _customLocationController.dispose();
    super.dispose();
  }

  void _saveMeasurement() {
    if (!_formKey.currentState!.validate()) return;

    final double val = double.parse(_valueController.text.trim());
    final String location = _selectedLocation == 'Custom...'
        ? (_customLocationController.text.trim().isNotEmpty
            ? _customLocationController.text.trim()
            : 'General Site')
        : _selectedLocation;

    final measurement = MeasurementItem(
      id: widget.existingItem?.id,
      projectId: widget.projectId,
      label: _labelController.text.trim(),
      type: _selectedType,
      value: val,
      unit: _selectedUnit,
      locationTag: location,
      notes: _notesController.text.trim(),
      isVerified: _isVerified,
    );

    Navigator.of(context).pop(measurement);
  }

  String _getConvertedPreview() {
    final val = double.tryParse(_valueController.text.trim());
    if (val == null || val <= 0) return '';

    if (_selectedUnit == MeasurementUnit.mm) {
      final m = val / 1000;
      final inch = val / 25.4;
      return '≈ ${m.toStringAsFixed(3)} m  |  ${inch.toStringAsFixed(2)} in';
    } else if (_selectedUnit == MeasurementUnit.cm) {
      final mm = val * 10;
      final inch = mm / 25.4;
      return '≈ ${mm.toStringAsFixed(0)} mm  |  ${inch.toStringAsFixed(2)} in';
    } else if (_selectedUnit == MeasurementUnit.m) {
      final mm = val * 1000;
      final ft = val * 3.28084;
      return '≈ ${mm.toStringAsFixed(0)} mm  |  ${ft.toStringAsFixed(2)} ft';
    } else if (_selectedUnit == MeasurementUnit.inch) {
      final mm = val * 25.4;
      final ft = val / 12;
      return '≈ ${mm.toStringAsFixed(1)} mm  |  ${ft.toStringAsFixed(2)} ft';
    } else if (_selectedUnit == MeasurementUnit.deg) {
      final rad = val * (3.14159265359 / 180);
      return '≈ ${rad.toStringAsFixed(3)} rad';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingItem == null ? 'Capture Measurement' : 'Edit Measurement'),
        actions: [
          TextButton.icon(
            onPressed: _saveMeasurement,
            icon: const Icon(Icons.check_rounded, color: AppTheme.accentCyan),
            label: const Text('Save', style: TextStyle(color: AppTheme.accentCyan, fontWeight: FontWeight.bold)),
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
              // Header description banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSlate,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.straighten_rounded, color: AppTheme.accentCyan, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Record accurate on-site dimensions with validation. Data is stored offline-first on device.',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Measurement Label
              const Text('Component / Opening Description *',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  hintText: 'e.g. North Curtain Wall Opening, Sill Rebate, Doorway',
                  prefixIcon: Icon(Icons.label_outline, color: AppTheme.accentCyan),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a description for this measurement';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),

              // Measurement Type
              const Text('Measurement Dimension Type',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MeasurementType.values.map((type) {
                  final isSelected = _selectedType == type;
                  return ChoiceChip(
                    label: Text(type.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedType = type;
                          if (type == MeasurementType.angle) {
                            _selectedUnit = MeasurementUnit.deg;
                          } else if (_selectedUnit == MeasurementUnit.deg) {
                            _selectedUnit = MeasurementUnit.mm;
                          }
                        });
                      }
                    },
                    selectedColor: AppTheme.accentCyan,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Value and Unit Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Measured Value *',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _valueController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentCyan),
                          decoration: InputDecoration(
                            hintText: '0.00',
                            prefixIcon: const Icon(Icons.numbers_rounded, color: AppTheme.accentCyan),
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    final current = double.tryParse(_valueController.text.trim()) ?? 0;
                                    if (current > 0) {
                                      setState(() {
                                        _valueController.text = (current - (_selectedUnit == MeasurementUnit.mm ? 10 : 1))
                                            .toStringAsFixed(0);
                                      });
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    final current = double.tryParse(_valueController.text.trim()) ?? 0;
                                    setState(() {
                                      _valueController.text = (current + (_selectedUnit == MeasurementUnit.mm ? 10 : 1))
                                          .toStringAsFixed(0);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Value is required';
                            }
                            final d = double.tryParse(val.trim());
                            if (d == null || d <= 0) {
                              return 'Enter valid positive number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Unit',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<MeasurementUnit>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          dropdownColor: AppTheme.surfaceSlate,
                          items: MeasurementUnit.values.map((u) {
                            return DropdownMenuItem(
                              value: u,
                              child: Text('${u.symbol} (${u.name})', style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (u) {
                            if (u != null) {
                              setState(() => _selectedUnit = u);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Live conversion preview
              if (_getConvertedPreview().isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    _getConvertedPreview(),
                    style: const TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Location tag
              const Text('Location Tag / Zone',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _commonLocations.map((loc) {
                  final isSelected = _selectedLocation == loc;
                  return FilterChip(
                    label: Text(loc),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedLocation = loc;
                      });
                    },
                    selectedColor: AppTheme.accentAmber.withValues(alpha: 0.3),
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.accentAmber : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),

              if (_selectedLocation == 'Custom...') ...[
                const SizedBox(height: 10),
                TextFormField(
                  controller: _customLocationController,
                  decoration: const InputDecoration(
                    hintText: 'Enter custom location name',
                    prefixIcon: Icon(Icons.place_outlined, color: AppTheme.accentAmber),
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Notes & field observations
              const Text('Installation Notes / Tolerances',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'e.g. Needs -5mm shim allowance, surface out of plumb by 2mm',
                  prefixIcon: Icon(Icons.note_alt_outlined, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 16),

              // Verified Checkbox
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isVerified,
                onChanged: (val) => setState(() => _isVerified = val ?? true),
                title: const Text('Field Verified with Dual Check',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                subtitle: const Text('Checked for diagonal squareness and levelness',
                    style: TextStyle(fontSize: 12, color: Colors.white54)),
                activeColor: AppTheme.statusGreen,
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveMeasurement,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    widget.existingItem == null ? 'Record Measurement to Local DB' : 'Update Measurement',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
