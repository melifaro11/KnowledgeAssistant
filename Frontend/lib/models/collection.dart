import 'source.dart';

class Collection {
  final String id;
  final String name;
  final DateTime createdAt;
  final List<Source> sources;

  Collection({
    required this.id,
    required this.name,
    required this.createdAt,
    this.sources = const [],
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      sources: (json['sources'] as List<dynamic>? ?? [])
          .map((sourceJson) => Source.fromJson(sourceJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'sources': sources.map((s) => s.toJson()).toList(),
    };
  }
}
