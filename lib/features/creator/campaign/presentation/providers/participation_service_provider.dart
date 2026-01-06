// lib/features/creator/campaign/presentation/providers/participation_service_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/participation_service.dart';

final participationServiceProvider = Provider<ParticipationService>((ref) {
  return ParticipationService();
});

// 参加中の案件IDキャッシュ
final participatingCampaignIdsProvider = StateProvider<Set<String>>((ref) => {});