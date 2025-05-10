import 'package:flutter/widgets.dart';

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

  Collection copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    List<Source>? sources,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      sources: sources ?? this.sources,
    );
  }

  factory Collection.fromJson(Map<String, dynamic> json) {
    debugPrint(json['id']);
    debugPrint(json['name']);
    debugPrint(json['created_at']);
    return Collection(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at']),
      sources:
          (json['sources'] as List<dynamic>? ?? [])
              .map(
                (sourceJson) =>
                    Source.fromJson(sourceJson as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'sources': sources.map((s) => s.toJson()).toList(),
    };
  }
}
