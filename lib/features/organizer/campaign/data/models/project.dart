// lib/features/organizer/campaign/data/models/project.dart

class Project {
  final String projectName;
  final String description;
  final String category;
  final List<String> platforms;  // 単数 → 複数
  final int targetViews;
  final int budget;
  final String endDate;
  final List<String> links;

  const Project({
    this.projectName = '',
    this.description = '',
    this.category = '',
    this.platforms = const [],  // リストに変更
    this.targetViews = 0,
    this.budget = 0,
    this.endDate = '',
    this.links = const [],
  });

  // 1000再生あたりの単価を計算
  double get pricePerThousand {
    if (targetViews == 0) return 0;
    return (budget / targetViews) * 1000;
  }

  Project copyWith({
    String? projectName,
    String? description,
    String? category,
    List<String>? platforms,
    int? targetViews,
    int? budget,
    String? endDate,
    List<String>? links,
  }) {
    return Project(
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      category: category ?? this.category,
      platforms: platforms ?? this.platforms,
      targetViews: targetViews ?? this.targetViews,
      budget: budget ?? this.budget,
      endDate: endDate ?? this.endDate,
      links: links ?? this.links,
    );
  }
}