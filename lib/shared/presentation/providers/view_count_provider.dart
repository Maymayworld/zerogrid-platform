// lib/shared/presentation/providers/view_count_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/view_count_service.dart';

final viewCountServiceProvider = Provider<ViewCountService>((ref) {
  return ViewCountService();
});

/// キャンペーンの合計視聴回数
final campaignTotalViewsProvider = FutureProvider.family<int, String>((ref, campaignId) async {
  final service = ref.read(viewCountServiceProvider);
  return service.getCampaignTotalViews(campaignId);
});

/// キャンペーン内のクリエイター別統計
final creatorViewStatsProvider = FutureProvider.family<List<CreatorViewStats>, String>((ref, campaignId) async {
  final service = ref.read(viewCountServiceProvider);
  return service.getCreatorViewStats(campaignId);
});

/// 自分の提出物統計
final mySubmissionStatsProvider = FutureProvider<List<SubmissionViewStats>>((ref) async {
  final service = ref.read(viewCountServiceProvider);
  return service.getMySubmissionStats();
});
