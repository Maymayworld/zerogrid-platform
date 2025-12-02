import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
              child: Row(
                children: [
                  _buildFilterChip(
                    label: '全て',
                    count: allTickets.length,
                    isSelected: true,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  _buildFilterChip(
                    label: '未使用',
                    count: allTickets.where((t) => !t.isUsed).length,
                    isSelected: false,
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  _buildFilterChip(
                    label: '使用済み',
                    count: allTickets.where((t) => t.isUsed).length,
                    isSelected: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingDefault),

            // チケットリスト
            Expanded(
              child: allTickets.isEmpty
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
                      itemCount: allTickets.length,
                      itemBuilder: (context, index) {
                        final ticket = allTickets[index];
                        return TicketCard(
                          ticket: ticket,
                          onShowQrCode: () {
                            context.push('/qr-code/${ticket.id}');
                          },
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
  }) {
    return Container(
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
    );
  }
}