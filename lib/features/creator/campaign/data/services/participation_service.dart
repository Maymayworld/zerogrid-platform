// lib/features/creator/campaign/data/services/participation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';

class ParticipationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // 案件に参加
  Future<void> joinCampaign(String campaignId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _supabase.from('participations').insert({
      'user_id': _userId,
      'campaign_id': campaignId,
      'status': 'active',
    });
  }

  // 参加をキャンセル
  Future<void> leaveCampaign(String campaignId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _supabase
        .from('participations')
        .update({'status': 'cancelled'})
        .eq('user_id', _userId!)
        .eq('campaign_id', campaignId);
  }

  // 参加済みか確認
  Future<bool> isParticipating(String campaignId) async {
    if (_userId == null) return false;

    final response = await _supabase
        .from('participations')
        .select('id')
        .eq('user_id', _userId!)
        .eq('campaign_id', campaignId)
        .eq('status', 'active')
        .maybeSingle();

    return response != null;
  }

  // 参加中の案件IDリストを取得
  Future<Set<String>> getParticipatingCampaignIds() async {
    if (_userId == null) return {};

    final response = await _supabase
        .from('participations')
        .select('campaign_id')
        .eq('user_id', _userId!)
        .eq('status', 'active');

    return (response as List)
        .map((row) => row['campaign_id'] as String)
        .toSet();
  }

  // 参加中の案件を取得（Campaign情報付き）
  Future<List<Campaign>> getParticipatingCampaigns() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('participations')
        .select('''
          campaign_id,
          campaigns (*)
        ''')
        .eq('user_id', _userId!)
        .eq('status', 'active')
        .order('joined_at', ascending: false);

    return (response as List)
        .where((row) => row['campaigns'] != null)
        .map((row) => Campaign.fromMap(row['campaigns']))
        .toList();
  }

  // 参加者数を取得
  Future<int> getParticipantCount(String campaignId) async {
    final response = await _supabase
        .from('participations')
        .select('id')
        .eq('campaign_id', campaignId)
        .eq('status', 'active');

    return (response as List).length;
  }
}