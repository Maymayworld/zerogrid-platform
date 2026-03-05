// lib/features/creator/feed/presentation/providers/creator_tab_index_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Creator メインレイアウトのボトムナビの選択インデックス
/// 0: Find, 1: Feed, 2: Dashboard, 3: Campaigns, 4: Profile
final creatorTabIndexProvider = StateProvider<int>((ref) => 0);
