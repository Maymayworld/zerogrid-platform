// lib/features/organizer/create/data/models/campaign.dart
import 'dart:convert';

class Campaign {
  final String id;
  final String organizerId;
  final String name;
  final String description;
  final String? thumbnailUrl;
  final int budget;
  final int targetViews;
  final String category;
  final List<String> platforms;
  final DateTime deadline;
  final List<String> resources;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Campaign({
    required this.id,
    required this.organizerId,
    required this.name,
    required this.description,
    this.thumbnailUrl,
    required this.budget,
    required this.targetViews,
    required this.category,
    required this.platforms,
    required this.deadline,
    required this.resources,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // 1000再生あたりの単価
  double get pricePerThousand {
    if (targetViews == 0) return 0;
    return (budget / targetViews) * 1000;
  }

  // DBから変換
  factory Campaign.fromMap(Map<String, dynamic> map) {
    // platformはJSON文字列で保存されてる
    List<String> platforms = [];
    if (map['platform'] != null) {
      try {
        platforms = List<String>.from(jsonDecode(map['platform']));
      } catch (e) {
        // JSON変換に失敗したら単一の値として扱う
        platforms = [map['platform'] as String];
      }
    }

    // resourcesはjsonb
    List<String> resources = [];
    if (map['resources'] != null) {
      resources = List<String>.from(map['resources']);
    }

    return Campaign(
      id: map['id'] as String,
      organizerId: map['organizer_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      thumbnailUrl: map['thumbnail_url'] as String?,
      budget: (map['budget'] as num).toInt(),
      targetViews: map['target_views'] as int,
      category: map['category'] as String,
      platforms: platforms,
      deadline: DateTime.parse(map['deadline'] as String),
      resources: resources,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  // 更新用にMapに変換
  Map<String, dynamic> toUpdateMap() {
    return {
      'name': name,
      'description': description,
      'thumbnail_url': thumbnailUrl,
      'budget': budget,
      'target_views': targetViews,
      'category': category,
      'platform': jsonEncode(platforms),
      'deadline': deadline.toIso8601String(),
      'resources': resources,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}