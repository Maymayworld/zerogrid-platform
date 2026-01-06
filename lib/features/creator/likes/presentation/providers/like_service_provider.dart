// lib/features/creator/likes/presentation/providers/like_service_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/like_service.dart';

final likeServiceProvider = Provider<LikeService>((ref) {
  return LikeService();
});

// いいね済みIDのキャッシュ（パフォーマンス向上）
final likedCampaignIdsProvider = StateProvider<Set<String>>((ref) => {});