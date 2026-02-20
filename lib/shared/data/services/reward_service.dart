// lib/shared/data/services/reward_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 自分の残高を取得
  Future<int> getBalance() async {
    if (_userId == null) return 0;

    try {
      final response = await _supabase
          .from('profiles')
          .select('balance')
          .eq('id', _userId!)
          .single();

      return (response['balance'] as num?)?.toInt() ?? 0;
    } catch (e) {
      print('Error getting balance: $e');
      return 0;
    }
  }

  /// 収益履歴を取得
  Future<List<RewardTransaction>> getRewardHistory({int limit = 50}) async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('transactions')
          .select()
          .eq('user_id', _userId!)
          .inFilter('type', ['payout', 'withdrawal'])
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((t) => RewardTransaction.fromMap(t))
          .toList();
    } catch (e) {
      print('Error getting reward history: $e');
      return [];
    }
  }

  /// 総収益を取得
  Future<int> getTotalEarnings() async {
    if (_userId == null) return 0;

    try {
      final response = await _supabase
          .from('transactions')
          .select('amount')
          .eq('user_id', _userId!)
          .eq('type', 'payout');

      final transactions = response as List;
      return transactions.fold<int>(
        0,
        (sum, t) => sum + ((t['amount'] as num?)?.toInt() ?? 0),
      );
    } catch (e) {
      print('Error getting total earnings: $e');
      return 0;
    }
  }

  /// キャンペーン別の収益を取得
  Future<List<CampaignEarning>> getCampaignEarnings() async {
    if (_userId == null) return [];

    try {
      final response = await _supabase
          .from('transactions')
          .select('''
            amount,
            reference_id,
            created_at,
            campaigns:reference_id (name, thumbnail_url)
          ''')
          .eq('user_id', _userId!)
          .eq('type', 'payout')
          .order('created_at', ascending: false);

      return (response as List).map((t) {
        final campaign = t['campaigns'] as Map<String, dynamic>?;
        return CampaignEarning(
          campaignId: t['reference_id'] as String,
          campaignName: campaign?['name'] as String? ?? 'Unknown Campaign',
          thumbnailUrl: campaign?['thumbnail_url'] as String?,
          amount: (t['amount'] as num?)?.toInt() ?? 0,
          earnedAt: DateTime.parse(t['created_at'] as String),
        );
      }).toList();
    } catch (e) {
      print('Error getting campaign earnings: $e');
      return [];
    }
  }

  /// 推定収益を計算（まだ分配されていない分）
  Future<int> getEstimatedPendingEarnings() async {
    if (_userId == null) return 0;

    try {
      // アクティブなキャンペーンの自分の提出物を取得
      final response = await _supabase
          .from('submission_requests')
          .select('''
            view_count,
            campaigns:campaign_id (budget, target_views, status)
          ''')
          .eq('creator_id', _userId!)
          .eq('status', 'approved');

      int totalEstimated = 0;

      for (final sub in (response as List)) {
        final campaign = sub['campaigns'] as Map<String, dynamic>?;
        if (campaign == null || campaign['status'] != 'active') continue;

        final viewCount = (sub['view_count'] as num?)?.toInt() ?? 0;
        final budget = (campaign['budget'] as num?)?.toInt() ?? 0;
        final targetViews = (campaign['target_views'] as num?)?.toInt() ?? 1;

        // 1000再生あたりの単価 × 視聴回数
        final pricePerThousand = (budget / targetViews) * 1000;
        final estimated = (viewCount / 1000 * pricePerThousand).round();
        totalEstimated += estimated;
      }

      return totalEstimated;
    } catch (e) {
      print('Error getting estimated earnings: $e');
      return 0;
    }
  }
}

/// 報酬トランザクション
class RewardTransaction {
  final String id;
  final String type;
  final int amount;
  final String? description;
  final String? referenceId;
  final DateTime createdAt;

  RewardTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory RewardTransaction.fromMap(Map<String, dynamic> map) {
    return RewardTransaction(
      id: map['id'] as String,
      type: map['type'] as String,
      amount: (map['amount'] as num?)?.toInt() ?? 0,
      description: map['description'] as String?,
      referenceId: map['reference_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  String get formattedAmount {
    final sign = amount >= 0 ? '+' : '';
    return '$sign¥${amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }

  String get formattedDate {
    return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}';
  }
}

/// キャンペーン別収益
class CampaignEarning {
  final String campaignId;
  final String campaignName;
  final String? thumbnailUrl;
  final int amount;
  final DateTime earnedAt;

  CampaignEarning({
    required this.campaignId,
    required this.campaignName,
    this.thumbnailUrl,
    required this.amount,
    required this.earnedAt,
  });

  String get formattedAmount {
    return '¥${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}
