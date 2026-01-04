// lib/features/organizer/create/presentation/providers/project_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/models/project.dart';

final projectProvider = StateNotifierProvider<ProjectNotifier, Project>((ref) {
  return ProjectNotifier();
});

class ProjectNotifier extends StateNotifier<Project> {
  ProjectNotifier() : super(const Project());

  // Page1: 名前と説明
  void setBasicInfo(String name, String description) {
    state = state.copyWith(projectName: name, description: description);
  }

  // Page2: カテゴリとプラットフォーム（複数）
  void setCategoryAndPlatforms(String category, List<String> platforms) {
    state = state.copyWith(category: category, platforms: platforms);
  }

  // Page3: 目標再生数
  void setTargetViews(int views) {
    state = state.copyWith(targetViews: views);
  }

  // Page4: 予算
  void setBudget(int budget) {
    state = state.copyWith(budget: budget);
  }

  // Page5: 期限
  void setEndDate(String date) {
    state = state.copyWith(endDate: date);
  }

  // Page6: リンク
  void setLinks(List<String> links) {
    state = state.copyWith(links: links);
  }

  // リセット（投稿完了後など）
  void reset() {
    state = const Project();
  }
}