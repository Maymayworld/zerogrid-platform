import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/foundation.dart';
import '../models/ticket.dart';

// チケットリストプロバイダー
final ticketListProvider = StateNotifierProvider<TicketListNotifier, List<Ticket>>((ref) {
  return TicketListNotifier();
});

class TicketListNotifier extends StateNotifier<List<Ticket>> {
  TicketListNotifier() : super([]) {
    // 初期データ（デモ用）
    debugPrint('🎫 TicketListNotifier初期化開始');
    _loadDemoTickets();
  }

  void _loadDemoTickets() {
    debugPrint('🎫 デモチケット読み込み開始');
    
    try {
      final tickets = [
        Ticket(
          id: 'TICKET-001',
          eventName: 'SUMMER SONIC 2025',
          eventImage: '',
          eventDate: DateTime(2025, 8, 16, 18, 0),
          venue: '幕張メッセ',
          seatType: 'VIP',
          ticketNumber: 'VIP-A-12',
        ),
        Ticket(
          id: 'TICKET-002',
          eventName: 'FUJI ROCK FESTIVAL',
          eventImage: '',
          eventDate: DateTime(2025, 7, 25, 19, 30),
          venue: '苗場スキー場',
          seatType: '一般',
          ticketNumber: 'GEN-FREE',
        ),
        Ticket(
          id: 'TICKET-003',
          eventName: 'ROCK IN JAPAN 2025',
          eventImage: '',
          eventDate: DateTime(2025, 8, 9, 17, 0),
          venue: '国営ひたち海浜公園',
          seatType: 'VIP',
          ticketNumber: 'VIP-B-08',
        ),
      ];
      
      state = tickets;
      debugPrint('🎫 チケット読み込み完了: ${tickets.length}件');
      debugPrint('🎫 チケット詳細:');
      for (var ticket in tickets) {
        debugPrint('  - ${ticket.eventName} (${ticket.id})');
      }
    } catch (e) {
      debugPrint('❌ チケット読み込みエラー: $e');
    }
  }

  // チケット追加
  void addTicket(Ticket ticket) {
    state = [...state, ticket];
    debugPrint('🎫 チケット追加: ${ticket.eventName}');
  }

  // チケット削除
  void removeTicket(String ticketId) {
    state = state.where((ticket) => ticket.id != ticketId).toList();
    debugPrint('🎫 チケット削除: $ticketId');
  }

  // チケット更新
  void updateTicket(Ticket updatedTicket) {
    state = [
      for (final ticket in state)
        if (ticket.id == updatedTicket.id) updatedTicket else ticket,
    ];
    debugPrint('🎫 チケット更新: ${updatedTicket.eventName}');
  }

  // 使用済みにする
  void markAsUsed(String ticketId) {
    state = [
      for (final ticket in state)
        if (ticket.id == ticketId) 
          ticket.copyWith(isUsed: true) 
        else 
          ticket,
    ];
    debugPrint('🎫 チケット使用済み: $ticketId');
  }
}

// マイチケット（未使用チケット）プロバイダー
final myTicketsProvider = Provider<List<Ticket>>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  final myTickets = allTickets.where((ticket) => !ticket.isUsed).toList();
  debugPrint('🎫 myTicketsProvider: ${myTickets.length}件の未使用チケット');
  return myTickets;
});

// 全チケット数プロバイダー
final totalTicketsCountProvider = Provider<int>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  return allTickets.length;
});