// lib/features/creator/campaign/data/services/participation_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../organizer/campaign/data/models/campaign.dart';
import '../../../../../shared/data/services/chat_service.dart';

class ParticipationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final ChatService _chatService = ChatService();

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 案件に参加（チャットルームも自動作成）
  Future<void> joinCampaign(String campaignId) async {
    if (_userId == null) throw Exception('User not logged in');

    // 1. participationsにレコード追加
    await _supabase.from('participations').insert({
      'user_id': _userId,
      'campaign_id': campaignId,
      'status': 'active',
    });

    // 2. 案件情報を取得してorganizer_idを得る
    final campaignResponse = await _supabase
        .from('campaigns')
        .select('organizer_id')
        .eq('id', campaignId)
        .single();
    final organizerId = campaignResponse['organizer_id'] as String;

    // 3. グループチャットルームを取得or作成
    final groupRoom = await _chatService.getOrCreateGroupRoom(campaignId);

    // 4. グループチャットにクリエイターを追加
    await _chatService.addMemberToRoom(groupRoom.id, _userId!);

    // 5. Organizerもグループチャットに追加（まだいなければ）
    await _chatService.addMemberToRoom(groupRoom.id, organizerId);

    // 6. 1:1チャットルームを作成
    final personalRoom = await _chatService.getOrCreatePersonalRoom(
      campaignId: campaignId,
      creatorId: _userId!,
    );

    // 7. 1:1チャットにクリエイターとOrganizerを追加
    await _chatService.addMemberToRoom(personalRoom.id, _userId!);
    await _chatService.addMemberToRoom(personalRoom.id, organizerId);
  }

  /// 参加をキャンセル
  Future<void> leaveCampaign(String campaignId) async {
    if (_userId == null) throw Exception('User not logged in');

    await _supabase
        .from('participations')
        .update({'status': 'cancelled'})
        .eq('user_id', _userId!)
        .eq('campaign_id', campaignId);

    // NOTE: チャットルームからは退出しない（履歴を残すため）
    // 必要に応じて退出処理を追加可能
  }

  /// 参加済みか確認
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

  /// 参加中の案件IDリストを取得
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

  /// 参加中の案件を取得（Campaign情報付き）
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

  /// 参加者数を取得
  Future<int> getParticipantCount(String campaignId) async {
    final response = await _supabase
        .from('participations')
        .select('id')
        .eq('campaign_id', campaignId)
        .eq('status', 'active');

    return (response as List).length;
  }
}