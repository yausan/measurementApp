import 'package:uuid/uuid.dart';
import 'measurement_item.dart';
import 'site_photo.dart';
import 'site_note.dart';

enum ProjectStatus {
  draft,
  inProgress,
  pendingSync,
  synced,
  completed,
}

enum SyncStatus {
  synced,
  pendingSync,
  offlineOnly,
  syncing,
  error,
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.draft:
        return 'Draft';
      case ProjectStatus.inProgress:
        return 'In Progress';
      case ProjectStatus.pendingSync:
        return 'Pending Sync';
      case ProjectStatus.synced:
        return 'Synced to Office';
      case ProjectStatus.completed:
        return 'Completed';
    }
  }
}

extension SyncStatusExtension on SyncStatus {
  String get displayName {
    switch (this) {
      case SyncStatus.synced:
        return 'Synced';
      case SyncStatus.pendingSync:
        return 'Pending Sync';
      case SyncStatus.offlineOnly:
        return 'Offline (Local)';
      case SyncStatus.syncing:
        return 'Syncing...';
      case SyncStatus.error:
        return 'Sync Error';
    }
  }
}

class ProjectModel {
  final String id;
  final String projectNumber;
  final String title;
  final String clientName;
  final String clientCompany;
  final String clientPhone;
  final String clientEmail;
  final String siteAddress;
  final String technicianName;
  final String deviceId;
  final DateTime scheduledDate;
  final ProjectStatus status;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final List<MeasurementItem> measurements;
  final List<SitePhoto> photos;
  final List<SiteNote> notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProjectModel({
    String? id,
    required this.projectNumber,
    required this.title,
    required this.clientName,
    this.clientCompany = '',
    required this.clientPhone,
    required this.clientEmail,
    required this.siteAddress,
    this.technicianName = 'Pooja Basoula (Field Tech)',
    this.deviceId = '',
    DateTime? scheduledDate,
    this.status = ProjectStatus.inProgress,
    this.syncStatus = SyncStatus.pendingSync,
    this.lastSyncedAt,
    List<MeasurementItem>? measurements,
    List<SitePhoto>? photos,
    List<SiteNote>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        scheduledDate = scheduledDate ?? DateTime.now(),
        measurements = measurements ?? [],
        photos = photos ?? [],
        notes = notes ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  int get totalMeasurements => measurements.length;
  int get totalPhotos => photos.length;
  int get totalNotes => notes.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectNumber': projectNumber,
        'title': title,
        'clientName': clientName,
        'clientCompany': clientCompany,
        'clientPhone': clientPhone,
        'clientEmail': clientEmail,
        'siteAddress': siteAddress,
        'technicianName': technicianName,
        'deviceId': deviceId,
        'scheduledDate': scheduledDate.toIso8601String(),
        'status': status.name,
        'syncStatus': syncStatus.name,
        'lastSyncedAt': lastSyncedAt?.toIso8601String(),
        'measurements': measurements.map((m) => m.toJson()).toList(),
        'photos': photos.map((p) => p.toJson()).toList(),
        'notes': notes.map((n) => n.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ProjectModel.fromJson(Map<String, dynamic> json) => ProjectModel(
        id: json['id'] as String,
        projectNumber: json['projectNumber'] as String,
        title: json['title'] as String,
        clientName: json['clientName'] as String,
        clientCompany: json['clientCompany'] as String? ?? '',
        clientPhone: json['clientPhone'] as String,
        clientEmail: json['clientEmail'] as String,
        siteAddress: json['siteAddress'] as String,
        technicianName: json['technicianName'] as String? ?? 'Pooja Basoula (Field Tech)',
        deviceId: json['deviceId'] as String? ?? '',
        scheduledDate: DateTime.parse(json['scheduledDate'] as String),
        status: ProjectStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ProjectStatus.inProgress,
        ),
        syncStatus: SyncStatus.values.firstWhere(
          (e) => e.name == json['syncStatus'],
          orElse: () => SyncStatus.pendingSync,
        ),
        lastSyncedAt: json['lastSyncedAt'] != null
            ? DateTime.parse(json['lastSyncedAt'] as String)
            : null,
        measurements: (json['measurements'] as List<dynamic>?)
                ?.map((e) => MeasurementItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        photos: (json['photos'] as List<dynamic>?)
                ?.map((e) => SitePhoto.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        notes: (json['notes'] as List<dynamic>?)
                ?.map((e) => SiteNote.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  ProjectModel copyWith({
    String? id,
    String? projectNumber,
    String? title,
    String? clientName,
    String? clientCompany,
    String? clientPhone,
    String? clientEmail,
    String? siteAddress,
    String? technicianName,
    String? deviceId,
    DateTime? scheduledDate,
    ProjectStatus? status,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    List<MeasurementItem>? measurements,
    List<SitePhoto>? photos,
    List<SiteNote>? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      ProjectModel(
        id: id ?? this.id,
        projectNumber: projectNumber ?? this.projectNumber,
        title: title ?? this.title,
        clientName: clientName ?? this.clientName,
        clientCompany: clientCompany ?? this.clientCompany,
        clientPhone: clientPhone ?? this.clientPhone,
        clientEmail: clientEmail ?? this.clientEmail,
        siteAddress: siteAddress ?? this.siteAddress,
        technicianName: technicianName ?? this.technicianName,
        deviceId: deviceId ?? this.deviceId,
        scheduledDate: scheduledDate ?? this.scheduledDate,
        status: status ?? this.status,
        syncStatus: syncStatus ?? this.syncStatus,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        measurements: measurements ?? this.measurements,
        photos: photos ?? this.photos,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}
