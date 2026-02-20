// lib/features/organizer/home/data/services/organizer_stats_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../../shared/data/services/view_count_service.dart';

class OrganizerStatsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 自分のキャンペーン一覧と統計を取得
  Future<List<CampaignStats>> getMyCampaignStats() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('campaigns')
          .select('''
            id,
            name,
            thumbnail_url,
            budget,
            target_views,
            total_views,
            status,
            deadline
          ''')
          .eq('organizer_id', _userId!)
          .order('created_at', ascending: false);

      return (response as List).map((c) => CampaignStats.fromMap(c)).toList();
    } catch (e) {
      print('Error getting campaign stats: $e');
      return [];
    }
  }

  /// 累計視聴回数を取得
  Future<int> getTotalViewsAcrossAllCampaigns() async {
    if (_userId == null) return 0;

    try {
      final response = await _supabase
          .from('campaigns')
          .select('total_views')
          .eq('organizer_id', _userId!);

      final campaigns = response as List;
      return campaigns.fold<int>(
        0,
        (sum, c) => sum + ((c['total_views'] as num?)?.toInt() ?? 0),
      );
    } catch (e) {
      print('Error getting total views: $e');
      return 0;
    }
  }

  /// アクティブなキャンペーン数を取得
  Future<int> getActiveCampaignCount() async {
    if (_userId == null) return 0;

    try {
      final response = await _supabase
          .from('campaigns')
          .select('id')
          .eq('organizer_id', _userId!)
          .eq('status', 'active');

      return (response as List).length;
    } catch (e) {
      print('Error getting active campaign count: $e');
      return 0;
    }
  }

  /// 累計消費予算を取得
  Future<int> getTotalSpentBudget() async {
    if (_userId == null) return 0;

    try {
      final response = await _supabase
          .from('transactions')
          .select('amount')
          .eq('user_id', _userId!)
          .eq('type', 'campaign_charge');

      final transactions = response as List;
      return transactions.fold<int>(
        0,
        (sum, t) => sum + ((t['amount'] as num?)?.toInt().abs() ?? 0),
      );
    } catch (e) {
      print('Error getting total spent: $e');
      return 0;
    }
  }
}

/// キャンペーンの統計情報
class CampaignStats {
  final String id;
  final String name;
  final String? thumbnailUrl;
  final int budget;
  final int targetViews;
  final int totalViews;
  final String status;
  final DateTime deadline;

  CampaignStats({
    required this.id,
    required this.name,
    this.thumbnailUrl,
    required this.budget,
    required this.targetViews,
    required this.totalViews,
    required this.status,
    required this.deadline,
  });

  factory CampaignStats.fromMap(Map<String, dynamic> map) {
    return CampaignStats(
      id: map['id'] as String,
      name: map['name'] as String,
      thumbnailUrl: map['thumbnail_url'] as String?,
      budget: (map['budget'] as num?)?.toInt() ?? 0,
      targetViews: (map['target_views'] as num?)?.toInt() ?? 1,
      totalViews: (map['total_views'] as num?)?.toInt() ?? 0,
      status: map['status'] as String? ?? 'active',
      deadline: DateTime.parse(map['deadline'] as String),
    );
  }

  /// 進捗率（%）
  double get progressPercentage {
    if (targetViews == 0) return 0;
    return (totalViews / targetViews * 100).clamp(0, 100);
  }

  /// 残り日数
  int get daysLeft {
    return deadline.difference(DateTime.now()).inDays;
  }

  /// フォーマット済み予算
  String get formattedBudget {
    if (budget >= 1000000) {
      return '¥${(budget / 1000000).toStringAsFixed(1)}M';
    } else if (budget >= 1000) {
      return '¥${(budget / 1000).toStringAsFixed(0)}K';
    }
    return '¥$budget';
  }

  /// フォーマット済み視聴回数
  String get formattedViews {
    if (totalViews >= 1000000) {
      return '${(totalViews / 1000000).toStringAsFixed(1)}M';
    } else if (totalViews >= 1000) {
      return '${(totalViews / 1000).toStringAsFixed(1)}K';
    }
    return totalViews.toString();
  }
}
