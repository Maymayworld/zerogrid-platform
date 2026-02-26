// lib/features/organizer/home/data/services/organizer_stats_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

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

  /// 累計視聴回数を取得（video_analytics経由）
  Future<int> getTotalViewsAcrossAllCampaigns() async {
    if (_userId == null) return 0;

    try {
      // campaigns → posts → video_analytics の経路で集計
      final response = await _supabase
          .from('video_analytics')
          .select('views, posts!inner(campaign_id, campaigns!inner(organizer_id))')
          .eq('posts.campaigns.organizer_id', _userId!);

      final rows = response as List;
      return rows.fold<int>(
        0,
        (sum, r) => sum + ((r['views'] as num?)?.toInt() ?? 0),
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

  /// キャンペーン詳細を取得
  Future<CampaignStats?> getCampaignDetails(String campaignId) async {
    try {
      final response = await _supabase
          .from('campaigns')
          .select('id, name, thumbnail_url, budget, target_views, total_views, status, deadline')
          .eq('id', campaignId)
          .maybeSingle();

      if (response == null) return null;
      return CampaignStats.fromMap(response);
    } catch (e) {
      return null;
    }
  }

  /// キャンペーンの提出物一覧（プラットフォームフィルタ付き）
  Future<List<SubmissionAnalytics>> getCampaignSubmissions({
    required String campaignId,
    String? platform,
  }) async {
    try {
      var query = _supabase
          .from('submission_requests')
          .select('id, creator_id, platform, view_count, video_title, video_url, submitted_at')
          .eq('campaign_id', campaignId)
          .eq('status', 'approved');

      if (platform != null && platform != 'All') {
        query = query.eq('platform', platform.toLowerCase());
      }

      final response = await query.order('view_count', ascending: false);

      return (response as List)
          .map((r) => SubmissionAnalytics.fromMap(r))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// キャンペーンのユーザーランキング
  Future<List<UserRanking>> getCampaignUserRanking({
    required String campaignId,
    String? platform,
  }) async {
    try {
      // 提出物を取得
      var query = _supabase
          .from('submission_requests')
          .select('creator_id, platform, view_count')
          .eq('campaign_id', campaignId)
          .eq('status', 'approved');

      if (platform != null && platform != 'All') {
        query = query.eq('platform', platform.toLowerCase());
      }

      final submissions = await query;

      // クリエイター別に集計
      final creatorMap = <String, int>{};
      final creatorSubmissionCount = <String, int>{};
      for (final sub in (submissions as List)) {
        final cid = sub['creator_id'] as String;
        final views = (sub['view_count'] as num?)?.toInt() ?? 0;
        creatorMap[cid] = (creatorMap[cid] ?? 0) + views;
        creatorSubmissionCount[cid] = (creatorSubmissionCount[cid] ?? 0) + 1;
      }

      if (creatorMap.isEmpty) return [];

      // クリエイターのプロフィールを取得
      final creatorIds = creatorMap.keys.toList();
      final profiles = await _supabase
          .from('profiles')
          .select('id, display_name, avatar_url')
          .inFilter('id', creatorIds);

      final profileMap = <String, Map<String, dynamic>>{};
      for (final p in (profiles as List)) {
        profileMap[p['id'] as String] = p;
      }

      // ランキング作成
      final rankings = creatorMap.entries.map((e) {
        final profile = profileMap[e.key];
        return UserRanking(
          creatorId: e.key,
          displayName: profile?['display_name'] as String? ?? 'Unknown',
          avatarUrl: profile?['avatar_url'] as String?,
          totalViews: e.value,
          submissionCount: creatorSubmissionCount[e.key] ?? 0,
        );
      }).toList();

      rankings.sort((a, b) => b.totalViews.compareTo(a.totalViews));
      return rankings;
    } catch (e) {
      return [];
    }
  }

  /// キャンペーンのプラットフォーム別視聴回数
  Future<Map<String, int>> getCampaignViewsByPlatform(String campaignId) async {
    try {
      final response = await _supabase
          .from('submission_requests')
          .select('platform, view_count')
          .eq('campaign_id', campaignId)
          .eq('status', 'approved');

      final result = <String, int>{};
      for (final sub in (response as List)) {
        final platform = sub['platform'] as String? ?? 'other';
        final views = (sub['view_count'] as num?)?.toInt() ?? 0;
        result[platform] = (result[platform] ?? 0) + views;
      }
      return result;
    } catch (e) {
      return {};
    }
  }
}

/// 提出物分析データ
class SubmissionAnalytics {
  final String id;
  final String creatorId;
  final String platform;
  final int viewCount;
  final String? videoTitle;
  final String? videoUrl;
  final DateTime submittedAt;

  SubmissionAnalytics({
    required this.id,
    required this.creatorId,
    required this.platform,
    required this.viewCount,
    this.videoTitle,
    this.videoUrl,
    required this.submittedAt,
  });

  factory SubmissionAnalytics.fromMap(Map<String, dynamic> map) {
    return SubmissionAnalytics(
      id: map['id'] as String,
      creatorId: map['creator_id'] as String,
      platform: map['platform'] as String? ?? 'other',
      viewCount: (map['view_count'] as num?)?.toInt() ?? 0,
      videoTitle: map['video_title'] as String?,
      videoUrl: map['video_url'] as String?,
      submittedAt: DateTime.parse(map['submitted_at'] as String),
    );
  }
}

/// ユーザーランキング
class UserRanking {
  final String creatorId;
  final String displayName;
  final String? avatarUrl;
  final int totalViews;
  final int submissionCount;

  UserRanking({
    required this.creatorId,
    required this.displayName,
    this.avatarUrl,
    required this.totalViews,
    required this.submissionCount,
  });

  String get formattedViews {
    if (totalViews >= 1000000) {
      return '${(totalViews / 1000000).toStringAsFixed(1)}M';
    } else if (totalViews >= 1000) {
      return '${totalViews.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
    return totalViews.toString();
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
