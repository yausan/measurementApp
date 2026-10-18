import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../core/theme.dart';
import '../measurements/measurement_entry_screen.dart';
import '../projects/project_view_model.dart';
import '../../../data/models/measurement_item.dart';

class InclinometerScreen extends StatefulWidget {
  final ProjectViewModel viewModel;

  const InclinometerScreen({super.key, required this.viewModel});

  @override
  State<InclinometerScreen> createState() => _InclinometerScreenState();
}

class _InclinometerScreenState extends State<InclinometerScreen>
    with SingleTickerProviderStateMixin {
  // Sensor stream
  StreamSubscription<AccelerometerEvent>? _accelSub;

  // Raw accelerometer values (m/s²)
  double _ax = 0.0;
  double _ay = 0.0;
  double _az = -9.8; // default = flat on table

  // Smoothing (low-pass filter alpha)
  static const double _alpha = 0.15;

  // Tare offsets
  double _tarePitch = 0.0;
  double _tareRoll = 0.0;

  bool _isLocked = false;
  bool _sensorAvailable = true;

  // Computed angles from accelerometer
  double get _rawPitch =>
      math.atan2(-_ax, math.sqrt(_ay * _ay + _az * _az)) * 180 / math.pi;
  double get _rawRoll =>
      math.atan2(_ay, _az) * 180 / math.pi;

  double get _effectivePitch => (_rawPitch - _tarePitch).clamp(-90.0, 90.0);
  double get _effectiveRoll => (_rawRoll - _tareRoll).clamp(-90.0, 90.0);
  bool get _isLevel =>
      _effectivePitch.abs() < 0.8 && _effectiveRoll.abs() < 0.8;

  @override
  void initState() {
    super.initState();
    _startSensor();
  }

  void _startSensor() {
    try {
      _accelSub = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (AccelerometerEvent event) {
          if (_isLocked) return;
          setState(() {
            // Low-pass filter to smooth jitter
            _ax = _ax + _alpha * (event.x - _ax);
            _ay = _ay + _alpha * (event.y - _ay);
            _az = _az + _alpha * (event.z - _az);
          });
        },
        onError: (_) {
          setState(() => _sensorAvailable = false);
        },
      );
    } catch (_) {
      setState(() => _sensorAvailable = false);
    }
  }

  void _tare() {
    setState(() {
      _tarePitch = _rawPitch;
      _tareRoll = _rawRoll;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Zeroed — current angle is now 0.0°'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetTare() {
    setState(() {
      _tarePitch = 0.0;
      _tareRoll = 0.0;
    });
  }

  void _recordToProject() async {
    final projects = widget.viewModel.projects;
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please create a project first.')),
      );
      return;
    }

    final selectedProject = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceSlate,
          title: const Text('Select Project to Save Angle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: projects.map((p) {
              return ListTile(
                title: Text(p.title),
                subtitle: Text(p.projectNumber),
                onTap: () => Navigator.pop(context, p.id),
              );
            }).toList(),
          ),
        );
      },
    );

    if (selectedProject != null && mounted) {
      final angleVal =
          double.parse(_effectivePitch.abs().toStringAsFixed(1));
      final result = await Navigator.of(context).push<MeasurementItem>(
        MaterialPageRoute(
          builder: (_) => MeasurementEntryScreen(
            projectId: selectedProject,
            existingItem: MeasurementItem(
              projectId: selectedProject,
              label: 'Field Surface Pitch Angle',
              type: MeasurementType.angle,
              value: angleVal,
              unit: MeasurementUnit.deg,
              notes: 'Measured with digital inclinometer (accelerometer)',
            ),
          ),
        ),
      );

      if (result != null) {
        await widget.viewModel.addMeasurement(selectedProject, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recorded ${result.formattedValue} to project!'),
              backgroundColor: AppTheme.statusGreen,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Inclinometer & Level'),
        actions: [
          IconButton(
            tooltip: _isLocked ? 'Unlock Reading' : 'Freeze / Lock Angle',
            icon: Icon(
              _isLocked ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: _isLocked ? AppTheme.accentAmber : Colors.white,
            ),
            onPressed: () => setState(() => _isLocked = !_isLocked),
          ),
          IconButton(
            tooltip: 'Tare / Calibrate to 0°',
            icon: const Icon(Icons.exposure_zero_rounded),
            onPressed: _tare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Sensor status banner
              if (!_sensorAvailable)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade400),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.sensors_off_rounded,
                          color: Colors.orange, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Accelerometer not available on this device. Using manual drag mode.',
                          style:
                              TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),

              // Digital Readout
              Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSlate,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isLevel
                        ? AppTheme.statusGreen
                        : const Color(0xFF334155),
                    width: _isLevel ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAngleBlock('PITCH / SLOPE', _effectivePitch),
                    Container(
                        height: 50,
                        width: 1,
                        color: const Color(0xFF475569)),
                    _buildAngleBlock('ROLL / TILT', _effectiveRoll),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Level Status Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _isLevel
                      ? AppTheme.statusGreen.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isLevel
                        ? AppTheme.statusGreen
                        : Colors.white24,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isLevel
                          ? Icons.check_circle_rounded
                          : Icons.sync_problem_rounded,
                      size: 16,
                      color: _isLevel
                          ? AppTheme.statusGreen
                          : Colors.white54,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isLevel
                          ? 'PERFECT LEVEL (0.0°)'
                          : 'SURFACE INCLINED',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _isLevel
                            ? AppTheme.statusGreen
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 2D Bullseye Spirit Level — driven by real sensor
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0F172A),
                  border: Border.all(
                    color: AppTheme.accentCyan.withValues(alpha: 0.5),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _BullseyeLevelPainter(
                    pitch: _effectivePitch,
                    roll: _effectiveRoll,
                    isLevel: _isLevel,
                  ),
                ),
              ),

              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _sensorAvailable
                        ? Icons.sensors_rounded
                        : Icons.touch_app_rounded,
                    size: 14,
                    color: Colors.white38,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _sensorAvailable
                        ? 'Live accelerometer — tilt your device'
                        : 'Drag on bullseye to test (no sensor)',
                    style: const TextStyle(
                        fontSize: 11, color: Colors.white38),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _resetTare,
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Reset Zero'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _recordToProject,
                      icon:
                          const Icon(Icons.add_task_rounded, size: 18),
                      label: const Text('Attach to Project'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Quick angle presets
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPresetChip('0.0° Level', 0.0),
                  _buildPresetChip('22.5° Glazing Pitch', 22.5),
                  _buildPresetChip('45.0° Rafter', 45.0),
                  _buildPresetChip('90.0° Plumb Wall', 90.0),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAngleBlock(String label, double deg) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${deg >= 0 ? '+' : ''}${deg.toStringAsFixed(1)}°',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: deg.abs() < 0.8 ? AppTheme.statusGreen : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip(String label, double targetPitch) {
    return ActionChip(
      backgroundColor: AppTheme.surfaceSlate,
      label: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.accentCyan),
      ),
      onPressed: () {
        setState(() {
          _tarePitch = _rawPitch - targetPitch;
          _tareRoll = _rawRoll;
        });
      },
    );
  }
}

// ─── Bullseye Painter ──────────────────────────────────────────────────────
class _BullseyeLevelPainter extends CustomPainter {
  final double pitch;
  final double roll;
  final bool isLevel;

  _BullseyeLevelPainter({
    required this.pitch,
    required this.roll,
    required this.isLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer rings
    final ringPaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius * 0.75, ringPaint);
    canvas.drawCircle(center, radius * 0.50, ringPaint);
    canvas.drawCircle(center, radius * 0.25, ringPaint);

    // Target centre circle
    final targetPaint = Paint()
      ..color = isLevel
          ? AppTheme.statusGreen
          : AppTheme.accentCyan.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, 24, targetPaint);

    // Crosshairs
    final linePaint = Paint()
      ..color = const Color(0xFF475569)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(center.dx - radius + 10, center.dy),
      Offset(center.dx + radius - 10, center.dy),
      linePaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 10),
      Offset(center.dx, center.dy + radius - 10),
      linePaint,
    );

    // Bubble position — pitch→Y, roll→X
    final maxOffset = radius * 0.72;
    final bx = (center.dx + (roll / 45.0) * maxOffset)
        .clamp(center.dx - maxOffset, center.dx + maxOffset);
    final by = (center.dy + (pitch / 45.0) * maxOffset)
        .clamp(center.dy - maxOffset, center.dy + maxOffset);
    final bubblePos = Offset(bx, by);

    // Glow
    canvas.drawCircle(
      bubblePos,
      20,
      Paint()
        ..color = isLevel
            ? AppTheme.statusGreen.withValues(alpha: 0.35)
            : AppTheme.accentAmber.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Bubble body
    canvas.drawCircle(
      bubblePos,
      17,
      Paint()
        ..color = isLevel ? AppTheme.statusGreen : AppTheme.accentAmber
        ..style = PaintingStyle.fill,
    );

    // Glass highlight
    canvas.drawCircle(
      Offset(bubblePos.dx - 5, bubblePos.dy - 5),
      5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _BullseyeLevelPainter old) =>
      old.pitch != pitch || old.roll != roll || old.isLevel != isLevel;
}
