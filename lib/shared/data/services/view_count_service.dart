// lib/shared/data/services/view_count_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewCountService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 単一の提出物の視聴回数を取得・更新
  Future<int?> fetchViewCount({
    required String submissionId,
    required String videoUrl,
    required String platform,
    String? userId,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'fetch-view-counts',
        body: {
          'submission_id': submissionId,
          'video_url': videoUrl,
          'platform': platform,
          'user_id': userId,
        },
      );

      if (response.status == 200 && response.data != null) {
        return response.data['view_count'] as int?;
      }
      return null;
    } catch (e) {
      print('Error fetching view count: $e');
      return null;
    }
  }

  /// キャンペーンの合計視聴回数を取得
  Future<int> getCampaignTotalViews(String campaignId) async {
    try {
      final response = await _supabase
          .from('submission_requests')
          .select('view_count')
          .eq('campaign_id', campaignId)
          .eq('status', 'approved');

      final submissions = response as List;
      return submissions.fold<int>(
        0,
        (sum, s) => sum + ((s['view_count'] as num?)?.toInt() ?? 0),
      );
    } catch (e) {
      print('Error getting campaign total views: $e');
      return 0;
    }
  }

  /// キャンペーン内のクリエイター別視聴回数を取得
  Future<List<CreatorViewStats>> getCreatorViewStats(String campaignId) async {
    try {
      final response = await _supabase
          .from('submission_requests')
          .select('''
            creator_id,
            view_count,
            profiles:creator_id (display_name, avatar_url)
          ''')
          .eq('campaign_id', campaignId)
          .eq('status', 'approved');

      final submissions = response as List;
      
      // クリエイター別に集計
      final Map<String, CreatorViewStats> statsMap = {};
      
      for (final sub in submissions) {
        final creatorId = sub['creator_id'] as String;
        final viewCount = (sub['view_count'] as num?)?.toInt() ?? 0;
        final profile = sub['profiles'] as Map<String, dynamic>?;
        
        if (statsMap.containsKey(creatorId)) {
          statsMap[creatorId]!.addViews(viewCount);
        } else {
          statsMap[creatorId] = CreatorViewStats(
            creatorId: creatorId,
            displayName: profile?['display_name'] as String? ?? 'Unknown',
            avatarUrl: profile?['avatar_url'] as String?,
            totalViews: viewCount,
            submissionCount: 1,
          );
        }
      }
      
      // 視聴回数順にソート
      final statsList = statsMap.values.toList();
      statsList.sort((a, b) => b.totalViews.compareTo(a.totalViews));
      
      return statsList;
    } catch (e) {
      print('Error getting creator view stats: $e');
      return [];
    }
  }

  /// 自分の提出物の視聴回数一覧を取得
  Future<List<SubmissionViewStats>> getMySubmissionStats() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _supabase
          .from('submission_requests')
          .select('''
            id,
            video_url,
            platform,
            view_count,
            status,
            campaign_id,
            campaigns:campaign_id (name, budget, target_views, total_views)
          ''')
          .eq('creator_id', userId)
          .eq('status', 'approved')
          .order('view_count', ascending: false);

      return (response as List).map((data) {
        final campaign = data['campaigns'] as Map<String, dynamic>?;
        return SubmissionViewStats(
          submissionId: data['id'] as String,
          videoUrl: data['video_url'] as String,
          platform: data['platform'] as String,
          viewCount: (data['view_count'] as num?)?.toInt() ?? 0,
          campaignId: data['campaign_id'] as String,
          campaignName: campaign?['name'] as String? ?? '',
          campaignBudget: (campaign?['budget'] as num?)?.toInt() ?? 0,
          campaignTargetViews: (campaign?['target_views'] as num?)?.toInt() ?? 1,
          campaignTotalViews: (campaign?['total_views'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting my submission stats: $e');
      return [];
    }
  }
}

/// クリエイター別の視聴回数統計
class CreatorViewStats {
  final String creatorId;
  final String displayName;
  final String? avatarUrl;
  int totalViews;
  int submissionCount;

  CreatorViewStats({
    required this.creatorId,
    required this.displayName,
    this.avatarUrl,
    required this.totalViews,
    required this.submissionCount,
  });

  void addViews(int views) {
    totalViews += views;
    submissionCount++;
  }

  /// 報酬計算用のシェア率（%）
  double getSharePercentage(int campaignTotalViews) {
    if (campaignTotalViews == 0) return 0;
    return (totalViews / campaignTotalViews) * 100;
  }
}

/// 提出物別の視聴回数統計
class SubmissionViewStats {
  final String submissionId;
  final String videoUrl;
  final String platform;
  final int viewCount;
  final String campaignId;
  final String campaignName;
  final int campaignBudget;
  final int campaignTargetViews;
  final int campaignTotalViews;

  SubmissionViewStats({
    required this.submissionId,
    required this.videoUrl,
    required this.platform,
    required this.viewCount,
    required this.campaignId,
    required this.campaignName,
    required this.campaignBudget,
    required this.campaignTargetViews,
    required this.campaignTotalViews,
  });

  /// 現時点での推定収益（distribute-rewards と同じ計算式）
  int get estimatedEarnings {
    if (campaignTotalViews == 0 || viewCount == 0) return 0;

    const platformFeeRate = 0.10;
    final achievementRate =
        (campaignTotalViews / campaignTargetViews).clamp(0.0, 1.0);
    final distributableAmount = (campaignBudget * achievementRate).floor();
    final platformFee = (distributableAmount * platformFeeRate).floor();
    final creatorPool = distributableAmount - platformFee;

    final myShare = viewCount / campaignTotalViews;
    return (creatorPool * myShare).floor();
  }
}
