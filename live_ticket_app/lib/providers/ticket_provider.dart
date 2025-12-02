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
        eventName: '春のロックフェス 2025',
        eventImage: 'https://source.unsplash.com/300x200/?rock,concert,music',
        eventDate: DateTime(2025, 3, 15, 18, 0),
        venue: '渋谷CLUB QUATTRO',
        seatType: 'スタンディング',
        ticketNumber: 'LIVE-2025-001',
      ),
      Ticket(
        id: 'TICKET-002',
        eventName: 'ジャズナイト Vol.12',
        eventImage: 'https://source.unsplash.com/300x200/?jazz,saxophone,music',
        eventDate: DateTime(2025, 4, 20, 19, 30),
        venue: '六本木ビルボードライブ東京',
        seatType: 'テーブル席 A-5',
        ticketNumber: 'JAZZ-2025-042',
      ),
      Ticket(
        id: 'TICKET-003',
        eventName: 'アコースティックライブ',
        eventImage: 'https://source.unsplash.com/300x200/?acoustic,guitar,live',
        eventDate: DateTime(2025, 5, 10, 17, 0),
        venue: '下北沢SHELTER',
        seatType: '指定席 B-12',
        ticketNumber: 'ACOUSTIC-2025-128',
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

// マイチケット（未使用チケット）プロバイダー
final myTicketsProvider = Provider<List<Ticket>>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  return allTickets.where((ticket) => !ticket.isUsed).toList();
});

// 全チケット数プロバイダー
final totalTicketsCountProvider = Provider<int>((ref) {
  final allTickets = ref.watch(ticketListProvider);
  return allTickets.length;
});