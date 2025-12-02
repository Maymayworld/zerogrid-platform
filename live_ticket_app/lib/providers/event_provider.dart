import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/event.dart';

// イベントリストプロバイダー
final eventListProvider = StateNotifierProvider<EventListNotifier, List<Event>>((ref) {
  return EventListNotifier();
});

class EventListNotifier extends StateNotifier<List<Event>> {
  EventListNotifier() : super([]) {
    debugPrint('🎪 EventListNotifier初期化開始');
    _loadDemoEvents();
  }

  void _loadDemoEvents() {
    debugPrint('🎪 デモイベント読み込み開始');
    
    try {
      final events = [
        Event(
          id: 'EVENT-001',
          name: 'SUMMER SONIC 2025',
          date: DateTime(2025, 8, 16, 18, 0),
          venue: '幕張メッセ',
          totalTickets: 2000,
          soldTickets: 1250,
          status: '開催中',
          staffPasscode: '12345',
          security: SecuritySettings(
            ticketSignature: true,
            bleEncryption: true,
            publicKeyDistribution: false,
          ),
        ),
        Event(
          id: 'EVENT-002',
          name: 'FUJI ROCK FESTIVAL',
          date: DateTime(2025, 7, 25, 19, 30),
          venue: '苗場スキー場',
          totalTickets: 1500,
          soldTickets: 850,
          status: '開催予定',
          staffPasscode: '54321',
          security: SecuritySettings(
            ticketSignature: true,
            bleEncryption: false,
            publicKeyDistribution: false,
          ),
        ),
      ];
      
      state = events;
      debugPrint('🎪 イベント読み込み完了: ${events.length}件');
      for (var event in events) {
        debugPrint('  - ${event.name} (${event.status})');
      }
    } catch (e) {
      debugPrint('❌ イベント読み込みエラー: $e');
    }
  }

  // イベント追加
  void addEvent(Event event) {
    state = [...state, event];
    debugPrint('🎪 イベント追加: ${event.name}');
  }

  // イベント削除
  void removeEvent(String eventId) {
    state = state.where((event) => event.id != eventId).toList();
    debugPrint('🎪 イベント削除: $eventId');
  }

  // イベント更新
  void updateEvent(Event updatedEvent) {
    state = [
      for (final event in state)
        if (event.id == updatedEvent.id) updatedEvent else event,
    ];
    debugPrint('🎪 イベント更新: ${updatedEvent.name}');
  }

  // セキュリティ設定更新
  void updateSecurity(String eventId, SecuritySettings newSecurity) {
    state = [
      for (final event in state)
        if (event.id == eventId)
          event.copyWith(security: newSecurity)
        else
          event,
    ];
    debugPrint('🎪 セキュリティ設定更新: $eventId');
  }
}

// 統計情報プロバイダー
final eventStatsProvider = Provider<EventStats>((ref) {
  final events = ref.watch(eventListProvider);
  
  final totalEvents = events.length;
  final activeEvents = events.where((e) => e.status == '開催中').length;
  final totalTickets = events.fold<int>(0, (sum, event) => sum + event.soldTickets);
  
  return EventStats(
    totalEvents: totalEvents,
    activeEvents: activeEvents,
    totalTickets: totalTickets,
  );
});

class EventStats {
  final int totalEvents;
  final int activeEvents;
  final int totalTickets;

  EventStats({
    required this.totalEvents,
    required this.activeEvents,
    required this.totalTickets,
  });
}