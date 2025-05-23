enum SourceType { file, git, url }

class Source {
  final String id;
  final String name;
  final SourceType type;
  final DateTime addedAt;
  final String? location;
  final bool isIndexed;
  final String? lastError;
  final Map<String, dynamic> config;
  final String? status;
  final int? progress;

  Source({
    required this.id,
    required this.name,
    required this.type,
    required this.addedAt,
    this.location,
    this.isIndexed = false,
    this.lastError,
    this.config = const {},
    this.status,
    this.progress,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SourceType.values.firstWhere(
        (e) => e.toString() == 'SourceType.${json['type']}',
        orElse: () => SourceType.file,
      ),
      addedAt: DateTime.parse(json['added_at'] as String),
      location: json['location'] as String?,
      isIndexed: json['is_indexed'] as bool? ?? false,
      lastError: json['last_error'] as String?,
      config: (json['config'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'added_at': addedAt.toIso8601String(),
      'location': location,
      'is_indexed': isIndexed,
      'last_error': lastError,
      'config': config,
    };
  }

  Source copyWith({
    String? id,
    String? name,
    SourceType? type,
    DateTime? addedAt,
    String? location,
    bool? isIndexed,
    String? lastError,
    Map<String, dynamic>? config,
    String? status,
    int? progress,
  }) {
    return Source(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      addedAt: addedAt ?? this.addedAt,
      location: location ?? this.location,
      isIndexed: isIndexed ?? this.isIndexed,
      lastError: lastError ?? this.lastError,
      config: config ?? this.config,
      status: status ?? this.status,
      progress: progress ?? this.progress,
    );
  }
}
