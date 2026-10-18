import 'package:uuid/uuid.dart';

class SitePhoto {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final String imagePath; // Local path or demo asset placeholder or data uri
  final String tag;
  final DateTime timestamp;

  SitePhoto({
    String? id,
    required this.projectId,
    required this.title,
    this.description = '',
    required this.imagePath,
    this.tag = 'General',
    DateTime? timestamp,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'title': title,
        'description': description,
        'imagePath': imagePath,
        'tag': tag,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SitePhoto.fromJson(Map<String, dynamic> json) => SitePhoto(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        title: json['title'] as String,
        description: json['description'] as String? ?? '',
        imagePath: json['imagePath'] as String,
        tag: json['tag'] as String? ?? 'General',
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  SitePhoto copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    String? imagePath,
    String? tag,
    DateTime? timestamp,
  }) =>
      SitePhoto(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        title: title ?? this.title,
        description: description ?? this.description,
        imagePath: imagePath ?? this.imagePath,
        tag: tag ?? this.tag,
        timestamp: timestamp ?? this.timestamp,
      );
}
