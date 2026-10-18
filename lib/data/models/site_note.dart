import 'package:uuid/uuid.dart';

enum NoteCategory {
  general,
  hazard,
  installationInstruction,
  customerRequest,
  accessIssue,
}

extension NoteCategoryExtension on NoteCategory {
  String get displayName {
    switch (this) {
      case NoteCategory.general:
        return 'General Note';
      case NoteCategory.hazard:
        return 'Site Hazard / Safety';
      case NoteCategory.installationInstruction:
        return 'Installation Note';
      case NoteCategory.customerRequest:
        return 'Client Special Request';
      case NoteCategory.accessIssue:
        return 'Site Access Restriction';
    }
  }
}

class SiteNote {
  final String id;
  final String projectId;
  final String content;
  final NoteCategory category;
  final String author;
  final DateTime timestamp;
  final bool isPinned;

  SiteNote({
    String? id,
    required this.projectId,
    required this.content,
    this.category = NoteCategory.general,
    this.author = 'Pooja Basoula (Field Tech)',
    DateTime? timestamp,
    this.isPinned = false,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'projectId': projectId,
        'content': content,
        'category': category.name,
        'author': author,
        'timestamp': timestamp.toIso8601String(),
        'isPinned': isPinned,
      };

  factory SiteNote.fromJson(Map<String, dynamic> json) => SiteNote(
        id: json['id'] as String,
        projectId: json['projectId'] as String,
        content: json['content'] as String,
        category: NoteCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => NoteCategory.general,
        ),
        author: json['author'] as String? ?? 'Pooja Basoula (Field Tech)',
        timestamp: DateTime.parse(json['timestamp'] as String),
        isPinned: json['isPinned'] as bool? ?? false,
      );

  SiteNote copyWith({
    String? id,
    String? projectId,
    String? content,
    NoteCategory? category,
    String? author,
    DateTime? timestamp,
    bool? isPinned,
  }) =>
      SiteNote(
        id: id ?? this.id,
        projectId: projectId ?? this.projectId,
        content: content ?? this.content,
        category: category ?? this.category,
        author: author ?? this.author,
        timestamp: timestamp ?? this.timestamp,
        isPinned: isPinned ?? this.isPinned,
      );
}
