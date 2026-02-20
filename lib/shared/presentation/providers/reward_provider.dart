// lib/shared/presentation/providers/reward_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/reward_service.dart';

final rewardServiceProvider = Provider<RewardService>((ref) {
  return RewardService();
});

/// クリエイターの残高
final creatorBalanceProvider = FutureProvider<int>((ref) async {
  final service = ref.read(rewardServiceProvider);
  return service.getBalance();
});

/// 総収益
final totalEarningsProvider = FutureProvider<int>((ref) async {
  final service = ref.read(rewardServiceProvider);
  return service.getTotalEarnings();
});

/// 報酬履歴
final rewardHistoryProvider = FutureProvider<List<RewardTransaction>>((ref) async {
  final service = ref.read(rewardServiceProvider);
  return service.getRewardHistory();
});

/// キャンペーン別収益
final campaignEarningsProvider = FutureProvider<List<CampaignEarning>>((ref) async {
  final service = ref.read(rewardServiceProvider);
  return service.getCampaignEarnings();
});

/// 推定保留収益
final estimatedPendingProvider = FutureProvider<int>((ref) async {
  final service = ref.read(rewardServiceProvider);
  return service.getEstimatedPendingEarnings();
});
