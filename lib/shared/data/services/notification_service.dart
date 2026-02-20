// lib/shared/data/services/notification_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_notification.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// 自分の通知一覧を取得
  Future<List<AppNotification>> getNotifications({int limit = 50}) async {
    if (_userId == null) return [];

    final response = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((json) => AppNotification.fromJson(json))
        .toList();
  }

  /// 未読数を取得
  Future<int> getUnreadCount() async {
    if (_userId == null) return 0;

    final response = await _supabase
        .from('notifications')
        .select('id')
        .eq('user_id', _userId!)
        .eq('is_read', false);

    return (response as List).length;
  }

  /// 個別既読
  Future<void> markAsRead(String notificationId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  /// 全既読
  Future<void> markAllAsRead() async {
    if (_userId == null) return;

    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _userId!)
        .eq('is_read', false);
  }

  /// 通知作成（他ユーザー宛に送る）
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data ?? {},
    });
  }

  /// Supabase Realtimeで通知を購読
  Stream<List<AppNotification>> watchNotifications() {
    if (_userId == null) return Stream.value([]);

    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId!)
        .order('created_at', ascending: false)
        .map((data) =>
            data.map((json) => AppNotification.fromJson(json)).toList());
  }
}
