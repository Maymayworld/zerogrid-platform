import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../models/ticket.dart';

// チケットリストプロバイダー
final ticketListProvider = StateNotifierProvider<TicketListNotifier, List<Ticket>>((ref) {
  return TicketListNotifier();
});

class TicketListNotifier extends StateNotifier<List<Ticket>> {
  TicketListNotifier() : super([]) {
    // 初期データ（デモ用）
    _loadDemoTickets();
  }

  void _loadDemoTickets() {
    state = [
      Ticket(
        id: 'TICKET-001',
        eventName: 'SUMMER SONIC 2025',
        eventImage: 'https://source.unsplash.com/300x200/?summer,festival,music',
        eventDate: DateTime(2025, 8, 16, 18, 0),
        venue: '幕張メッセ',
        seatType: 'VIP',
        ticketNumber: 'A-12',
        isPurchased: true, // 購入済み
      ),
      Ticket(
        id: 'TICKET-002',
        eventName: 'FUJI ROCK FESTIVAL',
        eventImage: 'https://source.unsplash.com/300x200/?rock,festival,outdoor',
        eventDate: DateTime(2025, 7, 25, 19, 30),
        venue: '苗場スキー場',
        seatType: '一般',
        ticketNumber: 'FREE',
        isPurchased: false, // 未購入
      ),
      Ticket(
        id: 'TICKET-003',
        eventName: 'ROCK IN JAPAN 2025',
        eventImage: 'https://source.unsplash.com/300x200/?japan,rock,concert',
        eventDate: DateTime(2025, 8, 10, 17, 0),
        venue: '国営ひたち海浜公園',
        seatType: 'VIP',
        ticketNumber: 'B-08',
        isPurchased: false, // 未購入
      ),
    ];
  }

  // チケット追加
  void addTicket(Ticket ticket) {
    state = [...state, ticket];
  }

  // チケット削除
  void removeTicket(String ticketId) {
    state = state.where((ticket) => ticket.id != ticketId).toList();
  }

  // チケット更新
  void updateTicket(Ticket updatedTicket) {
    state = [
      for (final ticket in state)
        if (ticket.id == updatedTicket.id) updatedTicket else ticket,
    ];
  }

  // 購入済みにする
  void purchaseTicket(String ticketId) {
    state = [
      for (final ticket in state)
        if (ticket.id == ticketId) 
          ticket.copyWith(isPurchased: true) 
        else 
          ticket,
    ];
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
  }
}

// 購入済みチケット（マイチケット）プロバイダー
final myTicketsProvider = Provider<List<Ticket>>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  return allTickets.where((ticket) => ticket.isPurchased && !ticket.isUsed).toList();
});

// 未購入チケット（購入可能）プロバイダー
final availableTicketsProvider = Provider<List<Ticket>>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  return allTickets.where((ticket) => !ticket.isPurchased).toList();
});

// 全チケット数プロバイダー
final totalTicketsCountProvider = Provider<int>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  return allTickets.length;
});