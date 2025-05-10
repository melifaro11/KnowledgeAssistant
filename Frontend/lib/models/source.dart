enum SourceType { file, git, url }

class Source {
  final String id;
  final String name;
  final SourceType type;
  final DateTime addedAt;
  final String? location;
  final bool isIndexed;
  final String? lastError;

  Source({
    required this.id,
    required this.name,
    required this.type,
    required this.addedAt,
    this.location,
    this.isIndexed = false,
    this.lastError,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'] as String,
      name: json['name'] as String,
      type: SourceType.values.firstWhere(
        (e) => e.toString() == 'SourceType.${json['type']}',
      ),
      addedAt: DateTime.parse(json['added_at']),
      location: json['location'] as String?,
      isIndexed: json['is_indexed'] as bool? ?? false,
      lastError: json['last_error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString().split('.').last,
      'added_at': addedAt.toIso8601String(),
      'location': location,
      'isIndexed': isIndexed,
    };
  }
}
