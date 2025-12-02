import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/ticket_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_card.dart';

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
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                      color: AppTheme.textColor,
                    ),
                    const SizedBox(width: AppTheme.paddingSmall),
                  ],
                  const Expanded(
                    child: Text(
                      'チケット一覧',
                      style: TextStyle(
                        fontSize: AppTheme.textSizeLarge,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
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
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: AppTheme.paddingDefault),
                          Text(
                            'チケットがありません',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
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
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 13,
          color: isSelected ? Colors.white : AppTheme.textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}