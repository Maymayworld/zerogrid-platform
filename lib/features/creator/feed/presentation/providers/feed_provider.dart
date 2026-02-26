// lib/features/creator/feed/presentation/providers/feed_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../data/services/feed_service.dart';

final feedServiceProvider = Provider<FeedService>((ref) {
  return FeedService();
});

/// フィードでいいね済みの提出IDセット
final feedLikedIdsProvider = StateProvider<Set<String>>((ref) => {});
