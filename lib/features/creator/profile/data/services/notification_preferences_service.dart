// lib/features/creator/profile/data/services/notification_preferences_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationPreferences {
  final bool allNotifications;
  final bool chat;
  final bool earnings;
  final bool news;

  const NotificationPreferences({
    this.allNotifications = true,
    this.chat = true,
    this.earnings = true,
    this.news = true,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      allNotifications: map['all_notifications'] as bool? ?? true,
      chat: map['chat'] as bool? ?? true,
      earnings: map['earnings'] as bool? ?? true,
      news: map['news'] as bool? ?? true,
    );
  }
}

class NotificationPreferencesService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String? get _userId => _supabase.auth.currentUser?.id;

  Future<NotificationPreferences> getPreferences() async {
    if (_userId == null) return const NotificationPreferences();

    final response = await _supabase
        .from('notification_preferences')
        .select()
        .eq('user_id', _userId!)
        .maybeSingle();

    if (response == null) return const NotificationPreferences();
    return NotificationPreferences.fromMap(response);
  }

  Future<void> updatePreference(String key, bool value) async {
    if (_userId == null) return;

    await _supabase.from('notification_preferences').upsert({
      'user_id': _userId!,
      key: value,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
