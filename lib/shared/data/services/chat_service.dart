// lib/shared/data/services/chat_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chat_room.dart';
import '../models/chat_message.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  // ============================================
  // ルーム作成・取得
  // ============================================

  /// グループチャットルームを作成（campaignにつき1つ）
  Future<ChatRoom> getOrCreateGroupRoom(String campaignId) async {
    // 既存のグループルームを探す
    final existing = await _supabase
        .from('chat_rooms')
        .select()
        .eq('campaign_id', campaignId)
        .eq('type', 'group')
        .maybeSingle();

    if (existing != null) {
      return ChatRoom.fromMap(existing);
    }

    // なければ作成
    final response = await _supabase.from('chat_rooms').insert({
      'campaign_id': campaignId,
      'type': 'group',
      'creator_id': null,
    }).select().single();

    return ChatRoom.fromMap(response);
  }

  /// 1:1チャットルームを作成（campaign + creatorにつき1つ）
  Future<ChatRoom> getOrCreatePersonalRoom({
    required String campaignId,
    required String creatorId,
  }) async {
    // 既存のパーソナルルームを探す
    final existing = await _supabase
        .from('chat_rooms')
        .select()
        .eq('campaign_id', campaignId)
        .eq('type', 'personal')
        .eq('creator_id', creatorId)
        .maybeSingle();

    if (existing != null) {
      return ChatRoom.fromMap(existing);
    }

    // なければ作成
    final response = await _supabase.from('chat_rooms').insert({
      'campaign_id': campaignId,
      'type': 'personal',
      'creator_id': creatorId,
    }).select().single();

    return ChatRoom.fromMap(response);
  }

  // ============================================
  // メンバー管理
  // ============================================

  /// ルームにメンバーを追加
  Future<void> addMemberToRoom(String roomId, String userId) async {
    try {
      await _supabase.from('chat_room_members').insert({
        'room_id': roomId,
        'user_id': userId,
      });
    } catch (e) {
      // 既に参加済みの場合はエラーを無視
      if (!e.toString().contains('duplicate')) {
        rethrow;
      }
    }
  }

  /// ルームのメンバー一覧を取得
  Future<List<String>> getRoomMembers(String roomId) async {
    final response = await _supabase
        .from('chat_room_members')
        .select('user_id')
        .eq('room_id', roomId);

    return (response as List).map((row) => row['user_id'] as String).toList();
  }

  /// ルームのメンバー数を取得
  Future<int> getRoomMemberCount(String roomId) async {
    final response = await _supabase
        .from('chat_room_members')
        .select('id')
        .eq('room_id', roomId);

    return (response as List).length;
  }

  // ============================================
  // メッセージ送受信
  // ============================================

  /// メッセージを送信
  Future<ChatMessage> sendMessage({
    required String roomId,
    required String content,
  }) async {
    if (_userId == null) throw Exception('User not logged in');

    final response = await _supabase.from('chat_messages').insert({
      'room_id': roomId,
      'sender_id': _userId,
      'content': content,
    }).select().single();

    return ChatMessage.fromMap(response);
  }

  /// ルームのメッセージ一覧を取得
  Future<List<ChatMessage>> getMessages(String roomId, {int limit = 50}) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((row) => ChatMessage.fromMap(row))
        .toList()
        .reversed
        .toList(); // 古い順に並べ替え
  }

  /// メッセージをリアルタイム購読
  RealtimeChannel subscribeToMessages(
    String roomId,
    void Function(ChatMessage) onMessage,
  ) {
    return _supabase
        .channel('messages:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'chat_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (payload) {
            final message = ChatMessage.fromMap(payload.newRecord);
            onMessage(message);
          },
        )
        .subscribe();
  }

  /// 購読を解除
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _supabase.removeChannel(channel);
  }

  // ============================================
  // ルーム一覧取得
  // ============================================

  /// 自分が参加しているルーム一覧を取得
  Future<List<ChatRoom>> getMyRooms() async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('chat_room_members')
        .select('''
          room_id,
          chat_rooms (*)
        ''')
        .eq('user_id', _userId!);

    return (response as List)
        .where((row) => row['chat_rooms'] != null)
        .map((row) => ChatRoom.fromMap(row['chat_rooms']))
        .toList();
  }

  /// キャンペーンのグループルームを取得
  Future<ChatRoom?> getGroupRoom(String campaignId) async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('campaign_id', campaignId)
        .eq('type', 'group')
        .maybeSingle();

    if (response == null) return null;
    return ChatRoom.fromMap(response);
  }

  /// キャンペーンの1:1ルーム一覧を取得（Organizer用）
  Future<List<ChatRoom>> getPersonalRoomsForCampaign(String campaignId) async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('campaign_id', campaignId)
        .eq('type', 'personal')
        .order('created_at', ascending: false);

    return (response as List).map((row) => ChatRoom.fromMap(row)).toList();
  }

  /// 特定のクリエイターとの1:1ルームを取得
  Future<ChatRoom?> getPersonalRoom({
    required String campaignId,
    required String creatorId,
  }) async {
    final response = await _supabase
        .from('chat_rooms')
        .select()
        .eq('campaign_id', campaignId)
        .eq('type', 'personal')
        .eq('creator_id', creatorId)
        .maybeSingle();

    if (response == null) return null;
    return ChatRoom.fromMap(response);
  }

  /// 最新メッセージを取得（ルームごと）
  Future<ChatMessage?> getLatestMessage(String roomId) async {
    final response = await _supabase
        .from('chat_messages')
        .select()
        .eq('room_id', roomId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return ChatMessage.fromMap(response);
  }
}