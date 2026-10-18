import 'package:uuid/uuid.dart';

enum MeasurementType {
  length,
  width,
  height,
  depth,
  perimeter,
  area,
  angle,
  custom,
}

enum MeasurementUnit {
  mm,
  cm,
  m,
  inch,
  feet,
  deg,
}

extension MeasurementTypeExtension on MeasurementType {
  String get displayName {
    switch (this) {
      case MeasurementType.length:
        return 'Length';
      case MeasurementType.width:
        return 'Width';
      case MeasurementType.height:
        return 'Height';
      case MeasurementType.depth:
        return 'Depth';
      case MeasurementType.perimeter:
        return 'Perimeter';
      case MeasurementType.area:
        return 'Surface Area';
      case MeasurementType.angle:
        return 'Angle / Pitch';
      case MeasurementType.custom:
        return 'Custom Dimension';
    }
  }
}

extension MeasurementUnitExtension on MeasurementUnit {
  String get symbol {
    switch (this) {
      case MeasurementUnit.mm:
        return 'mm';
      case MeasurementUnit.cm:
        return 'cm';
      case MeasurementUnit.m:
        return 'm';
      case MeasurementUnit.inch:
        return 'in';
      case MeasurementUnit.feet:
        return 'ft';
      case MeasurementUnit.deg:
        return '°';
    }
  }

  String get displayName {
    switch (this) {
      case MeasurementUnit.mm:
        return 'Millimeters (mm)';
      case MeasurementUnit.cm:
        return 'Centimeters (cm)';
      case MeasurementUnit.m:
        return 'Meters (m)';
      case MeasurementUnit.inch:
        return 'Inches (in)';
      case MeasurementUnit.feet:
        return 'Feet (ft)';
      case MeasurementUnit.deg:
        return 'Degrees (°)';
    }
  }
}

class MeasurementItem {
  final String id;
  final String projectId;
  final String label;
  final MeasurementType type;
  final double value;
  final MeasurementUnit unit;
  final String locationTag;
  final String notes;
  final DateTime timestamp;
  final bool isVerified;

  MeasurementItem({
    String? id,
    required this.projectId,
    required this.label,
    required this.type,
    required this.value,
    required this.unit,
    this.locationTag = 'General Site',
    this.notes = '',
    DateTime? timestamp,
    this.isVerified = true,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  String get formattedValue => '${value.toStringAsFixed(value % 1 == 0 ? 0 : 2)} ${unit.symbol}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'label': label,
        'type': type.name,
        'value': value,
        'unit': unit.name,
        'locationTag': locationTag,
        'notes': notes,
        'timestamp': timestamp.toIso8601String(),
        'isVerified': isVerified,
      };

  factory MeasurementItem.fromJson(Map<String, dynamic> json) => MeasurementItem(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        label: json['label'] as String,
        type: MeasurementType.values.firstWhere(
          (e) => e.name == json['type'],
          orElse: () => MeasurementType.length,
        ),
        value: (json['value'] as num).toDouble(),
        unit: MeasurementUnit.values.firstWhere(
          (e) => e.name == json['unit'],
          orElse: () => MeasurementUnit.mm,
        ),
        locationTag: json['locationTag'] as String? ?? 'General Site',
        notes: json['notes'] as String? ?? '',
        timestamp: DateTime.parse(json['timestamp'] as String),
        isVerified: json['isVerified'] as bool? ?? true,
      );

  MeasurementItem copyWith({
    String? id,
    String? projectId,
    String? label,
    MeasurementType? type,
    double? value,
    MeasurementUnit? unit,
    String? locationTag,
    String? notes,
    DateTime? timestamp,
    bool? isVerified,
  }) =>
      MeasurementItem(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        label: label ?? this.label,
        type: type ?? this.type,
        value: value ?? this.value,
        unit: unit ?? this.unit,
        locationTag: locationTag ?? this.locationTag,
        notes: notes ?? this.notes,
        timestamp: timestamp ?? this.timestamp,
        isVerified: isVerified ?? this.isVerified,
      );
}
