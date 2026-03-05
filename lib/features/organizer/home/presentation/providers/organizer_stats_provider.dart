// lib/features/organizer/home/presentation/providers/organizer_stats_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/organizer_stats_service.dart';

export '../../data/services/organizer_stats_service.dart' show CampaignStats;

final organizerStatsServiceProvider = Provider<OrganizerStatsService>((ref) {
  return OrganizerStatsService();
});

/// 自分のキャンペーン一覧と統計
final myCampaignStatsProvider = FutureProvider.autoDispose<List<CampaignStats>>((ref) async {
  final service = ref.read(organizerStatsServiceProvider);
  return service.getMyCampaignStats();
});

/// 累計視聴回数
final totalViewsProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.read(organizerStatsServiceProvider);
  return service.getTotalViewsAcrossAllCampaigns();
});

/// アクティブなキャンペーン数
final activeCampaignCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = ref.read(organizerStatsServiceProvider);
  return service.getActiveCampaignCount();
});
