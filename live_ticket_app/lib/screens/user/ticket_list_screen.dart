import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import '../../providers/ticket_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/ticket_card.dart';

class TicketListScreen extends HookConsumerWidget {
  final bool isFromBottomNav;

  const TicketListScreen({
    super.key,
    this.isFromBottomNav = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTickets = ref.watch(ticketListProvider);
    final purchasedTickets = allTickets.where((t) => t.isPurchased).toList();
    final availableTickets = allTickets.where((t) => !t.isPurchased).toList();
    
    // フィルター状態（0: 全て, 1: 購入済み, 2: 未購入）
    final filterIndex = useState(0);
    
    // 表示するチケットリスト
    final displayTickets = filterIndex.value == 0
        ? allTickets
        : filterIndex.value == 1
            ? purchasedTickets
            : availableTickets;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingDefault),
              child: Row(
                children: [
                  // ボトムナビゲーションから来た場合は戻るボタンを非表示
                  if (!isFromBottomNav) ...[
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                  ],
                  const Expanded(
                    child: Text(
                      'チケット一覧',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // フィルターチップ（使用済み/未使用）
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.paddingDefault,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: '全て',
                      count: allTickets.length,
                      isSelected: filterIndex.value == 0,
                      onTap: () => filterIndex.value = 0,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    _buildFilterChip(
                      label: '購入済み',
                      count: purchasedTickets.length,
                      isSelected: filterIndex.value == 1,
                      onTap: () => filterIndex.value = 1,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                    _buildFilterChip(
                      label: '未購入',
                      count: availableTickets.length,
                      isSelected: filterIndex.value == 2,
                      onTap: () => filterIndex.value = 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingDefault),

            // チケットリスト
            Expanded(
              child: displayTickets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_number_outlined,
                            size: 80,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: AppTheme.paddingDefault),
                          Text(
                            'チケットがありません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingDefault,
                      ),
                      itemCount: displayTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = displayTickets[index];
                        return Column(
                          children: [
                            TicketCard(
                              ticket: ticket,
                              onShowQrCode: ticket.isPurchased
                                  ? () {
                                      context.push('/user/qr-code/${ticket.id}');
                                    }
                                  : null,
                            ),
                            // 未購入チケットの場合は購入ボタンを表示
                            if (!ticket.isPurchased)
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppTheme.paddingDefault,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      ref.read(ticketListProvider.notifier).purchaseTicket(ticket.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${ticket.eventName} を購入しました'),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.accentCyan,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      '購入',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentCyan : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? AppTheme.darkBackground : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}