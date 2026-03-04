// lib/features/organizer/home/presentation/providers/organizer_tab_index_provider.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Organizer メインレイアウトのボトムナビの選択インデックス
/// 0: Home, 1: Campaigns, 2: Create/Approval, 3: Chat, 4: Profile
final organizerTabIndexProvider = StateProvider<int>((ref) => 0);
