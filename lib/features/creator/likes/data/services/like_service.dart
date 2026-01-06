// lib/features/creator/likes/data/services/like_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';

class LikeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // いいね追加
  Future<void> likeCampaign(String campaignId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _supabase.from('likes').insert({
      'user_id': _userId,
      'campaign_id': campaignId,
    });
  }

  // いいね削除
  Future<void> unlikeCampaign(String campaignId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _supabase
        .from('likes')
        .delete()
        .eq('user_id', _userId!)
        .eq('campaign_id', campaignId);
  }

  // いいねした案件IDリストを取得
  Future<Set<String>> getLikedCampaignIds() async {
    if (_userId == null) return {};

    final response = await _supabase
        .from('likes')
        .select('campaign_id')
        .eq('user_id', _userId!);

    return (response as List)
        .map((row) => row['campaign_id'] as String)
        .toSet();
  }

  // いいねした案件を取得（Campaign情報付き）
  Future<List<Campaign>> getLikedCampaigns() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('likes')
        .select('''
          campaign_id,
          campaigns (*)
        ''')
        .eq('user_id', _userId!)
        .order('created_at', ascending: false);

    return (response as List)
        .where((row) => row['campaigns'] != null)
        .map((row) => Campaign.fromMap(row['campaigns']))
        .toList();
  }

  // カテゴリでフィルターしたいいね案件を取得
  Future<List<Campaign>> getLikedCampaignsByCategory(String category) async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('likes')
        .select('''
          campaign_id,
          campaigns!inner (*)
        ''')
        .eq('user_id', _userId!)
        .eq('campaigns.category', category)
        .order('created_at', ascending: false);

    return (response as List)
        .where((row) => row['campaigns'] != null)
        .map((row) => Campaign.fromMap(row['campaigns']))
        .toList();
  }
}